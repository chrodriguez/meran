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

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);

@EXPORT = qw(
	&t_reservarOPAC
	&t_cancelar_reserva
	&t_cancelar_y_reservar
	&cancelar_reservas
	&verificaciones
	&cant_reservas
	&getReservasDeGrupo
	&cantReservasPorGrupo
	&DatosReservas
	&eliminarReservasVencidas
	&cant_waiting
	&CheckWaiting
	
	&Enviar_Email

	&prestar
);

sub t_reservarOPAC {
	
	my($params)=@_;
	my $reservaGrupo= 0;

	my ($error, $codMsg,$paraMens)= &verificaciones($params);
	
	if(!$error){
	#No hay error
		my $dbh = C4::Context->dbh;
		my ($paramsReserva);
		$dbh->{AutoCommit} = 0;  # enable transactions, if possible
		$dbh->{RaiseError} = 1;
		eval {
			($paramsReserva)= reservar($params);	
			$dbh->commit;
	
			#Se setean los parametros para el mensaje de la reserva SIN ERRORES
			if($paramsReserva->{'estado'} eq 'E'){
			#SE RESERVO CON EXITO UN EJEMPLAR
				$codMsg= 'U302';
				$paraMens->[0]= $paramsReserva->{'desde'};
				$paraMens->[1]= $paramsReserva->{'desdeh'};
				$paraMens->[2]= $paramsReserva->{'hasta'};
				$paraMens->[3]= $paramsReserva->{'hastah'};
			}else{
			#SE REALIZO UN RESERVA DE GRUPO
				$codMsg= 'U303';
				my $borrowerInfo= C4::AR::Usuarios::getBorrowerInfo($params->{'borrowernumber'});
				$paraMens->[0]= $borrowerInfo->{'emailaddress'};
			}	
		};

		if ($@){
			#Se loguea error de Base de Datos
			$codMsg= 'B400';
			&C4::AR::Mensajes::printErrorDB($@, $codMsg,"OPAC");
			eval {$dbh->rollback};
			#Se setea error para el usuario
			$error= 1;
			$codMsg= 'R009';
		}
		$dbh->{AutoCommit} = 1;
		
	}

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"OPAC",$paraMens);
	return ($error, $codMsg, $message);
}

sub t_cancelar_y_reservar {
	
	my($params)=@_;

	my $dbh = C4::Context->dbh;
	my $paramsReserva;
	my ($error, $codMsg,$paraMens);
	
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	eval {
		($error,$codMsg,$paraMens)=cancelar_reserva($params);

		($error, $codMsg,$paraMens)= &verificaciones($params);

		if(!$error){

			($paramsReserva)= reservar($params);	
		
			#Se setean los parametros para el mensaje de la reserva SIN ERRORES
			if($paramsReserva->{'estado'} eq 'E'){
			#SE RESERVO CON EXITO UN EJEMPLAR
				$codMsg= 'U302';
				$paraMens->[0]= $paramsReserva->{'desde'};
				$paraMens->[1]= $paramsReserva->{'desdeh'};
				$paraMens->[2]= $paramsReserva->{'hasta'};
				$paraMens->[3]= $paramsReserva->{'hastah'};
			}else{
			#SE REALIZO UN RESERVA DE GRUPO
				$codMsg= 'U303';
				my $borrowerInfo= C4::AR::Usuarios::getBorrowerInfo($params->{'borrowernumber'});
				$paraMens->[0]= $borrowerInfo->{'emailaddress'};
			}
		}

		$dbh->commit;	
	};

	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B407';
		&C4::AR::Mensajes::printErrorDB($@, $codMsg,"OPAC");
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'R011';
	}
	$dbh->{AutoCommit} = 1;
	

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"OPAC",$paraMens);
	return ($error, $codMsg, $message);
}

sub reservar {
	my($params)=@_;
	my $dateformat = C4::Date::get_date_format();
	my $data;
	$data->{'id3'}= $params->{'id3'};
	if($params->{'tipo'} eq 'OPAC'){
		$data= getItemsParaReserva($params->{'id2'});
	}
	#Numero de dias que tiene el usuario para retirar el libro si la reserva se efectua sobre un item
	my $numeroDias= C4::Context->preference("reserveItem");
	my ($desde,$hasta,$apertura,$cierre)= C4::Date::proximosHabiles($numeroDias,1);

	my %paramsReserva;
	$paramsReserva{'id1'}= $params->{'id1'};
	$paramsReserva{'id2'}= $params->{'id2'};
	$paramsReserva{'id3'}= $data->{'id3'};
	$paramsReserva{'borrowernumber'}= $params->{'borrowernumber'};
	$paramsReserva{'loggedinuser'}= $params->{'loggedinuser'};
	$paramsReserva{'reservedate'}= $desde;
	$paramsReserva{'reminderdate'}= $hasta;
	$paramsReserva{'branchcode'}= C4::Context->preference("defaultbranch");
	$paramsReserva{'estado'}= ($data->{'id3'} ne '')?'E':'G';
	$paramsReserva{'hasta'}= C4::Date::format_date($hasta,$dateformat);
	$paramsReserva{'desde'}= C4::Date::format_date($desde,$dateformat);
	$paramsReserva{'desdeh'}= $apertura;
	$paramsReserva{'hastah'}= $cierre;	
	$paramsReserva{'issuesType'}= $params->{'issuesType'};

	my $reservenumber= insertarReserva(\%paramsReserva);
	$paramsReserva{'reservenumber'}= $reservenumber;

	if( ($data->{'id3'} ne '')&&($params->{'tipo'} eq 'OPAC') ){
	#es una reserva de ITEM, se le agrega una SANCION al usuario al comienzo del dia siguiente
	#al ultimo dia que tiene el usuario para ir a retirar el libro
		my $err= "Error con la fecha";
		my $startdate=  C4::Date::DateCalc($hasta,"+ 1 days",\$err);
		$startdate= C4::Date::format_date_in_iso($startdate,$dateformat);
		my $daysOfSanctions= C4::Context->preference("daysOfSanctionReserves");
		my $enddate=  Date::Manip::DateCalc($startdate, "+ $daysOfSanctions days", \$err);
		$enddate= C4::Date::format_date_in_iso($enddate,$dateformat);

		C4::AR::Sanctions::insertSanction(	undef,
							$reservenumber,
							$params->{'borrowernumber'}, 
							$startdate, 
							$enddate, 
							undef
		);	
	}
	return (\%paramsReserva);
}

sub insertarReserva {
	my($params)=@_;
	my $dbh=C4::Context->dbh;
	my $query="	INSERT INTO reserves 	
			(id3,id2,borrowernumber,reservedate,notificationdate,reminderdate,branchcode,estado) 
			VALUES (?,?,?,?,NOW(),?,?,?) ";
	my $sth2=$dbh->prepare($query);
	$sth2->execute( $params->{'id3'},
			$params->{'id2'},
			$params->{'borrowernumber'},
			$params->{'reservedate'},
			$params->{'reminderdate'},
			$params->{'branchcode'},
			$params->{'estado'}
		);
	#Se obtiene el reservenumber
	my $sth3=$dbh->prepare(" SELECT LAST_INSERT_ID() ");
	$sth3->execute();
	my $reservenumber= $sth3->fetchrow;

#**********************************Se registra el movimiento en historicCirculation***************************
	my $estado;
	if($params->{'estado'} eq 'E'){
	#es una reserva sobre el ITEM
		$estado= 'reserve';
	}else{
	#es una reserva sobre el GRUPO
		$estado= 'queue';
		$params->{'id3'}= 0;
	}

	C4::Circulation::Circ2::insertHistoricCirculation(	$estado,
								$params->{'borrowernumber'},
								$params->{'loggedinuser'},
								$params->{'id1'},
								$params->{'id2'},
								$params->{'id3'},
								$params->{'defaultbranch'},
								$params->{'issuesType'},
								$params->{'reminderdate'}
							);
#*******************************Fin***Se registra el movimiento en historicCirculation*************************
	return $reservenumber;
}#end insertarReserva

sub cancelar_reservas{
# Este procedimiento cancela todas las reservas de los usuarios recibidos como parametro
	my ($loggedinuser,@borrowersnumbers)= @_;

	my $params;
	
	$params->{'loggedinuser'}= $loggedinuser;
	$params->{'tipo'}= 'INTRA';
        my $dbh = C4::Context->dbh;
	foreach (@borrowersnumbers) {
		my $sth=$dbh->prepare("	SELECT id2,reservenumber FROM reserves 
					WHERE borrowernumber = ? AND estado <> 'P'");
		$sth->execute($_);

		$params->{'borrowernumber'}= $_;
		while (my $data= $sth->fetchrow_hashref){
			$params->{'reservenumber'}= $data->{'reservenumber'};
			$params->{'id2'}= $data->{'id2'};
			cancelar_reserva($params);
		}
		
		$sth->finish;
	}
}

sub t_cancelar_reservas_inmediatas{
	my ($params)=@_;
	my $dbh = C4::Context->dbh;
	$dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;
	my $tipo=$params->{'tipo'};
	my $borrowernumber=$params->{'borrowernumber'};
	my $loggedinuser=$params->{'loggedinuser'};
	my ($error,$codMsg,$paraMens);
	eval{
# Este procedimiento cancela todas las reservas con item ya asignado de los usuarios recibidos como parametro
		my $sth=$dbh->prepare("	SELECT reservenumber 
					FROM reserves 
					WHERE borrowernumber = ? AND estado <> 'P' AND id3 IS NOT NULL ");
		$sth->execute($borrowernumber);

		while (my $reservenumber= $sth->fetchrow){
			$params->{'reservenumber'}=$reservenumber;
			($error,$codMsg,$paraMens)=cancelar_reserva($params);
		}
		$sth->finish;
		$dbh->commit;
	};
	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B404';
		C4::AR::Mensajes::printErrorDB($@, $codMsg,$tipo);
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'R010';
	}
	$dbh->{AutoCommit} = 1;
	return($error,$codMsg,$paraMens);
}

=item
t_cancelar_reserva
Transaccion que cancela una reserva.
@params: $params-->Hash con los datos necesarios para poder cancelar la reserva.
=cut
sub t_cancelar_reserva{
	my ($params)=@_;
	my $dbh = C4::Context->dbh;
	$dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;
	my $tipo=$params->{'tipo'};
	my ($error,$codMsg,$paraMens);
	eval{
		($error,$codMsg,$paraMens)=cancelar_reserva($params);
		$dbh->commit;
	};
	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B404';
		C4::AR::Mensajes::printErrorDB($@, $codMsg,$tipo);
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'R010';
	}
	$dbh->{AutoCommit} = 1;
	my $message= &C4::AR::Mensajes::getMensaje($codMsg,$tipo,$paraMens);
	return($error,$codMsg,$message);
}


=item
cancelar_reserva
Funcion que cancela una reserva
=cut
sub cancelar_reserva{
	my ($params)=@_;
	my $dbh= C4::Context->dbh;
	my $reservenumber=$params->{'reservenumber'};
	my $borrowernumber=$params->{'borrowernumber'};
	my $loggedinuser=$params->{'loggedinuser'};
	my $error=0;
	my $codMsg;
	my $paraMens;
	my $reserva=getDatosReserva($reservenumber);
	my $id2=$reserva->{'id2'};
	my $id3=$reserva->{'id3'};
	if($id3){
#Si la reserva que voy a cancelar estaba asociada a un item tengo que reasignar ese item a otra reserva para el mismo grupo
		my $reservaGrupo=getDatosReservaEnEspera($id2);
		if($reservaGrupo){
			$reservaGrupo->{'branchcode'}=$reserva->{'branchcode'};
			$reservaGrupo->{'borrowernumber'}=$borrowernumber;
			$reservaGrupo->{'loggedinuser'}=$loggedinuser;
			actualizarDatosReservaEnEspera($reservaGrupo);
		}
# Se borra la sancion correspondiente a la reserva si es que la sancion todavia no entro en vigencia
		C4::AR::Sanctions::borrarSancionReserva($reservenumber);
	}
#**********************************Se registra el movimiento en historicSanction***************************
	#traigo la info de la sancion
	my $infoSancion= &C4::AR::Sanctions::infoSanction($reservenumber);
	my $sanctiontypecode= 'null';
	my $fechaFinSancion= $infoSancion->{'enddate'};
	C4::AR::Sanctions::logSanction('Insert',$borrowernumber,$loggedinuser,$fechaFinSancion,$sanctiontypecode);
#**********************************Fin registra el movimiento en historicSanction***************************

#Actualizo la sancion para que refleje el id3 y asi poder informalo
	C4::AR::Sanctions::actualizarSancion($id3,$reservenumber);

#Haya o no uno esperando elimino el que existia porque la reserva se esta cancelando
	borrarReserva($reservenumber);

#**********************************Se registra el movimiento en historicCirculation***************************
	my $id1;
	my $branchcode=$reserva->{'branchcode'};
# 	if($id3){
# 		my $dataItems= C4::Circulation::Circ2::getDataItems($id3);
# 		$id1= $dataItems->{'id1'};
# 		$branchcode= $dataItems->{'homebranch'};
# 	}else{
		my $dataBiblioItems= C4::Circulation::Circ2::getDataBiblioItems($id2);
		$id1= $dataBiblioItems->{'id1'};
# 		$branchcode= 0;
# 	}
	my $issuetype= '-';
	my $end_date = 'null';
	C4::Circulation::Circ2::insertHistoricCirculation('cancel',$borrowernumber,$loggedinuser,$id1,$id2,$id3,$branchcode,$issuetype,$end_date); #C4::Circulation::Circ2
#******************************Fin****Se registra el movimiento en historicCirculation*************************

	return($error,$codMsg,$paraMens);
}

=item
getDatosReserva
Funcion que retorna la informacion de la reserva con el numero que se le pasa por parametro.
=cut
sub getDatosReserva{
	my ($reservenumber)=@_;
	my $dbh=C4::Context->dbh;
	my $sth=$dbh->prepare("	SELECT * 
				FROM reserves 
				WHERE reservenumber= ? FOR UPDATE");

	$sth->execute($reservenumber);
	return($sth->fetchrow_hashref);
}

=item
getDatosReservaEnEspera
Funcion que trae los datos de la primer reserva de la cola que estaba esperando que se desocupe un ejemplar del grupo devuelto o cancelado.
=cut
sub getDatosReservaEnEspera{
	my ($id2)=@_;
	my $dbh=C4::Context->dbh;
	my $sth=$dbh->prepare("	SELECT *
				FROM reserves
				WHERE id2=? AND id3 IS NULL
				ORDER BY timestamp LIMIT 1 ");
	$sth->execute($id2);
	return($sth->fetchrow_hashref);
}

=item
actualizarDatosReservaEnEspera
Funcion que actualiza la reserva que estaba esperando por un ejemplar.
=cut
sub actualizarDatosReservaEnEspera{
	my ($reservaGrupo)=@_;
	my $dbh=C4::Context->dbh;
	my $id2=$reservaGrupo->{'id2'};
	my $id3=$reservaGrupo->{'id3'};
	my $borrowernumber=$reservaGrupo->{'borrowernumber'};
	my $loggedinuser=$reservaGrupo->{'loggedinuser'};
	my ($desde,$fecha,$apertura,$cierre)=C4::Date::proximosHabiles(C4::Context->preference("reserveGroup"),1);
	my $sth=$dbh->prepare("UPDATE reserves 
			SET id3=?, reservedate=?, notificationdate=NOW(), reminderdate=?, branchcode=?, estado='E'
			WHERE id2=? AND borrowernumber=? ");
	$sth->execute($id3, $desde, $fecha,$reservaGrupo->{'branchcode'},$id2,$borrowernumber);

#**********************************Se registra el movimiento en historicCirculation***************************
	my $dataItems= C4::Circulation::Circ2::getDataItems($id3);
	my $id1= $dataItems->{'id1'};
	my $issuecode= '-';
	C4::Circulation::Circ2::insertHistoricCirculation('notification',$borrowernumber,$loggedinuser,$id1,$id2,$id3,$reservaGrupo->{'branchcode'},$issuecode,$fecha);
#********************************Fin**Se registra el movimiento en historicCirculation*************************

# Se agrega una sancion que comienza el dia siguiente al ultimo dia que tiene el usuario para ir a retirar el libro
	my $err= "Error con la fecha";
	my $dateformat=C4::Date::get_date_format();
	my $startdate= C4::Date::DateCalc($fecha,"+ 1 days",\$err);
	$startdate= C4::Date::format_date_in_iso($startdate,$dateformat);
	my $daysOfSanctions= C4::Context->preference("daysOfSanctionReserves");
	my $enddate= C4::Date::DateCalc($startdate, "+ $daysOfSanctions days", \$err);
	$enddate= C4::Date::format_date_in_iso($enddate,$dateformat);
	C4::AR::Sanctions::insertSanction(undef, $reservaGrupo->{'reservenumber'} ,$borrowernumber, $startdate, $enddate, undef);

	my $sth3=$dbh->prepare("commit");
	$sth3->execute();

	Enviar_Email($id3,$borrowernumber,$desde, $fecha, $apertura,$cierre,$loggedinuser);
}

=item
borrarReserva
Funcion que elimina la reserva de la base de datos.
=cut
sub borrarReserva{
	my ($reservenumber)=@_;
	my $dbh=C4::Context->dbh;
	my $sth=$dbh->prepare("DELETE FROM reserves WHERE reservenumber=?");
	$sth->execute($reservenumber);
}

=item
DatosReservas
Busca todas las reservas que tiene el usuario que llega como parametro, trae todo los datos de los documentos asociados a la reserva.
=cut
sub DatosReservas {
	my ($bor)=@_;
	my $dbh = C4::Context->dbh;
# FALTAN!!!!!!!!!!!!!!!!!!!!!!
# biblioitems.volume as volume, biblioitems.volumeddesc as volumeddesc

	my $query= "	SELECT n1.titulo as rtitulo, n1.id1 as rid1, n1.autor as rautor, 
			a.completo as nomCompleto, r.id2 as rid2, r.reservedate as rreservedate, 
			r.notificationdate as rnotificationdate,r.reminderdate as rreminderdate, r.reservenumber,
			r.estado, n2.anio_publicacion as rpublicationyear, r.id3 as rid3, r.branchcode as rbranch
			FROM reserves r
			INNER JOIN nivel2 n2 ON  n2.id2 = r.id2
			INNER JOIN nivel1 n1 ON n2.id1 = n1.id1 
			LEFT JOIN autores a ON (a.id = n1.autor)
			WHERE r.borrowernumber = ?
			AND cancellationdate is NULL AND r.estado <> 'P' ";
	
	my $sth=$dbh->prepare($query);
	$sth->execute($bor);
	my $dateformat = C4::Date::get_date_format();
	my @results;
	while (my $data=$sth->fetchrow_hashref){
		$data->{'rreminderdate'}=C4::Date::format_date($data->{'rreminderdate'},$dateformat);
		$data->{'rreservedate'}=C4::Date::format_date($data->{'rreservedate'},$dateformat);
		$data->{'rnotificationdate'}= C4::Date::format_date($data->{'rnotificationdate'},$dateformat);
		$data->{'redicion'}=C4::AR::Busquedas::buscarDatoDeCampoRepetible($data->{'rid2'},"250","a","2");#VER SI QUEDA!!!!!!!!!!!!!!!!!!
		push (@results,$data);
	}
	
	$sth->finish;
	return($#results+1,\@results);
}

=item
datosReservaRealizada
Trae los datos de todo el nivel2 (y nivel2_repetibles) con el nivel1 para la reserva que realizo el usuario.
=cut
sub datosReservaRealizada{
	my ($id2)=@_;
	my $dbh = C4::Context->dbh;

	my $query="SELECT * FROM nivel2 n2 INNER JOIN nivel1 n1 ON (n2.id1=n1.id1)
		   LEFT JOIN nivel2_repetibles n2r ON (n2.id2=n2r.id2) 
		   WHERE n2.id2=?";

	my $sth=$dbh->prepare($query);
	$sth->execute($id2);
	my @results;
	while (my $data=$sth->fetchrow_hashref){

		push (@results,$data);
	}
	
	$sth->finish;
}

sub getNotForLoan{
#Devuelve la disponibilidad del item ('SA'= Sala, 'DO'= Domiciliaria)
	my ($id3)=@_;	
	my $dbh = C4::Context->dbh;
	my $query= "	SELECT notforloan
			FROM nivel3
			WHERE (id3 = ?)";
	my $sth=$dbh->prepare($query);
	$sth->execute($id3);
	return $sth->fetchrow();
}

=item
verificarTipoReserva
Verifica que el usuario no reserve un item que ya tenga una reserva para el mismo grupo y para el mismo tipo de prestamo
=cut
sub verificarTipoReserva {
	my ($borrowernumber, $id2, $id3, $tipo)=@_;
	my $error= 0;
	my ($cant, $reservas)= getReservasDeBorrower($borrowernumber, $id2);
#Se intento reservar desde el OPAC sobre el mismo GRUPO
	if ($cant == 1){$error= 1;}
	return ($error);
}

sub getReservasDeBorrower {
#devuelve las reservas de grupo del usuario
	my ($borrowernumber, $id2)=@_;
	my $dbh = C4::Context->dbh;
	my $query= "	SELECT *
			FROM reserves
			WHERE (borrowernumber = ?) AND (id2 = ?)
			AND (estado <> 'P')";
	my $sth=$dbh->prepare($query);
	$sth->execute($borrowernumber, $id2);

	my @results;
	my $cant= 0;
	while (my $data=$sth->fetchrow_hashref){
		push (@results,$data);
		$cant++;
	}
	$sth->finish;
	return($cant,\@results);
}

sub getReservasDeId2 {
#devuelve las reservas de grupo
	my ($id2)=@_;
	my $dbh = C4::Context->dbh;
	my $query= "	SELECT *
			FROM reserves
			WHERE (id2 = ?) AND (estado <> 'P')";
	my $sth=$dbh->prepare($query);
	$sth->execute($id2);

	my @results;
	my $cant= 0;
	while (my $data=$sth->fetchrow_hashref){
		push (@results,$data);
		$cant++;
	}
	$sth->finish;
	return($cant,\@results);
}

sub getReservaDeId3{
	#devuelve las reservas del item
	my ($id3)=@_;
	my $dbh = C4::Context->dbh;
	
	my $sth=$dbh->prepare("SELECT * FROM reserves WHERE id3 = ? ");
	$sth->execute($id3);
	return ($sth->fetchrow_hashref);
}

sub cant_reservas{
#Cantidad de reservas totales de GRUPO y EJEMPLARES
        my ($bor)=@_;
        my $dbh = C4::Context->dbh;
        my $query="	SELECT count(*) as cant FROM reserves"; 
        $query .= " 	WHERE  borrowernumber = ? 
                        AND cancellationdate IS NULL AND estado <> 'P'";

        my $sth=$dbh->prepare($query);
        $sth->execute($bor);
        my $result=$sth->fetchrow();
        $sth->finish;

        return($result);
}

sub cantReservasPorGrupo{
#Devuelve la cantidad de reservas realizadas (SIN PRESTAR) sobre un GRUPO
   my ($id2)=@_;
   my $dbh = C4::Context->dbh;
   my $sth=$dbh->prepare("	SELECT  count(*) as reservas
                       		FROM reserves
                       		WHERE id2 =? AND estado <> 'P' ");
   $sth->execute($id2);
   return $sth->fetchrow;
}

sub cantReservasPorNivel1{
#Devuelve la cantidad de reservas realizadas (SIN PRESTAR) sobre el nivel1
   my ($id1)=@_;
   my $dbh = C4::Context->dbh;
   my $sth=$dbh->prepare("	SELECT  count(*) as reservas
                       		FROM reserves r INNER JOIN nivel2 n2 ON (r.id2 = n2.id2)
                       		WHERE n2.id1 =? AND estado <> 'P' ");
   $sth->execute($id1);
   return $sth->fetchrow;
}

sub getItemsParaReserva{
#Busca los items sin reservas para los prestamos y nuevas reservas.
	my ($id2)=@_;
        my $dbh = C4::Context->dbh;

	my $query= "	SELECT n3.id1, n3.id3, n3.holdingbranch 
			FROM nivel3 n3 WHERE n3.id2 = ? AND n3.notforloan='DO' AND n3.wthdrawn='0' 
			AND n3.id3 NOT IN (SELECT reserves.id3 FROM reserves 
			WHERE id2 = ? AND id3 IS NOT NULL)";#SE SACO!!!!!!!!!! FOR UPDATE ";

	my $sth=$dbh->prepare($query);
	$sth->execute($id2, $id2);

	return $sth->fetchrow_hashref;

}

sub getDisponibilidadGrupo{
#Busca los items sin reservas para los prestamos y nuevas reservas.
	my ($id2)=@_;
        my $dbh = C4::Context->dbh;

	my $query= "	SELECT count(*) as disponibilidad
			FROM nivel2 n2 INNER JOIN nivel3 n3 ON (n2.id2 = n3.id2)
			WHERE (n2.id2 = ?) AND (n3.notforloan = 'DO') ";

	my $sth=$dbh->prepare($query);
	$sth->execute($id2);

		

	return ($sth->fetchrow > 0)?'DO':'SA';
}

sub verificaciones {
	my($params)=@_;

	my $tipo= $params->{'tipo'}; #INTRA u OPAC
	my $id2= $params->{'id2'};
	my $id3= $params->{'id3'};
	my $barcode= $params->{'barcode'};
	my $borrowernumber= $params->{'borrowernumber'};
	my $loggedinuser= $params->{'loggedinuser'};
	my $issueType= $params->{'issuesType'};
	my $error= 0;
	my $codMsg= '000';
	my @paraMens;
	my $dateformat=C4::Date::get_date_format();

open(A,">>/tmp/debugVerif.txt");#Para debagear en futuras pruebas para saber por donde entra y que hace.
print A "tipo: $tipo\n";
print A "id2: $id2\n";
print A "id3: $id3\n";
print A "borrowernumber: $borrowernumber\n";
print A "issueType: $issueType\n";
#Se verifica que el usuario sea Regular
	if( !&C4::AR::Usuarios::esRegular($borrowernumber) ){
		$error= 1;
		$codMsg= 'U300';
print A "Entro al if de regularidad\n";
	}

#Se verifica que el usuario halla realizado el curso, segun preferencia del sistema.
	my $infoBorr=C4::AR::Usuarios::getBorrowerInfo($borrowernumber);
	if( !($error) && ($tipo eq "OPAC") && (C4::Context->preference("usercourse")) && ($infoBorr->{'usercourse'} == "NULL" ) ){
		$error= 1;
		$codMsg= 'U304';
print A "Entro al if del curso en el opac\n";
	}

#Se verifica que el usuario no tenga el maximo de prestamos permitidos para el tipo de prestamo.
#SOLO PARA INTRA, ES UN PRESTAMO INMEDIATO.
	if( !($error) && $tipo eq "INTRA" &&  verificarMaxTipoPrestamo($borrowernumber, $issueType) ){
		$error= 1;
		$codMsg= 'P101';
		$paraMens[0]=$params->{'descripcionTipoPrestamo'};
		$paraMens[1]=$barcode;
print A "Entro al if que verifica la cantidad de prestamos";
	}

#Se verifica si es un prestamo especial este dentro de los horarios que corresponde.
#SOLO PARA INTRA, ES UN PRESTAMO ESPECIAL.
	if(!$error && $tipo eq "INTRA" && $issueType eq 'ES' && verificarHorario()){
		$error=1;
		$codMsg='P102';
print A "Entro al if de prestamos especiales";
	}
#Se verfica si el usuario esta sancionado
	my ($sancionado,$fechaFin)= C4::AR::Sanctions::permitionToLoan($borrowernumber, $issueType);
print A "sancionado: $sancionado ------ fechaFin: $fechaFin\n";
	if( !($error) && ($sancionado||$fechaFin) ){
		$error= 1;
		$codMsg= 'S200';
		$paraMens[0]=C4::Date::format_date($fechaFin,$dateformat);
print A "Entro al if de sanciones";
	}
#Se verifica que el usuario no intente reservar desde el OPAC un item para SALA
	if(!$error && $tipo eq "OPAC" && getDisponibilidadGrupo($id2) eq 'SA'){
		$error=1;
		$codMsg='R007';
print A "Entro al if de prestamos de sala";
	}

#Se verifica que el usuario no tenga dos reservas sobre el mismo grupo para el mismo tipo prestamo
	if( !($error) && ($tipo eq "OPAC") && (&verificarTipoReserva($borrowernumber, $id2, $id3, $tipo)) ){
		$error= 1;
		$codMsg= 'R002';
print A "Entro al if de reservas iguales, sobre el mismo grupo y tipo de prestamo";
	}

#Se verifica que el usuario no supere el numero maximo de reservas posibles seteadas en el sistema desde OPAC
	if( !($error) && ($tipo eq "OPAC") && (C4::AR::Usuarios::llegoMaxReservas($borrowernumber))){
		$error= 1;
		$codMsg= 'R001';
		$paraMens[0]=C4::Context->preference("maxreserves");
print A "Entro al if de maximo de reservas desde OPAC";
	}

#Se verifica que el usuario no tenga dos prestamos sobre el mismo grupo para el mismo tipo prestamo
	if( !($error) && (&C4::AR::Issues::getCountPrestamosDeGrupo($borrowernumber, $id2, $issueType)) ){
		$error= 1;
		$codMsg= 'P100';
print A "Entro al if de prestamos iguales, sobre el mismo grupo y tipo de prestamo";
	}
print A "\n\n";
print A "error: $error ---- codMsg: $codMsg\n\n\n\n";
close(A);
	return ($error, $codMsg,\@paraMens);
}

#Esta funcion se utiliza para verificar post condiciones luego de un prestamo
sub verificacionesPostPrestamo {
	my($params)=@_;

	my $id2= $params->{'id2'};
	my $id3= $params->{'id3'};
	my $barcode= $params->{'barcode'};
	my $borrowernumber= $params->{'borrowernumber'};
	my $loggedinuser= $params->{'loggedinuser'};
	my $issueType= $params->{'issuesType'};
	my $error= 0;
	my $codMsg= 'P103'; # Se realizo el prestamo con exito
	my $paraMens;
	my $dateformat=C4::Date::get_date_format();
	$paraMens->[0]= $barcode;
open(A,">>/tmp/debugVerif.txt");#Para debagear en futuras pruebas para saber por donde entra y que hace.
print A "desde verificacionesPostPrestamo\n";
print A "id2: $id2\n";
print A "id3: $id3\n";
print A "borrowernumber: $borrowernumber\n";
print A "issueType: $issueType\n";

#Se verifica si el usuario llego al maximo de prestamos, se caen las demas reservas
if ($issueType eq "DO"){
# FIXME VER SI ES NECESARIO VERIFICAR OTROS TIPOS DE PRESTAMOS COMO POR EJ "DP", "DD", "DR"
	my ($cant, @issuetypes) = C4::AR::Issues::PrestamosMaximos($borrowernumber);
	foreach my $iss (@issuetypes){
		if ($iss->{'issuecode'} eq "DO"){#Domiciliario al maximo
			$codMsg= 'P108';
			$params->{'tipo'}="INTRA";
			($error,$codMsg,$paraMens)=C4::AR::Reservas::t_cancelar_reservas_inmediatas($params);
		}
	}
}

print A "error: $error ---- codMsg: $codMsg\n\n\n\n";
close(A);
	return ($error, $codMsg,$paraMens);
}


sub verificarMaxTipoPrestamo{
	my ($borrowernumber,$issuetype)=@_;
	my $error=0;
	my $dbh=C4::Context->dbh;
	my $sth=$dbh->prepare("SELECT maxissues FROM issuetypes WHERE issuecode = ? ");
	$sth->execute($issuetype);
	my $maxissues= $sth->fetchrow;
	$sth->finish;
	my ($cantissues, $issues)= C4::AR::Issues::DatosPrestamosPorTipo($borrowernumber,$issuetype);
	if ($cantissues >= $maxissues) {$error=1}
	return $error;
}


sub verificarHorario{
	my $end = ParseDate(C4::Context->preference("close"));
	my $begin =calc_beginES();
	my $actual=ParseDate("today");
	my $error=0;
	if ((Date_Cmp($actual, $begin) < 0) || (Date_Cmp($actual, $end) > 0)){$error=1;}
	return $error;
}

sub intercambiarId3{
	my ($borrowernumber, $id2, $id3, $oldid3)= @_;
        my $dbh = C4::Context->dbh;

	my $sth=$dbh->prepare("SELECT id3, estado FROM reserves WHERE id3=? FOR UPDATE ");
	$sth->execute($id3);
	my $data= $sth->fetchrow_hashref;
	my $error=0;
	my $codMsg='000';

	if ($data && $data->{'estado'} eq "E"){ 
		#quiere decir que hay una reserva sobre el itemnumber y NO esta prestado el item
		$sth=$dbh->prepare("UPDATE reserves SET id3= ? WHERE id3 = ?");
		$sth->execute($oldid3, $id3);
		#actualizo la reserva con el viejo id3 para la reserva del otro usuario.
	}
	if($data->{'estado'} eq "P"){
		$error=1; #El item esta prestado a otro usuario
		$codMsg='P107';
	}
	else{
		#el item con id3 esta libre se actualiza la reserva del usuario al que se va a prestar el item.
		$sth=$dbh->prepare("UPDATE reserves SET id3= ? WHERE id2=? AND borrowernumber=?");
		$sth->execute($id3, $id2, $borrowernumber);
	}

	return ($error,$codMsg);
}

sub cambiarId3 {
	my ($id3Libre,$reservenumber)=@_;
	my $dbh = C4::Context->dbh;
	my $query="UPDATE reserves SET id3= ? WHERE reservenumber = ?";
	my $sth=$dbh->prepare($query);
	$sth->execute($id3Libre,$reservenumber);
}


sub prestar{
	my ($params)=@_;
	
	my ($error,$codMsg,$paraMens)= &verificaciones($params);
	if(!$error){
	#No hay error
		my $dbh=C4::Context->dbh;
		$dbh->{AutoCommit} = 0;
		$dbh->{RaiseError} = 1;
		eval{
			($error, $codMsg, $paraMens)= chequeoParaPrestamo($params);
			$dbh->commit;
		};
		if ($@){
			#Se loguea error de Base de Datos
			$codMsg= 'B401';
			C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
			eval {$dbh->rollback};
			#Se setea error para el usuario
			$error= 1;
			$codMsg= 'P106';
		}
		$dbh->{AutoCommit} = 1;
	}
	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
	return ($error, $codMsg, $message);
}

sub chequeoParaPrestamo {
open(A,">>/tmp/debugChequeo.txt");
	my($params)=@_;
	my $dbh=C4::Context->dbh;

	my $borrowernumber= $params->{'borrowernumber'};
	my $id2= $params->{'id2'};
	my $id3= $params->{'id3'};
	my ($error, $codMsg, $paraMens);
print A "id2: $id2\n";
print A "id3: $id3\n";
#Se verifica si ya se tiene la reserva sobre el grupo
	my ($cant, $reservas)= getReservasDeBorrower($borrowernumber, $id2);# ver lo que sigue.
	$params->{'reservenumber'}= $reservas->[0]->{'reservenumber'};
print A "reservenumber de reserva: $reservas->[0]->{'reservenumber'}\n";
#********************************        VER!!!!!!!!!!!!!! *************************************************
# Si tiene un ejemplar prestado de ese grupo no devuelve la reserva porque en el where estado <> P, Salta error cuando se quiere crear una nueva reserva por el else de abajo. El error es el correcto, pero se puede detectar antes.
# Tendria que devolver todas las reservas y despues verificar los tipos de prestamos de cada ejemplar (notforloan)
# Si esta prestado la clase de prestamo que se quiere hacer en este momento. 
# Si no esta prestado se puede hacer lo de abajo, lo que sigue (estaba pensado para esa situacion).
# Tener en cuenta los prestamos especiales, $issueType ==> ES ---> SA. **** VER!!!!!!
	my $disponibilidad=getNotForLoan($id3);
	if($cant == 1 && $disponibilidad eq "DO"){
		#El usuario ya tiene la reserva
# 		($error, $codMsg, $paraMens)= &verificaciones($params);
# 		if(!$error){
#Se intercambiaron los id3 de las reservas, si el item que se quiere prestar esta prestado se devuelve el error.
		if($id3 != $reservas->[0]->{'id3'}){
		#Los ids son distintos, se intercambian.
			($error,$codMsg)=&intercambiarId3($borrowernumber,$id2,$id3,$reservas->{'id3'});
		}
# 		}
	}
	elsif($cant==1 && $disponibilidad eq "SA"){
# 		FALTA!!! SE PUEDE PONER EN EL ELSE???	
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
				&cambiarId3($datosNivel3->{'id3'},$data->{'reservenumber'});
# 				el id3 de params quedo libre para ser reservado
			}
			else{
# 				NO HAY EJEMPLARES LIBRES PARA EL PRESTAMO, SE PONE EL ID3 EN "" PARA QUE SE 					REALIZE UNA RESERVA DE GRUPO, SI SE PERMITE.
				$params->{'id3'}="";
				if(!C4::Context->preference('intranetGroupReserve')){
					$sePermiteReservaGrupo=0;
					$error=1;#Hay error no se permite realizar una reserva de grupo en intra.
					$codMsg='R004';
				}else{
					$codMsg='R005';#No hay error, se realiza una reserva de grupo.
					#Se verifica que el usuario no supere el numero maximo de reservas posibles seteadas en el sistema
					if( C4::AR::Usuarios::llegoMaxReservas($borrowernumber) ){
						$error= 1;
						$codMsg= 'R001';
						$paraMens->[0]=C4::Context->preference("maxreserves");
						$sePermiteReservaGrupo= 0;
					}

				}
			}
		}
		#Se realiza una reserva
		if($sePermiteReservaGrupo){
			my ($paraReservas)= reservar($params);
			$params->{'reservenumber'}= $paraReservas->{'reservenumber'};
		}
	}
	#Se verifica datos del prestamo
	#Se realiza el pretamo
	if(!$error){
		insertarPrestamo($params);

		($error, $codMsg, $paraMens)=verificacionesPostPrestamo($params);
	}
close(A);
	return ($error, $codMsg, $paraMens);
}

sub insertarPrestamo {

	my($params)=@_;
	my $dbh=C4::Context->dbh;

#Se acutualiza el estado de la reserva a P = Presetado
	my $sth=$dbh->prepare("	UPDATE reserves SET estado='P' WHERE id2 = ? AND borrowernumber = ? ");

	$sth->execute(	$params->{'id2'},
			$params->{'borrowernumber'}
	);

# Se borra la sancion correspondiente a la reserva porque se esta prestando el biblo

	my $sth2=$dbh->prepare("	DELETE FROM sanctions 
					WHERE reservenumber = ? ");

	$sth2->execute(	$params->{'reservenumber'});

#Se realiza el prestamo del item
	my $sth3=$dbh->prepare("	INSERT INTO issues 		
					(borrowernumber,id3,date_due,branchcode,issuingbranch,renewals,issuecode) 
					VALUES (?,?,NOW(),?,?,?,?) ");

	$sth3->execute(	$params->{'borrowernumber'}, 
			$params->{'id3'}, 
			$params->{'defaultbranch'}, 
			$params->{'defaultbranch'}, 
			0, 
			$params->{'issuesType'}
	);

#**********************************Se registra el movimiento en historicCirculation***************************
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
	my ($id3,$bor,$desde, $fecha, $apertura,$cierre,$loggedinuser)=@_;

	if (C4::Context->preference("EnabledMailSystem")){
		my $dbh = C4::Context->dbh;
		my $dateformat = C4::Date::get_date_format();
		my $sth=$dbh->prepare("Select * from borrowers where borrowernumber=?;");
		$sth->execute($bor);
		my $borrower= $sth->fetchrow_hashref;
# biblio.unititle as runititle, biblioitems.number as redicion FALTA NO ESTAN LOS DATOS EN LAS TABLAS!!!!
		$sth=$dbh->prepare("SELECT n1.titulo,n1.id1 as rid1,n1.autor,reserves.id2 as rid2,
				FROM reserves INNER JOIN nivel2 n2 ON n2.id3 = reserves.id3
				INNER JOIN nivel1 n1 ON n2.id1 = n1.id1 
				WHERE  reserves.borrowernumber =? and reserves.id3= ? ");
		$sth->execute($bor,$id3);
		my $res= $sth->fetchrow_hashref;

		my $mailFrom=C4::Context->preference("reserveFrom");
		my $mailSubject =C4::Context->preference("reserveSubject");
		my $mailMessage =C4::Context->preference("reserveMessage");
		my $branchname= C4::Search::getbranchname($borrower->{'branchcode'});
		$res->{'rauthor'}=(C4::Search::getautor($res->{'autor'}))->{'completo'};

		$mailSubject =~ s/BRANCH/$branchname/;
		$mailMessage =~ s/BRANCH/$branchname/;
		$mailMessage =~ s/FIRSTNAME/$borrower->{'firstname'}/;
		$mailMessage =~ s/SURNAME/$borrower->{'surname'}/;
		$mailMessage =~ s/UNITITLE/$res->{'runititle'}/;
		$mailMessage =~ s/TITLE/$res->{'titulo'}/;
		$mailMessage =~ s/AUTHOR/$res->{'rauthor'}/;
		$mailMessage =~ s/EDICION/$res->{'redicion'}/;
		$mailMessage =~ s/a2/$apertura/;
		$desde=C4::Date::format_date($desde,$dateformat);
		$mailMessage =~ s/a1/$desde/;
		$mailMessage =~ s/a3/$cierre/;
		$fecha=C4::Date::format_date($fecha,$dateformat);
		$mailMessage =~ s/a4/$fecha/;
		my %mail = ( To => $borrower->{'emailaddress'},
                        From => $mailFrom,
                        Subject => $mailSubject,
                        Message => $mailMessage);
		my $resultado='ok';
		if ($borrower->{'emailaddress'} && $mailFrom ){
			sendmail(%mail) or die $resultado='error';
		}else {$resultado='';}

=item
#**********************************Se registra el movimiento en historicCirculation***************************
my $issuetype= '-';
my $dataItems= C4::Circulation::Circ2::getDataItems($itemnumber);
my $branchcode= $dataItems->{'homebranch'};
my $end_date= $fecha;
C4::Circulation::Circ2::insertHistoricCir$itemnumberculation('notification',$bor,$loggedinuser,$res->{'rbiblionumber'},$res->{'rbiblioitemnumber'},$itemnumber,$branchcode,$issuetype,$end_date);
#*******************************Fin***Se registra el movimiento en historicCirculation*************************
=cut

	}#end if (C4::Context->preference("EnabledMailSystem"))
}


#esta funcion se saco de Reserves, se cambiaron los nombres de los campos para que se adapten a la V3, pero faltaria revisar el codigo!!!!!!!!!!!!!!!!!!!!!!
sub eliminarReservasVencidas(){
	my ($loggedinuser)=@_;
	my $dbh = C4::Context->dbh;

	my $query= "	SELECT * 
			FROM reserves 
			WHERE estado <> 'P' AND reminderdate < NOW() AND id3 IS NOT NULL";

	my $sth=$dbh->prepare($query);
	$sth->execute();
	#Se buscan si hay reservas esperando sobre el grupo que se va a elimninar la reservas vencidas
	my @resultado;
	while(my $data=$sth->fetchrow_hashref){
		my $sth1=$dbh->prepare("	SELECT * 
						FROM reserves WHERE id2=? AND id3 is NULL 
						ORDER BY timestamp LIMIT 1 ");

		$sth1->execute($data->{'id2'});
		my $data2= $sth1->fetchrow_hashref;
		if ($data2) { #Quiere decir que hay reservas esperando para este mismo grupo
			@resultado= ($data->{'id3'}, $data2->{'id2'}, $data2->{'borrowernumber'});
		}

#**********************************Se registra el movimiento en historicSanction***************************
		my $infoSancion= &infoSanction($data->{'reservenumber'});
		my $fechaFinSancion= $infoSancion->{'enddate'};

		my $responsable= $loggedinuser;
		my $sanctiontypecode= 'null';
		my $borrowernumber= $data->{'borrowernumber'};

		logSanction('Insert',$borrowernumber,$responsable,$fechaFinSancion,$sanctiontypecode);
#**********************************Fin registra el movimiento en historicSanction***************************

		#Actualizo la sancion para que refleje el itemnumber y asi poder informalo
		my $sth6=$dbh->prepare(" UPDATE sanctions SET id3 = ? WHERE reservenumber = ? ");
		$sth6->execute($data->{'id3'},$data->{'reservenumber'});

		#Haya o no uno esperando elimino el que existia porque la reserva se esta cancelando
		my $sth3=$dbh->prepare("DELETE FROM reserves WHERE reservenumber=? ");
		$sth3->execute($data->{'reservenumber'});


		if (@resultado){
		#esto quiere decir que se realizo un movimiento de asignacion de item a una reserva que estaba en espera en la base, hay que actualizar las fechas y notificarle al usuario
			my ($desde,$fecha,$apertura,$cierre)=proximosHabiles(C4::Context->preference("reserveGroup"),1);
			my $sth4=$dbh->prepare("UPDATE reserves 
						SET id3=?, reservedate=?, notificationdate=NOW(), reminderdate=? 
						WHERE id2=? AND borrowernumber=? ");

			$sth4->execute($resultado[0], $desde, $fecha,$resultado[1],$resultado[2]);
			Enviar_Email($resultado[0],$resultado[2],$desde, $fecha, $apertura,$cierre,$loggedinuser);
			
#**********************************Se registra el movimiento en historicCirculation***************************
		my $itemnumber= $resultado[0];
		my $dataItems= C4::Circulation::Circ2::getDataItems($itemnumber);
		my $biblionumber= $dataItems->{'id1'};
		my $biblioitemnumber= $dataItems->{'id2'};
		my $end_date= $fecha;
		my $issuecode= '-';
		my $borrnum= $resultado[2];
	
		C4::Circulation::Circ2::insertHistoricCirculation('notification',$borrnum,$loggedinuser,$biblionumber,$biblioitemnumber,$itemnumber,$data->{'branchcode'},$issuecode,$end_date);
#********************************Fin**Se registra el movimiento en historicCirculation*************************

		}
	}

}

=item
Esta funcion retorna la cantidad de reservas en espera
=cut
sub cant_waiting{
        my ($borrowernumber)=@_;

        my $dbh = C4::Context->dbh;
        my $query="	SELECT count(*) as cant from reserves
   			WHERE borrowernumber = ?
			AND cancellationdate is NULL
			AND estado <> 'P'
			AND id3 is Null ";

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

	my $sth=$dbh->prepare("	SELECT n3.barcode, n1.titulo, b.branchname, n2.id2, it.description, r. * 
				FROM reserves r
				INNER JOIN nivel3 n3 ON r.id3 = n3.id3
				INNER JOIN nivel1 n1 ON n1.id1 = n3.id1
				INNER JOIN nivel2 n2 ON n1.id1 = n2.id1 AND n3.id2 = n2.id2
				INNER JOIN itemtypes it ON it.itemtype = n2.tipo_documento
				INNER JOIN branches b ON b.branchcode = r.branchcode
				WHERE borrowernumber =? AND cancellationdate IS NULL");

 	$sth->execute($borrowernumber);

    	while (my $data=$sth->fetchrow_hashref) {
		push(@itemswaiting,$data);
    	}
    	$sth->finish;
    	return (scalar(@itemswaiting),\@itemswaiting);
}


=item
Verifica si el item tiene reservas, se saco de C4::AR::Reserves, solo es llamada de delitem.pl, creo q no se va
a usar mas
=cut
sub tiene_reservas {

	my ($id3)=@_;
  	my $dbh = C4::Context->dbh;
  	my $query= "	SELECT * FROM reserves  
			WHERE cancellationdate is NULL
			AND estado <> 'P'
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

	my $query="	SELECT reserves.borrowernumber 
			FROM reserves INNER JOIN persons ON reserves.borrowernumber = persons.borrowernumber
			WHERE regular = '0'
			AND cancellationdate is NULL
			AND reserves.estado is NULL";

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
efectivizar_reserva se deja para sacar validadciones, luego se va a borrar
=cut
sub efectivizar_reserva{

	my $dbh = C4::Context->dbh;
	my ($borrowernumber,$biblioitemnumber,$issuecode,$loggedinuser)=@_;
	my @sancion= permitionToLoan($borrowernumber, $issuecode);
	if ($sancion[0]||$sancion[1]) {
		return 0;
	} else {

		#Si NO es regular
		my $regular =  C4::AR::Usuarios::esRegular($borrowernumber);
		return(0) if ($regular eq 0);

		#Se pasa del maximo
		my $sth=$dbh->prepare("Select count(*) as prestamos from issues where returndate is NULL and borrowernumber=? and issuecode=?");
		$sth->execute($borrowernumber,$issuecode);
		my $datamax= $sth->fetchrow;
		my $sth=$dbh->prepare("SELECT daysissues,maxissues FROM issuetypes WHERE issuecode = ? ");
		$sth->execute($issuecode);
		my ($max,$fecha_devolucion)= $sth->fetchrow_hashref;
		return(0) if ($datamax >= $max);

#agregar comprobacion de maximos de prestamos y sanciones
		$sth=$dbh->prepare("SET autocommit=0");
		$sth->execute();
#Primero busco los datos de la reserva que se quiere efectivizar
		$sth=$dbh->prepare("Select * from reserves where biblioitemnumber=? and borrowernumber=? for update ");
		$sth->execute($biblioitemnumber,$borrowernumber);
		my $data= $sth->fetchrow_hashref;
		if($data->{'itemnumber'}){ 
#Si la reserva que voy a efectivizar estaba asociada a un item se puede sino hubo un error
			$sth=$dbh->prepare("Update reserves set constrainttype='P'  where biblioitemnumber=? and borrowernumber=? ");
			$sth->execute($biblioitemnumber,$borrowernumber);
# Se borra la sancion correspondiente a la reserva porque se esta prestando el biblo
			my $sth4=$dbh->prepare("Delete from sanctions where reservenumber=? ");
			$sth4->execute($data->{'reservenumber'});
			#my $fecha_devolucion=C4::Context->preference("daysissue");
			$fecha_devolucion=proximoHabil($fecha_devolucion,0);
			my $sth3=$dbh->prepare("INSERT INTO issues (borrowernumber,itemnumber,date_due,branchcode,issuingbranch,renewals,issuecode) VALUES (?,?,NOW(),?,?,?,?) ");
			$sth3->execute($data->{'borrowernumber'}, $data->{'itemnumber'}, $data->{'branchcode'}, $data->{'branchcode'}, 0, $issuecode);

#**********************************Se registra el movimiento en historicCirculation***************************
			my $dataItems= C4::Circulation::Circ2::getDataItems($data->{'itemnumber'});
			my $biblionumber= $dataItems->{'biblionumber'};
			my $end_date= 'null';
	
			C4::Circulation::Circ2::insertHistoricCirculation('issue',$data->{'borrowernumber'},$loggedinuser,$biblionumber,$biblioitemnumber,$data->{'itemnumber'},$data->{'branchcode'},$issuecode,$end_date);
#********************************Fin**Se registra el movimiento en historicCirculation*************************

			$sth3=$dbh->prepare("commit;");
			$sth3->execute();

		}

		return 1;
	}
}



1;
