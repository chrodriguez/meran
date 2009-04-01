package C4::Modelo::CircPrestamo;

use strict;
use Date::Manip;
use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'circ_prestamo',

    columns => [
        id_prestamo              => { type => 'serial', not_null => 1 },
        id3                      => { type => 'integer' },
        nro_socio	               => { type => 'integer', default => '0', not_null => 1 },
	     tipo_prestamo            => { type => 'character', length => 2, default => 'DO', not_null => 1 },
        fecha_prestamo           => { type => 'varchar', not_null => 1 },
        id_ui_origen             => { type => 'varchar', length => 4 },
	    id_ui_prestamo	         => { type => 'varchar', length => 4 },
        fecha_devolucion         => { type => 'varchar' },
        renovaciones             => { type => 'integer', default => '0', not_null => 1},
        fecha_ultima_renovacion  => { type => 'varchar' },
        timestamp                => { type => 'timestamp', not_null => 1 },
        agregacion_temp          => { type => 'varchar', length => 255, not_null => 0 },
    ],

    primary_key_columns => [ 'id_prestamo' ],

    relationships => [
      nivel3 => {
            class       => 'C4::Modelo::CatNivel3',
            key_columns => { id3 => 'id3' },
	         type        => 'one to one',
        },
      tipo => {
            class       => 'C4::Modelo::CircRefTipoPrestamo',
            key_columns => { tipo_prestamo => 'id_tipo_prestamo' },
	         type        => 'one to one',
        },

	   socio => {
            class       => 'C4::Modelo::UsrSocio',
            key_columns => { nro_socio => 'nro_socio' },
	         type        => 'one to one',
        },
      ui =>  {
            class       => 'C4::Modelo::PrefUnidadInformacion',
            key_columns => { id_ui_origen => 'id_ui' },
            type        => 'one to one',
      },
      ui_prestamo =>  {
            class       => 'C4::Modelo::PrefUnidadInformacion',
            key_columns => { id_ui_prestamo => 'id_ui' },
            type        => 'one to one',
      },
    ],
);

sub getId_prestamo{
    my ($self) = shift;
    return ($self->id_prestamo);
}

sub setId_prestamo{
    my ($self) = shift;
    my ($id_prestamo) = @_;
    $self->id_reserva($id_prestamo);
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

sub getNro_socio{
    my ($self) = shift;
    return ($self->nro_socio);
}

sub setNro_socio{
    my ($self) = shift;
    my ($nro_socio) = @_;
    $self->nro_socio($nro_socio);
}

sub getTipo_prestamo{
    my ($self) = shift;
    return ($self->tipo_prestamo);
}

sub setTipo_prestamo{
    my ($self) = shift;
    my ($tipo_prestamo) = @_;
    $self->tipo_prestamo($tipo_prestamo);
}

sub getFecha_prestamo{
    my ($self) = shift;
    return ($self->fecha_prestamo);
}

sub getFecha_prestamo_formateada{
	my ($self)=shift;
	my $dateformat = C4::Date::get_date_format();
	return C4::Date::format_date($self->getFecha_prestamo,$dateformat);
}

sub setFecha_prestamo{
    my ($self) = shift;
    my ($fecha_prestamo) = @_;
    $self->fecha_prestamo($fecha_prestamo);
}

sub getId_ui_origen{
    my ($self) = shift;
    return ($self->id_ui_origen);
}

sub setId_ui_origen{
    my ($self) = shift;
    my ($id_ui) = @_;
    $self->id_ui_origen($id_ui);
}

sub getId_ui_prestamo{
    my ($self) = shift;
    return ($self->id_ui_prestamo);
}

sub setId_ui_prestamo{
    my ($self) = shift;
    my ($id_ui_prestamo) = @_;
    $self->id_ui_prestamo($id_ui_prestamo);
}

sub getFecha_devolucion{
    my ($self) = shift;
    return ($self->fecha_devolucion);
}

sub getFecha_devolucion_formateada{
	my ($self)=shift;
	my $dateformat = C4::Date::get_date_format();
	return C4::Date::format_date($self->getFecha_devolucion,$dateformat);
}

sub setFecha_devolucion{
    my ($self) = shift;
    my ($fecha_devolucion) = @_;
    $self->fecha_devolucion($fecha_devolucion);
}


sub getRenovaciones{
    my ($self) = shift;
    return ($self->renovaciones);
}

sub setRenovaciones{
    my ($self) = shift;
    my ($renovaciones) = @_;
    $self->renovaciones($renovaciones);
}

sub getFecha_ultima_renovacion{
    my ($self) = shift;
    return ($self->fecha_ultima_renovacion);
}

sub getFecha_ultima_renovacion_formateada{
	my ($self)=shift;
	my $dateformat = C4::Date::get_date_format();
	return C4::Date::format_date($self->getFecha_ultima_renovacion,$dateformat);
}


sub setFecha_ultima_renovacion{
    my ($self) = shift;
    my ($fecha_ultima_renovacion) = @_;
    $self->fecha_ultima_renovacion($fecha_ultima_renovacion);
}

sub getTimestamp{
    my ($self) = shift;
    return ($self->timestamp);
}

=item
agregar
Funcion que agrega un prestamo
=cut

sub agregar {
    my ($self)=shift;
    my ($data_hash)=@_;
    $self->debug("SE AGREGO EL PRESTAMO");
    #Asignando data...
    $self->setId3($data_hash->{'id3'});
    $self->setNro_socio($data_hash->{'nro_socio'});
    $self->setFecha_prestamo(ParseDate("today"));
    $self->setTipo_prestamo($data_hash->{'tipo_prestamo'});
    $self->setId_ui_origen($data_hash->{'id_ui'});
    $self->setId_ui_prestamo($data_hash->{'id_ui_prestamo'});
    $self->setRenovaciones(0);
    $self->save();

	#**********************************Se registra el movimiento en rep_historial_circulacion***************************
   $self->debug("Se loguea en historico de circulacion el prestamo");
   use C4::Modelo::RepHistorialCirculacion;
   my ($historial_circulacion) = C4::Modelo::RepHistorialCirculacion->new(db=>$self->db);
   $data_hash->{'tipo'}='prestamo';
   $historial_circulacion->agregar($data_hash);
  #*******************************Fin***Se registra el movimiento en rep_historial_circulacion*************************
}


sub prestar {
    my ($self)=shift;
    my ($params,$msg_object)=@_;

	my $nro_socio= $params->{'nro_socio'};
	my $id2= $params->{'id2'};
	my $id3= $params->{'id3'};
	C4::AR::Debug::debug("_chequeoParaPrestamo=> id2: ".$id2);
	C4::AR::Debug::debug("_chequeoParaPrestamo=> id3: ".$id3);
	C4::AR::Debug::debug("_chequeoParaPrestamo=> nro_socio: ".$nro_socio);

#Se verifica si ya se tiene la reserva sobre el grupo
	my ($reservas, $cant)= C4::AR::Reservas::getReservasDeSocio($nro_socio, $id2);

#********************************        VER!!!!!!!!!!!!!! *************************************************
# Si tiene un ejemplar prestado de ese grupo no devuelve la reserva porque en el where estado <> P, Salta error cuando se quiere crear una nueva reserva por el else de abajo. El error es el correcto, pero se puede detectar antes.
# Tendria que devolver todas las reservas y despues verificar los tipos de prestamos de cada ejemplar (notforloan)
# Si esta prestado la clase de prestamo que se quiere hacer en este momento. 
# Si no esta prestado se puede hacer lo de abajo, lo que sigue (estaba pensado para esa situacion).
# Tener en cuenta los prestamos especiales, $tipo_prestamo ==> ES ---> SA. **** VER!!!!!!
	my $disponibilidad= C4::AR::Reservas::getDisponibilidad($id3);
	if($cant == 1 && $disponibilidad eq "Domiciliario"){
	#El usuario ya tiene la reserva, 
	$self->debug("El usuario ya tiene una reserva ID::: ".$reservas->[0]->getId_reserva);
	$params->{'id_reserva'}= $reservas->[0]->getId_reserva;
	
		if($id3 != $reservas->[0]->getId3){
		$self->debug("Los ids son distintos, se intercambian");
		#se le esta entregando un item que es <> al que se le asigno al relizar la reserva
		#Se intercambiaron los id3 de las reservas, si el item que se quiere prestar esta prestado se devuelve el error.
		#Los ids son distintos, se intercambian.
			$reservas->[0]->db=$self->db;
			$reservas->[0]->intercambiarId3($id3,$msg_object);
		}
	}
	elsif($cant ==1 && $disponibilidad eq "Para Sala"){
		#FALTA!!! SE PUEDE PONER EN EL ELSE???	
		#llamar a la funcion verificaciones!!
		#verificar disponibilidad del item??? ya esta prestado- hay libre para prestamo de SALA.
		#es un prestamo ES ?????? ****VER****
	}
	else{#NO EXITE LA RESERVA -> HAY QUE RESERVAR!!!
		$self->debug("NO EXITE LA RESERVA -> HAY QUE RESERVAR!!!");
		my $seReserva=1;
		#Se verifica disponibilidad del item;
		my $reserva=C4::AR::Reservas::getReservaDeId3($id3);
		if ($reserva){
		$self->debug("El item se encuentra reservado, y hay que buscar otro item del mismo grupo para asignarlo a la reserva del otro usuario");
		#el item se encuentra reservado, y hay que buscar otro item del mismo grupo para asignarlo a la reserva del otro usuario
			my ($nivel3)= C4::AR::Reservas::getNivel3ParaReserva($params->{'id2'},$disponibilidad);
			if($nivel3){
				#CAMBIAMOS EL ID3 A OTRO LIBRE Y ASI LIBERAMOS EL QUE SE QUIERE PRESTAR
				$self->debug("CAMBIAMOS EL ID3 A OTRO LIBRE Y ASI LIBERAMOS EL QUE SE QUIERE PRESTAR");
				$reserva->db=$self->db;
				$reserva->setId3($nivel3->getId3);
				$reserva->save();
				# el id3 de params quedo libre para ser reservado
				
			}
			else{
				$self->debug("NO HAY EJEMPLARES LIBRES PARA EL PRESTAMO");
# NO HAY EJEMPLARES LIBRES PARA EL PRESTAMO, SE PONE EL ID3 EN "" PARA QUE SE
# REALIZE UNA RESERVA DE GRUPO, SI SE PERMITE.
				$params->{'id3'}="";
				if(!C4::AR::Preferencias->getValorPreferencia('intranetGroupReserve')){
				#NO SE PERMITE LA RESERVA DE GRUPO
					$seReserva=0;
					#Hay error no se permite realizar una reserva de grupo en intra.
					$self->debug("Hay error no se permite realizar una reserva de grupo en intra");
					$msg_object->{'error'}= 1;
					C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'R004', 'params' => []} ) ;
				}else{
				#SE PERMITE LA RESERVA DE GRUPO
					$self->debug("No hay error, se realiza una reserva de grupo");
					#No hay error, se realiza una reserva de grupo.
					$msg_object->{'error'}= 1;
					C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'R005', 'params' => []} ) ;
				}
			}
		}
		#Se realiza una reserva
		if($seReserva){
			$self->debug("Se realiza una reserva!! ");

			my ($reserva) = C4::Modelo::CircReserva->new(db=>$self->db);
			my ($paramsReserva)= $reserva->reservar($params);
 			$params->{'id_reserva'}= $reserva->getId_reserva;
			$self->debug("Se realizo la reserva ID: ".$params->{'id_reserva'});
		}
	}
	
	if(!$msg_object->{'error'}){
	#No hay error, se realiza el pretamo
		$self->debug("Se va a insertar el prestamo");
		$self->insertarPrestamo($params);

		$self->debug("se realizan las verificacioines luego de realizar el prestamo");
		#se realizan lgetFecha_vencimiento_formateadaas verificacioines luego de realizar el prestamo
		$self->_verificacionesPostPrestamo($params,$msg_object);
	}

	}


sub insertarPrestamo {
	my ($self)=shift;
	my($params)=@_;

	use C4::Modelo::CircReserva;
    my ($reserva) = C4::Modelo::CircReserva->new(db=> $self->db, id_reserva => $params->{'id_reserva'});
    $reserva->load();
	$self->debug("Se actualiza el estado de la reserva a P = Prestado");
#Se actualiza el estado de la reserva a P = Prestado
	$reserva->setEstado('P');
	$reserva->save();

	$self->debug("Se borra la sancion correspondiente a la reserva porque se esta prestando el biblo");
# Se borra la sancion correspondiente a la reserva porque se esta prestando el biblo
	use C4::Modelo::CircSancion::Manager;
	my $sancion= C4::Modelo::CircSancion::Manager->get_circ_sancion(db=>$self->db,query =>[id_reserva =>{eq => $reserva->getId_reserva }]);
	if ($sancion->[0]){$sancion->[0]->delete();}

	$self->debug("Se realiza el prestamo del item");
#Se realiza el prestamo del item
	$self->agregar($params);

}#end insertarPrestamo



=item
Esta funcion se utiliza para verificar post condiciones luego de un prestamo, y realizar las operaciones que sean necesarias
=cut
sub _verificacionesPostPrestamo {
	my ($self)=shift;
	my($params, $msg_object)=@_;

	#Se verifica si el usuario llego al maximo de prestamos, se caen las demas reservas
	if(C4::AR::Prestamos::_verificarMaxTipoPrestamo($params->{'nro_socio'}, $params->{'tipo_prestamo'})){
				$self->debug("Se verifica si el usuario llego al maximo de prestamos, se caen las demas reservas");
 				$params->{'tipo'}="INTRA";
				$msg_object->{'error'}= 0;
				C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P108', 'params' => [$params->{'barcode'}]});
				my ($reserva) = C4::Modelo::CircReserva->new(db=>$self->db);
				$reserva->cancelar_reservas_inmediatas($params);
	}
	else{
			# Se realizo el prestamo con exito
			$msg_object->{'error'}= 0;
			C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P103', 'params' => [$params->{'barcode'}]} ) ;
		}
}



sub estaVencido{
	my ($self)=shift;
	
	my $dateformat = C4::Date::get_date_format();
	my $hoy=C4::Date::format_date_in_iso(C4::Date::ParseDate("today"),$dateformat);
	my $cierre= C4::AR::Preferencias->getValorPreferencia("close");
	my $close = C4::Date::ParseDate($cierre);
	my $err;
   if (Date::Manip::Date_Cmp($close,C4::Date::ParseDate("today"))<0){#Se paso la hora de cierre
     		$hoy=C4::Date::format_date_in_iso(C4::Date::DateCalc($hoy,"+ 1 day",\$err),$dateformat);}

   	my $df=C4::Date::format_date_in_iso($self->getFecha_vencimiento,$dateformat);
   	if (Date::Manip::Date_Cmp($df,$hoy)<0){ return 1;}
		else {
			if ($self->getTipo_prestamo eq 'ES'){#Prestamo especial
				if (Date::Manip::Date_Cmp($df,$hoy)==0){#Se tiene que devolver hoy	
					my $end = Date::Manip::calc_endES();
					my $actual= Date::Manip::ParseDate("today");
					if (Date::Manip::Date_Cmp($actual, $end) > 0){#Se devuelve despues del limite
						return(1);
					}
				}
		   	}#Fin ES
			}
#No esta vencido
	return 0;
}
	
=item
la fecha en que vence el prestamo
=cut

sub getFecha_vencimiento{
	my ($self)=shift;

		my $plazo_actual;
		if ($self->getRenovaciones > 0){#quiere decir que ya fue renovado entonces tengo que calcular sobre los dias de un prestamo renovado para saber si estoy en fecha
	 	 	$plazo_actual=$self->tipo->getDias_renovacion;
			return (C4::Date::proximoHabil($plazo_actual,0,$self->getFecha_ultima_renovacion));
		} 
		else{#es la primer renovacion por lo tanto tengo que ver sobre los dias de un prestamo normal para saber si estoy en fecha de renovacion
		 $plazo_actual=$self->tipo->getDias_prestamo;
		 return (C4::Date::proximoHabil($plazo_actual,0,$self->getFecha_prestamo));
		}
}

sub getFecha_vencimiento_formateada{
	my ($self)=shift;
	my $dateformat = C4::Date::get_date_format();
	return C4::Date::format_date($self->getFecha_vencimiento,$dateformat);
}

sub sePuedeRenovar{
	my ($self)=shift;
	return 0;
}


1;

