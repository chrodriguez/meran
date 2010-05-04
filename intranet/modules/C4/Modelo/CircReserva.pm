package C4::Modelo::CircReserva;

use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'circ_reserva',

    columns => [
        id2              => { type => 'integer', not_null => 1 },
        id3              => { type => 'integer' },
        id_reserva       => { type => 'serial', not_null => 1 },
        nro_socio    	 => { type => 'varchar', length => 16, not_null => 1 },
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
            class       => 'C4::Modelo::CatRegistroMarcN3',
            key_columns => { id3 => 'id' },
	        type        => 'one to one',
        },
        nivel2 => {
            class       => 'C4::Modelo::CatRegistroMarcN2',
            key_columns => { id2 => 'id' },
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

sub getFecha_recordatorio_formateada{
    my ($self) = shift; 
	my $dateformat = C4::Date::get_date_format();
	$self->debug("Fecha de recordatorio: ".$self->getFecha_recordatorio);
    return C4::Date::format_date(C4::AR::Utilidades::trim($self->getFecha_recordatorio),$dateformat);
}

sub setFecha_recordatorio{
    my ($self) = shift;
    my ($fecha_recordatorio) = @_;
    $self->fecha_recordatorio($fecha_recordatorio);
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
    $self->setFecha_recordatorio($data_hash->{'fecha_recordatorio'});
    $self->setId_ui($data_hash->{'id_ui'});
    $self->setEstado($data_hash->{'estado'});
    $self->save();

#**********************************Se registra el movimiento en rep_historial_circulacion***************************
   use C4::Modelo::RepHistorialCirculacion;
   my ($historial_circulacion) = C4::Modelo::RepHistorialCirculacion->new(db=>$self->db);
   $data_hash->{'tipo'}= 'reserva';
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


	$self->debug("RESERVA: tipo: ".$params->{'tipo'}." id3: ".$params->{'id3'}." tipo_p:".$params->{'tipo_prestamo'});
	$self->debug("RESERVA: socio: ".$params->{'nro_socio'}." resp: ".$params->{'loggedinuser'});

	my $dateformat = C4::Date::get_date_format();
	my $id3= $params->{'id3'}||'';
	if($params->{'tipo'} eq 'OPAC'){
		my $nivel3= C4::AR::Reservas::getNivel3ParaReserva($params->{'id2'},'Domiciliario');
		if($nivel3){ $id3=$nivel3->getId3;}
	}

	#Numero de dias que tiene el usuario para retirar el libro si la reserva se efectua sobre un item
	my $numeroDias= C4::AR::Preferencias->getValorPreferencia("reserveItem");
	my ($desde,$hasta,$apertura,$cierre)= C4::Date::proximosHabiles($numeroDias,1);

	my %paramsReserva;
	$paramsReserva{'id1'}= $params->{'id1'};
	$paramsReserva{'id2'}= $params->{'id2'};
	$paramsReserva{'id3'}= $id3;
	$paramsReserva{'nro_socio'}= $params->{'nro_socio'};
	$paramsReserva{'loggedinuser'}= $params->{'loggedinuser'};
	$paramsReserva{'responsable'}= $params->{'loggedinuser'};
	$paramsReserva{'fecha_reserva'}= $desde;
	$paramsReserva{'fecha_recordatorio'}= $hasta;
	$paramsReserva{'id_ui'}= C4::AR::Preferencias->getValorPreferencia("defaultUI");
	$paramsReserva{'estado'}= ($id3 ne '')?'E':'G';
	$paramsReserva{'hasta'}= C4::Date::format_date($hasta,$dateformat);
	$paramsReserva{'desde'}= C4::Date::format_date($desde,$dateformat);
	$paramsReserva{'desdeh'}= $apertura;
	$paramsReserva{'hastah'}= $cierre;
	$paramsReserva{'tipo_prestamo'}= $params->{'tipo_prestamo'};


$self->debug("RESERVA: estado: ".$paramsReserva{'estado'}." id_ui: ".	$paramsReserva{'id_ui'});

	$self->agregar(\%paramsReserva);
	
	$paramsReserva{'id_reserva'}= $self->getId_reserva;

	if( ($id3 ne '')&&($params->{'tipo'} eq 'OPAC') ){
	#es una reserva de ITEM, se le agrega una SANCION al usuario al comienzo del dia siguiente
	#al ultimo dia que tiene el usuario para ir a retirar el libro
		my $err= "Error con la fecha";
		my $startdate= C4::Date::proximoHabil(1,0,$hasta);
		$startdate= C4::Date::format_date_in_iso($startdate,$dateformat);
		my $daysOfSanctions= C4::AR::Preferencias->getValorPreferencia("daysOfSanctionReserves");
		my $enddate= C4::Date::proximoHabil($daysOfSanctions,0,$startdate);
		$enddate= C4::Date::format_date_in_iso($enddate,$dateformat);
		
		use C4::Modelo::CircSancion;
		my  $sancion = C4::Modelo::CircSancion->new(db => $self->db);
		my %paramsSancion;
        $paramsSancion{'loggedinuser'}= $params->{'loggedinuser'};
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
		$self->reasignarEjemplarASiguienteReservaEnEspera($nro_socio);
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
   $data_hash->{'responsable'}=$loggedinuser;
   $data_hash->{'hasta'}=undef;
   $data_hash->{'tipo_prestamo'}='-';
   $data_hash->{'id_ui'}=$self->getId_ui;
   $data_hash->{'tipo'}='cancelacion';
   use C4::Modelo::RepHistorialCirculacion;
   my ($historial_circulacion) = C4::Modelo::RepHistorialCirculacion->new(db=>$self->db);
   $historial_circulacion->agregar($data_hash);
#*******************************Fin***Se registra el movimiento en rep_historial_circulacion*************************
	$self->debug("Se cancela efectivamente");
#Haya o no uno esperando elimino el que existia porque la reserva se esta cancelando
	$self->delete();
}



=item sub actualizarDatosReservaEnEspera
Funcion que actualiza la reserva que estaba esperando por un ejemplar.
=cut
sub actualizarDatosReservaEnEspera{
	my ($self) = shift;

	my ($loggedinuser) = @_;

	my $dateformat = C4::Date::get_date_format();
	my $hoy = C4::Date::format_date_in_iso(ParseDate("today"), $dateformat);

    #Se actualiza la reserva
	my ($desde,$hasta,$apertura,$cierre) = C4::Date::proximosHabiles(C4::AR::Preferencias->getValorPreferencia("reserveGroup"),1);
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
    $paramsSancion{'loggedinuser'}= $loggedinuser;
	$sancion->insertar_sancion(\%paramsSancion);
	# Se registra la actualizacion
	$paramsSancion{'id3'}= $self->getId3;

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

=item sub getReservaEnEspera
Funcion que trae los datos de la primer reserva de la cola que estaba esperando que se desocupe un ejemplar del grupo de esta misma reserva.
=cut
sub getReservaEnEspera{
	my ($self) = shift;

    use C4::Modelo::CircReserva::Manager;
    my @filtros;
    push(@filtros, ( id2 => { eq => $self->getId2 }));
    push(@filtros, ( id3 => undef ));

    my $reservas_array_ref = C4::Modelo::CircReserva::Manager->get_circ_reserva(    db      => $self->db,
																			        query   => \@filtros,
                                                                                    sort_by => 'timestamp',
                                                                                    limit   => 1
                                                                ); 

    if(scalar(@$reservas_array_ref) > 0){
        return ($reservas_array_ref->[0]);
    }else{
        #NO hay reservas en espera para este grupo
        return 0;
    }
}


=item
cancelar_reservas_inmediatas
Se cancelan todas las reservas del usuario que viene por parametro cuando este llega al maximo de prestamos de un tipo determinado.
=cut
sub cancelar_reservas_inmediatas{
	my ($self)=shift;
	my ($params)=@_;
	my $socio=$params->{'nro_socio'};
	
    	use C4::Modelo::CircReserva;
    	use C4::Modelo::CircReserva::Manager;

    	my $reservas_array_ref = C4::Modelo::CircReserva::Manager->get_circ_reserva(
					db=>$self->db,
					query => [ nro_socio => { eq => $socio }, estado => {ne => 'P'}, id3 => undef ]
     				);
    	
	foreach my $reserva (@$reservas_array_ref){
		$reserva->cancelar_reserva($params);
	}

}


sub cancelar_reservas{
# Este procedimiento cancela todas las reservas de los usuarios recibidos como parametro
	my ($self)=shift;
	my ($loggedinuser,$nro_socios)= @_;
	my $params;
	
	$params->{'loggedinuser'}= $loggedinuser;
	$params->{'tipo'}= 'INTRA';

	foreach (@$nro_socios) {
		my $reservas_array_ref = C4::Modelo::CircReserva::Manager->get_circ_reserva( db => $self->db,
									query => [ nro_socio => { eq => $_ }, estado => {ne => 'P'}]); 

		foreach my $reserva (@$reservas_array_ref){
			$reserva->cancelar_reserva($params);
		}
	}
}


=item
cancelar_reservas_sancionados
Se cancelan todas las reservas de usuarios sancionados.
=cut
sub cancelar_reservas_sancionados {
	my ($self)=shift;
	my ($loggedinuser)= @_;

	#Se buscan los socios sancionados
	my $dateformat = C4::Date::get_date_format();
    my $hoy=C4::Date::format_date_in_iso(ParseDate("today"), $dateformat);
  	my $tipo_prestamo=C4::AR::Preferencias->getValorPreferencia("defaultissuetype");
	use C4::Modelo::CircSancion::Manager;
    my $sanciones_array_ref = C4::Modelo::CircSancion::Manager->get_circ_sancion ( db=>$self->db, 
																	query => [ 
																			fecha_comienzo 	=> { le => $hoy },
																			fecha_final    	=> { ge => $hoy},
																			tipo_prestamo 	=> { eq => $tipo_prestamo },
																			or   => [
																				tipo_prestamo => { eq => 0 },
                                                                            ],
																		],
																	select => ['nro_socio'],
																	with_objects => [ 'ref_tipo_prestamo_sancion' ]
									);

  my @socios_sancionados;
  foreach my $sancion (@$sanciones_array_ref){
  	push (@socios_sancionados,$sancion->getNro_socio);
  }


	$self->cancelar_reservas($loggedinuser,\@socios_sancionados);
}


=item
cancelar_reservas_no_regulares
Se cancelan todas las reservas de usuarios que perdieron la regularidad.
=cut
sub cancelar_reservas_no_regulares {
	my ($self)=shift;
	my ($loggedinuser)= @_;

    my $params;
    $params->{'loggedinuser'}= $loggedinuser;
    $params->{'tipo'}= 'INTRA';

	my $reservas_array_ref = C4::Modelo::CircReserva::Manager->get_circ_reserva( db => $self->db,
													          query => [ estado => {ne => 'P'}]);

	foreach my $reserva (@$reservas_array_ref){
        if(! $reserva->socio->estado->regular){$reserva->cancelar_reserva($params)};
	}
}


#========================================================================================================================================


=item sub reasignarEjemplarASiguienteReservaEnEspera

    Esta funcion asgina el ejemplar a una reserva (SI EXISTE) que se encontraba en la cola de espera para un grupo determinado
    Esta reserva ya tenia el ejemplar asignado

    @Parametros:
        $loggedinuser: el usuario logueado
=cut
sub reasignarEjemplarASiguienteReservaEnEspera{
    my ($self) = shift;

    my ($loggedinuser) = @_;

    my ($reservaGrupo) = $self->getReservaEnEspera(); #retorna la primer reserva en espera SI EXISTE

    if($reservaGrupo){
        #Si hay al menos un ejemplar esperando se reasigna
        $reservaGrupo->setId3($self->getId3);
        $reservaGrupo->setId_ui($self->getId_ui);
        $reservaGrupo->actualizarDatosReservaEnEspera($loggedinuser);
    }
}


=item sub cancelar_reservas_socio
    Este procedimiento cancela todas las reservas del usuario recibido como parametro

    @Parametros
        loggedinuser = usuario logueado en el sistema
        nro_socio    = socio al que se le cancelan las reservas
=cut
sub cancelar_reservas_socio{
    my ($self) = shift;

    my ($params) = @_;
    $params->{'tipo'}= 'INTRA';

    my ($reservas_array_ref) = C4::Modelo::CircReserva::Manager->get_circ_reserva( 
#                                                                 FIXME este db esta bien????
                                                                db      => $self->db,
                                                                query   => [    nro_socio   => { eq => $params->{'nro_socio'} }, 
                                                                                estado      => { ne => 'P'} 
                                                                            ]
                                                        );

    foreach my $reserva (@$reservas_array_ref){
        $reserva->cancelar_reserva($params);
    }
}


=item
eliminarReservasVencidas
Elimina las reservas vencidas al dia de la fecha y actualiza la reservas de grupo, si es que exiten, para los item liberados.
=cut
sub cancelar_reservas_vencidas {
    my ($self) = shift;

    my ($loggedinuser, $db) = @_;

    #Se buscan las reservas vencidas!!!!
    my ($reservas_vencidas_array_ref) = getReservasVencidas($db);

    #Se buscan si hay reservas esperando sobre el grupo que se va a elimninar la reservas vencidas
    foreach my $reserva (@$reservas_vencidas_array_ref){
       $reserva->reasignarEjemplarASiguienteReservaEnEspera($loggedinuser);
        #Haya o no uno esperando elimino el que existia porque la reserva se esta cancelando

        $self->debug("Se loguea en historico de circulacion la cancelacion");
        #**********************************Se registra el movimiento en rep_historial_circulacion***************************
        my $data_hash;
        $data_hash->{'id1'} = $reserva->nivel2->nivel1->getId1;
        $data_hash->{'id2'} = $reserva->getId2;
        $data_hash->{'id3'} = $reserva->getId3;
        $data_hash->{'nro_socio'} = $reserva->getNro_socio;
        $data_hash->{'loggedinuser'} = $loggedinuser;
        $data_hash->{'responsable'} = $loggedinuser;
        $data_hash->{'hasta'} = undef;
        $data_hash->{'tipo_prestamo'} = '-';
        $data_hash->{'id_ui'} = $reserva->getId_ui;
        $data_hash->{'tipo'} = 'cancelacion';

        use C4::Modelo::RepHistorialCirculacion;
        my ($historial_circulacion) = C4::Modelo::RepHistorialCirculacion->new(db => $db);

        $historial_circulacion->agregar($data_hash);
        #*******************************Fin***Se registra el movimiento en rep_historial_circulacion*************************

       $reserva->delete();
    }# END foreach my $reserva (@$reservasVencidas)
}

=item sub getReservasVencidas
    Retorna un arreglo de objetos reserva que se encuentran VENCIDAS
=cut
sub getReservasVencidas {
    my ($self) = shift;

    my ($db) = @_;

    my $dateformat  = C4::Date::get_date_format();
    my $hoy         = C4::Date::format_date_in_iso(ParseDate("today"), $dateformat);

    #Se buscan las reservas vencidas!!!!
    my ($reservas_vencidas_array_ref) = C4::Modelo::CircReserva::Manager->get_circ_reserva(
                                                                        db => $db,
                                                                        query => [ 
                                                                                fecha_recordatorio  => { lt => $hoy }, 
                                                                                estado              => { ne => 'P'},
                                                                                id3                 => { ne => undef}
                                                                            ]
                                                        );

    return ($reservas_vencidas_array_ref);
}

=item sub borrar_sancion_de_reserva
Borra la sancion que corresponde a esta reserva
=cut
sub borrar_sancion_de_reserva{
    my ($self) = shift;
    my ($db) = @_;

    my $dateformat  = C4::Date::get_date_format();
    my $hoy         = C4::Date::format_date_in_iso(ParseDate("today"), $dateformat);

    use C4::Modelo::CircSancion::Manager;
    use C4::Modelo::CircSancion;
    my @filtros;
    push(@filtros, ( id_reserva     => { eq => $self->getId_reserva}));
    push(@filtros, ( fecha_comienzo => { gt => $hoy} ));

    my ($sancion_reserva_array_ref) = C4::Modelo::CircSancion::Manager->get_circ_sancion( db => $db, query => \@filtros);

    if(scalar(@$sancion_reserva_array_ref) > 0){
        $sancion_reserva_array_ref->[0]->delete();
    }
}

sub pasar_a_espera{
    my ($self) = shift;

    $self->setId3(undef);
    $self->save();
}

=item sub intercambiarId3

    Este metodo intercambia el id3 de la reserva, por el id3 pasado por parametro
=cut
sub intercambiarId3{
    my ($self) = shift;

    my ($db, $nuevo_Id3, $msg_object) = @_;
    
    C4::AR::Debug::debug("intercambiarId3 => se va a intercambiar el id3, nuevo_Id3: ".$nuevo_Id3);
    use C4::Modelo::CircReserva::Manager;
    my @filtros;
    push(@filtros, ( id3 => { eq => $nuevo_Id3 } ));
    my ($reserva_array_ref) = C4::Modelo::CircReserva::Manager->get_circ_reserva( db => $db, query => \@filtros);

    if (scalar(@$reserva_array_ref) > 0){ 
        #Ya existe una reserva sobre ese Id3
        if($reserva_array_ref->[0]->getEstado eq "E"){ 
        C4::AR::Debug::debug("intercambiarId3 => EXISTE reserva asginada a id3: ".$nuevo_Id3);
            #quiere decir que hay una reserva sobre el $nuevo_Id3 y NO esta prestado el item -> SE HACE EL INTERCAMBIO
            #actualizo la reserva con el viejo id3 para la reserva del otro usuario.
            $reserva_array_ref->[0]->setId3($self->getId3);
            $reserva_array_ref->[0]->save();
            #luego actualizo la actual
            $self->setId3($nuevo_Id3);
            $self->save();
            
        }elsif($reserva_array_ref->[0]->getEstado eq "P"){
            $msg_object->{'error'} = 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P107', 'params' => []} ) ;
        }
    }else{
        #el item con id3 esta libre se actualiza la reserva del usuario al que se va a prestar el item.
        $self->setId3($nuevo_Id3);
        $self->save();
    }

}

1;

