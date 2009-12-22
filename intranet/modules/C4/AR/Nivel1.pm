package C4::AR::Nivel1;

use strict;
require Exporter;
use C4::Context;
use C4::Modelo::CatRegistroMarcN1;
use C4::Modelo::CatRegistroMarcN1::Manager;


use vars qw(@EXPORT @ISA);

@ISA=qw(Exporter);

@EXPORT=qw(
	&getAutoresAdicionales
	&getColaboradores
	&getUnititle
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
sub t_guardarNivel1

    Esta funcion se invoca desde el template para guardar los datos de nivel1, se apoya en una funcion de Catalogacion.pm que lo que hace es transformar los datos que llegan a un objeto MARC::Record que luego va a insertarse en la base de datos a traves de un objeto CatRegistroMarcN1, ese dato estara filtrado de acuerdo a los datos que corresponden al nivel, solo conteniendo datos que 
=cut
sub t_guardarNivel1 {
    my($params) = @_;
    my $msg_object = C4::AR::Mensajes::create();
    my $id1;

    if(!$msg_object->{'error'}){
    #No hay error
        my $marc_record = C4::AR::Catalogacion::meran_nivel1_to_meran($params);
        ($msg_object,$id1) = guardarRealmente($msg_object,$marc_record);
        
    }
    return ($msg_object, $id1);
}
=head2
sub guardarRealmente

Esta funcion realmente guarda el elemento en la base
=cut
sub guardarRealmente{
    my ($msg_object,$marc_record)=@_;
    my $id1;
    if(!$msg_object->{'error'}){
        my $catRegistroMarcN1 = C4::Modelo::CatRegistroMarcN1->new();  
        my $db = $catRegistroMarcN1->db;
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
        $db->begin_work;
        
        eval {
            $catRegistroMarcN1->agregar($marc_record->as_usmarc);
            $db->commit;            
            #recupero el id1 recien agregado
            $id1 = $catRegistroMarcN1->getId1;
            C4::AR::Busquedas::generar_indice($id1);
            C4::AR::Busquedas::reindexar();
            #se cambio el permiso con exito
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U368', 'params' => [$id1]} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B427',"INTRA");
            $db->rollback;
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
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
 
# FIXME falta verificar que no se agregue con barcode repetido
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

            $cat_registro_marc_n1->modificar($marc_record->as_usmarc);
            $db->commit;
            C4::AR::Busquedas::generar_indice($cat_registro_marc_n1->getId1());
            C4::AR::Busquedas::reindexar();
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
            C4::AR::Busquedas::generar_indice($cat_registro_marc_n1->getId1());
            C4::AR::Busquedas::reindexar();
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
=item sub guardarRegistroMARC
Este funcion recibe un objeto MARC::Record  y lo guarda en el Catálogo (Solo Nivel1, Nivel2 y sus repetibles)
=cut
sub guardarRegistroMARC {
    my ($marc)=@_;

    my $msg_object= C4::AR::Mensajes::create();
       $msg_object->{'tipo'}="INTRA";

    my $id1;

    if(!$msg_object->{'error'}){
    #No hay error
        my  $catNivel1;
        $catNivel1= C4::Modelo::CatNivel1->new();
        my $db= $catNivel1->db;
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
         $db->begin_work;
    
        eval {
            $catNivel1->agregarDesdeMARC($marc);
            $id1 = $catNivel1->getId1;
            $db->commit;
            #se cambio el permiso con exito
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U368', 'params' => [$catNivel1->getId1]} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B427',"INTRA");
            $db->rollback;
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U371', 'params' => []} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object, $id1);
}









#======================================================DEPRECATED?????????????==================================================================

=item sub getNivel1RepetibleFromId1Repetible
Recupero el objeto nivel1_repetible a partir de un rep_n1_id
retorna un objeto o 0 si no existe ninguno
=cut
# sub getNivel1RepetibleFromId1Repetible{
#     my ($rep_n1_id, $db) = @_;
#         
#     $db = $db || C4::Modelo::PermCatalogo->new()->db;    
#     
#     my $nivel1_repetible_array_ref = C4::Modelo::CatNivel1Repetible::Manager->get_cat_nivel1_repetible( 
#                                                                             db => $db,
#                                                                             query => [
#                                                                                         rep_n1_id => { eq => $rep_n1_id } 
#                                                                                 ] 
#                                                             );
#     
#     if( scalar(@$nivel1_repetible_array_ref) > 0){
#         return ($nivel1_repetible_array_ref->[0]);
#     }else{
#         return 0;
#     }
# }


=item sub getNivel1RepetiblesFromId1
Recupero todos los nivel1_repetible a partir de un id1
retorna un arreglo de objetos o 0 si no existe ninguno
=cut
# FIXME DEPRECATED
=item
sub getNivel1RepetiblesFromId1{
  my ($id1) = @_;

  my $nivel1_repetible_array_ref = C4::Modelo::CatNivel1Repetible::Manager->get_cat_nivel1_repetible(   
                                    query => [ 
                                          id1 => { eq => $id1 },
                                      ], 
#                                                                         with_objects => [ 'cat_autor' ]    
                                );

  if( scalar(@$nivel1_repetible_array_ref) > 0){
    return ($nivel1_repetible_array_ref->[0]);
  }else{
    return 0;
  }
}
=cut


=item sub t_eliminarNivel1Repetible
    Elimina el nivel 1 repetido pasado por parametro
=cut
# FIXME DEPRECATED
=item
sub t_eliminarNivel1Repetible{
    my ($params) = @_;
   
    my $msg_object = C4::AR::Mensajes::create();
    my $campo;
    my $subcampo;
    my $parametro;
    my $catNivel1Repetible;
  

    #No hay error
        my $db = C4::Modelo::PermCatalogo->new()->db;
        my $array_nivel_repetible = $params->{'id_rep_array'};
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
        $db->begin_work;
    
        eval {
            for(my $i=0;$i<scalar(@$array_nivel_repetible);$i++){  

                ($catNivel1Repetible) = getNivel1RepetibleFromId1Repetible($array_nivel_repetible->[$i], $db);

                if(!$catNivel1Repetible){
                    #NO EXISTE EL OBJETO
                    #Se setea error para el usuario
                    $msg_object->{'error'} = 1;
                    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U409', 'params' => []} ) ;
                }else{
                    #EXISTE EL OBJETO
                    #verifico condiciones necesarias antes de eliminar     
                    $campo = $catNivel1Repetible->getCampo();
                    $subcampo = $catNivel1Repetible->getSubcampo();
                    $parametro = $array_nivel_repetible->[$i]." - ".$campo.", ".$subcampo;
                    $catNivel1Repetible->eliminar;  
                    $db->commit;
                    #se cambio el permiso con exito
                    $msg_object->{'error'} = 0;
                    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U407', 'params' => [$parametro]} ) ;
                }
            }# for
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B447',"INTRA");
            $db->rollback;
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U408', 'params' => [$parametro]} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    return ($msg_object);
}
=cut



#========================================================FIN IMPORTACION MARC======================================================================
#
=back

=head1 AUTHOR

Grupo de Desarrollo Meran <koha@linti.unlp.edu.ar>

=head1 SEE ALSO

C4::AR::Nivel2 C4::AR::Nivel3

=cut

