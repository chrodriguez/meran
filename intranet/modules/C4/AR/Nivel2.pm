package C4::AR::Nivel2;


use strict;
require Exporter;
use C4::Context;
use C4::Modelo::CatRegistroMarcN2;
use C4::Modelo::CatRegistroMarcN2::Manager;

use vars qw(@EXPORT @ISA);

@ISA=qw(Exporter);

@EXPORT=qw(
		
		&getCantPrestados
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
    my $catRegistroMarcN2;

    if(!$msg_object->{'error'}){
    #No hay error
        my $marc_record = C4::AR::Catalogacion::meran_nivel2_to_meran($params);
        $catRegistroMarcN2 = C4::Modelo::CatRegistroMarcN2->new();  
        my $db = $catRegistroMarcN2->db;
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
        $db->begin_work;
    
        eval {
            $params->{'marc_record'} = $marc_record->as_usmarc;
            $catRegistroMarcN2->agregar($params);
            $db->commit;

            #recupero el id1 recien agregado
            $id2 = $catRegistroMarcN2->getId2;
            #se cambio el permiso con exito
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U369', 'params' => [$id2]} ) ;
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

    return ($msg_object, $catRegistroMarcN2);
}

=head2
sub getNivel2FromId1

    Recupero TODOS los catRegistroMarcN2 que existen relacionados a un CatRegistroMarcN1 a traves del id1
=cut
sub getNivel2FromId1{
    my ($id1) = @_;

    my $nivel2_array_ref = C4::Modelo::CatRegistroMarcN2::Manager->get_cat_registro_marc_n2(   
                                                                      query => [ 
                                                                                    id1 => { eq => $id1 },
                                                                            ]
                                                                );
    return $nivel2_array_ref;
}





#***********************************************ACA FINALIZA LA NUEVA ESTRUCTURA***************************************************************


=item sub getCantPrestados
    retorna la canitdad de items prestados para el grupo pasado por parametro
=cut
sub getCantPrestados{
	my ($id2) = @_;

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



=item sub getNivel2RepetibleFromId2Repetible
Recupero el objeto nivel2_repetible a partir de un rep_n2_id
retorna un objeto o 0 si no existe ninguno
=cut
sub getNivel2RepetibleFromId2Repetible{
  my ($rep_n2_id) = @_;

  my $nivel2_repetible_array_ref = C4::Modelo::CatNivel2Repetible::Manager->get_cat_nivel2_repetible( 
                                                                        query => [ rep_n2_id => { eq => $rep_n2_id } ] 
                                                        );

  if( scalar(@$nivel2_repetible_array_ref) > 0){
    return ($nivel2_repetible_array_ref->[0]);
  }else{
    return 0;
  }
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

=item sub getNivel2RepetibleFromId2Repetible
Recupero un nivel 2 repetible a partir de un $id2_rep (id2 repetible)
retorna un objeto o 0 si no existe
=cut
sub getNivel2RepetibleFromId2Repetible{
  my ($id2_rep, $db) = @_;

  $db = $db || C4::Modelo::PermCatalogo->new()->db;
  my $nivel2_repetible_array_ref = C4::Modelo::CatNivel2Repetible::Manager->get_cat_nivel2_repetible(   
                                                                                    db => $db,
                                                                                    query   => [  
                                                                                                rep_n2_id => { eq => $id2_rep},
                                                                                                ], 
                #                                                                     require_objects => ['CEC']
                                );

  if( scalar(@$nivel2_repetible_array_ref) > 0){
    return ($nivel2_repetible_array_ref->[0]);
  }else{
    return 0;
  }
}

#=======================================================================ABM Nivel 1=======================================================



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
    my($msg_object, $params, $catNivel2)=@_;

    $msg_object->{'error'} = 0;#no hay error

    if( !($msg_object->{'error'}) && $catNivel2->tienePrestamos() ){
        C4::AR::Debug::debug("_verificarDeleteNivel2 => tiene al menos 1 ejemplar prestado ");
        #verifico que el nivel2 que quiero eliminar no tenga ningun ejemplar prestado
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P124', 'params' => [$params->{'id2'}]} ) ;

    }elsif( !($msg_object->{'error'}) && $catNivel2->tieneReservas() ){
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
    my $catNivel2= C4::Modelo::CatNivel2->new();
    my $db = $catNivel2->db;
    my ($catNivel2) = getNivel2FromId2($id2, $db);
   
    if(!$catNivel2){
        #NO EXISTE EL OBJETO
        #Se setea error para el usuario
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U404', 'params' => []} ) ;
    }else{
        #EXISTE EL OBJETO
         $params->{'id2'} = $id2;
        #verifico condiciones necesarias antes de eliminar     
        _verificarDeleteNivel2($msg_object, $params, $catNivel2);
    }

    if(!$msg_object->{'error'}){
        #No hay error        
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
        $db->begin_work;
    
        eval {
            $catNivel2->eliminar;  
            $db->commit;
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

=item sub t_eliminarNivel2Repetible
    Elimina el nivel 2 repetido pasado por parametro
=cut
sub t_eliminarNivel2Repetible{
    my ($params) = @_;
   
    my $msg_object = C4::AR::Mensajes::create();
    my $campo;
    my $subcampo;
    my $parametro;
    my $catNivel2Repetible;
   
    my $db = C4::Modelo::PermCatalogo->new()->db;
    my $array_nivel_repetible = $params->{'id_rep_array'};
    # enable transactions, if possible
    $db->{connect_options}->{AutoCommit} = 0;
    $db->begin_work;

    eval {
        for(my $i=0;$i<scalar(@$array_nivel_repetible);$i++){  

            ($catNivel2Repetible) = getNivel2RepetibleFromId2Repetible($array_nivel_repetible->[$i], $db);

            if(!$catNivel2Repetible){
                #NO EXISTE EL OBJETO
                #Se setea error para el usuario
                $msg_object->{'error'} = 1;
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U409', 'params' => []} ) ;
            }else{
                #EXISTE EL OBJETO
                #verifico condiciones necesarias antes de eliminar     
                $campo = $catNivel2Repetible->getCampo();
                $subcampo = $catNivel2Repetible->getSubcampo();
                $parametro = $array_nivel_repetible->[$i]." - ".$campo.", ".$subcampo;
                $catNivel2Repetible->eliminar;  
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

#===================================================================Fin====ABM Nivel 1====================================================


=item
retorna el primer isbn del grupo con correpondiente al parametro $id2
=cut
# FIXME DEPRECATED
sub getISBN{
    my ($id2)=@_;
    return C4::AR::Busquedas::buscarDatoDeCampoRepetible($id2,"020","a","2");
}

=item
retorna el primer isbn del grupo con correpondiente al parametro $id1
=cut
# FIXME DEPRECATED
sub getISBNById1{
    my ($id1)=@_;


    use C4::Modelo::CatNivel2Repetible;
    use C4::Modelo::CatNivel2Repetible::Manager;

    my @filtros;
    push(@filtros, ( campo    => { eq => "020"}));
    push(@filtros, ( subcampo    => { eq => "a"}));
    push(@filtros, ( id1    => { eq => $id1}));

    my $repetibles_array_ref = C4::Modelo::CatNivel2Repetible::Manager->get_cat_nivel2_repetible( query => \@filtros, with_objects => "cat_nivel2");

        if(scalar(@$repetibles_array_ref) > 0){
            return $repetibles_array_ref->[0]->getDato;
        }else{
            return 0;
        }

}
