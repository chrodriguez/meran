package C4::AR::Nivel2;


use strict;
require Exporter;
use C4::Context;
use C4::AR::Amazon;

use vars qw(@EXPORT @ISA);

@ISA=qw(Exporter);

@EXPORT=qw(
		
		&getCantPrestados
);


=item sub getCantPrestados
    retorna la canitdad de items prestados para el grupo pasado por parametro
=cut
sub getCantPrestados{
	my ($id2)=@_;

	my $cantPrestamos_count = C4::Modelo::CircPrestamo::Manager->get_circ_prestamo_count(
                                                               	query => [ 	't2.id2' => { eq => $id2 },
 																			fecha_devolucion => { eq => undef }  
																		 ],
																require_objects => ['nivel3.nivel2'],
																with_objects => ['nivel3'],
										);

# 	C4::AR::Debug::debug("C4::AR::Nivel2::getCantPrestados ".$cantPrestamos_count);


	return $cantPrestamos_count;
}


=item sub getNivel2FromId1
    Recupero TODOS los nivel 2 a partir de un id1
=cut
sub getNivel2FromId1{
	my ($id1) = @_;

	my $nivel2_array_ref = C4::Modelo::CatNivel2::Manager->get_cat_nivel2(   
															query => [ 
																		id1 => { eq => $id1 },
																], 
										);

    return $nivel2_array_ref;
}

=item sub getNivel2FromId2
    Recupero un nivel 2 a partir de un id2
    retorna un objeto o 0 si no existe
=cut
sub getNivel2FromId2{
	my ($id2, $db) = @_;

	my $nivel2_array_ref = C4::Modelo::CatNivel2::Manager->get_cat_nivel2(   
                                                                        db => $db,             
																		query => [ 
																					id2 => { eq => $id2 },
																			], 
																);

	if( scalar(@$nivel2_array_ref) > 0){
		return ($nivel2_array_ref->[0]);
	}else{
		return (0);
	}
}


#=======================================================================ABM Nivel 1=======================================================

=item sub t_guardarNivel2
    transaccion guarda un nivel 2
=cut
sub t_guardarNivel2 {
    my($params)=@_;

## FIXME ver si falta verificar algo!!!!!!!!!!
    my $msg_object= C4::AR::Mensajes::create();
    my $id2;
    my $catNivel2;

    if(!$msg_object->{'error'}){
    #No hay error
		$catNivel2= C4::Modelo::CatNivel2->new();
        my $db= $catNivel2->db;
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
         $db->begin_work;
    
        eval {
            $catNivel2->agregar($params);  
            $db->commit;
            $id2 = $catNivel2->getId2;
            #se cambio el permiso con exito
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U369', 'params' => [$catNivel2->getId2]} ) ;
        };
    
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

    return ($msg_object, $catNivel2);
}


=item sub t_modificarNivel2
    transaccion mofica el nivel 2 pasado por parametro
=cut
sub t_modificarNivel2 {
    my($params)=@_;

## FIXME ver si falta verificar algo!!!!!!!!!!
    my $msg_object= C4::AR::Mensajes::create();
    my $id2;

    my  $catNivel2 = C4::Modelo::CatNivel2->new();
    my  $db = $catNivel2->db;
    my ($catNivel2) = getNivel2FromId2($params->{'id2'}, $db);

    if(!$catNivel2){
        #Se setea error para el usuario
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U403', 'params' => []} ) ;
    }

    if(!$msg_object->{'error'}){
    #No hay error
		
		$params->{'modificado'} = 1;
        my $db= $catNivel2->db;
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
         $db->begin_work;
    
        eval {
            $catNivel2->agregar($params);  
            $db->commit;
            $id2 = $catNivel2->getId2;
            #se cambio el permiso con exito
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U381', 'params' => [$catNivel2->getId2]} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B431',"INTRA");
            $db->rollback;
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U384', 'params' => [$catNivel2->getId2]} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object, $catNivel2);
}


sub _verificarDeleteNivel2 {
    my($msg_object, $params)=@_;

    $msg_object->{'error'} = 0;#no hay error

    if( !($msg_object->{'error'}) && C4::AR::Prestamos::tienePrestamos($params->{'id2'}) ){
        C4::AR::Debug::debug("_verificarDeleteNivel2 => tiene al menos 1 ejemplar prestado ");
        #verifico que el nivel2 que quiero eliminar no tenga ningun ejemplar prestado
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P124', 'params' => [$params->{'id2'}]} ) ;

    }elsif( !($msg_object->{'error'}) && C4::AR::Reservas::tieneReservas($params->{'id2'}) ){
        #verifico que el nivel2 que quiero eliminar no tenga ningun ejemplar reservado
        $msg_object->{'error'} = 1;
        C4::AR::Debug::debug("_verificarDeleteNivel2 => Se está intentando eliminar un ejemplar que tiene al menos un ejemplar reservado ");
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P123', 'params' => [$params->{'id2'}]} ) ;
    }

}

=item sub t_eliminarNivel2
    Elimina el nivel 2 pasado por parametro
=cut
sub t_eliminarNivel2{
   my($id2) = @_;
   
   my $msg_object= C4::AR::Mensajes::create();

    my $params;    
    my  $catNivel2= C4::Modelo::CatNivel2->new();
    my $db = $catNivel2->db;
    my ($catNivel2) = getNivel2FromId2($id2, $db);
   
    if(!$catNivel2){
        #Se setea error para el usuario
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U404', 'params' => []} ) ;
    }

    $params->{'id2'} = $id2;
    _verificarDeleteNivel2($msg_object, $params);

    if(!$msg_object->{'error'}){
    #No hay error        
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
        $db->begin_work;
    
        eval {
            $catNivel2->eliminar;  
            $db->commit;
            #se cambio el permiso con exito
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U375', 'params' => [$id2]} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B429',"INTRA");
            $db->rollback;
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U378', 'params' => [$id2]} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object);

}

#===================================================================Fin====ABM Nivel 1====================================================