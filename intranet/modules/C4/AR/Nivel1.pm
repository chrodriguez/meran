package C4::AR::Nivel1;

use strict;
require Exporter;
use C4::Context;
use C4::Modelo::CatRegistroMarcN1;
use C4::Modelo::CatRegistroMarcN1::Manager;
use C4::Modelo::CatFavoritosOpac::Manager;
use C4::Modelo::CatFavoritosOpac;
use C4::AR::Sphinx qw(generar_indice);


use vars qw(@EXPORT_OK @ISA);

@ISA=qw(Exporter);

@EXPORT_OK = qw(
                  &getAutoresAdicionales
                  &getColaboradores
                  &getUnititle
                  &getNivel1FromId1
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

=item sub verificar_Alta_Nivel1

campos clave => 
  
      titulo => 245, a
      autor => 100, a
      edicion => 250, a
=cut

sub verificar_Alta_Nivel1 {
    my ($marc_record, $msg_object) = @_;
    # FIXME la edicion no la puedo validar con los datos de N1

    my $ref_autor   = $marc_record->subfield("100","a");
    my $titulo      = $marc_record->subfield("245","a");

    my ($cant_titulo, $id1_array_ref) = C4::AR::Busquedas::busquedaPorTitulo($titulo);
#     C4::AR::Debug::debug("C4::AR::verificar_Alta_Nivel1 => cantidad titulos => ".$cant_titulo);

    my $id_autor        = C4::AR::Catalogacion::getRefFromStringConArrobas($ref_autor);
    my $autor           = C4::Modelo::CatAutor->getByPk($id_autor);
    my $nombre_completo = $autor->getCompleto();

    my ($cant_autor, $id1_array_ref)    = C4::AR::Busquedas::busquedaPorAutor($nombre_completo);
#     C4::AR::Debug::debug("C4::AR::verificar_Alta_Nivel1 => autor 100, a => ".$nombre_completo);
#     C4::AR::Debug::debug("C4::AR::verificar_Alta_Nivel1 => cantidad autores 100, a => ".$cant_autor);

    if (($cant_titulo > 0)&&($cant_autor > 0)){
        $msg_object->{'error'} = 1;
  
        my %params_hash;
        %params_hash    = ('id1' => $id1_array_ref->[0]->{'id1'});
        my $url         = C4::AR::Utilidades::url_for("/catalogacion/estructura/detalle.pl", \%params_hash);
        my $link        = C4::AR::Filtros::link_to( text    => $id1_array_ref->[0]->{'id1'},
                                                    url     => $url 
                                              );

        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U501', 'params' => [$titulo." - ".$nombre_completo, $link]} ) ;
    }
}

=head2
sub t_guardarNivel1

    Esta funcion se invoca desde el template para guardar los datos de nivel1, se apoya en una funcion de Catalogacion.pm que lo que hace es transformar los datos que llegan a un objeto MARC::Record que luego va a insertarse en la base de datos a traves de un objeto CatRegistroMarcN1, ese dato estara filtrado de acuerdo a los datos que corresponden al nivel, solo conteniendo datos que 
=cut
sub t_guardarNivel1 {
    my($params) = @_;
    my $msg_object = C4::AR::Mensajes::create();
    my $id1;

    my $marc_record     = C4::AR::Catalogacion::meran_nivel1_to_meran($params);
    
    verificar_Alta_Nivel1($marc_record, $msg_object);

    if(!$msg_object->{'error'}){
        ($msg_object, $id1) = guardarRealmente($msg_object,$marc_record,$params);
    }

    return ($msg_object, $id1);
}

=head2
sub guardarRealmente

Esta funcion realmente guarda el elemento en la base
=cut
sub guardarRealmente{
    my ($msg_object,$marc_record,$params) = @_;

    my $id1;
    if(!$msg_object->{'error'}){
        my $catRegistroMarcN1 = C4::Modelo::CatRegistroMarcN1->new();  
        my $db = $catRegistroMarcN1->db;
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
        $db->begin_work;
        
        eval {
            $catRegistroMarcN1->agregar($marc_record->as_usmarc,$params);
            $db->commit;            
            #recupero el id1 recien agregado
            $id1 = $catRegistroMarcN1->getId1;
            C4::AR::Sphinx::generar_indice($id1, 'R_PARTIAL', 'INSERT');
            #ahora el indice se encuentra DESACTUALIZADO
            C4::AR::Preferencias::setVariable('indexado', 0, $db);
            #se cambio el permiso con exito
            $msg_object->{'error'} = 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U368', 'params' => [$id1]} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B427',"INTRA");
            $db->rollback;
            #Se setea error para el usuario
            $msg_object->{'error'} = 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U371', 'params' => []} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object, $id1);
}


=head2 
sub getNivel1FromId1

Recupero un nivel 1 a partir de un id1
retorna un objeto o 0 si no existe
=cut
sub getNivel1FromId1{
    my ($id1, $db) = @_;

    $db = $db || C4::Modelo::CatRegistroMarcN3->new()->db();
    
    my $nivel1_array_ref = C4::Modelo::CatRegistroMarcN1::Manager->get_cat_registro_marc_n1(
                                                                        db => $db,    
                                                                        query => [ 
                                                                                    id => { eq => $id1 },
                                                                            ]
                                                                );

    if( scalar(@$nivel1_array_ref) > 0){
        return ($nivel1_array_ref->[0]);
    }else{
        return 0;
    }
}

=head2 
sub getNivel1Completo

Se recupera TODOS los nivel 1
=cut
# FIXME getAllNivel1
sub getNivel1Completo {
    my ($db) = @_;

    $db = $db || C4::Modelo::CatRegistroMarcN3->new()->db();
    
    my $nivel1_array_ref = C4::Modelo::CatRegistroMarcN1::Manager->get_cat_registro_marc_n1(
                                                                        db => $db,    
#                                                                         query => [ 
#                                                                                     id => { eq => $id1 },
#                                                                             ]
                                                                );

    return ($nivel1_array_ref);
}

sub getNivel1FromId3{
    my ($id3) = @_;
    my $nivel3 = C4::AR::Nivel3::getNivel3FromId3($id3);

    if ($nivel3){
      return ($nivel3->nivel2->nivel1);
    }else{
        return(0);
    }
}

sub getNivel1FromId1OPAC{
    my ($id1, $db) = @_;

    $db = $db || C4::Modelo::CatRegistroMarcN3->new()->db();

    my $nivel1 = getNivel1FromId1($id1, $db);
    
    
    
}


#***********************************************ACA FINALIZA LA NUEVA ESTRUCTURA***************************************************************


sub getAutoresAdicionales(){
	my ($id)=@_;

# 	falta implementar, seria un campo de nivel 1 repetibles
}


sub getColaboradores(){
	my ($id)=@_;

# 	falta implementar, seria un campo de nivel 1 repetibles
}

=item sub getUnititle

	$titulo_unico=getUnititle($id_nivel1);
	Esta funcion retorna el untitle segun un id1
=cut
# TODO DEPRECATED
sub getUnititle {
	my($id1)= @_;
	return C4::AR::Busquedas::buscarDatoDeCampoRepetible($id1,"245","b","1");
}



=item sub t_modificarNivel1
    Modifica el nivel 1 pasado por parametro
=cut
sub t_modificarNivel1 {
    my($params) = @_;
 
    my $msg_object= C4::AR::Mensajes::create();
    my $id1 = 0;

    my ($cat_registro_marc_n1) = getNivel1FromId1($params->{'id1'});

    if(!$cat_registro_marc_n1){
        #Se setea error para el usuario
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U404', 'params' => []} ) ;
    }

    if(!$msg_object->{'error'}){
    #No hay error

        my $db = $cat_registro_marc_n1->db;
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
         $db->begin_work;
    
        eval {
            my $marc_record = C4::AR::Catalogacion::meran_nivel1_to_meran($params);

            $cat_registro_marc_n1->modificar($marc_record->as_usmarc, $params);
            $db->commit;
            C4::AR::Sphinx::generar_indice($cat_registro_marc_n1->getId1(), 'R_PARTIAL', 'UPDATE');
            #ahora el indice se encuentra DESACTUALIZADO
            C4::AR::Preferencias::setVariable('indexado', 0, $db);

            #se cambio el permiso con exito
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U380', 'params' => [$cat_registro_marc_n1->getId1]} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B430',"INTRA");
            $db->rollback;
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U383', 'params' => [$cat_registro_marc_n1->getId1]} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object, $cat_registro_marc_n1->getId1);
}

sub _verificarDeleteNivel1 {
    my($msg_object, $params, $cat_registro_marc_n1)=@_;

    $msg_object->{'error'} = 0;#no hay error

    if( !($msg_object->{'error'}) && $cat_registro_marc_n1->tienePrestamos() ){
        C4::AR::Debug::debug("_verificarDeleteNivel1 => tiene al menos 1 ejemplar prestado ");
        #verifico que el nivel2 que quiero eliminar no tenga ningun ejemplar prestado
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P124', 'params' => [$params->{'id2'}]} ) ;

    }
# TODO falta el tieneReservas
#     elsif( !($msg_object->{'error'}) && $cat_registro_marc_n1->tieneReservas() ){
#         #verifico que el nivel2 que quiero eliminar no tenga ningun ejemplar reservado
#         $msg_object->{'error'} = 1;
#         C4::AR::Debug::debug("_verificarDeleteNivel1 => Se está intentando eliminar un ejemplar que tiene al menos un ejemplar reservado ");
#         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P123', 'params' => [$params->{'id2'}]} ) ;
#     }

}

=item sub t_eliminarNivel1
    Elimina el nivel 1 pasado por parametro
=cut
sub t_eliminarNivel1{
   my ($id1) = @_;
   
   my $msg_object = C4::AR::Mensajes::create();

# FIXME falta verificar si es posible eliminar el nivel 1
    my $params;

    my $cat_registro_marc_n1 = C4::Modelo::CatRegistroMarcN1->new();
    my $db = $cat_registro_marc_n1->db;
    my ($cat_registro_marc_n1) = getNivel1FromId1($id1, $db);

    if(!$cat_registro_marc_n1){
        #NO EXISTE EL OBJETO
        #Se setea error para el usuario
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U404', 'params' => []} ) ;
    }else{
        #EXISTE EL OBJETO
        $params->{'id1'} = $id1;
        #verifico condiciones necesarias antes de eliminar     
        _verificarDeleteNivel1($msg_object, $params, $cat_registro_marc_n1);
    }

    if(!$msg_object->{'error'}){
    #No hay error
#         my $db = $cat_registro_marc_n1->db;
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
        $db->begin_work;
    
        eval {
            $cat_registro_marc_n1->eliminar;  
            $db->commit;
            C4::AR::Sphinx::generar_indice($cat_registro_marc_n1->getId1(), 'R_PARTIAL', 'UPDATE');
            #ahora el indice se encuentra DESACTUALIZADO
            C4::AR::Preferencias::setVariable('indexado', 0, $db);
            #se cambio el permiso con exito
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U374', 'params' => [$id1]} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B429',"INTRA");
            $db->rollback;
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U377', 'params' => [$id1]} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object);
}

#===================================================================Fin====ABM Nivel 1=============================================================
#========================================================IMPORTACION MARC==========================================================================

sub getUltimosGrupos{
    my @filtros;

    my $grupos = C4::Modelo::CatRegistroMarcN1::Manager->get_cat_registro_marc_n1(query => \@filtros,
                                                                                  limit => 5,
                                                                                  offset => 0,
                                                                                  sorty_by => ['id DESC'],
                                                                                  );
    my @arreglo_temp;

    foreach my $grupo (@$grupos){
        $grupo->{'id1'} = $grupo->getId1;
        push (@arreglo_temp,$grupo);
    }

    my %obj_for_log = {};
    my ($cantidad,$results) = C4::AR::Busquedas::armarInfoNivel1(\%obj_for_log,@arreglo_temp);

    return ($cantidad,$results);
}

sub addToFavoritos{
    my($id1,$nro_socio) = @_;

    my $favorito_obj    = C4::Modelo::CatFavoritosOpac->new();
    my $status          = 0;

    $favorito_obj       = $favorito_obj->getObjeto($nro_socio, $id1);

    eval{
        $favorito_obj->save();
        $status = 1;
    };

    return($status);
}

sub removeFromFavoritos{
    my($id1,$nro_socio) = @_;

    my $favorito_obj = C4::Modelo::CatFavoritosOpac->new();

    $favorito_obj = $favorito_obj->getObjeto($nro_socio, $id1);
    return($favorito_obj->delete());

}

sub estaEnFavoritos{
    my($id1) = @_;

    my @filtros;
    my $nro_socio = C4::AR::Auth::getSessionNroSocio();
    
    push (@filtros, (nro_socio => {eq => $nro_socio}) );
    push (@filtros, (id1 => {eq => $id1}) );

    my $favoritos_count = C4::Modelo::CatFavoritosOpac::Manager->get_cat_favoritos_opac_count(query => \@filtros,);
    
    return ($favoritos_count);

}

sub getFavoritos{
    my($nro_socio) = @_;

    my @filtros;
    my %obj_for_log = {};

    push (@filtros, (nro_socio => {eq => $nro_socio}) );

    my $favoritos = C4::Modelo::CatFavoritosOpac::Manager->get_cat_favoritos_opac(  query => \@filtros,
                                                                                    select    => ['id1'],
                                                                                  );
    my @arreglo_temp;
    
    foreach my $favorito (@$favoritos){
        push (@arreglo_temp,$favorito);
    }
    my ($cantidad,$results) = C4::AR::Busquedas::armarInfoNivel1(\%obj_for_log,@arreglo_temp);

    return ($cantidad,$results);

}

END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Grupo de Desarrollo Meran <koha@linti.unlp.edu.ar>

=head1 SEE ALSO

C4::AR::Nivel2 C4::AR::Nivel3

=cut

