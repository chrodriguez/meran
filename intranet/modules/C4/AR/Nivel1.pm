package C4::AR::Nivel1;

use strict;
require Exporter;
use C4::Context;

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


=item sub getNivel1FromId1
Recupero un nivel 1 a partir de un id1
retorna un objeto o 0 si no existe
=cut
sub getNivel1FromId1{
	my ($id1) = @_;

	my $nivel1_array_ref = C4::Modelo::CatNivel1::Manager->get_cat_nivel1(   
																		query => [ 
																					id1 => { eq => $id1 },
																			], 
                                                                        with_objects => [ 'cat_autor' ]    
																);

	if( scalar(@$nivel1_array_ref) > 0){
		return ($nivel1_array_ref->[0]);
	}else{
		return 0;
	}
}

=item sub getNivel1RepetiblesFromId1
Recupero todos los nivel1_repetible a partir de un id1
retorna un arreglo de objetos o 0 si no existe ninguno
=cut
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

=item sub getNivel1RepetibleFromId1Repetible
Recupero el objeto nivel1_repetible a partir de un rep_n1_id
retorna un objeto o 0 si no existe ninguno
=cut
sub getNivel1RepetibleFromId1Repetible{
    my ($rep_n1_id, $db) = @_;
        
    $db = $db || C4::Modelo::PermCatalogo->new()->db;    
    
    my $nivel1_repetible_array_ref = C4::Modelo::CatNivel1Repetible::Manager->get_cat_nivel1_repetible( 
                                                                            db => $db,
                                                                            query => [
                                                                                        rep_n1_id => { eq => $rep_n1_id } 
                                                                                ] 
                                                            );
    
    if( scalar(@$nivel1_repetible_array_ref) > 0){
        return ($nivel1_repetible_array_ref->[0]);
    }else{
        return 0;
    }
}



#=======================================================================ABM Nivel 1=======================================================
=item sub t_guardarNivel1
	guardar datos de nivel1
=cut
sub t_guardarNivel1 {
    my($params)=@_;

## FIXME ver si falta verificar algo!!!!!!!!!!
    my $msg_object= C4::AR::Mensajes::create();
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
            $catNivel1->agregar($params);  
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

=item sub t_modificarNivel1
    Modifica el nivel 1 pasado por parametro
=cut
sub t_modificarNivel1 {
    my($params) = @_;
 
# FIXME falta verificar que no se agregue con barcode repetido
    my $msg_object= C4::AR::Mensajes::create();
    my $id1 = 0;

    my ($catNivel1) = getNivel1FromId1($params->{'id1'});

    if(!$catNivel1){
        #Se setea error para el usuario
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U404', 'params' => []} ) ;
    }

    if(!$msg_object->{'error'}){
    #No hay error
		$params->{'modificado'}=1;

        my $db = $catNivel1->db;
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
         $db->begin_work;
    
        eval {
            $catNivel1->agregar($params);  
            $id1 = $catNivel1->getId1;
            $db->commit;
            #se cambio el permiso con exito
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U380', 'params' => [$catNivel1->getId1]} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B430',"INTRA");
            $db->rollback;
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U383', 'params' => [$catNivel1->getId1]} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object, $id1);
}

sub _verificarDeleteNivel1 {
    my($msg_object, $params, $catNivel1)=@_;

    $msg_object->{'error'} = 0;#no hay error

    if( !($msg_object->{'error'}) && $catNivel1->tienePrestamos() ){
        C4::AR::Debug::debug("_verificarDeleteNivel1 => tiene al menos 1 ejemplar prestado ");
        #verifico que el nivel2 que quiero eliminar no tenga ningun ejemplar prestado
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P124', 'params' => [$params->{'id2'}]} ) ;

    }elsif( !($msg_object->{'error'}) && $catNivel1->tieneReservas() ){
        #verifico que el nivel2 que quiero eliminar no tenga ningun ejemplar reservado
        $msg_object->{'error'} = 1;
        C4::AR::Debug::debug("_verificarDeleteNivel1 => Se está intentando eliminar un ejemplar que tiene al menos un ejemplar reservado ");
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P123', 'params' => [$params->{'id2'}]} ) ;
    }

}

=item sub t_eliminarNivel1
    Elimina el nivel 1 pasado por parametro
=cut
sub t_eliminarNivel1{
   my ($id1) = @_;
   
   my $msg_object= C4::AR::Mensajes::create();

# FIXME falta verificar si es posible eliminar el nivel 1
    my $params;
    my ($catNivel1) = getNivel1FromId1($id1);

    if(!$catNivel1){
        #NO EXISTE EL OBJETO
        #Se setea error para el usuario
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U404', 'params' => []} ) ;
    }else{
        #EXISTE EL OBJETO
        $params->{'id1'} = $id1;
        #verifico condiciones necesarias antes de eliminar     
        _verificarDeleteNivel1($msg_object, $params, $catNivel1);
    }

    if(!$msg_object->{'error'}){
    #No hay error
        my $db = $catNivel1->db;
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
        $db->begin_work;
    
        eval {
            $catNivel1->eliminar;  
            $db->commit;
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

=item sub t_eliminarNivel1Repetible
    Elimina el nivel 1 repetido pasado por parametro
=cut
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
#========================================================FIN IMPORTACION MARC======================================================================
#
=back

=head1 AUTHOR

Grupo de Desarrollo Meran <koha@linti.unlp.edu.ar>

=head1 SEE ALSO

C4::AR::Nivel2 C4::AR::Nivel3

=cut

