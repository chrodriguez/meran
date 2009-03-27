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
    #Asignando data...
    $self->setId3($data_hash->{'id3'});
    $self->setNro_socio($data_hash->{'nro_socio'});
    $self->setFecha_prestamo($data_hash->{'fecha_prestamo'});
    $self->setTipo_prestamo($data_hash->{'tipo_prestamo'});
    $self->setId_ui($data_hash->{'id_ui'});
    $self->setId_ui_prestamo($data_hash->{'id_ui_prestamo'});
    $self->setRenovaciones(0);
    $self->save();

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
	#El usuario ya tiene la reserva, se le esta entregando un item que es <> al que se le asigno al relizar la reserva
	#Se intercambiaron los id3 de las reservas, si el item que se quiere prestar esta prestado se devuelve el error.
		if($id3 != $reservas->[0]->getId3){
		#Los ids son distintos, se intercambian.
			$reservas->[0]->db=$self->db;
			$reservas->[0]->intercambiarId3($id3,$msg_object);
		}
	}
	elsif($cant==1 && $disponibilidad eq "Para Sala"){
		#FALTA!!! SE PUEDE PONER EN EL ELSE???	
		#llamar a la funcion verificaciones!!
		#verificar disponibilidad del item??? ya esta prestado- hay libre para prestamo de SALA.
		#es un prestamo ES ?????? ****VER****
	}
	else{
		#Se verifca disponibilidad del item;
		my $data=getReservaDeId3($id3);
		my $sePermiteReservaGrupo=1;
		if ($data){
		#el item se encuentra reservado, y hay que buscar otro item del mismo grupo para asignarlo a la reserva del otro usuario
			my ($datosNivel3)= getItemsParaReserva($params->{'id2'});
			if($datosNivel3){
				&cambiarId3($datosNivel3->{'id3'},$data->getId_reserva);
				# el id3 de params quedo libre para ser reservado
			}
			else{
# NO HAY EJEMPLARES LIBRES PARA EL PRESTAMO, SE PONE EL ID3 EN "" PARA QUE SE
# REALIZE UNA RESERVA DE GRUPO, SI SE PERMITE.
				$params->{'id3'}="";
				if(!C4::AR::Preferencias->getValorPreferencia('intranetGroupReserve')){
				#NO SE PERMITE LA RESERVA DE GRUPO
					$sePermiteReservaGrupo=0;
					#Hay error no se permite realizar una reserva de grupo en intra.
					$msg_object->{'error'}= 1;
					C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'R004', 'params' => []} ) ;
				}else{
				#SE PERMITE LA RESERVA DE GRUPO
					#No hay error, se realiza una reserva de grupo.
					$msg_object->{'error'}= 1;
					C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'R005', 'params' => []} ) ;
				}
			}
		}
		#Se realiza una reserva
		if($sePermiteReservaGrupo){
			my ($reserva) = C4::Modelo::CircReserva->new();
			$reserva->load();
# 			my $db = $reserva->db;
# # FIXME faltan devolver los parametros
# 			my ($paraReservas)= reservar($params);
# 			$params->{'reservenumber'}= $paraReservas->{'reservenumber'};
		}
	}
	
	if(!$msg_object->{'error'}){
	#No hay error, se realiza el pretamo
		insertarPrestamo($params);

		#se realizan las verificacioines luego de realizar el prestamo
		_verificacionesPostPrestamo($params,$msg_object);
	}


	}
1;

