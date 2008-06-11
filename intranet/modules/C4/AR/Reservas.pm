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

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);

@EXPORT = qw(
	&reservar
	&insertarReserva
	&insertarPrestamo
	&verificaciones
	&cant_reservas
	&getReservasDeGrupo
	&cantReservasPorGrupo
	&DatosReservas
	&cancelar_reserva

	&prestar
);

sub reservarOPAC {
	
	my($params)=@_;
	my $reservaGrupo= 0;

	my ($error, $codMsg,$paraMens)= &verificaciones($params);
	
	if(!$error){
	#No hay error

		my ($paramsReserva)= reservar($params);
		#Se setean los parametros para el mensaje de la reserva SIN ERRORES
		if($paramsReserva->{'estado'} eq 'E'){
		#SE RESERVO CON EXITO UN EJEMPLAR
			$codMsg= 'U302';
			$paraMens->{'desde'}= $paramsReserva->{'desde'};
			$paraMens->{'desdeh'}= $paramsReserva->{'desdeh'};	
			$paraMens->{'hasta'}= $paramsReserva->{'hasta'};
			$paraMens->{'hastah'}= $paramsReserva->{'hastah'};
		}else{
		#SE REALIZO UN RESERVA DE GRUPO
			$codMsg= 'U303';
			my $borrowerInfo= C4::AR::Usuarios::getBorrowerInfo($params->{'borrowernumber'});
			$paraMens->{'mail'}= $borrowerInfo->{'emailaddress'};
		}
		
	}

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
	
	$paramsReserva{'id1'}= $data->{'id1'};
	$paramsReserva{'id2'}= $params->{'id2'};
	$paramsReserva{'id3'}= $data->{'id3'};
	$paramsReserva{'borrowernumber'}= $params->{'borrowernumber'};
	$paramsReserva{'loggedinuser'}= $params->{'loggedinuser'};			
	$paramsReserva{'reservedate'}= $desde;
	$paramsReserva{'reminderdate'}= $hasta;
	$paramsReserva{'branchcode'}= $data->{'holdingbranch'}||$params->{'holdingbranch'};
	$paramsReserva{'estado'}= ($data->{'id3'} ne '')?'E':'G';
	$paramsReserva{'hasta'}= $hasta;
	$paramsReserva{'desde'}= $desde;
	$paramsReserva{'desdeh'}= $apertura;
	$paramsReserva{'hastah'}= $cierre;	
	$paramsReserva{'issuesType'}= $params->{'issuesType'};

	my $reservenumber= insertarReserva(\%paramsReserva);

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


=item
Funcion que cancela una reserva
Se invoca con dos parametros cancelar-reserva($biblioitem,$borrowernumber);
un biblioitem y un numero de usuario correspondiente al que hizo la reserva, ya que son los dos campos con los que identifico una reserva sin duplicados
=cut

sub cancelar_reserva {

	my ($biblioitemnumber,$borrowernumber,$loggedinuser)=@_;
	my $dbh = C4::Context->dbh;
	my $dateformat = C4::Date::get_date_format();
	my $sth=$dbh->prepare("SET autocommit=0;");
	$sth->execute();
#Primero busco los datos de la reserva que se quiere borrar
	$sth=$dbh->prepare("	SELECT * 
				FROM reserves 
				WHERE id2= ? AND borrowernumber= ? FOR UPDATE");

	$sth->execute($biblioitemnumber,$borrowernumber);
	my @resultado;
	my $data= $sth->fetchrow_hashref;
	if($data->{'id3'}){
#Si la reserva que voy a cancelar estaba asociada a un item tengo que reasignar ese item a otra reserva para el mismo grupo
		my $sth1=$dbh->prepare("	SELECT * 
						FROM reserves 
						WHERE id2=? AND id3 is NULL 
						ORDER BY timestamp LIMIT 1 ");
		$sth1->execute($biblioitemnumber);
# Se borra la sancion correspondiente a la reserva si es que la sancion todavia no entro en vigencia
		my $sth4=$dbh->prepare("	DELETE FROM sanctions 
						WHERE reservenumber=? AND (now() < startdate)");
		$sth4->execute($data->{'reservenumber'});

		my $data2= $sth1->fetchrow_hashref;

		if ($data2) { 
		#Quiere decir que hay reservas esperando para este mismo grupo
			@resultado= ($data->{'id3'}, $data2->{'id2'}, $data2->{'borrowernumber'}, $data2->{'reservenumber'});
		}
	}

#**********************************Se registra el movimiento en historicSanction***************************
		#traigo la info de la sancion
		my $infoSancion= &C4::AR::Sanctions::infoSanction($data->{'reservenumber'});

		my $responsable= $loggedinuser;
		my $sanctiontypecode= 'null';
		my $fechaFinSancion= $infoSancion->{'enddate'};
		C4::AR::Sanctions::logSanction('Insert',$borrowernumber,$responsable,$fechaFinSancion,$sanctiontypecode);
#**********************************Fin registra el movimiento en historicSanction***************************

#Actualizo la sancion para que refleje el itemnumber y asi poder informalo
	my $sth6=$dbh->prepare(" UPDATE sanctions SET id3 = ? WHERE reservenumber = ? ");
	$sth6->execute($data->{'id3'},$data->{'reservenumber'});

#Haya o no uno esperando elimino el que existia porque la reserva se esta cancelando
	$sth=$dbh->prepare("DELETE FROM reserves WHERE id2=? AND borrowernumber=?");
	$sth->execute($biblioitemnumber,$borrowernumber);

	if (@resultado) {#esto quiere decir que se realizo un movimiento de asignacion de item a una reserva que estaba en espera en la base, hay que actualizar las fechas y notificarle al usuario
		my ($desde,$fecha,$apertura,$cierre)=proximosHabiles(C4::Context->preference("reserveGroup"),1);
		$sth=$dbh->prepare("	UPDATE reserves 
					SET id3=?, reservedate=?, notificationdate=NOW(), reminderdate=?, branchcode=? 
					WHERE id2=? AND borrowernumber=? ");
		$sth->execute($resultado[0], $desde, $fecha,$data->{'branchcode'},$resultado[1],$resultado[2]);

#**********************************Se registra el movimiento en historicCirculation***************************
		my $itemnumber= $resultado[0];
		my $dataItems= C4::Circulation::Circ2::getDataItems($itemnumber);
		my $biblionumber= $dataItems->{'id1'};
		my $end_date= $fecha;
		my $issuecode= '-';
		my $borrnum= $resultado[2];
	
		C4::Circulation::Circ2::insertHistoricCirculation('notification',$borrnum,$loggedinuser,$biblionumber,$biblioitemnumber,$itemnumber,$data->{'branchcode'},$issuecode,$end_date);
#********************************Fin**Se registra el movimiento en historicCirculation*************************

# Se agrega una sancion que comienza el dia siguiente al ultimo dia que tiene el usuario para ir a retirar el libro
		my $err= "Error con la fecha";
		my $startdate= DateCalc($fecha,"+ 1 days",\$err);
		$startdate= C4::Date::format_date_in_iso($startdate,$dateformat);
		my $daysOfSanctions= C4::Context->preference("daysOfSanctionReserves");
		my $enddate= DateCalc($startdate, "+ $daysOfSanctions days", \$err);
		$enddate= C4::Date::format_date_in_iso($enddate,$dateformat);
		C4::AR::Sanctions::insertSanction(undef, $resultado[3] ,$borrowernumber, $startdate, $enddate, undef);

		my $sth3=$dbh->prepare("commit");
		$sth3->execute();

		Enviar_Email($resultado[0],$resultado[2],$desde, $fecha, $apertura,$cierre,$loggedinuser);

#Este thread se utiliza para enviar el mail al usuario avisandole de la disponibilidad
#my $t = Thread->new(\&Enviar_Email, ($resultado[0],$resultado[2],$desde, $fecha, $apertura,$cierre));
#$t->detach;
#FALTA ENVIARLE EL MAIL al usuario avisandole de  la disponibilidad del libro mediante un proceso separado, un thread por ej, el problema me parece es que el thread no accede a las bases de datos.

	}else{
		my $sth3=$dbh->prepare("commit");
		$sth3->execute();
	}

#**********************************Se registra el movimiento en historicCirculation***************************
	my $biblionumber;
	my $branchcode;

	if($data->{'id3'}){

		my $dataItems= C4::Circulation::Circ2::getDataItems($data->{'id3'});
		$biblionumber= $dataItems->{'id1'};
		$branchcode= $dataItems->{'homebranch'};
	}else{
		my $dataBiblioItems= C4::Circulation::Circ2::getDataBiblioItems($biblioitemnumber);
		$biblionumber= $dataBiblioItems->{'id1'};
		$branchcode= 0;
	}
	
	my $issuetype= '-';
	my $loggedinuser= $borrowernumber;
	my $end_date = 'null';
	C4::Circulation::Circ2::insertHistoricCirculation('cancel',$borrowernumber,$loggedinuser,$biblionumber,$biblioitemnumber,$data->{'id3'},$branchcode,$issuetype,$end_date); #C4::Circulation::Circ2
#******************************Fin****Se registra el movimiento en historicCirculation*************************
}

sub DatosReservas {
	my ($bor)=@_;
	my $dbh = C4::Context->dbh;
# FALTAN!!!!!!!!!!!!!!!!!!!!!!
# biblioitems.volume as volume, biblioitems.volumeddesc as volumeddesc , biblioitems.number as redicion

	my $query= "	SELECT n1.titulo as rtitulo, n1.id1 as rid1, n1.autor as rautor, 
			a.completo as nomCompleto, r.id2 as rid2, r.reservedate as rreservedate, 
			r.notificationdate as rnotificationdate,r.reminderdate as rreminderdate, n2.anio_publicacion as rpublicationyear, r.id3 as ritemnumber, r.branchcode as rbranch
			FROM reserves r
			INNER JOIN nivel2 n2 ON  n2.id2 = r.id2
			INNER JOIN nivel1 n1 ON n2.id1 = n1.id1 
			LEFT JOIN autores a ON (a.id = n1.autor)
			WHERE r.borrowernumber = ?
			AND cancellationdate is NULL AND r.estado <> 'P' ";
	
	my $sth=$dbh->prepare($query);
	$sth->execute($bor);

	my @results;
	while (my $data=$sth->fetchrow_hashref){

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

sub verificarTipoReserva {
#Verifica que el usuario no reserve un item que ya tenga una reserva para el mismo grupo y 
#para el mismo tipo de prestamo

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
			WHERE id2 = ? AND id3 IS NOT NULL) FOR UPDATE ";

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
	my $borrowernumber= $params->{'borrowernumber'};
	my $loggedinuser= $params->{'loggedinuser'};
	my $issueType= $params->{'issuesType'};
	my $error= 0;
	my $codMsg= '000';
	my %paraMens;

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
		$paraMens{'tipoPrestamo'}=$issueType;
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
		$paraMens{'finDeSancion'}=$fechaFin;
print A "Entro al if de sanciones";
	}
#Se verifica que el usuario no intente reservar desde el OPAC un item para SALA
	if(!$error && $tipo eq "OPAC" && getDisponibilidadGrupo($id2) eq 'SA'){
		$error=1;
		$codMsg='R007';
print A "Entro al if de prestamos de sala";
	}

#Se verifica que el usuario no supere el numero maximo de reservas posibles seteadas en el sistema
	if( !($error) && (C4::AR::Usuarios::llegoMaxReservas($borrowernumber)) ){
		$error= 1;
		$codMsg= 'R001';
		$paraMens{'cantMaxReservas'}=C4::Context->preference("maxreserves");
print A "Entro al if de maximo de reservas";
	}

#Se verifica que el usuario no tenga dos reservas sobre el mismo grupo para el mismo tipo prestamo
	if( !($error) && ($tipo eq "OPAC") && (&verificarTipoReserva($borrowernumber, $id2, $id3, $tipo)) ){
		$error= 1;
		$codMsg= 'R002';
print A "Entro al if de reservas iguales, sobre el mismo grupo y tipo de prestamo";
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
	return ($error, $codMsg,\%paraMens);
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
		$estado= 'reserve'
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
								$params->{'branchcode'},
								$params->{'issuesType'},
								$params->{'hasta'}
							);
#*******************************Fin***Se registra el movimiento en historicCirculation*************************

	return $reservenumber;

}#end insertarReserva

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
		$sth=$dbh->prepare("UPDATE reserves SET id3= ? where id3 = ?");
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
	my $query="UPDATE reserves SET id3= ? where reservenumber = ?";
	my $sth=$dbh->prepare($query);
	$sth->execute($id3Libre,$reservenumber);
}


sub prestar{
	my ($params)=@_;

	my ($error, $codMsg,$paraMens)= &verificaciones($params);
	if(!$error){
	#No hay error

		my ($paramsPrestamo)= chequeoParaPrestamo($params);
		
	}

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
	return ($error, $message);
}

sub chequeoParaPrestamo {

	my($params)=@_;
	my $dbh=C4::Context->dbh;

	my $borrowernumber= $params->{'borrowernumber'};
	my $id2= $params->{'id2'};
	my $id3= $params->{'id3'};
	my ($error, $codMsg, $paraMens);
	
#Se verifica si ya se tiene la reserva sobre el grupo
	my ($cant, $reservas)= getReservasDeBorrower($borrowernumber, $id2);# ver lo que sigue.
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
		if($id3 != $reservas->{'id3'}){
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
		my $ok=1;
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
					$ok=0;
					$error=1;#Hay error no se permite realizar una reserva de grupo en intra.
					$codMsg='R004';
				}else{
					$codMsg='R005';#No hay error, se realiza una reserva de grupo.
				}
			}
		}
		#Se realiza una reserva
		if($ok){
			($error, $codMsg, $paraMens)= reservar($params);
		}
	}
	#Se verifica datos del prestamo
	#Se realiza el pretamo
	if(!$error){
		insertarPrestamo($params);
		# Se realizo el prestamo con exito
		$codMsg= 'P103';
	}

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
=item
	my $sth2=$dbh->prepare("	DELETE FROM sanctions 
					WHERE reservenumber = ? ");

	$sth2->execute(	$params->{'reservenumber'});
=cut


#Se realiza el prestamo del item
	my $sth3=$dbh->prepare("	INSERT INTO issues 		
					(borrowernumber,id3,date_due,branchcode,issuingbranch,renewals,issuecode) 
					VALUES (?,?,NOW(),?,?,?,?) ");

	$sth3->execute(	$params->{'borrowernumber'}, 
			$params->{'id3'}, 
			$params->{'branchcode'}, 
			$params->{'branchcode'}, 
			0, 
			$params->{'issuesType'}
	);

}

1;
