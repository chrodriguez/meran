package C4::AR::Nivel2;

use strict;
require Exporter;
use C4::Context;
use C4::Modelo::CatRegistroMarcN2;
use C4::Modelo::CatRegistroMarcN2::Manager;
use C4::Modelo::CatRating::Manager;
use C4::Modelo::CatRating;
use HTML::Entities;
use C4::AR::Sphinx qw(generar_indice);

use POSIX qw(NULL ceil);


use vars qw(@EXPORT_OK @ISA);

@ISA    = qw(Exporter);

@EXPORT_OK = qw(
		getNivel1FromId2
		getCantPrestados
        getNivel2FromId1
        getFirstItemTypeFromN1
        
);

=head1 NAME

C4::AR::Nivel1 - Funciones que manipulan datos del catálogo de nivel 1

=head1 SYNOPSIS

  use C4::AR::Nivel1;

=head1 DESCRIPTION

  Descripción del modulo COMPLETAR

=head1 FUNCTIONS

=over 2

=cut

=head2
 sub t_guardarNivel2

    Esta funcion se invoca desde el template para guardar los datos de nivel2, se apoya en una funcion de Catalogacion.pm que lo que hace es transformar los datos que llegan en un objeto MARC::Record que luego va a insertarse en la base de datos a traves de un objeto CatRegistroMarcN2
=cut
sub t_guardarNivel2 {
    my ($params) = @_;

    my $msg_object = C4::AR::Mensajes::create();
    my $id2;
    if(!$msg_object->{'error'}){
    #No hay error
        my $marc_record     = C4::AR::Catalogacion::meran_nivel2_to_meran($params);
        ($msg_object,$id2)  = guardarRealmente($msg_object,$params->{'id1'},$marc_record);
    }
    return ($msg_object, $params->{'id1'}, $id2);
}



=head2
sub guardarRealmente

Esta funcion realmente guarda el elemento en la base
=cut
sub guardarRealmente{
    my ($msg_object,$id1,$marc_record)=@_;
    my $id2;
    my $catRegistroMarcN2;
    if(!$msg_object->{'error'}){
        $catRegistroMarcN2 = C4::Modelo::CatRegistroMarcN2->new();  
        my $db = $catRegistroMarcN2->db;
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
        $db->begin_work;
    
        eval {
            $catRegistroMarcN2->agregar($id1,$marc_record->as_usmarc);
            $db->commit;
            #recupero el id1 recien agregado
            $id2 = $catRegistroMarcN2->getId2;
            C4::AR::Sphinx::generar_indice($catRegistroMarcN2->getId1, 'R_PARTIAL', 'INSERT');
            #ahora el indice se encuentra DESACTUALIZADO
            C4::AR::Preferencias::setVariable('indexado', 0, $db);

            #se cambio el permiso con exito
            $msg_object->{'error'} = 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U369', 'params' => [$id2]} ) ;
        };

#         C4::AR::Sphinx::reindexar();

    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B428',"INTRA");
            eval {$db->rollback};
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U372', 'params' => []} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object, $id2);
}

=head2 sub t_eliminarNivel2
    Elimina el nivel 2 pasado por parametro
=cut
sub t_eliminarNivel2{
    my($id2) = @_;
   
    my $msg_object = C4::AR::Mensajes::create();

    my $params;    
    my $cat_registro_marc_n2 = C4::Modelo::CatRegistroMarcN2->new();
    my $db = $cat_registro_marc_n2->db;
    my ($cat_registro_marc_n2) = getNivel2FromId2($id2, $db);
   
    if(!$cat_registro_marc_n2){
        #NO EXISTE EL OBJETO
        #Se setea error para el usuario
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U404', 'params' => []} ) ;
    }else{
        #EXISTE EL OBJETO
         $params->{'id2'} = $id2;
        #verifico condiciones necesarias antes de eliminar     
        _verificarDeleteNivel2($msg_object, $params, $cat_registro_marc_n2);
    }

    if(!$msg_object->{'error'}){
        #No hay error        
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
        $db->begin_work;
    
        eval {
            $cat_registro_marc_n2->eliminar($params);  
            $db->commit;
            C4::AR::Sphinx::generar_indice($cat_registro_marc_n2->getId1(), 'R_PARTIAL', 'UPDATE');
            #ahora el indice se encuentra DESACTUALIZADO
            C4::AR::Preferencias::setVariable('indexado', 0, $db);
            #se cambio el permiso con exito
            $msg_object->{'error'} = 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U375', 'params' => [$id2]} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B429',"INTRA");
            $db->rollback;
            #Se setea error para el usuario
            $msg_object->{'error'} = 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U378', 'params' => [$id2]} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object);
}

=head2
sub getNivel2FromId1

    Recupero TODOS los catRegistroMarcN2 que existen relacionados a un CatRegistroMarcN1 a traves del id1
=cut
sub getNivel2FromId1{
    my ($id1, $db) = @_;
    
    $db = $db || C4::Modelo::CatRegistroMarcN2->new()->db();

    my $nivel2_array_ref = C4::Modelo::CatRegistroMarcN2::Manager->get_cat_registro_marc_n2(
                                                                        db => $db,
                                                                        query => [
                                                                                        id1 => { eq => $id1 },
                                                                                ]
                                                                );
    return $nivel2_array_ref;
}

sub getFirstItemTypeFromN1{
    my ($id1) = @_;
    
    my $nivel2 = getNivel2FromId1($id1);
    
    if (scalar(@$nivel2)){
    	return ($nivel2->[0]->getTipoDocumento);
    }
    
    return ('DEFAULT');
        
}

=head2 sub getNivel2FromId2
    Recupero un nivel 2 a partir de un id2
    retorna un objeto o 0 si no existe
=cut
sub getNivel2FromId2{
    my ($id2, $db) = @_;

    my $nivel2_array_ref = C4::Modelo::CatRegistroMarcN2::Manager->get_cat_registro_marc_n2(
                                                                        db => $db, 
                                                                        query => [ 
                                                                                    id => { eq => $id2 },
                                                                            ],
                                                                        require_objects => ['nivel1'],
#                                                                         select          => ['cat_registro_marc_n1.*']
                                                                        select          => ['*']    
                                                                );

    if (scalar(@$nivel2_array_ref) > 0){
        return ($nivel2_array_ref->[0]);
    }else{
        return (0);
    }
}

sub getTipoEjemplarFromId2{
    my ($id2) = @_;

    my ($cat_registro_marc_n2) = getNivel2FromId2($id2);

    if($cat_registro_marc_n2){
        return $cat_registro_marc_n2->getTipoDocumento;
    }
}

sub _verificarDeleteNivel2 {
    my($msg_object, $params, $cat_registro_marc_n2)=@_;

    $msg_object->{'error'} = 0;#no hay error

    if( !($msg_object->{'error'}) && $cat_registro_marc_n2->tienePrestamos() ){
        C4::AR::Debug::debug("_verificarDeleteNivel2 => tiene al menos 1 ejemplar prestado ");
        #verifico que el nivel2 que quiero eliminar no tenga ningun ejemplar prestado
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P124', 'params' => [$params->{'id2'}]} ) ;

    }elsif( !($msg_object->{'error'}) && $cat_registro_marc_n2->tieneReservas() ){
        #verifico que el nivel2 que quiero eliminar no tenga ningun ejemplar reservado
        $msg_object->{'error'} = 1;
        C4::AR::Debug::debug("_verificarDeleteNivel2 => Se está intentando eliminar un ejemplar que tiene al menos un ejemplar reservado ");
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P123', 'params' => [$params->{'id2'}]} ) ;
    }

}


=head2 sub getCantPrestados
    retorna la canitdad de items prestados para el grupo pasado por parametro
=cut
sub getCantPrestados{
    my ($id2) = @_;
# FIXME falta arreglar las ref
    my $cantPrestamos_count = C4::Modelo::CircPrestamo::Manager->get_circ_prestamo_count(
                                                                query => [  't2.id2' => { eq => $id2 },
                                                                            fecha_devolucion => { eq => undef }  
                                                                         ],
                                                                require_objects     => ['nivel3.nivel2'],
                                                                with_objects        => ['nivel3'],
                                        );

    #C4::AR::Debug::debug("C4::AR::Nivel2::getCantPrestados ".$cantPrestamos_count);

    return $cantPrestamos_count;
}


=item
  sub getNivel2FromTipoDocumento

  devuelve un arreglo de niveles 2 filtrados por tipo de documento
=cut
sub getNivel2FromTipoDocumento {
    my ($tipo_doc) = @_;
    

# TODO Miguel ver si esto es eficiente, de todos modos no se si se puede hacer de otra manera!!!!!!!!!!
# 1) parece q no queda otra, hay q "abrir" el marc_record y sacar el barcode para todos los ejemplares e ir comparando cada uno GARRONNNN!!!!
# 2) se podria usar el indice??????????????

    my @filtros;
    my $cat_registro_marc_n2_array_ref;
    my @cat_registro_marc_n2_array_ref_result;

    
    my $cat_registro_marc_n2_array_ref = C4::Modelo::CatRegistroMarcN2::Manager->get_cat_registro_marc_n2( query => \@filtros ); 

    my $cant = scalar(@$cat_registro_marc_n2_array_ref);

    for(my $i=0; $i < $cant; $i++){

        if($cat_registro_marc_n2_array_ref->[$i]->getTipoDocumentoObject() eq $tipo_doc){
            push(@cat_registro_marc_n2_array_ref_result, $cat_registro_marc_n2_array_ref->[$i]);
            last();
        }
    }

    if(scalar(@cat_registro_marc_n2_array_ref_result) > 0){
        return (\@cat_registro_marc_n2_array_ref_result);
    }else{
        return (0);
    }
}

=head2
    sub getISBNById1
    Retorna (SI EXISTE) el ISBN segun el Id1 pasado por parametro
=cut
sub getISBNById1{
    my ($id1) = @_;

    my @filtros;
    my @cat_registro_marc_n2_array_result;
    push(@filtros, ( id1    => { eq => $id1}));

    my $cat_registro_marc_n2_array_ref = C4::Modelo::CatRegistroMarcN2::Manager->get_cat_registro_marc_n2( query => \@filtros );

    if(scalar(@$cat_registro_marc_n2_array_ref) > 0){
        return ($cat_registro_marc_n2_array_ref->[0]->getISBN());
    }else{
        return (0);
    }
}

=head2
    sub getISBNById1
    Retorna (SI EXISTE) el ISBN segun el Id1 pasado por parametro
=cut
sub getISBNById2{
    my ($id2) = @_;

    my @filtros;
    my @cat_registro_marc_n2_array_result;
    push(@filtros, ( id    => { eq => $id2}));

    my $cat_registro_marc_n2_array_ref = C4::Modelo::CatRegistroMarcN2::Manager->get_cat_registro_marc_n2( query => \@filtros );

    if(scalar(@$cat_registro_marc_n2_array_ref) > 0){
        return ($cat_registro_marc_n2_array_ref->[0]->getISBN());
    }else{
        return (0);
    }
}
#***********************************************ACA FINALIZA LA NUEVA ESTRUCTURA***************************************************************




=item sub t_modificarNivel2
    transaccion mofica el nivel 2 pasado por parametro
=cut
sub t_modificarNivel2 {
    my($params) = @_;

## FIXME ver si falta verificar algo!!!!!!!!!!
    my $msg_object                          = C4::AR::Mensajes::create();
    my $cat_registro_marc_n2                = C4::Modelo::CatRegistroMarcN2->new();
    my $db                                  = $cat_registro_marc_n2->db;
    my ($cat_registro_marc_n2)              = getNivel2FromId2($params->{'id2'}, $db);

    if(!$cat_registro_marc_n2){
        #Se setea error para el usuario
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U403', 'params' => []} ) ;
    }

    if(!$msg_object->{'error'}){
    #No hay error
		
		$params->{'modificado'} = 1;
#         my $db = $cat_registro_marc_n2->db;
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
         $db->begin_work;
    
        eval {
            my $marc_record = C4::AR::Catalogacion::meran_nivel2_to_meran($params);
            $cat_registro_marc_n2->modificar($marc_record->as_usmarc);  
            $db->commit;
            C4::AR::Sphinx::generar_indice($cat_registro_marc_n2->getId1, 'R_PARTIAL', 'UPDATE');
            #ahora el indice se encuentra DESACTUALIZADO
            C4::AR::Preferencias::setVariable('indexado', 0, $db);

            #se cambio el permiso con exito
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U381', 'params' => [$cat_registro_marc_n2->getId2]} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B431',"INTRA");
            $db->rollback;
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U384', 'params' => [$cat_registro_marc_n2->getId2]} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object, $cat_registro_marc_n2);
}

sub getRating{
    my($id2) = @_;

    my @filtros;

    push (@filtros, (id2 => {eq => $id2}));
    my $rating = C4::Modelo::CatRating::Manager->get_cat_rating(query => \@filtros,);
    my $rating_count = C4::Modelo::CatRating::Manager->get_cat_rating_count(query => \@filtros,);
    my $count = 0;

    foreach my $rate (@$rating){
        $count+= $rate->getRate();
    }

    if($rating_count > 0){
        $rating_count = POSIX::ceil($count/$rating_count);
    } 
    
    return $rating_count;
}

sub getRatingPromedio{
    my($nivel2_array_ref) = @_;

    my $cant = scalar(@$nivel2_array_ref);
    if ($cant > 0){
        my $ratings = 0;
        foreach my $nivel2 (@$nivel2_array_ref){
            $ratings+= getRating($nivel2->getId2);
        }
        my $rating_count = POSIX::ceil($ratings/$cant);
        return $rating_count;
    }else{
        return (0);
    }
}

sub rate{
    my($rate,$id2,$nro_socio) = @_;

    my $rating_obj = C4::Modelo::CatRating->new();
    

    $rating_obj = $rating_obj->getObjeto($nro_socio, $id2);
    $rating_obj->setRate($rate);
    $rating_obj->save();

}


sub getCantReviews{
    my($id2) = @_;

    my @filtros;

    push (@filtros, (id2 => {eq => $id2}));
    push (@filtros, (review => {ne => NULL}));
    my $reviews = C4::Modelo::CatRating::Manager->get_cat_rating_count(query => \@filtros,);

    return $reviews;
}

sub getReviews{
    my($id2) = @_;
    my @filtros;

    push (@filtros, (id2 => {eq => $id2}));
    push (@filtros, (review => {ne => NULL}));
    my $reviews = C4::Modelo::CatRating::Manager->get_cat_rating(query => \@filtros,
                                                                 include_objects => ['socio'],
                                                                 );
    if (scalar(@$reviews) > 0){
        return $reviews
    }else{
        return 0;
    }

}

sub reviewNivel2{
    my ($id2,$review,$nro_socio) = @_;
    my $rating_obj = C4::Modelo::CatRating->new();

    $rating_obj = $rating_obj->getObjeto($nro_socio, $id2);
    
    $review = encode_entities($review);
    
    $rating_obj->setReview($review);
    $rating_obj->save();
}

END { }       # module clean-up code here (global destructor)

1;
__END__
