package C4::Modelo::CircReserva;

use strict;
use Date::Manip;
use C4::Date;#formatdate
use C4::AR::Utilidades;#trim
use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'circ_reserva',

    columns => [
        id2              => { type => 'integer', not_null => 1 },
        id3              => { type => 'integer' },
        id_reserva       => { type => 'serial', not_null => 1 },
        nro_socio    	 => { type => 'integer', default => '0', not_null => 1 },
        fecha_reserva    => { type => 'varchar', default => '0000-00-00', not_null => 1 },
        estado           => { type => 'character', length => 1 },
        id_ui	      	 => { type => 'varchar', length => 4 },
        fecha_notificacion => { type => 'varchar' },
        fecha_recordatorio  => { type => 'varchar' },
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
    return C4::Date::format_date(C4::AR::Utilidades::trim($self->getFecha_reserva),$dateformat);
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
		$self->debug("Fecha de notificacion: ".$self->getFecha_notificacion);
    return C4::Date::format_date(C4::AR::Utilidades::trim($self->getFecha_notificacion),$dateformat);
}

sub setFecha_notificacion{
    my ($self) = shift;
    my ($fecha_notificacion) = @_;
    $self->fecha_notificacion($fecha_notificacion);
}

sub getFecha_recordatorio{
    my ($self) = shift;
    return ($self->fecha_recordatorio);
}

sub getFecha_recodatorio_formateada{
    my ($self) = shift; 
	my $dateformat = C4::Date::get_date_format();
	$self->debug("Fecha de recordatorio: ".$self->getFecha_recodatorio);
    return C4::Date::format_date(C4::AR::Utilidades::trim($self->getFecha_recodatorio),$dateformat);
}

sub setFecha_recordatorio{
    my ($self) = shift;
    my ($fecha_recodatorio) = @_;
    $self->fecha_recordatorio($fecha_recodatorio);
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


# 
# =item
# cancelar_reserva
# Funcion que cancela una reserva
# =cut
sub cancelar_reserva{
	my ($self)=shift;
	my ($params)=@_;
	my $nro_socio=$params->{'nro_socio'};
	my $loggedinuser=$params->{'loggedinuser'};

	if($self->getId3){
		$self->debug("Es una reserva asignada se trata de reasignar");
#Si la reserva que voy a cancelar estaba asociada a un item tengo que reasignar ese item a otra reserva para el mismo grupo
		$self->reasignarReservaEnEspera($nro_socio);
# Se borra la sancion correspondiente a la reserva si es que la sancion todavia no entro en vigencia
		$self->debug("Se borra la sancion de la reserva");
		$self->borrar_sancion_de_reserva();
	}

#FIXME y esto??? porque no se hace arriba?? solo actualiza la sancion y hace el logueo -> los paso a actualizarDatosReservaEnEspera
#Actualizo la sancion para que refleje el id3 y asi poder informalo 
# 	$params->{'id3'}= $self->getId3;
# 	$params->{'id_reserva'}= $self->getId_reserva;
# 	C4::AR::Sanciones::actualizarSancion($params);
	$self->debug("Se loguea en historico de circulacion la cancelacion");
#**********************************Se registra el movimiento en rep_historial_circulacion***************************
   my $data_hash;
   $data_hash->{'id1'}=$self->nivel2->nivel1->getId1;
   $data_hash->{'id2'}=$self->getId2;
   $data_hash->{'id3'}=$self->getId3;
   $data_hash->{'nro_socio'}=$self->getNro_socio;
   $data_hash->{'loggedinuser'}=$loggedinuser;
   $data_hash->{'end_date'}=undef;
   $data_hash->{'issuesType'}='-';
   $data_hash->{'id_ui'}=$self->getId_ui;
   $data_hash->{'tipo'}='cancel';
   use C4::Modelo::RepHistorialCirculacion;
   my ($historial_circulacion) = C4::Modelo::RepHistorialCirculacion->new(db=>$self->db);
   $historial_circulacion->agregar($data_hash);
#*******************************Fin***Se registra el movimiento en rep_historial_circulacion*************************
	$self->debug("Se cancela efectivamente");
#Haya o no uno esperando elimino el que existia porque la reserva se esta cancelando
	$self->delete();
}


=item
Esta funcion recibe como parametro 
id2 del grupo
id3 del item
loggedinuser
branchcode
=cut
sub reasignarReservaEnEspera{
	my ($self)=shift;
	my ($responsable)=@_;

	my $reservaGrupo=$self->getReservaEnEspera();
	if($reservaGrupo){
		#Si hay ejemplares esperando se reasigna
		$reservaGrupo->setId3($self->getId3);
		$reservaGrupo->setId_ui($self->getId_ui);
		$reservaGrupo->actualizarDatosReservaEnEspera($responsable);
	}
}

=item
actualizarDatosReservaEnEspera
Funcion que actualiza la reserva que estaba esperando por un ejemplar.
=cut
sub actualizarDatosReservaEnEspera{
	my ($self)=shift;
	my ($loggedinuser)=@_;

	my $dateformat = C4::Date::get_date_format();
	my $hoy=C4::Date::format_date_in_iso(ParseDate("today"), $dateformat);

#Se actualiza la reserva
	my ($desde,$hasta,$apertura,$cierre)=C4::Date::proximosHabiles(C4::AR::Preferencias->getValorPreferencia("reserveGroup"),1);
	$self->setEstado('E');
	$self->setFecha_reserva($desde);
	$self->setFecha_notificacion($hoy);
	$self->setFecha_recodatorio($hasta);
	$self->save();

# Se agrega una sancion que comienza el dia siguiente al ultimo dia que tiene el usuario para ir a retirar el libro
	my $err= "Error con la fecha";
	my $dateformat=C4::Date::get_date_format();
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
	$paramsSancion{'nro_socio'}= $self->getNro_socio;
	$paramsSancion{'fecha_comienzo'}= $startdate;
	$paramsSancion{'fecha_final'}= $enddate;
	$paramsSancion{'dias_sancion'}= undef;
	$sancion->insertar_sancion(\%paramsSancion);
	# Se registra la actualizacion
	$paramsSancion{'id3'}= $self->getId3;
	$paramsSancion{'loggedinuser'}= $loggedinuser;
	$sancion->actualizar_sancion(\%paramsSancion);
	#

	my $params;
	$params->{'cierre'}= $cierre;
	$params->{'fecha'}= $hasta;
	$params->{'desde'}= $desde;
	$params->{'apertura'}= $apertura;
	$params->{'loggedinuser'}= $loggedinuser;
	#Se envia una notificacion al usuario avisando que se le asigno una reserva
	C4::AR::Reservas::Enviar_Email($self,$params);
}

=item
getReservaEnEspera
Funcion que trae los datos de la primer reserva de la cola que estaba esperando que se desocupe un ejemplar del grupo de esta misma reserva.
=cut
sub getReservaEnEspera{
	my ($self)=shift;

    use C4::Modelo::CircReserva::Manager;
    my @filtros;
    push(@filtros, ( id2 => { eq => $self->getId2}));
    push(@filtros, ( id3 => undef ));

    my $reservas_array_ref = C4::Modelo::CircReserva::Manager->get_circ_reserva( db=> $self->db,
																			query => \@filtros,
                                                                            sort_by => 'timestamp',
                                                                            limit   => 1); 
    return ($reservas_array_ref->[0]);
}

=item
borrar_sancion_de_reserva
Borra la sancion que corresponde a esta reserva
=cut
sub borrar_sancion_de_reserva
{		my ($self)=shift;

		my $dateformat = C4::Date::get_date_format();
		my $hoy=C4::Date::format_date_in_iso(ParseDate("today"), $dateformat);

		use C4::Modelo::CircSancion::Manager;
		use C4::Modelo::CircSancion;
		my @filtros;
		push(@filtros, ( id_reserva => { eq => $self->getId_reserva}));
    	push(@filtros, ( fecha_comienzo => { gt => $hoy} ));
    	my $sancion_reserva_ref = C4::Modelo::CircSancion::Manager->get_circ_sancion(db=>$self->db,query => \@filtros);
     	if($sancion_reserva_ref->[0])
			{$sancion_reserva_ref->[0]->delete();}
}


1;

