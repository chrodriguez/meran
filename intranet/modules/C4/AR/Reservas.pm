package C4::AR::Reservas;

#Este modulo provee funcionalidades para la reservas de documentos
#
#Copyright (C) 2003-2008  Linti, Facultad de Inform�tica, UNLP
#This file is part of Koha-UNLP
#
#This program is free software; you can redistribute it and/or
#modify it under the terms of the GNU General Public License
#as published by the Free Software Foundation; either version 2
#of the License, or (at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software
#Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

use strict;
require Exporter;

use Mail::Sendmail;
use C4::AR::Mensajes;
use C4::AR::Prestamos;
use C4::Modelo::CircReserva;
use C4::Modelo::CircReserva::Manager;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);

@EXPORT = qw(
	&t_reservarOPAC
	&t_cancelar_reserva
	&t_cancelar_y_reservar
	&cancelar_reservas
	&cant_reservas
	&getReservasDeGrupo
	&cantReservasPorGrupo
	&DatosReservas
	&getDatosReservaDeId3
	&cant_waiting

	&CheckWaiting
	&tiene_reservas
	&Enviar_Email
	&FindNotRegularUsersWithReserves
	&eliminarReservasVencidas
	&reasignarTodasLasReservasEnEspera
	&reasignarReservaEnEspera

	&t_realizarPrestamo
	&eliminarReservas
);

sub t_reservarOPAC {
	
	my($params)=@_;
	my $reservaGrupo= 0;
	C4::AR::Debug::debug("Antes de verificar");
	my ($msg_object)= &_verificaciones($params);
	
	if(!$msg_object->{'error'}){
	#No hay error
		C4::AR::Debug::debug("No hay error");
		my ($paramsReserva);
		C4::AR::Debug::debug("antes de reservar!!!");
		my  $reserva = C4::Modelo::CircReserva->new();
        my $db = $reserva->db;
		   $db->{connect_options}->{AutoCommit} = 0;
           $db->begin_work;

		eval {
			C4::AR::Debug::debug("Se va a reservar!!!");
			($paramsReserva)= $reserva->reservar($params);	
			$db->commit;
			C4::AR::Debug::debug("Termino de  reservar!!!");
			#Se setean los parametros para el mensaje de la reserva SIN ERRORES
			if($paramsReserva->{'estado'} eq 'E'){
			C4::AR::Debug::debug("SE RESERVO CON EXITO UN EJEMPLAR!!!");
			#SE RESERVO CON EXITO UN EJEMPLAR
				$msg_object->{'error'}= 0;
				C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U302', 'params' => [	$paramsReserva->{'desde'},
													$paramsReserva->{'desdeh'},
													$paramsReserva->{'hasta'},
													$paramsReserva->{'hastah'}
								]} ) ;
			}else{
			#SE REALIZO UN RESERVA DE GRUPO
				C4::AR::Debug::debug("SE REALIZO UN RESERVA DE GRUPO");
				my $socio= C4::AR::Usuarios::getSocioInfo($params->{'nro_socio'});
				$msg_object->{'error'}= 0;
				C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U303', 'params' => [$socio->persona->getEmail]} ) ;
			}	
		};

		if ($@){
			C4::AR::Debug::debug("ERROR");
			#Se loguea error de Base de Datos
			&C4::AR::Mensajes::printErrorDB($@, 'B400',"OPAC");
			eval {$db->rollback};
			#Se setea error para el usuario
			$msg_object->{'error'}= 1;
			C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'R009', 'params' => []} ) ;
		}
		$db->{connect_options}->{AutoCommit} = 1;
		
	}

	return ($msg_object);
}

sub t_cancelar_y_reservar {
	
	my($params)=@_;

	my $paramsReserva;
	my ($msg_object);	

	my ($reserva) = C4::Modelo::CircReserva->new();
    
	my $db = $reserva->db;
	$db->{connect_options}->{AutoCommit} = 0;
    $db->begin_work;

	eval {
		_cancelar_reserva($params);

		my ($msg_object)= &_verificaciones($params);
		
		if(!$msg_object->{'error'}){

			($paramsReserva)= reservar($params);

			#Se setean los parametros para el mensaje de la reserva SIN ERRORES
			if($paramsReserva->{'estado'} eq 'E'){
			#SE RESERVO CON EXITO UN EJEMPLAR
				$msg_object->{'error'}= 0;
				C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U302', 'params' => [	$paramsReserva->{'desde'}, 
													$paramsReserva->{'desdeh'},
													$paramsReserva->{'hasta'},
													$paramsReserva->{'hastah'}
						]} ) ;

			}else{
			#SE REALIZO UN RESERVA DE GRUPO
				my $borrowerInfo= C4::AR::Usuarios::getBorrowerInfo($params->{'borrowernumber'});
				$msg_object->{'error'}= 0;
				C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U303', 'params' => [$borrowerInfo->{'emailaddress'}]} ) ;
			}
		}

		$db->commit;	
	};

	if ($@){
		#Se loguea error de Base de Datos
		&C4::AR::Mensajes::printErrorDB($@, 'B407',"OPAC");
		eval {$db->rollback};
		#Se setea error para el usuario
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'R011', 'params' => []} ) ;
	}
	$db->{connect_options}->{AutoCommit} = 1;
	
	return ($msg_object);
}

sub cancelar_reservas{
# Este procedimiento cancela todas las reservas de los usuarios recibidos como parametro
	my ($loggedinuser,@borrowersnumbers)= @_;

	my $params;
	
	$params->{'loggedinuser'}= $loggedinuser;
	$params->{'tipo'}= 'INTRA';

	foreach (@borrowersnumbers) {
		
		my $reservas_array_ref=obtenerReservasDeSocio($_);
		foreach my $reserva (@$reservas_array_ref){
			$params->{'reservenumber'}= $reserva->getId;
			$params->{'id2'}= $reserva->getId2;
			_cancelar_reserva($params);
		}
	}
}

sub obtenerReservasDeSocio {
    
    use C4::Modelo::CircReserva;
    use C4::Modelo::CircReserva::Manager;

    my ($socio)=@_;

    my $reservas_array_ref = C4::Modelo::CircReserva::Manager->get_circ_reserva( 
							query => [ nro_socio => { eq => $socio }, estado => {ne => 'P'}]
     							); 
    return ($reservas_array_ref);
}



=item
cancelar_reservas_inmediatas
Se cancelan todas las reservas del usuario que viene por parametro cuando este llega al maximo de prestamos de un tipo determinado.
=cut
sub cancelar_reservas_inmediatas{
	my ($params)=@_;
	my $socio=$params->{'borrowernumber'};
	
    	use C4::Modelo::CircReserva;
    	use C4::Modelo::CircReserva::Manager;

    	my $reservas_array_ref = C4::Modelo::CircReserva::Manager->get_circ_reserva( 
					query => [ nro_socio => { eq => $socio }, estado => {ne => 'P'}, id3 => undef ]
     							); 
    	
	foreach my $reserva (@$reservas_array_ref){
		$params->{'reservenumber'}=$reserva->getId;
		_cancelar_reserva($params);
	}

}

=item
t_cancelar_reserva
Transaccion que cancela una reserva.
@params: $params-->Hash con los datos necesarios para poder cancelar la reserva.
=cut
sub t_cancelar_reserva{
	my ($params)=@_;
		
	my $tipo=$params->{'tipo'};
	my $msg_object= C4::AR::Mensajes::create();


	my ($reserva) = C4::Modelo::CircReserva->new();
        my $db = $reserva->db;
	$db->{connect_options}->{AutoCommit} = 0;
        $db->begin_work;

	eval{
		_cancelar_reserva($params);
		$db->commit;
		$msg_object->{'error'}= 0;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U308', 'params' => []} ) ;
	};
	if ($@){
		#Se loguea error de Base de Datos
		C4::AR::Mensajes::printErrorDB($@, 'B404',$tipo);
		eval {$db->rollback};
		#Se setea error para el usuario
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'R010', 'params' => []} ) ;
	}
	$db->{connect_options}->{AutoCommit} = 1;

	return ($msg_object);
}

=item
Esta funcion elimina todas las del borrower pasado por parametro
=cut
sub eliminarReservas{
	my ($socio)=@_;

	use C4::Modelo::CircReserva;
    	use C4::Modelo::CircReserva::Manager;

    	my $reservas_array_ref = C4::Modelo::CircReserva::Manager->get_circ_reserva(query => [ nro_socio => { eq => $socio } ]); 
	foreach my $reserva (@$reservas_array_ref){
	$reserva->delete();
	}
}


=item
Esta funcion reasigna todas las reservas de un borrower
recibe como parametro un borrowernumber y el loggedinuser
Esta funcion se utiliza por ej. cuando se elimina un usuario
=cut
sub reasignarTodasLasReservasEnEspera{
	my ($params)=@_;
	my $reservas= _getReservasAsignadas($params->{'borrowernumber'});

	foreach my $reserva (@$reservas){

		reasignarReservaEnEspera($reserva,$reserva->{'loggedinuser'});
	}
}

=item
Dado un borrowernumber, devuelve las reservas asignadas a el
=cut
sub _getReservasAsignadas {

	my ($socio)=@_;
	
    	use C4::Modelo::CircReserva;
    	use C4::Modelo::CircReserva::Manager;

    	my $reservas_array_ref = C4::Modelo::CircReserva::Manager->get_circ_reserva(
					query => [ nro_socio => { eq => $socio }, id3 => {ne => undef} ] );
	return($reservas_array_ref);
}

=item
Esta funcion recibe como parametro 
id2 del grupo
id3 del item
loggedinuser
branchcode
=cut
sub reasignarReservaEnEspera{
	my ($reserva,$responsable)=@_;

	my $reservaGrupo=getReservaEnEspera($reserva->getId2);
	if($reservaGrupo){
		$reservaGrupo->setId3($reserva->getId3);
		$reservaGrupo->setId_ui($reserva->getId_ui);
		_actualizarDatosReservaEnEspera($reservaGrupo,$responsable);
	}
}
# 
# =item
# cancelar_reserva
# Funcion que cancela una reserva
# =cut
sub _cancelar_reserva{
	my ($params)=@_;
	my $dbh= C4::Context->dbh;
	my $id_reserva=$params->{'id_reserva'};
	my $nro_socio=$params->{'nro_socio'};
	my $loggedinuser=$params->{'loggedinuser'};
	my $reserva=getReserva($id_reserva);

	my $id2=$reserva->getId2;
	my $id3=$reserva->getId3;

	if($id3){
#Si la reserva que voy a cancelar estaba asociada a un item tengo que reasignar ese item a otra reserva para el mismo grupo
		reasignarReservaEnEspera($reserva,$nro_socio);
# Se borra la sancion correspondiente a la reserva si es que la sancion todavia no entro en vigencia
		C4::AR::Sanciones::borrarSancionReserva($id_reserva);
	}

#Actualizo la sancion para que refleje el id3 y asi poder informalo
	$params->{'id3'}= $id3;
	$params->{'id_reserva'}= $id_reserva;
	C4::AR::Sanciones::actualizarSancion($params);

#**********************************Se registra el movimiento en rep_historial_circulacion***************************
   my $data_hash;
   $data_hash->{'id1'}=$reserva->getId1;
   $data_hash->{'id2'}=$reserva->getId2;
   $data_hash->{'id3'}=$reserva->getId3;
   $data_hash->{'nro_socio'}=$reserva->getNro_socio;
   $data_hash->{'loggedinuser'}=$loggedinuser;
   $data_hash->{'end_date'}=undef;
   $data_hash->{'issuesType'}='-';
   $data_hash->{'id_ui'}=$reserva->getId_ui;
   $data_hash->{'tipo'}='cancel';
   use C4::Modelo::RepHistorialCirculacion;
   my ($historial_circulacion) = C4::Modelo::RepHistorialCirculacion->new();
   $historial_circulacion->agregar($data_hash);
#*******************************Fin***Se registra el movimiento en rep_historial_circulacion*************************

#Haya o no uno esperando elimino el que existia porque la reserva se esta cancelando
	$reserva->delete();
}

=item
getReserva
Funcion que retorna la informacion de la reserva con el numero que se le pasa por parametro.
=cut
sub getReserva{
    my ($id)=@_;
    my ($reserva) = C4::Modelo::CircReserva->new(id => $id);
    $reserva->load();
    return ($reserva);
}

=item
getReservaEnEspera
Funcion que trae los datos de la primer reserva de la cola que estaba esperando que se desocupe un ejemplar del grupo devuelto o cancelado.
=cut
sub getReservaEnEspera{
    my ($id2)=@_;

    use C4::Modelo::CircReserva;
    use C4::Modelo::CircReserva::Manager;
    my ($id2)=@_;
    my @filtros;
    push(@filtros, ( id2 => { eq => $id2}));
    push(@filtros, ( id3 => undef ));

    my $reservas_array_ref = C4::Modelo::CircReserva::Manager->get_circ_reserva( query => \@filtros,
                                                                            sort_by => 'timestamp',
                                                                            limit   => 1,
									); 
    return ($reservas_array_ref->[0]);
}

=item
actualizarDatosReservaEnEspera
Funcion que actualiza la reserva que estaba esperando por un ejemplar.
=cut
sub _actualizarDatosReservaEnEspera{
	my ($reservaGrupo,$loggedinuser)=@_;

#Se agrega actualiza la reserva
	my ($desde,$fecha,$apertura,$cierre)=C4::Date::proximosHabiles(C4::AR::Preferencias->getValorPreferencia("reserveGroup"),1);
	$reservaGrupo->setEstado('E');
	$reservaGrupo->setFecha_reserva($desde);
	$reservaGrupo->setFecha_notificacion(ParseDate("today"));
	$reservaGrupo->setFecha_recodatorio($fecha);
	$reservaGrupo->save();

# Se agrega una sancion que comienza el dia siguiente al ultimo dia que tiene el usuario para ir a retirar el libro
	my $err= "Error con la fecha";
	my $dateformat=C4::Date::get_date_format();
	my $startdate= C4::Date::DateCalc($fecha,"+ 1 days",\$err);
	$startdate= C4::Date::format_date_in_iso($startdate,$dateformat);
	my $daysOfSanctions= C4::AR::Preferencias->getValorPreferencia("daysOfSanctionReserves");
	my $enddate= C4::Date::DateCalc($startdate, "+ $daysOfSanctions days", \$err);
	$enddate= C4::Date::format_date_in_iso($enddate,$dateformat);
	C4::AR::Sanciones::insertSanction(undef, $reservaGrupo->getId ,$reservaGrupo->getNro_socio, $startdate, $enddate, undef);

	my $params;
	$params->{'cierre'}= $cierre;
	$params->{'fecha'}= $fecha;
	$params->{'desde'}= $desde;
	$params->{'apertura'}= $apertura;
	$params->{'loggedinuser'}= $loggedinuser;
	#Se envia una notificacion al usuario avisando que se le asigno una reserva
	Enviar_Email($reservaGrupo,$params);
}

=item
borrarReserva
Funcion que elimina la reserva de la base de datos.
=cut
# sub borrarReserva{
# 	my ($reservenumber)=@_;
# 	my $dbh=C4::Context->dbh;
# 	my $sth=$dbh->prepare("DELETE FROM circ_reserva WHERE reservenumber=?");
# 	$sth->execute($reservenumber);
# }

=item
DEPRECATED  -- se usa directamente obtenerReservasDeSocio
DatosReservas
Busca todas las reservas que tiene el usuario que llega como parametro, trae todo los datos de los documentos asociados a la reserva.
=cut
sub DatosReservas {
	my ($nro_socio)=@_;

	my $reservas_array_ref =obtenerReservasDeSocio($nro_socio);
	
my $dateformat = C4::Date::get_date_format();
	my @results;

	foreach my $reserva (@$reservas_array_ref){
		my $data;

		$data->{'rid3'}=$reserva->getId3;
		$data->{'rbranch'}=$reserva->getId_ui;
		$data->{'id_reserva'}=$reserva->getId_reserva;
		$data->{'estado'}=$reserva->getEstado;
		$data->{'rtitulo'}=$reserva->nivel2->nivel1->getTitulo;
		$data->{'rid1'}=$reserva->nivel2->nivel1->getId1;
		$data->{'rid2'}=$reserva->nivel2->getId2;
		$data->{'anio_publicacion'}=$reserva->nivel2->getAnio_publicacion;
 		$data->{'rautor'}=$reserva->nivel2->nivel1->cat_autor->getId;
 		$data->{'nomCompleto'}=$reserva->nivel2->nivel1->cat_autor->getCompleto;

		$data->{'fecha_recodatorio'}=C4::Date::format_date($reserva->getFecha_recodatorio,$dateformat);
		$data->{'rreservedate'}=C4::Date::format_date($reserva->getFecha_reserva,$dateformat);
		$data->{'rnotificationdate'}= C4::Date::format_date($reserva->getFecha_notificacion,$dateformat);
		$data->{'redicion'}=C4::AR::Nivel2::getEdicion($reserva->getId2);

		push (@results,$data);
	}


	return(scalar(@$reservas_array_ref),$reservas_array_ref);
}

# =item
# datosReservaRealizada
# Trae los datos de todo el nivel2 (y nivel2_repetibles) con el nivel1 para la reserva que realizo el usuario.
# =cut
# sub datosReservaRealizada{
# 	my ($id2)=@_;
# 	my $dbh = C4::Context->dbh;
# 
# 	my $query="SELECT * FROM cat_nivel2 n2 INNER JOIN cat_nivel1 n1 ON (n2.id1=n1.id1)
# 		   LEFT JOIN cat_nivel2_repetible n2r ON (n2.id2=n2r.id2) 
# 		   WHERE n2.id2=?";
# 
# 	my $sth=$dbh->prepare($query);
# 	$sth->execute($id2);
# 	my @results;
# 	while (my $data=$sth->fetchrow_hashref){
# 
# 		push (@results,$data);
# 	}
# 	
# 	$sth->finish;
# }

sub getDisponibilidad{
#Devuelve la disponibilidad del item ('Para Sala', 'Domiciliario')
	my ($id3)=@_;	

	my  $catNivel3= C4::Modelo::CatNivel3->new(id3 => $id3);
        $catNivel3->load;

	return $catNivel3->ref_disponibilidad->getNombre;
}

=item
_verificarTipoReserva
Verifica que el usuario no reserve un item y que ya tenga una reserva para el mismo grupo
=cut
sub _verificarTipoReserva {
	my ($nro_socio, $id2)=@_;
	my $error= 0;
	my ($reservas, $cant)= getReservasDeSocio($nro_socio, $id2);
	#Se intento reservar desde el OPAC sobre el mismo GRUPO
	if ($cant == 1){$error= 1;}
	return ($error);
}


# =item
# Esta funcion devuelve la reserva (si existe) de grupo
# =cut
# sub getReservasDeBorrower {
# #devuelve las reservas de grupo del usuario
# #DEPRECATED!!! se usa getReservasDeSocio
# 	my ($borrowernumber, $id2)=@_;
# 	my $dbh = C4::Context->dbh;
# 	my $query= "SELECT *
# 			FROM circ_reserva
# 			WHERE (nro_socio = ?) AND (id2 = ?)
# 			AND (estado <> 'P')";
# 	my $sth=$dbh->prepare($query);
# 	$sth->execute($borrowernumber, $id2);
# 
# 	my @results;
# 	my $cant= 0;
# 	while (my $data=$sth->fetchrow_hashref){
# 		push (@results,$data);
# 		$cant++;
# 	}
# 	$sth->finish;
# 	return($cant,\@results);
# }
	
sub getReservasDeSocio {
#devuelve las reservas de grupo del usuario
    my ($nro_socio,$id2)=@_;

    use C4::Modelo::CircReserva;
    use C4::Modelo::CircReserva::Manager;
    my @filtros;
    push(@filtros, ( id2 	=> { eq => $id2}));
    push(@filtros, ( nro_socio 	=> { eq => $nro_socio} ));
    push(@filtros, ( estado 	=> { ne => 'P'} ));

    my $reservas_array_ref = C4::Modelo::CircReserva::Manager->get_circ_reserva( query => \@filtros); 
    return ($reservas_array_ref,scalar(@$reservas_array_ref));

}

sub getReservasDeId2 {
#devuelve las reservas de grupo
	my ($id2)=@_;
    	use C4::Modelo::CircReserva;
    	use C4::Modelo::CircReserva::Manager;
    	my @filtros;
    	push(@filtros, ( id2 	=> { eq => $id2}));
    	push(@filtros, ( estado 	=> { ne => 'P'} ));

    	my $reservas_array_ref = C4::Modelo::CircReserva::Manager->get_circ_reserva( query => \@filtros); 
    	return ($reservas_array_ref,scalar(@$reservas_array_ref));
}

sub getReservaDeId3{
	#devuelve la reserva del item
	my ($id3)=@_;
    	use C4::Modelo::CircReserva;
    	use C4::Modelo::CircReserva::Manager;
    	my @filtros;
    	push(@filtros, ( id3 	=> { eq => $id3}));
    	push(@filtros, ( estado 	=> { ne => 'P'} ));

    	my $reservas_array_ref = C4::Modelo::CircReserva::Manager->get_circ_reserva( query => \@filtros); 
    	return ($reservas_array_ref->[0]);
}

=item
DEPRECATED!!!!
Esta funcion devuelve la informacion de la reserva sobre un item
=cut
sub getDatosReservaDeId3{

	my ($id3)=@_;
	my $dbh = C4::Context->dbh;

	my $query= "   	SELECT  * 
			FROM circ_reserva LEFT JOIN  usr_socio ON
			circ_reserva.nro_socio=usr_socio.id_socio  
			WHERE circ_reserva.id3 = ? AND estado <> 'P' ";

	my $sth=$dbh->prepare($query);
	$sth->execute($id3);
      	my $result=$sth->fetchrow_hashref;
        $sth->finish;

        return($result);

}

sub cant_reservas{
#Cantidad de reservas totales de GRUPO y EJEMPLARES
        my ($socio)=@_;
	
    	use C4::Modelo::CircReserva;
    	use C4::Modelo::CircReserva::Manager;
    	my @filtros;
    	push(@filtros, ( nro_socio 	=> { eq => $socio}));
    	push(@filtros, ( estado 	=> { ne => 'P'} ));

    	my $reservas_count = C4::Modelo::CircReserva::Manager->get_circ_reserva_count( query => \@filtros); 
    	return ($reservas_count);
}

sub cantReservasPorGrupo{
#Devuelve la cantidad de reservas realizadas (SIN PRESTAR) sobre un GRUPO
	my ($id2)=@_;

    	use C4::Modelo::CircReserva;
    	use C4::Modelo::CircReserva::Manager;
    	my @filtros;
    	push(@filtros, ( id2 	=> { eq => $id2}));
    	push(@filtros, ( estado => { ne => 'P'} ));

    	my $reservas_count = C4::Modelo::CircReserva::Manager->get_circ_reserva_count( query => \@filtros); 
    	return ($reservas_count);
}

#cuenta las reservas pendientes del grupo
sub cantReservasPorGrupoEnEspera{
	my ($id2)=@_;

    	use C4::Modelo::CircReserva;
    	use C4::Modelo::CircReserva::Manager;
    	my @filtros;
    	push(@filtros, ( id2 	=> { eq => $id2}));
	push(@filtros, ( id3 	=> { eq => undef}));
    	push(@filtros, ( estado => { ne => 'P'} ));

    	my $reservas_count = C4::Modelo::CircReserva::Manager->get_circ_reserva_count( query => \@filtros); 
    	return ($reservas_count);
}

## FIXME reservas por Nivel 1 ?????????????
sub cantReservasPorNivel1{
#Devuelve la cantidad de reservas realizadas (SIN PRESTAR) sobre el nivel1
   my ($id1)=@_;
   my $dbh = C4::Context->dbh;
   my $sth=$dbh->prepare("	SELECT  count(*) as reservas
                       		FROM circ_reserva r INNER JOIN cat_nivel2 n2 ON (r.id2 = n2.id2)
                       		WHERE n2.id1 =? AND estado <> 'P' ");
   $sth->execute($id1);

   return $sth->fetchrow;
}

#Busca los items sin reservas para los prestamos y nuevas reservas.
sub getItemsParaReserva{
	my ($id2)=@_;
        my $dbh = C4::Context->dbh;

	my $query= "	SELECT n3.id1, n3.id3, n3.id_ui_poseedora 
			FROM cat_nivel3 n3 WHERE n3.id2 = ? AND n3.id_disponibilidad=0 AND n3.id_estado=0 
			AND n3.id3 NOT IN (	SELECT r.id3 FROM circ_reserva r 
						WHERE id2 = ? AND id3 IS NOT NULL   )";

	my $sth=$dbh->prepare($query);
	$sth->execute($id2, $id2);

	return $sth->fetchrow_hashref;

}

sub getDisponibilidadGrupo{
#Busca si el grupo tiene solo ejemplares para prestamo en sala o no.
	my ($id2)=@_;

	my @filtros;
	push(@filtros, ( id2 => { eq => $id2}) );
	push(@filtros, ( id_disponibilidad => { eq => 0}) ); # Es Domiciliario
	push(@filtros, ( id_estado => { eq => 0}) ); # Esta Disponible

	my $cantidad_prestamos= C4::Modelo::CatNivel3::Manager->get_cat_nivel3_count( query => \@filtros);

	return ($cantidad_prestamos > 0)?'DO':'SA';
}

sub _verificaciones {
	my($params)=@_;

	my $tipo= $params->{'tipo'}; #INTRA u OPAC
	my $id2= $params->{'id2'};
	my $id3= $params->{'id3'};
	my $barcode= $params->{'barcode'};
	my $nro_socio= $params->{'nro_socio'};
	my $loggedinuser= $params->{'loggedinuser'};
	my $issueType= $params->{'issuesType'};
	my $msg_object= C4::AR::Mensajes::create();
	my $dateformat=C4::Date::get_date_format();

	my $socio= C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);

open(A,">>/tmp/debugVerif.txt");#Para debagear en futuras pruebas para saber por donde entra y que hace.
print A "tipo: $tipo\n";
print A "id2: $id2\n";
print A "id3: $id3\n";
print A "socio: $nro_socio\n";
print A "issueType: $issueType\n";

#Se verifica que el usuario sea Regular
	if( !$socio->esRegular ){
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U300', 'params' => []} ) ;
	print A "Entro al if de regularidad\n";
	}

#Se verifica que el usuario halla realizado el curso, segun preferencia del sistema.
	if( !($msg_object->{'error'}) && ($tipo eq "OPAC") && (C4::AR::Preferencias->getValorPreferencia("usercourse")) && (!$socio->getCumple_requisito) ){
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U304', 'params' => []} ) ;
	print A "Entro al if de si cumple o no requisito\n";
	}

#Se verifica que el usuario no tenga el maximo de prestamos permitidos para el tipo de prestamo.
#SOLO PARA INTRA, ES UN PRESTAMO INMEDIATO.
	if( !($msg_object->{'error'}) && $tipo eq "INTRA" &&  C4::AR::Prestamos::_verificarMaxTipoPrestamo($nro_socio, $issueType) ){
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P101', 'params' => [$params->{'descripcionTipoPrestamo'}, $barcode]} ) ;
print A "Entro al if que verifica la cantidad de prestamos";
	}

#Se verifica si es un prestamo especial este dentro de los horarios que corresponde.
#SOLO PARA INTRA, ES UN PRESTAMO ESPECIAL.
	if(!$msg_object->{'error'} && $tipo eq "INTRA" && $issueType eq 'ES' && _verificarHorario()){
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P102', 'params' => []} ) ;
print A "Entro al if de prestamos especiales";
	}
#Se verfica si el usuario esta sancionado
	my ($sancionado,$fechaFin)= C4::AR::Sanciones::permitionToLoan($nro_socio, $issueType);
print A "sancionado: $sancionado ------ fechaFin: $fechaFin\n";
	if( !($msg_object->{'error'}) && ($sancionado||$fechaFin) ){
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=>  'S200', 'params' => [C4::Date::format_date($fechaFin,$dateformat)]} ) ;
print A "Entro al if de sanciones";
	}
#Se verifica que el usuario no intente reservar desde el OPAC un item para SALA
	if(!$msg_object->{'error'} && $tipo eq "OPAC" && getDisponibilidadGrupo($id2) eq 'SA'){
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=>  'R007', 'params' => []} ) ;
print A "Entro al if de prestamos de sala";
	}

#Se verifica que el usuario no tenga dos reservas sobre el mismo grupo
	if( !($msg_object->{'error'}) && ($tipo eq "OPAC") && (&_verificarTipoReserva($nro_socio, $id2)) ){
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=>  'R002', 'params' => []} ) ;
print A "Entro al if de reservas iguales, sobre el mismo grupo y tipo de prestamo";
	}

#Se verifica que el usuario no supere el numero maximo de reservas posibles seteadas en el sistema desde OPAC
	if( !($msg_object->{'error'}) && ($tipo eq "OPAC") && (C4::AR::Usuarios::llegoMaxReservas($nro_socio))){
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=>  'R001', 'params' => [C4::AR::Preferencias->getValorPreferencia("maxreserves")]} ) ;
print A "Entro al if de maximo de reservas desde OPAC";
	}


#Se verifica que el usuario no tenga dos prestamos sobre el mismo grupo para el mismo tipo prestamo
	if( !($msg_object->{'error'}) && (&C4::AR::Prestamos::getCountPrestamosDeGrupo($nro_socio, $id2, $issueType)) ){
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=>  'P100', 'params' => []} ) ;
print A "Entro al if de prestamos iguales, sobre el mismo grupo y tipo de prestamo";
	}

print A "FIN ".$msg_object->{'error'}." !!!\n\n";
print A "FIN VERIFICACION !!!\n\n";
# print A "error: $error ---- codMsg: $codMsg\n\n\n\n";
close(A);

	return ($msg_object);
}

=item
Esta funcion se utiliza para verificar post condiciones luego de un prestamo, y realizar las operaciones que sean necesarias
=cut
sub _verificacionesPostPrestamo {
	my($params, $msg_object)=@_;

	my $id2= $params->{'id2'};
	my $id3= $params->{'id3'};
	my $barcode= $params->{'barcode'};
	my $borrowernumber= $params->{'borrowernumber'};
	my $loggedinuser= $params->{'loggedinuser'};
	my $issueType= $params->{'issuesType'};
	my $dateformat=C4::Date::get_date_format();
open(A,">>/tmp/debugVerif.txt");#Para debagear en futuras pruebas para saber por donde entra y que hace.
print A "desde verificacionesPostPrestamo\n";
print A "id2: $id2\n";
print A "id3: $id3\n";
print A "borrowernumber: $borrowernumber\n";
print A "issueType: $issueType\n";

	#Se verifica si el usuario llego al maximo de prestamos, se caen las demas reservas
	if ($issueType eq "DO"){
	# FIXME VER SI ES NECESARIO VERIFICAR OTROS TIPOS DE PRESTAMOS COMO POR EJ "DP", "DD", "DR"
		my ($cant, @issuetypes) = C4::AR::Prestamos::PrestamosMaximos($borrowernumber);
		foreach my $iss (@issuetypes){
			if ($iss->{'issuecode'} eq "DO"){#Domiciliario al maximo
# 				$codMsg= 'P108';
 				$params->{'tipo'}="INTRA";
				$msg_object->{'error'}= 0;
				C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P108', 'params' => [$barcode]} ) ;
				C4::AR::Reservas::cancelar_reservas_inmediatas($params);
			}
		}

		##el usuario no llego al maximo de prestamos
		if(scalar(@issuetypes) eq 0){
			# Se realizo el prestamo con exito
			$msg_object->{'error'}= 0;
			C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P103', 'params' => [$barcode]} ) ;
		}
	}

close(A);
}


sub _verificarHorario{
	my $end = ParseDate(C4::AR::Preferencias->getValorPreferencia("close"));
	my $begin =calc_beginES();
	my $actual=ParseDate("today");
	my $error=0;
	if ((Date_Cmp($actual, $begin) < 0) || (Date_Cmp($actual, $end) > 0)){$error=1;}

	return $error;
}

## FIXME esto viene mal de la V2, ver!!!!
sub intercambiarId3{
	my ($borrowernumber, $id2, $id3, $oldid3, $msg_object)= @_;
        my $dbh = C4::Context->dbh;

	my $sth=$dbh->prepare("SELECT id3, estado FROM circ_reserva WHERE id3=? FOR UPDATE ");
	$sth->execute($id3);
	my $data= $sth->fetchrow_hashref;

	if ($data && $data->{'estado'} eq "E"){ 
		#quiere decir que hay una reserva sobre el itemnumber y NO esta prestado el item
		$sth=$dbh->prepare("UPDATE circ_reserva SET id3= ? WHERE id3 = ?");
		$sth->execute($oldid3, $id3);
		#actualizo la reserva con el viejo id3 para la reserva del otro usuario.
	}
	if($data->{'estado'} eq "P"){
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P107', 'params' => []} ) ;
	}
	else{
		#el item con id3 esta libre se actualiza la reserva del usuario al que se va a prestar el item.
		$sth=$dbh->prepare("UPDATE circ_reserva SET id3= ? WHERE id2=? AND nro_socio=?");
		$sth->execute($id3, $id2, $borrowernumber);
	}

}


sub cambiarId3 {
	my ($id3Libre,$reservenumber)=@_;
	my $dbh = C4::Context->dbh;
	my $query="UPDATE circ_reserva SET id3= ? WHERE id_reserva = ?";
	my $sth=$dbh->prepare($query);
	$sth->execute($id3Libre,$reservenumber);
}


sub t_realizarPrestamo{
	my ($params)=@_;
	
	my ($msg_object)= &_verificaciones($params);
	if(!$msg_object->{'error'}){
	#No hay error
		my $dbh=C4::Context->dbh;
		$dbh->{AutoCommit} = 0;
		$dbh->{RaiseError} = 1;
		eval{
			_chequeoParaPrestamo($params,$msg_object);
			$dbh->commit;
		};
		if ($@){
			#Se loguea error de Base de Datos
			C4::AR::Mensajes::printErrorDB($@, 'B401',"INTRA");
			eval {$dbh->rollback};
			#Se setea error para el usuario
			$msg_object->{'error'}= 1;
			C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P106', 'params' => []} ) ;
		}
		$dbh->{AutoCommit} = 1;
	}

	return ($msg_object);
}

sub _chequeoParaPrestamo {
open(A,">>/tmp/debugChequeo.txt");
	my($params,$msg_object)=@_;
	my $dbh=C4::Context->dbh;

	my $borrowernumber= $params->{'borrowernumber'};
	my $id2= $params->{'id2'};
	my $id3= $params->{'id3'};
print A "id2: $id2\n";
print A "id3: $id3\n";
#Se verifica si ya se tiene la reserva sobre el grupo
	my ($reservas, $cant)= getReservasDeSocio($borrowernumber, $id2);# ver lo que sigue.
	$params->{'reservenumber'}= $reservas->[0]->getId_reserva;

# print A "reservenumber de reserva: $reservas->[0]->getId_reserva\n";

#********************************        VER!!!!!!!!!!!!!! *************************************************
# Si tiene un ejemplar prestado de ese grupo no devuelve la reserva porque en el where estado <> P, Salta error cuando se quiere crear una nueva reserva por el else de abajo. El error es el correcto, pero se puede detectar antes.
# Tendria que devolver todas las reservas y despues verificar los tipos de prestamos de cada ejemplar (notforloan)
# Si esta prestado la clase de prestamo que se quiere hacer en este momento. 
# Si no esta prestado se puede hacer lo de abajo, lo que sigue (estaba pensado para esa situacion).
# Tener en cuenta los prestamos especiales, $issueType ==> ES ---> SA. **** VER!!!!!!
	my $disponibilidad=getDisponibilidad($id3);
	if($cant == 1 && $disponibilidad eq "Domiciliario"){
	#El usuario ya tiene la reserva, se le esta entregando un item que es <> al que se le asigno al relizar la reserva
	#Se intercambiaron los id3 de las reservas, si el item que se quiere prestar esta prestado se devuelve el error.
		if($id3 != $reservas->[0]->getId3){
		#Los ids son distintos, se intercambian.
			&intercambiarId3($borrowernumber,$id2,$id3,$reservas->[0]->getId3,$msg_object);
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
			my ($paraReservas)= reservar($params);
			$params->{'reservenumber'}= $paraReservas->{'reservenumber'};
		}
	}
	
	if(!$msg_object->{'error'}){
	#No hay error, se realiza el pretamo
		insertarPrestamo($params);

		#se realizan las verificacioines luego de realizar el prestamo
		_verificacionesPostPrestamo($params,$msg_object);
	}
close(A);
}

sub insertarPrestamo {
	my($params)=@_;

	my $dbh=C4::Context->dbh;
#Se acutualiza el estado de la reserva a P = Presetado
	my $sth=$dbh->prepare("	UPDATE circ_reserva SET estado='P' WHERE id2 = ? AND nro_socio = ? ");

	$sth->execute(	
			$params->{'id2'},
			$params->{'borrowernumber'}
	);
# Se borra la sancion correspondiente a la reserva porque se esta prestando el biblo
	my $sth2=$dbh->prepare("	DELETE FROM circ_sancion 
					WHERE reservenumber = ? ");

	$sth2->execute(	$params->{'reservenumber'});
#Se realiza el prestamo del item
	my $sth3=$dbh->prepare("	INSERT INTO  circ_prestamo 		
					(borrowernumber,id3,date_due,branchcode,issuingbranch,renewals,issuecode) 
					VALUES (?,?,NOW(),?,?,?,?) ");

	$sth3->execute(	$params->{'borrowernumber'}, 
			$params->{'id3'}, 
			$params->{'defaultbranch'}, 
			$params->{'defaultbranch'}, 
			0, 
			$params->{'issuesType'}
	);
#*********************************Se registra el movimiento en historicCirculation***************************
	C4::Circulation::Circ2::insertHistoricCirculation(	'issue',
								$params->{'borrowernumber'},
								$params->{'loggedinuser'},
								$params->{'id1'},
								$params->{'id2'},
								$params->{'id3'},
								$params->{'defaultbranch'},
								$params->{'issuesType'},
								$params->{'hasta'}
							);
#*******************************Fin***Se registra el movimiento en historicCirculation*************************
}#end insertarPrestamo

#para enviar un mail cuando al usuario se le vence la reserva
sub Enviar_Email{
	my ($reserva,$params)=@_;

  	my $desde= $params->{'desde'};
  	my $fecha= $params->{'fecha'};
 	my $apertura= $params->{'apertura'};
 	my $cierre= $params->{'cierre'};
 	my $loggedinuser= $params->{'loggedinuser'};
	my $branchcode= $reserva->getId_ui;
	my $id3= $reserva->getId3;

	if (C4::AR::Preferencias->getValorPreferencia("EnabledMailSystem")){

		my $dateformat = C4::Date::get_date_format();
		my $socio= C4::AR::Usuarios::getSocioInfo($reserva->getNro_socio);
		my $persona= $socio->getPersona;

		my $nivel1=C4::AR::Catalogacion::buscarNivel1($reserva->getId1);
		$nivel1->{'autor'}=(C4::AR::Busquedas::getautor($nivel1->{'autor'}))->{'completo'};
		
		my $mailFrom=C4::AR::Preferencias->getValorPreferencia("reserveFrom");
		my $mailSubject =C4::AR::Preferencias->getValorPreferencia("reserveSubject");
		my $mailMessage =C4::AR::Preferencias->getValorPreferencia("reserveMessage");
		my $branchname= C4::AR::Busquedas::getBranch($reserva->getId_ui)->{'branchname'};


		my $edicion=C4::AR::Nivel2::getEdicion($reserva->getId2);
		$mailSubject =~ s/BRANCH/$branchname/;
		$mailMessage =~ s/BRANCH/$branchname/;
		$mailMessage =~ s/FIRSTNAME/$persona->getNombre/;
		$mailMessage =~ s/SURNAME/$persona->getApellido/;
		my $unititle=C4::AR::Nivel1::getUnititle($reserva->getId1);
		$mailMessage =~ s/UNITITLE/$unititle/;
		$mailMessage =~ s/TITLE/$nivel1->{'titulo'}/;
		$mailMessage =~ s/AUTHOR/$nivel1->{'autor'}/;
		$mailMessage =~ s/EDICION/$edicion/;
		$mailMessage =~ s/a2/$apertura/;
		$desde=C4::Date::format_date($desde,$dateformat);
		$mailMessage =~ s/a1/$desde/;
		$mailMessage =~ s/a3/$cierre/;
		$fecha=C4::Date::format_date($fecha,$dateformat);
		$mailMessage =~ s/a4/$fecha/;
		my %mail = ( 	To => $persona->getEmail,
				From => $mailFrom,
				Subject => $mailSubject,
				Message => $mailMessage);

		my $resultado='ok';
		if ($persona->getEmail && $mailFrom ){
## FIXME me da error
		sendmail(%mail) or die $resultado='error';
		}else {$resultado='';}

#**********************************Se registra el movimiento en rep_historial_circulacion***************************
   my $data_hash;
   $data_hash->{'id1'}=$reserva->getId1;
   $data_hash->{'id2'}=$reserva->getId2;
   $data_hash->{'id3'}=$reserva->getId3;
   $data_hash->{'nro_socio'}=$reserva->getNro_socio;
   $data_hash->{'loggedinuser'}=$loggedinuser;
   $data_hash->{'end_date'}=$fecha;
   $data_hash->{'issuesType'}='-';
   $data_hash->{'id_ui'}=$reserva->getId_ui;
   $data_hash->{'tipo'}='notification';

   use C4::Modelo::RepHistorialCirculacion;
   my ($historial_circulacion) = C4::Modelo::RepHistorialCirculacion->new();
   $historial_circulacion->agregar($data_hash);
#*******************************Fin***Se registra el movimiento en rep_historial_circulacion*************************

	}#end if (C4::Context->preference("EnabledMailSystem"))
}


=item
eliminarReservasVencidas
Elimina las reservas vencidas al dia de la fecha y actualiza la reservas de grupo, si es que exiten, para los item liberados.
=cut
sub eliminarReservasVencidas{
	my ($loggedinuser)=@_;

	my $reservasVencidas=reservasVencidas();
	#Se buscan si hay reservas esperando sobre el grupo que se va a elimninar la reservas vencidas

	foreach my $reserva (@$reservasVencidas){

		reasignarReservaEnEspera($reserva,$loggedinuser);

		#Actualizo la sancion para que refleje el id3 del item y asi poder informalo
		my %params;
		$params{'id3'}=$reserva->getId3;
		$params{'reservenumber'}=$reserva->getId;
		$params{'loggedinuser'}= $loggedinuser;
		C4::AR::Sanciones::actualizarSancion(\%params);

		#Haya o no uno esperando elimino el que existia porque la reserva se esta cancelando
		$reserva->delete();
	}

}

=item
reservasVencidas
Devuele una referencia a un arreglo con todas las reservas que esta vencidas al dia de la fecha.
=cut
sub reservasVencidas{

    use C4::Modelo::CircReserva;
    use C4::Modelo::CircReserva::Manager;

    my ($socio)=@_;

    my $reservas_array_ref = C4::Modelo::CircReserva::Manager->get_circ_reserva(
							query => [ fecha_recodatorio => { lt => ParseDate("today") }, 
								   estado => {ne => 'P'}, 
								   id3 => {ne => undef}]
     							); 
    return ($reservas_array_ref);

}

=item
Esta funcion retorna la cantidad de reservas en espera
=cut
sub cant_waiting{
        my ($borrowernumber)=@_;
        my $dbh = C4::Context->dbh;
        my $query="	SELECT count(*) as cant FROM circ_reserva
   			WHERE nro_socio = ?
			AND estado <> 'P'
			AND id3 IS NULL ";
        my $sth=$dbh->prepare($query);
        $sth->execute($borrowernumber);

        my $result=$sth->fetchrow_hashref;
        $sth->finish;
        return($result);
}

sub CheckWaiting {
    	my ($borrowernumber)=@_;

    	my $dbh = C4::Context->dbh;
    	my @itemswaiting;

	my $sth=$dbh->prepare("	SELECT n3.barcode, n1.titulo, b.nombre, n2.id2, it.nombre, r. * 
				FROM circ_reserva r
				INNER JOIN cat_nivel3 n3 ON r.id3 = n3.id3
				INNER JOIN cat_nivel1 n1 ON n1.id1 = n3.id1
				INNER JOIN cat_nivel2 n2 ON n1.id1 = n2.id1 AND n3.id2 = n2.id2
				INNER JOIN cat_ref_tipo_nivel3 it ON it.id_tipo_doc = n2.tipo_documento
				INNER JOIN pref_unidad_informacion b ON b.id_ui = r.id_ui
				WHERE nro_socio =?");


 	$sth->execute($borrowernumber);

    	while (my $data=$sth->fetchrow_hashref) {
		push(@itemswaiting,$data);
    	}
    	$sth->finish;
    	return (scalar(@itemswaiting),\@itemswaiting);
}


=item
tiene_reservas
Verifica si el item tiene reservas, se saco de C4::AR::Reserves, solo es llamada de delitem.pl, creo q no se va
a usar mas
=cut
sub tiene_reservas {
	my ($id3)=@_;

  	my $dbh = C4::Context->dbh;
  	my $query= "	SELECT * FROM circ_reserva  
			WHERE estado <> 'P'
			AND id3 = ?";

	my $sth=$dbh->prepare($query);

	$sth->execute($id3);

 	my $result="";
        if (my $data = $sth->fetchrow_hashref){ 
		$result=1
	} else {
		 $result=0
	}

        return($result);
}

sub FindNotRegularUsersWithReserves {
	my $dbh = C4::Context->dbh;
	my $query="	SELECT circ_reserva.nro_socio 
			FROM circ_reserva INNER JOIN usr_socio ON circ_reserva.nro_socio = usr_socio.id_socio
			INNER JOIN usr_estado ON usr_estado.id_estado = usr_socio.id_estado
			WHERE usr_estado.regular = '0'
			AND circ_reserva.estado IS NULL";

        my $sth=$dbh->prepare($query);
        $sth->execute();
        my @results;

        while (my $data=$sth->fetchrow){
		push (@results,$data);
        }

        $sth->finish;
        return(@results);
}

=item
mailReservas
Busca todas las reservas que no estan prestadas de una biblioteca, con los usarios que las hicieron.
Para poder mandarles un mail.
=cut
sub mailReservas{
	my ($branch)=@_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("SELECT * FROM circ_reserva 
		INNER JOIN usr_socio ON (circ_reserva.nro_socio=usr_socio.id_socio) 
		LEFT JOIN cat_nivel3 n3 ON (circ_reserva.id3 = n3.id3 )
		INNER JOIN cat_nivel1 n1 ON (n3.id1 = n1.id1)
		WHERE circ_reserva.id_ui=? AND estado <> 'P'");
	$sth->execute($branch);
	my @result;
	while (my $data = $sth->fetchrow_hashref) {
		my $author=getautor($data->{'author'});
		$author=$author->{'completo'};
		$data->{'author'}=$author;
		push @result, $data;
	}
	$sth->finish;
	return(scalar(@result), \@result);

}


=item
Esta funcion ....
Se usa cuando ...
=cut

## FIXME esta funcion se trae de la V2, tratar de modularizar mas y reusar funciones, puede que haya
# consultas repetidas..
sub cambiarReservaEnEspera {
my ($id2,$id3,$responsable)=@_;
	my $dbh=C4::Context->dbh;

	#Tiene una reserva asignada??
	my $query=" SELECT * FROM circ_reserva WHERE (estado <> 'P') AND (id3 = ?) ";
	my $sth=$dbh->prepare($query);
	$sth->execute($id3);
	my $reserva=$sth->fetchrow_hashref;
	
	if($reserva){
	#Tenia una reserva asignada hay que cambiarla
		my $item= getItemsParaReserva($id2); #busco un item libre del grupo
		if ($item) {
		#Hay un ejemplar libre para el usuario
			my $sth2=$dbh->prepare("UPDATE circ_reserva SET id3= ? WHERE id_reserva= ?; ");
			$sth2->execute($item->{'id3'},$reserva->{'reservenumber'});

		}else {
		#NO hay ejemplares libres!!! 
		#Queda algun ejemplar Disponible?? (wthdrawn = 0) y (notforloan = 0)
# 		my $query2="SELECT * FROM nivel3 WHERE id2 = ? and wthdrawn='0' and notforloan = '0'";
		my $query2="SELECT * FROM cat_nivel3 WHERE id2 = ? AND wthdrawn='0' AND notforloan = 'DO'";
		my $sth4=$dbh->prepare($query2);
		$sth4->execute($id2);
		my $disponibles=$sth4->fetchrow_hashref;
			if ($disponibles){
		#Si hay algun ejemplar que se pueda prestar, se debe agregar al principio de la cola de reservas.
				my $query3="UPDATE circ_reserva SET timestamp='0000-00-00 00:00:00', id3 = NULL
					    WHERE id_reserva=? ";
				my $sth5=$dbh->prepare($query3);
				$sth5->execute($reserva->{'reservenumber'});
			}
			else {
			#Cancelar TODAS las reservas!!! No hay mas ejemplares disponibles
			cancelar_todas_las_reservas_de_un_grupo($id2,$responsable);
			}
		}
	
	}

}


=item
Esta funcion cancela todas las reservas que existan sobre el grupo.
Se usa cuando por ej. se elimina o cambia la disponibilidad de los items de un grupo, de manera tal que
ya no queden itemes disponibles en el grupo, entonces se deben cancelar todas las reservas sobre el grupo
=cut

## FIXME esta funcion se trae de la V2, tratar de modularizar mas y reusar funciones, puede que haya
# consultas repetidas..
sub cancelar_todas_las_reservas_de_un_grupo{
my ($id2,$loggedinuser)=@_;

	my $dbh = C4::Context->dbh;

        #Primero busco los datos de las reservas que se quieren borrar
	my $sth=$dbh->prepare("SELECT * FROM circ_reserva WHERE id2 = ? ");
	$sth->execute($id2);
	my @resultado;

	while (my $data=$sth->fetchrow_hashref){
		push (@resultado,$data);
	}

	#Elimino las reservas se estan cancelando
	$sth=$dbh->prepare(" DELETE FROM circ_reserva WHERE id2 = ? ");
	$sth->execute($id2);

	foreach my $data (@resultado){
#**********************************Se registra el movimiento en historicCirculation***************************
		my $id1;
		my $branchcode;

		if($data->{'id3'}){
#ES UNA RESERVA ASIGNADA
# Se borra la sancion correspondiente a la reserva si es que la sancion todavia no entro en vigencia
			my $sth4=$dbh->prepare("	DELETE FROM circ_sancion 
							WHERE reservenumber=? AND (now() < startdate) ");

			$sth4->execute($data->{'reservenumber'});
	
			my $dataItems= C4::AR::Nivel3::getDataNivel3($data->{'id3'});
			$id1= $dataItems->{'id1'};
			$branchcode= $dataItems->{'homebranch'};
		}else{
			my $dataBiblioItems= C4::Circulation::Circ2::getDataBiblioItems($id2);
			$id1= $dataBiblioItems->{'id1'};
			$branchcode= 0;
		}
		
		my $issuetype= '-';
		my $borrowernumber= $loggedinuser;
# 		my $end_date = 'null';
		my $end_date = undef;
		C4::Circulation::Circ2::insertHistoricCirculation(
									'cancel',
									$borrowernumber,
									$loggedinuser,
									$id1,
									$id2,
									$data->{'id3'},
									$branchcode,
									$issuetype,
									$end_date
		); 

	}# end foreach my $data (@resultado)
#******************************Fin****Se registra el movimiento en historicCirculation*************************

}#end sub cancelar_todas_las_reservas_de_un_grupo{



1;
