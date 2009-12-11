package C4::Modelo::CatNivel3;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_nivel3',

    columns => [
        id3                   => { type => 'serial', not_null => 1 },
        id1                   => { type => 'integer', not_null => 1 },
        id2                   => { type => 'integer', not_null => 1 },
        barcode               => { type => 'varchar', length => 20 },
        signatura_topografica => { type => 'varchar', length => 30 },
        id_ui_poseedora       => { type => 'varchar', length => 4 }, #ui que tiene el item
        id_ui_origen          => { type => 'varchar', length => 4 }, #ui de donde viene el item
        id_disponibilidad     => { type => 'integer', length => 5, default => '0', not_null => 1 },
        id_estado             => { type => 'character', default => '0', length => 2 },
        timestamp             => { type => 'timestamp', not_null => 1 },
        agregacion_temp       => { type => 'varchar', length => 255 },
    ],

    primary_key_columns => [ 'id3' ],

    relationships => [
	    nivel2 => {
            class      => 'C4::Modelo::CatNivel2',
            column_map => { id2 => 'id2' },
            type       => 'one to one',
        },

		  nivel1 => {
            class      => 'C4::Modelo::CatNivel1',
            column_map => { id1 => 'id1' },
            type       => 'one to one',
        },

        cat_nivel3_repetible => {
            class      => 'C4::Modelo::CatNivel3Repetible',
            column_map => { id3 => 'id3' },
            type       => 'one to many',
        },

        circ_reserva => {
            class      => 'C4::Modelo::CircReserva',
            column_map => { id3 => 'id3' },
            type       => 'one to many',
        },
        
        ref_disponibilidad => {
            class      => 'C4::Modelo::RefDisponibilidad',
            column_map => { id_disponibilidad => 'codigo' },
            type       => 'one to one',
        },

	 	ref_estado => {
            class      => 'C4::Modelo::RefEstado',
            column_map => { id_estado => 'codigo' },
            type       => 'one to one',
        },

#         ref_ui_poseedora => {
#             class      => 'C4::Modelo::RefUnidadInformacion',
#             column_map => { id_ui_poseedora => 'id_ui' },
#             type       => 'one to many',
#         },
#         
#         ref_ui_origen => {
#             class      => 'C4::Modelo::RefUnidadInformacion',
#             column_map => { id_ui_origen => 'id_ui' },
#             type       => 'one to many',
#         },
    ],
);




sub ESTADO_DISPONIBLE{
=item    
ESTADO

    0   Disponible
    1   Perdido
    2   Compartido
    4   Baja
    5   Ejemplar deteriorado
    6   En Encuadernación
=cut
    
    my ($estado) = @_;

    return ($estado eq 0);
}   

=item
DISPONIBILIDAD

    1   Prestamo
    2   Sala de Lectura
=cut

sub DISPONIBILIDAD_PRESTAMO{
    my ($estado) = @_;

    return ($estado eq 1);
}

sub DISPONIBILIDAD_PARA_SALA{
    my ($estado) = @_;

    return ($estado eq 2);
}

sub verificar_cambio {
    my ($self) = shift;

    my ($db, $params) = @_;

    my $estado_anterior             = $params->{'estado_anterior'};          #(DISPONIBLE, "NO DISPONIBLES" => BAJA, COMPARTIDO, etc)
    my $estado_nuevo                = $params->{'estado_nuevo'};
    my $disponibilidad_anterior     = $params->{'disponibilidad_anterior'};  #(DISPONIBLE, PRESTAMO, SALA LECTURA)
    my $disponibilidad_nueva        = $params->{'disponibilidad_nueva'};
    C4::AR::Debug::debug("verificar_cambio => estado_anterior: ".$params->{'estado_anterior'});
    C4::AR::Debug::debug("verificar_cambio => estado_nuevo: ".$params->{'estado_nuevo'});
    C4::AR::Debug::debug("verificar_cambio => disponibilidad_anterior: ".$params->{'disponibilidad_anterior'});
    C4::AR::Debug::debug("verificar_cambio => disponibilidad_nueva: ".$params->{'disponibilidad_nueva'});

    #  ESTADOS
    #   wthdrawn = 0 => DISPONIBLE
    #   wthdrawn > => NO DISPONIBLE

    #  DISPONIBILIDADES
    #   notforloan = 1 => PARA SALA
    #   notforload = 0 => PARA PRESTAMO
        
    my $msg_object;
    
    if( ESTADO_DISPONIBLE($estado_anterior) && (!ESTADO_DISPONIBLE($estado_nuevo)) && DISPONIBILIDAD_PRESTAMO($disponibilidad_anterior) ){
    #pasa de NO DISPONIBLE a DISPONIBLE con disponibilidad_anterior PRESTAMO
    #Si estado_anterior es DISPONIBLE y estado_nuevo es NO DISPONIBLE y disponibilidad_anterior es PARA PRESTAMO
    #hay que reasignar las reservas que existen para el ejemplar, si no se puede reasignar se eliminan las reservas y sanciones
        C4::AR::Debug::debug("verificar_cambio => DISPONIBLE a NO DISPONIBLE con disponibilidad anterior PRESTAMO");
        
        C4::AR::Reservas::reasignarNuevoEjemplarAReserva($db, $params, $msg_object);

    }elsif ( (!ESTADO_DISPONIBLE($estado_anterior)) && ESTADO_DISPONIBLE($estado_nuevo) && DISPONIBILIDAD_PRESTAMO($disponibilidad_nueva) ){
    #pasa de DISPONIBLE a NO DISPONIBLE con disponibilidad_nueva PRESTAMO
    #Si estado_anterior es NO DISPONIBLE  y  estado_nuevo es DISPONIBLE  y  disponibilidad_nueva es PRESTAMO
    #hay que verificar si hay reservas en espera, si hay se reasignan al nuevo ejemplar
        C4::AR::Debug::debug("verificar_cambio => NO DISPONIBLE a DISPONIBLE con disponibilidad nueva PRESTAMO");
        C4::AR::Reservas::asignarEjemplarASiguienteReservaEnEspera($params);

    }elsif ( ESTADO_DISPONIBLE($estado_anterior) && DISPONIBILIDAD_PRESTAMO($disponibilidad_anterior) && 
             DISPONIBILIDAD_PARA_SALA($disponibilidad_nueva) ){
    #Si estaba DISPONIBLE y pasa de disponibilidad_anterior PRESTAMO a disponibilidad_nueva SALA
    #hay que verificar si tiene reservas, si tiene se reasignan si no se puden reasignar se cancelan
        C4::AR::Debug::debug("verificar_cambio => DISPONIBLE de disponibilidad anterior PRESTAMO a disponibilidad nueva PARA SALA");
        C4::AR::Reservas::reasignarNuevoEjemplarAReserva($db, $params, $msg_object);            

    }elsif ( ESTADO_DISPONIBLE($estado_anterior) && DISPONIBILIDAD_PARA_SALA($disponibilidad_anterior) &&
             DISPONIBILIDAD_PRESTAMO($disponibilidad_nueva) ){
    #Si estaba DISPONIBLE y pasa de disponibilidad_anterior PARA SALA a disponibilidad_nueva PRESTAMO
    #Se verifica si hay reservas en espera, si hay se reasignan al nuevo ejemplar
        C4::AR::Debug::debug("verificar_cambio => DISPONIBLE de disponibilidad anterior PARA SALA a disponibilidad nueva PRESTAMO");
        C4::AR::Reservas::asignarEjemplarASiguienteReservaEnEspera($params);
    }
    
}

sub getId_ui_poseedora{
    my ($self) = shift;

    return ($self->id_ui_poseedora);
}

sub setId_ui_poseedora{
    my ($self) = shift;

    my ($id_ui_poseedora) = @_;

    $self->id_ui_poseedora($id_ui_poseedora);
}

sub getId_ui_origen{
    my ($self) = shift;
    return ($self->id_ui_origen);
}

sub setId_ui_origen{
    my ($self) = shift;
    my ($id_ui_origen) = @_;
    $self->id_ui_origen($id_ui_origen);
}

sub getId1{
    my ($self) = shift;
    return ($self->nivel1->id1);
}

sub setId1{
    my ($self) = shift;
    my ($id1) = @_;
    $self->id1($id1);
}

sub getId2{
    my ($self) = shift;
    return ($self->id2);
}

sub setId2{
    my ($self) = shift;
    my ($id2) = @_;
    $self->id2($id2);
}

sub getId3{
    my ($self) = shift;
    return ($self->id3);
}

sub setId3{
    my ($self) = shift;
    my ($id3) = @_;
    $self->id3($id3);
}

sub getBarcode{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->barcode));
}

sub setBarcode{
    my ($self) = shift;
    my ($barcode) = @_;
    $self->barcode($barcode);
}

sub getSignatura_topografica{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->signatura_topografica));
}

sub setSignatura_topografica{
    my ($self) = shift;
    my ($signatura_topografica) = @_;
    $self->signatura_topografica($signatura_topografica);
}

sub getId_disponibilidad{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->id_disponibilidad));
}

sub setId_disponibilidad{
    my ($self) = shift;
    my ($id_disponibilidad) = @_;
    $self->id_disponibilidad($id_disponibilidad);
}

sub setId_estado{
    my ($self) = shift;
    my ($id_estado) = @_;
    $self->id_estado($id_estado);
}

sub getId_estado{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->id_estado));
}

sub getTimestamp{
    my ($self) = shift;
    return ($self->timestamp);
}

sub setTimestamp{
    my ($self) = shift;
    my ($timestamp) = @_;
    $self->timestamp($timestamp);
}


# DEPRECADDD
# sub estaPrestado {
#     my ($self) = shift;
# 
#     return (C4::AR::Prestamos::estaPrestado($self->getId3));
# }

# DEPRECADDD
# sub estadoDisponible{
# 	my ($self) = shift;
# 	return (C4::AR::Referencias::getNombreEstado($self->getId_estado) eq "Disponible");
# }
# 
# DEPRECADDD
# sub esParaSala{
# 	my ($self) = shift;
# 	return (C4::AR::Referencias::getNombreDisponibilidad($self->getId_estado) eq "Sala de Lectura");
# }

# DEPRECADDD
# sub getEstado{
# 	my ($self) = shift;
# 
# 	return (C4::AR::Referencias::getNombreEstado($self->getId_estado));
# }

# ===================================================SOPORTE=====ESTRUCTURA CATALOGACION=================================================

=item
Esta funcion devuelve los campos de nivel 3 mapeados en un arreglo de {campo, subcampo, dato}
=cut
sub toMARC{
    my ($self) = shift;
	my @marc_array;

	my $campo= '995';
	my $subcampo= 'd';
	my %hash;
	$hash{'campo'}= $campo;
	$hash{'subcampo'}= $subcampo;
	$hash{'header'}= C4::AR::Catalogacion::getHeader($campo);
	$hash{'dato'}= C4::AR::Referencias::getNombreUI($self->getId_ui_origen);
	my $estructura= C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($campo, $subcampo);
	
	if($estructura){
        if($estructura->getReferencia){
	        #tiene referencia
		    $hash{'datoReferencia'}= $self->getId_ui_origen;
        }
    
        $hash{'liblibrarian'}= $estructura->getLiblibrarian;
	}

    $hash{'id1'} = $self->getId1;

	push (@marc_array, \%hash);

	$campo= '995';
	$subcampo= 'f';
	my %hash;
	$hash{'campo'}= $campo;
	$hash{'subcampo'}= $subcampo;
	$hash{'header'}= C4::AR::Catalogacion::getHeader($campo);
	$hash{'dato'}= $self->getBarcode;
    $hash{'id1'} = $self->getId1;

	push (@marc_array, \%hash);

	$campo= '995';
	$subcampo= 'c';
	my %hash;
	$hash{'campo'}= $campo;
	$hash{'subcampo'}= $subcampo;
	$hash{'header'}= C4::AR::Catalogacion::getHeader($campo);
	$hash{'dato'}= C4::AR::Referencias::getNombreUI($self->getId_ui_poseedora);
	my $estructura= C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($campo, $subcampo);

    if($estructura){
        if($estructura->getReferencia){
	        #tiene referencia
            $hash{'datoReferencia'}= $self->getId_ui_poseedora;
        }
    
        $hash{'liblibrarian'}= $estructura->getLiblibrarian;
	}
    $hash{'id1'} = $self->getId1;

	push (@marc_array, \%hash);

	$campo= '995';
	$subcampo= 't';
	my %hash;
	$hash{'campo'}= $campo;
	$hash{'subcampo'}= $subcampo;
	$hash{'header'}= C4::AR::Catalogacion::getHeader($campo);
	$hash{'dato'}= $self->getSignatura_topografica;
    $hash{'id1'} = $self->getId1;  

	push (@marc_array, \%hash);

	$campo= '995';
	$subcampo= 'e';
	my %hash;
	$hash{'campo'}= $campo;
	$hash{'subcampo'}= $subcampo;
	$hash{'header'}= C4::AR::Catalogacion::getHeader($campo);
	$hash{'dato'}= C4::AR::Referencias::getNombreEstado($self->getId_estado);
	my $estructura= C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($campo, $subcampo);

    if($estructura){
        if($estructura->getReferencia){
	        #tiene referencia
		    $hash{'datoReferencia'}= $self->getId_estado;
        }
    
        $hash{'liblibrarian'}= $estructura->getLiblibrarian;
	}

    $hash{'id1'} = $self->getId1;

	push (@marc_array, \%hash);

	$campo= '995';
	$subcampo= 'o';
	my %hash;
	$hash{'campo'}= $campo;
	$hash{'subcampo'}= $subcampo;
	$hash{'header'}= C4::AR::Catalogacion::getHeader($campo);
	$hash{'dato'}= C4::AR::Referencias::getNombreDisponibilidad($self->getId_disponibilidad);
	my $estructura= C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($campo, $subcampo);

    if($estructura){
        if($estructura->getReferencia){
	        #tiene referencia
		    $hash{'datoReferencia'}= $self->getId_disponibilidad;
        }
    
        $hash{'liblibrarian'}= $estructura->getLiblibrarian;
	}

    $hash{'id1'} = $self->getId1;


	push (@marc_array, \%hash);

	
	return (\@marc_array);
}

=item
Esta funcion devuelve los campos de nivel 3 y nivel3Repetible mapeados en un arreglo de {campo, subcampo, dato}
=cut
sub nivel3CompletoToMARC{
    my ($self) = shift;

	my ($marc_array) = $self->toMARC;
	my ($nivel3Repetible_object_array) = C4::Modelo::CatNivel3Repetible::Manager->get_cat_nivel3_repetible( 
																						query => [ id3 => { eq => $self->getId3 } ]
																		);

	my $campo;
	my $subcampo;
	my $dato;	
    my $id1 = $self->getId1;

	foreach my $marc_object (@$nivel3Repetible_object_array){
		$campo                  = $marc_object->getCampo;
		$subcampo               = $marc_object->getSubcampo;
		$dato                   = $marc_object->getDato;
		my %hash;
		$hash{'header'}         = C4::AR::Catalogacion::getHeader($campo);
		$hash{'campo'}          = $campo;
		$hash{'subcampo'}       = $subcampo;
		$hash{'liblibrarian'}   = C4::AR::Catalogacion::getLiblibrarian($campo, $subcampo);
		$hash{'dato'}           = $dato;
        $hash{'id1'}            = $id1;
    
        #obtengo el dato de la referencia solo si es un repetible, los campos fijos recuperan de otra forma el dato de la referencia 
        my $valor_referencia    = C4::AR::Catalogacion::getDatoFromReferencia($campo, $subcampo, $dato);
        $hash{'dato'}           = $valor_referencia;
    
        push(@$marc_array, \%hash);
        C4::AR::Debug::debug("CatNivel3 => nivel1CompletoToMARC => nivel1CompletoToMARC => campo, subcampo: ".$campo.", ".$subcampo);
        C4::AR::Debug::debug("CatNivel3 => nivel1CompletoToMARC => nivel1CompletoToMARC => id1: ".$id1);  

 		push(@$marc_array, \%hash);
	}

    C4::AR::Debug::debug("nivel3CompletoToMARC => cant: ".scalar(@$marc_array));
	
	return ($marc_array);
}

# ==============================================FIN===SOPORTE=====ESTRUCTURA CATALOGACION================================================


sub getInvolvedCount{
 
    my ($self) = shift;

    my ($campo, $value)= @_;
    
    my @filtros;

    push (@filtros, ( $campo => $value ) );

    my $cat_nivel3_count = C4::Modelo::CatNivel3::Manager->get_cat_nivel3_count( query => \@filtros );

    return ($cat_nivel3_count);
}

sub replaceBy{
 
    my ($self) = shift;

    my ($campo,$value,$new_value)= @_;
    
    my @filtros;

    push (  @filtros, ( $campo => { eq => $value},) );


    my $replaced = C4::Modelo::CatNivel3::Manager->update_cat_nivel3(   where => \@filtros,
                                                                        set   => { $campo => $new_value });
}

#=======================================================DEPRECADDD========================================================================

=item sub estaReservado
    Verifica si el ejemplar se encuentra reservado o no
=cut
# sub estaReservado {
#     my ($self) = shift;
# 
#     return C4::AR::Reservas::estaReservado($self->getId3);
# }

=item sub estaPrestado
    Verifica si el ejemplar se encuentra prestado o no
=cut
# sub estaPrestado {
#     my ($self) = shift;
#     
#     return C4::AR::Prestamos::estaPrestado($self->getId3);
# }


# sub agregar{
#     my ($self) = shift;
# 
#     my ($db, $data_hash) = @_;
# 
#     use C4::Modelo::CatNivel2Repetible;
# 
#     my @arrayNivel3;
#     my @arrayNivel3Repetibles;
#     my $infoArrayNivel3 = $data_hash->{'infoArrayNivel3'}; #seteo el arreglo de campos repetibles y no repetibles
#     #se separa la info en arreglo de repetibles y no repetibles
# #     foreach my $infoNivel3 (@$infoArrayNivel3){
# #         if($infoNivel3->{'repetible'}){
# #             push(@arrayNivel3Repetibles, $infoNivel3);
# #         }else{
# #             push(@arrayNivel3, $infoNivel3);
# #         }
# #     }
# 
#     foreach my $infoNivel3 (@$infoArrayNivel3){
# 
#         if($infoNivel3->{'tiene_estructura'} eq '1'){
#     #         if($infoNivel2->{'repetible'}){
#             #si es fijo es un campo de la tabla cat_nivel3
#             if(($infoNivel3->{'fijo'} ne '1')|| !defined $infoNivel3->{'fijo'}){
#                 push(@arrayNivel3Repetibles, $infoNivel3);
#             }else{
#             #es es un campo de la tabla cat_nivel3_repetible
#                 push(@arrayNivel3, $infoNivel3);
#             }
#         }
#     }
# 
#     $self->setId1($data_hash->{'id1'});
#     $self->setId2($data_hash->{'id2'});
# 
#     my $params;
#     #recupero la disponibilidad anterior
#     $params->{'disponibilidad_anterior'} = $self->getId_disponibilidad; 
#     #recupero el estado anterior
#     $params->{'estado_anterior'} = $self->getId_estado;
#     $params->{'id2'} = $self->getId2;
#     $params->{'id3'} = $self->getId3;
# 
#     #se guardan los datos de Nivel3
#     foreach my $infoNivel3 (@arrayNivel3){  
#         $self->setDato($infoNivel3);
# 
#         if( ($infoNivel3->{'campo'} eq '995')&&($infoNivel3->{'subcampo'} eq 'o') ){
#             #disponibilidad
# # TODO esta feo ver si se puede modularizar
#             if ($infoNivel3->{'referencia'}) {
#                     $params->{'disponibilidad_nueva'} = $infoNivel3->{'datoReferencia'};
#                     $params->{'estado_nuevo'} = $infoNivel3->{'datoReferencia'};
#                 }else{
#                     $params->{'disponibilidad_nueva'} = $infoNivel3->{'dato'};
#                     $params->{'estado_nuevo'} = $infoNivel3->{'dato'};
#             }
# 
#         }elsif( ($infoNivel3->{'campo'} eq '995')&&($infoNivel3->{'subcampo'} eq 'e') ){
#         #estado del ejemplar
#             if ($infoNivel3->{'referencia'}) {
#                 $params->{'estado_nuevo'} = $infoNivel3->{'datoReferencia'};
#                 $params->{'disponibilidad_nueva'} = $infoNivel3->{'datoReferencia'};
#             }else{
#                 $params->{'estado_nuevo'} = $infoNivel3->{'dato'};
#                 $params->{'disponibilidad_nueva'} = $infoNivel3->{'dato'};
#             }
#         }
# 
# 
#     } #END foreach my $infoNivel3 (@arrayNivel3)
# 
# # TODO ver esto para q es????
#     if(!$data_hash->{'modificado'}){
#         $self->setBarcode($data_hash->{'barcode'});
#     }
#     
#     $self->save(); #guardo un nivel 3
# 
# #     $params->{'db'} = $self->db;
#     #se verifica si luego del cambio realizado en el ejemplar es necesario reasignar las colas de reservas
#     $self->verificar_cambio($db, $params);
# 
# 
#     my $id3= $self->getId3;
# 
#     #Se guradan los datos en Nivel 3 repetibles
#     foreach my $infoNivel3 (@arrayNivel3Repetibles){
#         $infoNivel3->{'id3'}= $id3;
#         my $nivel3Repetible;
#         C4::AR::Debug::debug("CatNivel3 => campo, subcampo: ".$infoNivel3->{'campo'}.", ".$infoNivel3->{'subcampo'});
# 
#         if ( $infoNivel3->{'Id_rep'} != 0 ){
#             C4::AR::Debug::debug("CatNivel3 => agregar => Se va a modificar CatNivel3, Id_rep: ". $infoNivel3->{'Id_rep'});
#             $nivel3Repetible = C4::AR::Nivel3::getNivel3RepetibleFromId3Repetible($infoNivel3->{'Id_rep'},$self->db);
#         }else{
#             C4::AR::Debug::debug("CatNivel3 => agregar => No existe el REPETIBLE se crea uno");
#             $nivel3Repetible = C4::Modelo::CatNivel3Repetible->new(db => $db);
#         }
# 
#         $nivel3Repetible->setId3($infoNivel3->{'id3'});
#         $nivel3Repetible->setCampo($infoNivel3->{'campo'});
#         $nivel3Repetible->setSubcampo($infoNivel3->{'subcampo'});
#         if ($infoNivel3->{'referencia'}) {
#             C4::AR::Debug::debug("CatNivel3 => REPETIBLE con REFERENCIA: ".$infoNivel3->{'datoReferencia'});
#             $nivel3Repetible->dato($infoNivel3->{'datoReferencia'});
#         }else{
#             C4::AR::Debug::debug("CatNivel3 => REPETIBLE sin REFERENCIA: ".$infoNivel3->{'dato'});
#             $nivel3Repetible->dato($infoNivel3->{'dato'});
#         }
# 
#         $nivel3Repetible->save();
#     }
# }

# sub eliminar{
#     my ($self)=shift;
# 
#     my ($db) = @_;
# 
#     $db = $db || $self->db;
# 
#     use C4::Modelo::CatNivel3Repetible;
#     use C4::Modelo::CatNivel3Repetible::Manager;
# 
#     my ($repetiblesNivel3) = C4::Modelo::CatNivel3Repetible::Manager->get_cat_nivel3_repetible( 
#                                                                                     db => $db,                                          
#                                                                                     query => [ id3 => { eq => $self->getId3 } ] 
#                                                                                 );
#     foreach my $n3Rep (@$repetiblesNivel3){
#         $n3Rep->eliminar();
#     }
# 
#     $self->delete();
# }

# sub setDato{
#     my ($self) = shift;
# 
#     my ($data_hash) = @_;
# 
#     $data_hash->{'id2'} = $self->getId2;
#     $data_hash->{'id3'} = $self->getId3;
# 
# 
#     if( ($data_hash->{'campo'} eq '995')&&($data_hash->{'subcampo'} eq 'f') ){
#         if($data_hash->{'modificado'}){
#             $self->setBarcode($data_hash->{'dato'});
#         }
#     }
# 
#     if( ($data_hash->{'campo'} eq '995')&&($data_hash->{'subcampo'} eq 't') ){
#     #signatura_topografica
#         if ($data_hash->{'referencia'}) {
#                 $self->setSignatura_topografica($data_hash->{'datoReferencia'});
#             }else{
#                 $self->setSignatura_topografica($data_hash->{'dato'});
#         }
#     }
# 
#     elsif( ($data_hash->{'campo'} eq '995')&&($data_hash->{'subcampo'} eq 'c') ){
#     #UI poseedora
#         if ($data_hash->{'referencia'}) {
#                 $self->setId_ui_poseedora($data_hash->{'datoReferencia'});
#             }else{
#                 $self->setId_ui_poseedora($data_hash->{'dato'});
#         }
#     }
# 
#     elsif( ($data_hash->{'campo'} eq '995')&&($data_hash->{'subcampo'} eq 'd') ){
#     #UI origen
#         if ($data_hash->{'referencia'}){            
#                 $self->setId_ui_origen($data_hash->{'datoReferencia'});
#             }else{
#                 $self->setId_ui_origen($data_hash->{'dato'});
#         }
#     }
# 
#     elsif( ($data_hash->{'campo'} eq '995')&&($data_hash->{'subcampo'} eq 'o') ){
#     #disponibilidad
#         C4::AR::Debug::debug("DISPONIBILIDAD");
#         C4::AR::Debug::debug("995, o => dato: ".$data_hash->{'dato'});
#         C4::AR::Debug::debug("995, o => datoReferencia: ".$data_hash->{'datoReferencia'});
# 
#         #recupero la disponibilidad anterior
# #         $data_hash->{'disponibilidad_anterior'} = $self->getId_disponibilidad;
# #         $data_hash->{'estado_anterior'} = $self->getId_estado;  
# 
#         if ($data_hash->{'referencia'}) {
#                 $self->setId_disponibilidad($data_hash->{'datoReferencia'});
# #                 $data_hash->{'disponibilidad_nueva'} = $data_hash->{'datoReferencia'};
# #                 $data_hash->{'estado_nuevo'} = $data_hash->{'datoReferencia'};
#             }else{
#                 $self->setId_disponibilidad($data_hash->{'dato'});
# #                 $data_hash->{'disponibilidad_nueva'} = $data_hash->{'dato'};
# #                 $data_hash->{'estado_nuevo'} = $data_hash->{'dato'};
#         }
#         
#     }
# 
#     elsif( ($data_hash->{'campo'} eq '995')&&($data_hash->{'subcampo'} eq 'e') ){
#     #estado del ejemplar
#         C4::AR::Debug::debug("ESTADO");
#         C4::AR::Debug::debug("995, e => dato: ".$data_hash->{'dato'});
#         C4::AR::Debug::debug("995, e => datoReferencia: ".$data_hash->{'datoReferencia'});
#         
#         #recupero el estado anterior
# #         $data_hash->{'estado_anterior'} = $self->getId_estado;
# #         $data_hash->{'disponibilidad_anterior'} = $self->getId_disponibilidad;
#     
#         if ($data_hash->{'referencia'}) {
#             $self->setId_estado($data_hash->{'datoReferencia'});
# #             $data_hash->{'estado_nuevo'} = $data_hash->{'datoReferencia'};
# #             $data_hash->{'disponibilidad_nueva'} = $data_hash->{'datoReferencia'};
#         }else{
#             $self->setId_estado($data_hash->{'dato'});
# #             $data_hash->{'estado_nuevo'} = $data_hash->{'dato'};
# #             $data_hash->{'disponibilidad_nueva'} = $data_hash->{'dato'};
#         }
# 
#     }
# }

1;

