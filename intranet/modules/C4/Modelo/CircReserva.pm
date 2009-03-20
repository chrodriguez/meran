package C4::Modelo::CircReserva;

use strict;
use Date::Manip;
use C4::Date;
use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'circ_reserva',

    columns => [
        id2              => { type => 'integer', not_null => 1 },
        id3              => { type => 'integer' },
        id_reserva       => { type => 'serial', not_null => 1 },
        nro_socio	 => { type => 'integer', default => '0', not_null => 1 },
        fecha_reserva    => { type => 'date', default => '0000-00-00', not_null => 1 },
        estado           => { type => 'character', length => 1 },
        id_ui		 => { type => 'varchar', length => 4 },
        fecha_notificacion => { type => 'date' },
        fecha_recodatorio  => { type => 'date' },
        timestamp        => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id_reserva' ],

    unique_key => [ 'nro_socio', 'id3' ],

    relationships => [
        nivel3 => {
            class       => 'C4::Modelo::CatNivel3',
            key_columns => { id3 => 'id3' },
	    type        => 'one to one',
        },
        nivel2 => {
            class       => 'C4::Modelo::CatNivel2',
            key_columns => { id2 => 'id2' },
	    type        => 'one to one',
        },
	socio => {
            class       => 'C4::Modelo::UsrSocio',
            key_columns => { nro_socio => 'nro_socio' },
	    type        => 'one to one',
        },
      ui =>  {
        class       => 'C4::Modelo::PrefUnidadInformacion',
        key_columns => { id_ui => 'id_ui' },
        type        => 'one to one',
      },
    ],
);

sub getId_reserva{
    my ($self) = shift;
    return ($self->id_reserva);
}

sub setId_reserva{
    my ($self) = shift;
    my ($id_reserva) = @_;
    $self->id_reserva($id_reserva);
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

sub getId2{
    my ($self) = shift;
    return ($self->id2);
}

sub setId2{
    my ($self) = shift;
    my ($id2) = @_;
    $self->id2($id2);
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

sub getFecha_reserva{
    my ($self) = shift;
    return ($self->fecha_reserva);
}

sub getFecha_reserva_formateada{
    my ($self) = shift; 
	my $dateformat = C4::Date::get_date_format();
    return (format_date($self->getFecha_reserva,$dateformat));
}

sub setFecha_reserva{
    my ($self) = shift;
    my ($fecha_reserva) = @_;
    $self->fecha_reserva($fecha_reserva);
}

sub getFecha_notificacion{
    my ($self) = shift;
    return ($self->fecha_notificacion);
}

sub getFecha_notificacion_formateada{
    my ($self) = shift; 
	my $dateformat = C4::Date::get_date_format();
    return (format_date($self->getFecha_notificacion,$dateformat));
}

sub setFecha_notificacion{
    my ($self) = shift;
    my ($fecha_notificacion) = @_;
    $self->fecha_notificacion($fecha_notificacion);
}

sub getFecha_recodatorio{
    my ($self) = shift;
    return ($self->fecha_recodatorio);
}

sub getFecha_recodatorio_formateada{
    my ($self) = shift; 
	my $dateformat = C4::Date::get_date_format();
    return (format_date($self->getFecha_recodatorio,$dateformat));
}

sub setFecha_recodatorio{
    my ($self) = shift;
    my ($fecha_recodatorio) = @_;
    $self->fecha_recodatorio($fecha_recodatorio);
}

sub getId_ui{
    my ($self) = shift;
    return ($self->id_ui);
}

sub setId_ui{
    my ($self) = shift;
    my ($id_ui) = @_;
    $self->id_ui($id_ui);
}

sub getEstado{
    my ($self) = shift;
    return ($self->estado);
}

sub setEstado{
    my ($self) = shift;
    my ($estado) = @_;
    $self->estado($estado);
}

sub getTimestamp{
    my ($self) = shift;
    return ($self->timestamp);
}

=item
agregar
Funcion que agrega una reserva
=cut

sub agregar {
    my ($self)=shift;
    my ($data_hash)=@_;
    #Asignando data...
    $self->setId3($data_hash->{'id3'}||undef);
    $self->setId2($data_hash->{'id2'});
    $self->setNro_socio($data_hash->{'nro_socio'});
    $self->setFecha_reserva($data_hash->{'fecha_reserva'});
    $self->setFecha_recodatorio($data_hash->{'fecha_recodatorio'});
    $self->setFecha_notificacion($data_hash->{'fecha_notificacion'});
    $self->setId_ui($data_hash->{'id_ui'});
    $self->setEstado($data_hash->{'estado'});
    $self->save();

#**********************************Se registra el movimiento en rep_historial_circulacion***************************
   use C4::Modelo::RepHistorialCirculacion;
   my ($historial_circulacion) = C4::Modelo::RepHistorialCirculacion->new(db=>$self->db);
   $historial_circulacion->agregar($data_hash);
#*******************************Fin***Se registra el movimiento en rep_historial_circulacion*************************

}

=item
agregar
Funcion para reservar
=cut

sub reservar {
	my ($self)=shift;
	my($params)=@_;

	my $dateformat = C4::Date::get_date_format();
	my $item;
	$item->{'id3'}= $params->{'id3'}||'';
	if($params->{'tipo'} eq 'OPAC'){
		$item= C4::AR::Reservas::getItemsParaReserva($params->{'id2'});
	}
	#Numero de dias que tiene el usuario para retirar el libro si la reserva se efectua sobre un item
	my $numeroDias= C4::AR::Preferencias->getValorPreferencia("reserveItem");
	my ($desde,$hasta,$apertura,$cierre)= C4::Date::proximosHabiles($numeroDias,1);

	my %paramsReserva;
	$paramsReserva{'id1'}= $params->{'id1'};
	$paramsReserva{'id2'}= $params->{'id2'};
	$paramsReserva{'id3'}= $item->{'id3'};
	$paramsReserva{'nro_socio'}= $params->{'nro_socio'};
	$paramsReserva{'loggedinuser'}= $params->{'loggedinuser'};
	$paramsReserva{'fecha_reserva'}= $desde;
	$paramsReserva{'fecha_recodatorio'}= $hasta;
	$paramsReserva{'id_ui'}= C4::AR::Preferencias->getValorPreferencia("defaultbranch");
	$paramsReserva{'estado'}= ($item->{'id3'} ne '')?'E':'G';
	$paramsReserva{'hasta'}= C4::Date::format_date($hasta,$dateformat);
	$paramsReserva{'desde'}= C4::Date::format_date($desde,$dateformat);
	$paramsReserva{'desdeh'}= $apertura;
	$paramsReserva{'hastah'}= $cierre;	
	$paramsReserva{'tipo_prestamo'}= $params->{'tipo_prestamo'};

	$self->agregar(\%paramsReserva);
	
	$paramsReserva{'id_reserva'}= $self->getId_reserva;

	if( ($item->{'id3'} ne '')&&($params->{'tipo'} eq 'OPAC') ){
	#es una reserva de ITEM, se le agrega una SANCION al usuario al comienzo del dia siguiente
	#al ultimo dia que tiene el usuario para ir a retirar el libro
		my $err= "Error con la fecha";
		my $startdate=  C4::Date::DateCalc($hasta,"+ 1 days",\$err);
		$startdate= C4::Date::format_date_in_iso($startdate,$dateformat);
		my $daysOfSanctions= C4::AR::Preferencias->getValorPreferencia("daysOfSanctionReserves");
		my $enddate=  Date::Manip::DateCalc($startdate, "+ $daysOfSanctions days", \$err);
		$enddate= C4::Date::format_date_in_iso($enddate,$dateformat);
		
		use C4::Modelo::CircSancion;
		my  $sancion = C4::Modelo::CircSancion->new(db => $self->db);
		my %paramsSancion;
		$paramsSancion{'tipo_sancion'}= undef;
		$paramsSancion{'id_reserva'}= $self->getId_reserva;
		$paramsSancion{'nro_socio'}= $params->{'nro_socio'};
		$paramsSancion{'fecha_comienzo'}= $startdate;
		$paramsSancion{'fecha_final'}= $enddate;
		$paramsSancion{'dias_sancion'}= undef;
		$sancion->insertar_sancion(\%paramsSancion);
	}
	return (\%paramsReserva);
}
1;

