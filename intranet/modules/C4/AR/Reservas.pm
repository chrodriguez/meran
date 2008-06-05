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

	&prestar
);

sub reservar {

	my($params)=@_;

=item
	my $tipo= $params->{'tipo'}= ; #INTRA u OPAC
	my $id2= $params->{'id2'};
	my $id3= $params->{'id3'};
	my $borrowernumber= $params->{'borrowernumber'};
	my $loggedinuser= $params->{'loggedinuser'};
	my $issuesType= $params->{'issuesType'};
=cut
	my ($error, $codMsg,$paraMens)= &verificaciones($params);

	if(!$error){
#No hay error
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
		$paramsReserva{'issuesType'}= $params{'issuesType'};

		insertarReserva(\%paramsReserva);

	}

	return ($error, $codMsg,$paraMens);
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

sub getReservaDeId3(){
	#devuelve las reservas del item
	my ($id2)=@_;
	my $dbh = C4::Context->dbh;
	
	my $sth=$dbh->prepare("SELECT * FROM reserves WHERE id3 = ? ");
	$sth->execute($id3);
	
	return $sth->fecthrow_hashref();
}

sub cant_reservas{
#Cantidad de reservas totales de GRUPO y EJEMPLARESgetReservasDeBorrower
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

sub getItemsParaReserva{
#Busca los items sin reservas para los prestamos 
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
#Se verifica que el usuario sea Regular
	if( !&C4::AR::Usuarios::esRegular($borrowernumber) ){
		$error= 1;
		$codMsg= 'U300';
	}

#Se verifica que el usuario no tenga el maximo de prestamos permitidos para el tipo de prestamo.
#SOLO PARA INTRA, ES UN PRESTAMO INMEDIATO.
	if( !($error) && $tipo eq "INTRA" &&  verificarMaxTipoPrestamo($borrowernumber, $issueType) ){
		$error= 1;
		$codMsg= 'P101';
		$paraMens{'tipoPrestamo'}=$issueType;
	}

#Se verifica si es un prestamo especial este dentro de los horarios que corresponde.
#SOLO PARA INTRA, ES UN PRESTAMO ESPECIAL.
	if(!$error && $tipo eq "INTRA" && $issueType eq 'ES' && verificarHorario()){
		$error=1;
		$codMsg='P102';
	}
#Se verfica si el usuario esta sancionado
	my ($sancionado,$fechaFin)= C4::AR::Sanctions::permitionToLoan($borrowernumber, $issueType);
	if( !($error) && ($sancionado||$fechaFin) ){
		$error= 1;
		$codMsg= 'S200';
		$paraMens{'finDeSancion'}=$fechaFin;
	}

#Se verifica que el usuario no supere el numero maximo de reservas posibles seteadas en el sistema
	if( !($error) && (C4::AR::Usuarios::llegoMaxReservas($borrowernumber)) ){
		$error= 1;
		$codMsg= 'R001';
		$paraMens{'cantMaxReservas'}=C4::Context->preference("maxreserves");
	}

#Se verifica que el usuario no tenga dos reservas sobre el mismo grupo para el mismo tipo prestamo
	if( !($error) && ($tipo eq "OPAC") && (&verificarTipoReserva($borrowernumber, $id2, $id3, $tipo)) ){
		$error= 1;
		$codMsg= 'R002';
	}

#Se verifica que el usuario no tenga dos prestamos sobre el mismo grupo para el mismo tipo prestamo
	if( !($error) && (&C4::AR::Issues::getCountPrestamosDeGrupo($borrowernumber, $id2, $issueType)) ){
		$error= 1;
		$codMsg= 'P100';
	}
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
=item
sub sePuedePrestar(){
	my($params)=@_;
	
	my $oldid3=$params->{'oldid3'};
	my $id3=$params->{'id3'};
	my $issueType=$params->{'issueType'};
	my $borrowernumber=$params->{'borrowernumber'};
	my $error=0;
	my %paraMens;

	my ($cant, $reservas)= getReservasDeId2($id2);
#Si ya tiene una reserva se verifica que no sean para el mismo tipo de prestamo
#Es un prestamo inmediato desde la INTRA, se intercambian los id3.
	if( ($cant == 1) && (getNotForLoan($reservas->[0]->{'id3'}) eq getNotForLoan($id3) ) ){
		intercambiar_id3($borrowernumber,$id2,$id3,$oldid3);
	}
	else{
	
	}
	
#Se verfica si el usuario esta sancionado
	my ($sancionado,$fechaFin)= C4::AR::Sanctions::permitionToLoan($borrowernumber, $issueType);
	if( !($error) && ($sancionado||$fechaFin) ){
		$error= 1;
		$codMsg= 'S200';
		$paraMens{'finDeSancion'}=$fechaFin;
	}
#Se verifica si es un prestamo especial este dentro de los horarios que corresponde.
	if(!$error && $issueType eq 'ES' && verificarHorario()){
		$error=1;
		$codMsg='P102';
	}
	
	return($error,$codMsg,\%paraMens);
}

sub verificarHorario{
	my $end = ParseDate(C4::Context->preference("close"));
	my $begin =calc_beginES();
	my $actual=ParseDate("today");
	my $error=0;
	if ((Date_Cmp($actual, $begin) < 0) || (Date_Cmp($actual, $end) > 0)){$error=1;}
	return $error;
}
=cut

sub intercambiar_id3{
	my ($borrowernumber, $id2, $id3, $oldid3)= @_;
        my $dbh = C4::Context->dbh;

	my $sth=$dbh->prepare("SELECT id3, estado FROM reserves WHERE id3=? FOR UPDATE ");
	$sth->execute($id3);
	my $data= $sth->fetchrow_hashref;
	if ($data && $data->{'estado'} eq "E"){ 
		#quiere decir que hay una reserva sobre el itemnumber y NO esta prestado el item
		$sth=$dbh->prepare("UPDATE reserves SET id3= ? where id3 = ?");
		$sth->execute($oldid3, $id3);
	}
	#actualizo la reserva con el nuevo itemnumber
	if($data->{'estado'} eq "P"){
		return 0; #El item esta prestado a otro usuario
	}
	else{
		$sth=$dbh->prepare("UPDATE reserves SET id3= ? WHERE id2=? AND borrowernumber=?");
		$sth->execute($id3, $id2, $borrowernumber);
	}

	return 1;
}

sub cambiarId3{
	my ($id3Libre,$reservenumber)=@_;
	my $dbh = C4::Context->dbh;
	my $query="UPDATE reserves SET id3= ? where reservenumber = ?";
	my $sth=$dbh->prepare($query);
	$sth->execute($id3Libre,$reservenumber);
}

sub prestar {

	my($params)=@_;
	my $dbh=C4::Context->dbh;

	my $borrowernumber= $params->{'borrowernumber'};
	my $id2= $params->{'id2'};
	my $id3= $params->{'id3'};
	my ($error, $codMsg, $paraMens);
	
#Se verifica si ya se tiene la reserva sobre el grupo
	my ($cant, $reservas)= getReservasDeBorrower($borrowernumber, $id2);
	my $tipoPrestamo=getNotForLoan($id3);
	if($cant == 1 && $tipoPrestamo eq "DO"){
		#El usuario ya tiene la reserva
		($error, $codMsg, $paraMens)= &verificaciones($params);
		#Se actualiza la reserva si no hay error...FALTA
		
	}
	elsif($cant==1 && $tipoPrestamo eq "SA"){
# 		FALTA!!! SE PUEDE PONER EN EL ELSE???	
	}
	else{
		#Se verifca disponibilidad del item;
		
		#Se verifica si ya hay una reserva sobre el item (DE CUALQUIER USUARIO)
# 		my $sth=$dbh->prepare("SELECT * FROM reserves WHERE id3 = ? ");
# 		$sth->execute($id3);

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
					$error=1;
					$codMsg='R004';
				}else{
					$codMsg='R005';
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
	my $sth=$dbh->prepare("	UPDATE reserves SET estado='P' 
				WHERE id2 = ? AND borrowernumber = ? ");

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
