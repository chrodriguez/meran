# -*- tab-width: 8 -*-
# NOTE: This file uses standard 8-character tabs

package C4::AR::Issues;

# $Id: C4::AR::Reserves.pm,v 1.0.0.2 2005/08/25  Exp $

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
require Exporter;
use DBI;
use C4::Date;
use C4::Context;
use C4::Circulation::Circ2;
use C4::Search;
use C4::AR::Sanctions;
use C4::AR::Reservas;
use Date::Manip;
use Time::HiRes qw(gettimeofday);
use Thread;
use Mail::Sendmail;
use C4::Auth;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::AR::Issues

=head1 SYNOPSIS

  use C4::AR::Issues;

=head1 DESCRIPTION

FIXME

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);

@EXPORT = qw(
    &t_devolver
    &t_renovar
    &DatosPrestamos
    &DatosPrestamosPorTipo
    &sepuederenovar
    &vencimiento
    &verificarTipoPrestamo
    &PrestamosMaximos
    &IssueType
    &IssuesType
    &IssuesTypeEnabled
    &fechaDeVencimiento
    &enviar_recordatorios_prestamos
    &crearTicket
    &estaVencido

   	&getCountPrestamosDeGrupo
	&prestamosPorUsuario
);


=item
Transaccion que maneja los erroes de base de datos y llama a la funcion devolver
=cut
sub t_devolver {
	my($params)=@_;
	my $codMsg;
	my $error;
	my $paraMens;
	my $dbh = C4::Context->dbh;
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	eval {
		($error,$codMsg,$paraMens)= devolver($params);
		$dbh->commit;
	};
	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B406';
		&C4::AR::Mensajes::printErrorDB($@, $codMsg,"OPAC");
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$error= 1;
		$paraMens->[0]=$params->{'barcode'};
		$codMsg= 'P110';
	}
	$dbh->{AutoCommit} = 1;

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"OPAC",$paraMens);
	return ($error, $codMsg, $message);
}

=item
la funcion devolver recibe una hash y actualiza la tabla de prestamos,la tabla de reservas y de historicissues. Realiza las comprobaciones para saber si hay reservas esperando en ese momento para ese item, si las hay entonces realiza las actualizaciones y envia un mail a el borrower correspondiente.
=cut 

sub devolver {
	my ($params)=@_;
	my $id3= $params->{'id3'};
	my $tipo= $params->{'tipo'};
	my $loggedinuser= $params->{'loggedinuser'};
	my $borrowernumber= $params->{'borrowernumber'};
	my $codMsg;
	my $error;
	my $paraMens;
	#se setea el barcode para informar al usuario en la devolucion
	$paraMens->[0]= $params->{'barcode'};

	my $prestamo= getDatosPrestamo($id3);
	my $fechaVencimiento= vencimiento($id3); # tiene que estar aca porque despues ya se marco como devuelto
	actualizarPrestamo($id3,$borrowernumber);

	my $notforloan=C4::AR::Reservas::getNotForLoan($id3);
	
	my $reserva=C4::AR::Reservas::getReservaDeId3($id3);
	if($reserva->{'id3'}){
	#Si la reserva que voy a borrar existia realmente sino hubo un error
		if($notforloan eq 'DO'){#si no es para sala
			my $reservaGrupo=C4::AR::Reservas::getDatosReservaEnEspera($reserva->{'id2'});
			if($reservaGrupo){
				$reservaGrupo->{'branchcode'}=$prestamo->{'branchcode'};
				$reservaGrupo->{'borrowernumber'}=$borrowernumber;
				$reservaGrupo->{'loggedinuser'}=$loggedinuser;
				C4::AR::Reservas::actualizarDatosReservaEnEspera($reservaGrupo);
			}
		}
		#Haya o no uno esperando elimino el que existia porque la reserva se esta cancelando
		C4::AR::Reservas::borrarReserva($reserva->{'reservenumber'});

#**********************************Se registra el movimiento en historicCirculation***************************
		my $dataItems= C4::Circulation::Circ2::getDataItems($id3);
		my $id1= $dataItems->{'id1'};
		my $end_date= "null";

		C4::Circulation::Circ2::insertHistoricCirculation('return',$borrowernumber,$loggedinuser,$id1,$reserva->{'id2'},$id3,$reserva->{'branchcode'},$prestamo->{'issuecode'},$end_date);

#*******************************Fin***Se registra el movimiento en historicCirculation*************************

### Se sanciona al usuario si es necesario, solo si se devolvio el item correctamente
		my $hasdebts=0;
		my $sanction=0;
		my $fechaFinSancion;

# Hay que ver si devolvio el biblio a termino para, en caso contrario, aplicarle una sancion 	
		my $issuetype=IssueType($prestamo->{'issuecode'});
		my $daysissue=$issuetype->{'daysissues'};
		my $dateformat = C4::Date::get_date_format();
		my $fechaHoy = C4::Date::format_date_in_iso(ParseDate("today"),$dateformat);
		my $categorycode=C4::Search::obtenerCategoria($borrowernumber);
                my $sanctionDays= SanctionDays($fechaHoy, $fechaVencimiento, $categorycode, $prestamo->{'issuecode'});

		if ($sanctionDays gt 0) {
# Se calcula el tipo de sancion que le corresponde segun la categoria del prestamo devuelto tardiamente y la categoria de usuario que tenga
			my $sanctiontypecode = getSanctionTypeCode($prestamo->{'issuecode'}, $categorycode);
			if (tieneLibroVencido($borrowernumber)) {
# El borrower tiene libros vencidos en su poder (es moroso)
				$hasdebts = 1;
			 	insertPendingSanction($sanctiontypecode, undef, $borrowernumber, $sanctionDays);
			}
			else{
				my $err;
# Se calcula la fecha de fin de la sancion en funcion de la fecha actual (hoy + cantidad de dias de sancion)
				$fechaFinSancion= C4::Date::format_date_in_iso(DateCalc(ParseDate("today"),"+ ".$sanctionDays." days",\$err),$dateformat);
				insertSanction($sanctiontypecode, undef, $borrowernumber, $fechaHoy, $fechaFinSancion, $sanctionDays);
				$sanction = 1;
#**********************************Se registra el movimiento en historicSanction***************************
				my $responsable= $loggedinuser;
				logSanction('Insert',$borrowernumber,$responsable,$fechaFinSancion,$sanctiontypecode);
#**********************************Fin registra el movimiento en historicSanction***************************

#Se borran las reservas del usuario sancionado
				C4::AR::Reservas::cancelar_reservas($loggedinuser,$borrowernumber);
			}
		}
### Final del tema sanciones
		# Si la devolucion se pudo realizar
		$error= 0;
		$codMsg= 'P109';
	}
	else {
		# Si la devolucion dio error
		$error= 1;
		$codMsg= 'P110';
	}
	#se obtiene el mensaje para el usuario
	my $message=C4::AR::Mensajes::getMensaje($codMsg,$tipo,$paraMens);

	return ($error,$codMsg, $message);
}

sub getDatosPrestamo{
	my ($id3)=@_;
	my $dbh=C4::Context->dbh;
	my $sth=$dbh->prepare("SELECT * FROM issues WHERE id3=? AND returndate IS NULL");
	$sth->execute($id3);
	return ($sth->fetchrow_hashref);
}

sub actualizarPrestamo{
	my ($id3,$borrowernumber)=@_;
	my $dbh=C4::Context->dbh;
	my $sth=$dbh->prepare("UPDATE issues SET returndate=NOW() WHERE id3=? AND borrowernumber=? AND returndate IS NULL");
	$sth->execute($id3,$borrowernumber);
}


=item
fechaDeVencimiento recibe dos parametro, un id3 y la fecha de prestamo lo que hace es devolver la fecha en que vence o vencio ese prestamo
=cut

sub fechaDeVencimiento {
	my ($id3,$date_due)=@_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("SELECT * FROM issues WHERE id3 = ? AND date_due = ? ");
	$sth->execute($id3,$date_due);
	my $data= $sth->fetchrow_hashref;
	if ($data){
		my $issuetype=IssueType($data->{'issuecode'}); 
		my $plazo_actual;
	
		if ($data->{'renewals'} > 0){#quiere decir que ya fue renovado entonces tengo que calcular sobre los dias de un prestamo renovado para saber si estoy en fecha
	 	 	$plazo_actual=$issuetype->{'renewdays'};
		 	return (proximoHabil($plazo_actual,0,$data->{'lastreneweddate'}));
		} 
		else{#es la primer renovacion por lo tanto tengo que ver sobre los dias de un prestamo normal para saber si estoy en fecha de renovacion
			$plazo_actual=$issuetype->{'daysissues'};
		 	return (proximoHabil($plazo_actual,0,$data->{'date_due'}));
		}

	}
}


=item
vencimiento recibe un parametro, un itemnumber  lo que hace es devolver la fecha en que vence el prestamo
=cut

sub vencimiento {
	my ($id3)=@_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("SELECT * FROM issues WHERE id3=? AND returndate IS NULL");
	$sth->execute($id3);
	my $data= $sth->fetchrow_hashref;
	if ($data){
		my $issuetype=IssueType($data->{'issuecode'}); 
		my $plazo_actual;
		if ($data->{'renewals'} > 0){#quiere decir que ya fue renovado entonces tengo que calcular sobre los dias de un prestamo renovado para saber si estoy en fecha
	 	 	$plazo_actual=$issuetype->{'renewdays'};
			return (proximoHabil($plazo_actual,0,$data->{'lastreneweddate'}));
		} 
		else{#es la primer renovacion por lo tanto tengo que ver sobre los dias de un prestamo normal para saber si estoy en fecha de renovacion
		 $plazo_actual=$issuetype->{'daysissues'};
		 return (proximoHabil($plazo_actual,0,$data->{'date_due'}));
		}
	}
}


=item
sepuederenovar recibe dos parametros un itemnumber y un borrowernumber, lo que hace es si el usario no tiene problemas de multas/sanciones, las fechas del prestamo estan en orden y no hay ninguna reserva pendiente se devuelve true, sino false
=cut
sub sepuederenovar(){
my ($borrowernumber,$id3)=@_;
my $dbh = C4::Context->dbh;

my $sth=$dbh->prepare(" SELECT * FROM reserves INNER JOIN issues ON issues.id3=reserves.id3 
			AND reserves.borrowernumber=issues.borrowernumber  WHERE reserves.id3=? 
			AND reserves.borrowernumber=? AND reserves.estado='P' AND returndate IS NULL");

$sth->execute($id3,$borrowernumber);

if (my $data= $sth->fetchrow_hashref){

	my $issuetype=IssueType($data->{'issuecode'});
	
	if ($issuetype->{'renew'} eq 0){ #Si es 0 NO SE RENUEVA NUNCA
		return 0;
	}

	if (!&hayReservasEsperando($data->{'id2'})){
		#quiere decir que no hay reservas esperando por lo que podemos seguir
		
		if (!C4::AR::Usuarios::estaSancionado($borrowernumber, $data->{'issuecode'})){
			#El usuario no tiene sanciones, puede seguir.
			
			#veo si el nro de renovaciones realizadas es mayor al nro maximo de renovaciones posibles permitidas

			my $intervalo_vale_renovacion=$issuetype->{'dayscanrenew'}; #Numero de dias en el que se puede hacer la renovacion antes del vencimiento.
			my $plazo_actual;

			if ($data->{'renewals'}){#quiere decir que ya fue renovado entonces tengo que calcular sobre los dias de un prestamo renovado para saber si estoy en fecha
				my $maximo_de_renovaciones=$issuetype->{'renew'};
				if ($data->{'renewals'} < $maximo_de_renovaciones) {#quiere decir que no se supero el maximo de renovaciones
					if(chequeoDeFechas($issuetype->{'renewdays'},$data->{'lastreneweddate'},$intervalo_vale_renovacion)){
						return 1;
					}
					else{ 
						return 0;
					}
				}
				else{ #se supero la cantidad maxima de renovaciones
					return 0;
				}	
			} 
			else{#es la primer renovacion por lo tanto tengo que ver sobre los dias de un prestamo normal para saber si estoy en fecha de renovacion
				if(chequeoDeFechas($issuetype->{'daysissues'},$data->{'date_due'},$intervalo_vale_renovacion)){
					return 2;
				}
				else{
					return 0;
				}
			}
		}
	}
}#if ($data-)
return 0;
}
		


sub hayReservasEsperando(){
	my ($id2)=@_;

	my $dbh = C4::Context->dbh;
	my $sth1=$dbh->prepare("SELECT * FROM reserves WHERE id2=? AND id3 IS NULL ORDER BY timestamp LIMIT 1;");
	$sth1->execute($id2);
	my $data1= $sth1->fetchrow_hashref;
	if ($data1){# esto quiere decir que hay reservas esperando entonces se devuelve un false indicando que no se puede hacer la renovacion del prestamo
		return 1;
	}
	else{
		return 0;
	}
}

sub chequeoDeFechas(){
	my ($cantDiasRenovacion,$fechaRenovacion,$intervalo_vale_renovacion)=@_;
	# La $fechaRenovacion es la ultima fecha de renovacion o la fecha del prestamo si nunca se renovo
	my $plazo_actual=$cantDiasRenovacion;# Cuantos dias mï¿½s se puede renovar el prestamo
	my $vencimiento=proximoHabil($plazo_actual,0,$fechaRenovacion);
	my $err= "Error con la fecha";
	my $dateformat = C4::Date::get_date_format();
	my $hoy=C4::Date::format_date_in_iso(DateCalc(ParseDate("today"),"+ 0 days",\$err),$dateformat);#se saco el 2 para que ande bien.
	my $desde=C4::Date::format_date_in_iso(DateCalc($vencimiento,"- ".$intervalo_vale_renovacion." days",\$err,2),$dateformat);#SE AGREGO EL 2 PARA QUE SALTEE LOS SABADOS Y DOMINGOS. 01/10/2007
	my $flag = Date_Cmp($desde,$hoy);
	#comparo la fecha de hoy con el inicio del plazo de renovacion	
	if (!($flag gt 0)){ 
		#quiere decir que la fecha de hoy es mayor o igual al inicio del plazo de renovacion
		#ahora tengo que ver que la fecha de hoy sea anterior al vencimiento
		my $flag2=Date_Cmp($vencimiento,$hoy);
		if (!($flag2 lt 0)){
			#la fecha esta ok
			return 1;
			
		}

	}
	return 0;
}

#**********************************Termina ACA ********************************************

=item
renovar recibe dos parametros un itemnumber y un borrowernumber, lo que hace es si el usario no tiene problemas de multas/sanciones, las fechas del prestamo estan en orden y no hay ninguna reserva pendiente se renueva el prestamo de ese ejmemplar para el usuario que actualmente lo tiene.
=cut
 
sub renovar {
	my ($params)=@_;
	my $borrowernumber= $params->{'borrowernumber'};
	my $id3= $params->{'id3'};
	my $tipo= $params->{'tipo'};
	my $loggedinuser= $params->{'loggedinuser'};
	my $paraMens;
	my $codMsg;
	my $error= 0;

#ESTA FUNCION HAY Q LIMPIARLA Y ADAPTARLA, DEBERIA DEVOLVER VODIGOS DE ERROR, ADEMAS DEBERIA IR DENTRO
# DE VERIFICAR PARA RENOVAR
	my $renovacion= &sepuederenovar($borrowernumber,$id3);
	my ($error, $codMsg,$paraMens)= verificarParaRenovar($params);

	if( ($renovacion) && (!$error) ){
	#Esto quiere decir que se puede renovar el prestamo, por lo tanto lo renuevo

		my $dbh = C4::Context->dbh;
		my $sth=$dbh->prepare("	UPDATE issues 
					SET renewals= IFNULL(renewals,0) + 1, lastreneweddate = now() 
					WHERE id3 = ? AND borrowernumber = ?");
		$sth->execute($id3, $borrowernumber);

#**********************************Se registra el movimiento en historicCirculation***************************
#esto se podria cruzar con la lo trae getDataItms para hacer una sola funcion
		my $dbh = C4::Context->dbh;
		my $sth=$dbh->prepare(" SELECT issuecode
					FROM issues
					WHERE(id3 = ? AND borrowernumber = ?) ");
		$sth->execute($id3, $borrowernumber);
		my $data = $sth->fetchrow_hashref;

		my $issuetype= $data->{'issuecode'};
		my $dataItems= C4::Circulation::Circ2::getDataItems($id3);
		my $id1= $dataItems->{'id1'};
		my $id2= $dataItems->{'id2'};
		my $branchcode= $dataItems->{'homebranch'};
		my $end_date= C4::AR::Issues::vencimiento($id3);

		C4::Circulation::Circ2::insertHistoricCirculation(	'renew',
									$borrowernumber,
									$loggedinuser,
									$id1,
									$id2,
									$id3,
									$branchcode,
									$issuetype,
									$end_date
								);
#****************************Fin******Se registra el movimiento en historicCirculation*************************
		$codMsg= 'P111';
		$error= 0;		
	}else{
		#el prestamo no se puede renovar
		$codMsg= 'P112';
		$error= 1;
	}
	return ($error,$codMsg, $paraMens);
}

=item
Se verifica que se cumplan las condiciones para poder renovar
=cut
sub verificarParaRenovar{
	my ($params)=@_;

	my $error= 0;
	my $codMsg= '000';
	my @paraMens;
	#se setea el barcode para informar al usuario en la renovacion	
	@paraMens[0]= $params->{'barcode'};	

	my ($borrower, $flags) = C4::Circulation::Circ2::getpatroninformation(	undef, 				
										$params->{'borrowernumber'}
									);	
	$params->{'usercourse'}= $borrower->{'usercourse'};

	#Se verifica que el usuario haya realizado el curso, simpre y cuando esta preferencia este seteada
	if( !($error) && $params->{'tipo'} eq "OPAC" && (C4::Context->preference("usercourse") && ($params->{'usercourse'} == "NULL" ) ) ){
		$error= 1;
		$codMsg= 'P114';
	}

	return ($error, $codMsg,\@paraMens);
}

=item
t_renovar
Transaccion que renueva un prestamo.
@params: $params-->Hash con los datos necesarios para poder renovar un prestamo.
=cut
sub t_renovar{
	my ($params)=@_;
	my $dbh = C4::Context->dbh;
	$dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;
	my $tipo=$params->{'tipo'};
	my ($error,$codMsg,$paraMens);
	eval{
		($error,$codMsg,$paraMens)= renovar($params);
		$dbh->commit;
	};
	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B405';
		C4::AR::Mensajes::printErrorDB($@, $codMsg,$tipo);
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'P113';
	}
	$dbh->{AutoCommit} = 1;
	my $message= &C4::AR::Mensajes::getMensaje($codMsg,$tipo,$paraMens);
	return($error,$codMsg,$message);
}

sub verificarTipoPrestamo {
#retorna verdadero si se puede hacer un determinado tipo de prestamo
	my ($issuetype,$notforloan)=@_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("SELECT * FROM issuetypes WHERE issuecode = ? AND notforloan = ?");
	$sth->execute($issuetype,$notforloan);
	return($sth->fetchrow_hashref);
}


sub IssueType {
#retorna los datos del tipo de prestamo
	my ($issuetype)=@_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("SELECT * FROM issuetypes WHERE issuecode = ?");
	$sth->execute($issuetype);
	return($sth->fetchrow_hashref);
}

sub IssuesType {
#Trae todos los tipos de Prestamos existentes
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("SELECT issuecode, description FROM issuetypes ORDER BY description");
	$sth->execute();
	my @result;
	while (my $ref= $sth->fetchrow_hashref) {
    		push @result, $ref;
  	}

	return(@result);
}

=item
IssuesTypeEnabled
Esta funcion devuelve los tipos de prestamos permitidos para un usuario, en un arreglo de hash.
=cut
sub IssuesTypeEnabled {
 	my ($notforloan, $borrowernumber)=@_;
	my $dbh = C4::Context->dbh;
  	my $sth;
#Trae todos los tipos de prestamos que estan habilitados
  	my $query= " SELECT * FROM issuetypes WHERE enabled = 1 ";
	$query .= " AND issuecode NOT IN (SELECT issuetypes.issuecode FROM sanctions 
	INNER JOIN sanctiontypes ON sanctions.sanctiontypecode = sanctiontypes.sanctiontypecode 
	INNER JOIN sanctionissuetypes ON sanctiontypes.sanctiontypecode = sanctionissuetypes.sanctiontypecode 
	INNER JOIN issuetypes ON sanctionissuetypes.issuecode = issuetypes.issuecode 
	WHERE borrowernumber = ? AND (now() between startdate AND enddate)) ";

  	if ($notforloan ne undef){
		$query.=" AND notforloan = ? ORDER BY description";
    		$sth = $dbh->prepare($query);
    		$sth->execute($borrowernumber, $notforloan);
  	} 
	else{
    		$query.=" ORDER BY description";
    		$sth = $dbh->prepare($query);
    		$sth->execute($borrowernumber);
  	}

  	my %issueslabels;
 	my @issuesvalues;
	my @issuesType;
	my $i=0;
  	while (my $res = $sth->fetchrow_hashref) {
		$issuesType[$i]->{'value'}=$res->{'issuecode'};
		$issuesType[$i]->{'label'}=$res->{'description'};
		$i++;
		
 	}
  	$sth->finish;
	return(\@issuesType);
}

=item
DatosPrestamos
Esta funcion retorna los datos de los prestamos de un usuario
=cut
sub DatosPrestamos {
	my ($borrowernumber)=@_;
	my $dbh = C4::Context->dbh;
	my $dateformat = C4::Date::get_date_format();
	my $sth=$dbh->prepare("SELECT * FROM issues WHERE returndate IS NULL AND borrowernumber = ?");
	$sth->execute($borrowernumber);
	my $hoy=C4::Date::format_date_in_iso(ParseDate("today"),$dateformat);
	my @result;
	while (my $ref= $sth->fetchrow_hashref) {
		my $fechaDeVencimiento= C4::AR::Issues::vencimiento($ref->{'id3'});
		$ref->{'overdue'}= (Date::Manip::Date_Cmp($fechaDeVencimiento,$hoy)<0);
		push @result, $ref;
	}
	$sth->finish;
  	return(scalar(@result), \@result);
}

=item
DatosPrestamosPorTipo
Esta funcion retorna los datos de los prestamos de un usuario por tipo de prestamo
=cut
sub DatosPrestamosPorTipo {
	my ($borrowernumber,$issuetype)=@_;
	my $dbh = C4::Context->dbh;
	my $dateformat = C4::Date::get_date_format();
	my $query="SELECT * FROM issues WHERE returndate IS NULL AND borrowernumber = ? AND issuecode=?";
	my $sth=$dbh->prepare($query);
	$sth->execute($borrowernumber,$issuetype);
	my $hoy=C4::Date::format_date_in_iso(ParseDate("today"),$dateformat);
	my @result;
	while (my $ref= $sth->fetchrow_hashref) {
		my $fechaDeVencimiento= C4::AR::Issues::vencimiento($ref->{'id3'});
		$ref->{'overdue'}= (Date::Manip::Date_Cmp($fechaDeVencimiento,$hoy)<0);
		push @result, $ref;
	}
	$sth->finish;
	return(scalar(@result), \@result);
}

sub PrestamosMaximos {
  #Esta funcion retorna los prestamos que esten en el maximo
  my ($borrowernumber)=@_;
  my $dbh = C4::Context->dbh;
  
    my $sth=$dbh->prepare("SELECT * FROM issuetypes;");
    $sth->execute();
    my @result;
   my $cant=0;	
	my @result;	
    while (my $iss= $sth->fetchrow_hashref) {
    	my $issuetype=$iss->{'issuecode'};
  	my $sth1=$dbh->prepare("SELECT count(*) AS prestamos FROM issues WHERE returndate IS NULL AND borrowernumber = ? AND issuecode=?");
  	$sth1->execute($borrowernumber,$issuetype);
	
	my $tot=$sth1->fetchrow;
        if ($iss->{'maxissues'} eq $tot) {
	$result[$cant]= $iss;
	$cant++;
	};
	$sth1->finish;
  }
  $sth->finish;

  return($cant, @result);
}

=item
mail de recordatorio envia los mails a los dueños de los items que vencen el proximo dia habil
=cut

sub Enviar_Recordatorio{
	my ($id3,$bor,$vencimiento)=@_;

	if ((C4::Context->preference("EnabledMailSystem"))&&(C4::Context->preference("reminderMail"))){

		my $dbh = C4::Context->dbh;
		my $borrower= C4::AR::Usuarios::getBorrower($bor);
# 		biblio.unititle as runititle, biblioitems.number as redicion FALTA!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		my $sth=$dbh->prepare("SELECT titulo, n1.id1 AS rid1, n2.id2 AS rid2, autor, reserves.id3 AS rid3
				    FROM reserves
				    INNER JOIN nivel2 n2 ON n2.id2 = reserves.id2
				    INNER JOIN nivel1 n1 ON n2.id1 = n1.id1
				    WHERE  reserves.borrowernumber =? AND reserves.id3= ?");
		$sth->execute($bor,$id3);
		my $res= $sth->fetchrow_hashref;	

		my $mailFrom=C4::Context->preference("mailFrom");
		my $mailSubject =C4::Context->preference("reminderSubject");
		my $mailMessage =C4::Context->preference("reminderMessage");
		my $branchname= C4::Search::getbranchname($borrower->{'branchcode'});

	$res->{'autor'}=(C4::Search::getautor($res->{'autor'}))->{'completo'};
	my $edicion=C4::AR::Busquedas::buscarDatoDeCampoRepetible($res->{'rid2'},"250","a","2");
	$mailFrom =~ s/BRANCH/$branchname/;
	$mailSubject =~ s/BRANCH/$branchname/;
	$mailMessage =~ s/BRANCH/$branchname/;
	$mailMessage =~ s/FIRSTNAME/$borrower->{'firstname'}/;
	$mailMessage =~ s/SURNAME/$borrower->{'surname'}/;
	$mailMessage =~ s/UNITITLE/$res->{'runititle'}/;
	$mailMessage =~ s/TITLE/$res->{'titulo'}/;
	$mailMessage =~ s/AUTHOR/$res->{'autor'}/;
	$mailMessage =~ s/EDICION/$edicion/;
	$mailMessage =~ s/VENCIMIENTO/$vencimiento/;

	my %mail = ( To => $borrower->{'emailaddress'},
                     From => $mailFrom,
                     Subject => $mailSubject,
                     Message => $mailMessage);
	my $resultado='ok';
	if ($borrower->{'emailaddress'} && $mailFrom ){
		sendmail(%mail) or die $resultado='error';
	}else {
		$resultado='';
	}

#**********************************Se registra el movimiento en historicCirculation***************************
	my $dataItems= C4::Circulation::Circ2::getDataItems($id3);
	my $id1= $dataItems->{'id1'};
	my $id2= $dataItems->{'id2'};
	my $branchcode= $dataItems->{'homebranch'};
	my $borrowernumber= $bor;
	my $loggedinuser= $bor;
	my $issuecode= '-';
	my $end_date= "null";
		
	C4::Circulation::Circ2::insertHistoricCirculation('reminder',$borrowernumber,$loggedinuser,$id1,$id2,$id3,$branchcode,$issuecode,$end_date);
#*******************************Fin***Se registra el movimiento en historicCirculation**********************

	}#end if (C4::Context->preference("EnabledMailSystem"))
}



sub enviar_recordatorios_prestamos {
	my $dbh = C4::Context->dbh;
	my $dateformat = C4::Date::get_date_format();
	my $sth=$dbh->prepare("SELECT * FROM issues iss LEFT JOIN issuetypes isst ON iss.issuecode=isst.issuecode 
			       WHERE iss.returndate IS NULL AND isst.notforloan = 0");
	$sth->execute();

	while(my $data= $sth->fetchrow_hashref) {
		my $fechaDeVencimiento=vencimiento ($data->{'id3'});
		my $proximohabil=proximoHabil(1,0);
		if (Date::Manip::Date_Cmp($fechaDeVencimiento,$proximohabil) == 0) {
			Enviar_Recordatorio($data->{'id3'},$data->{'borrowernumber'},&C4::Date::format_date($fechaDeVencimiento,$dateformat));
		};
	}
}


sub crearTicket {
	my ($id3,$bornum,$loggedinuser)=@_;
	my %env;
	my $dateformat = C4::Date::get_date_format();
	my ($borrower, $flags, $hash) = C4::Circulation::Circ2::getpatroninformation(\%env,$bornum,0);
	my ($librarian, $flags2, $hash2) = C4::Circulation::Circ2::getpatroninformation(\%env,$loggedinuser,0);
	my $iteminfo= C4::Circulation::Circ2::getiteminformation(\%env, $id3);
	my $ticket_duedate = vencimiento($iteminfo->{'id3'});
	my %ticket;
	$ticket{'borrowerName'}=CGI::Util::escape($borrower->{'firstname'} . " " . $borrower->{'surname'});
	$ticket{'borrowerNumber'}=CGI::Util::escape($borrower->{'cardnumber'});
	$ticket{'documentType'}=CGI::Util::escape($borrower->{'documenttype'});
	$ticket{'documentNumber'}=CGI::Util::escape($borrower->{'documentnumber'});
	$ticket{'autor'}=CGI::Util::escape($iteminfo->{'autor'});
	$ticket{'titulo'}=CGI::Util::escape($iteminfo->{'titulo'});
	$ticket{'topoSign'}=CGI::Util::escape($iteminfo->{'signatura_topografica'});
	$ticket{'barcode'}=CGI::Util::escape($iteminfo->{'barcode'});
# 	$ticket{'volume'}=CGI::Util::escape($iteminfo->{'volume'}); FALTA CODIGO MARC
	$ticket{'borrowDate'}=CGI::Util::escape(format_date_hour(ParseDate("today"),$dateformat));
	$ticket{'returnDate'}=CGI::Util::escape(format_date($ticket_duedate,$dateformat));
	$ticket{'librarian'}=CGI::Util::escape($librarian->{'firstname'} . " " . $librarian->{'surname'});
	$ticket{'issuedescription'}=CGI::Util::escape($iteminfo->{'issuedescription'});
	$ticket{'librarianNumber'}=CGI::Util::escape($librarian->{'cardnumber'});
	return(\%ticket);
}

sub estaVencido(){
	my($id3,$tipoPres)=@_;
# 	my @datearr = localtime(time);
	my $err;
	my $dateformat=C4::Date::get_date_format();
# 	my $hoy =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
	my $hoy=C4::Date::format_date_in_iso(DateCalc(ParseDate("today"),"+ 0 days",\$err),$dateformat);
	my $venc=vencimiento($id3);
	if (Date_Cmp($venc, $hoy) >= 0) {
		#Si es un prestamo especial debe devolverlo antes de una determinada hora
   		if ($tipoPres ne 'ES'){return(0,$venc);}
   		else{#Prestamo especial
			if (Date_Cmp($venc, $hoy) == 0){#Se tiene que devolver hoy	
				my $begin = ParseDate(C4::Context->preference("open"));
				my $end =calc_endES();
				my $actual=ParseDate("today");
				if (Date_Cmp($actual, $end) <= 0){#No hay sancion se devuelve entre la apertura de la biblioteca y el limite
					return(0,$venc);
				}
			}
			else {#Se devuelve antes de la fecha de devolucion
 				return(0,$venc);
			}
		}#else ES
	}#if Date_Cmp
	return(1,$venc);
}


#********************************AGREGADO PARA V3******************************************************

sub getCountPrestamosDeGrupo() {
#devuelve los prestamos de grupo del usuario
	my ($borrowernumber, $id2, $issuesType)=@_;
	my $dbh = C4::Context->dbh;

	my $query= "	SELECT count(*) AS cantPrestamos
        		FROM issues i LEFT JOIN nivel3 n3 ON n3.id3 = i.id3
        		INNER JOIN  nivel2 n2 ON n3.id2 = n2.id2
         		WHERE i.borrowernumber = ? AND n2.id2 = ?
			AND n3.notforloan = ? AND i.returndate IS NULL ";

	my $sth=$dbh->prepare($query);
	$sth->execute($borrowernumber, $id2, $issuesType);
	my $cant=$sth->fetchrow();
	$sth->finish;
	return($cant);
}

sub prestamosPorUsuario {
	my ($borrowernumber) = @_;
	my $dbh = C4::Context->dbh;
	my %currentissues;

	my $select= " SELECT  iss.timestamp AS timestamp, iss.date_due AS date_due, iss.issuecode AS issuecode,
                n3.id1, n2.id2, n3.id3, n3.barcode AS barcode, signatura_topografica,
                n1.titulo AS titulo, n1.autor, isst.description AS issuetype
                FROM issues iss INNER JOIN issuetypes isst ON ( iss.issuecode = isst.issuecode )
		INNER JOIN nivel3 n3 ON ( iss.id3 = n3.id3 )
		INNER JOIN nivel1 n1 ON ( n3.id1 = n1.id1)
		INNER JOIN nivel2 n2 ON ( n2.id2 = n3.id2 )
		INNER JOIN itemtypes it ON ( it.itemtype = n2.tipo_documento )
                WHERE iss.borrowernumber = ?
                AND iss.returndate IS NULL
                ORDER BY iss.date_due ";

# FALTA!!!!!!!!!
# 		biblio.unititle			AS unititle,
# 		biblioitems.dewey     		AS dewey,
# 		biblioitems.number 		AS redicion,
# 		biblioitems.volume 		AS volume,
# 		biblioitems.volumeddesc 	AS volumeddesc, 
# 		biblioitems.subclass  		AS subclass,
# 		biblioitems.classification 	AS classification,

	my $sth=$dbh->prepare($select);
	$sth->execute($borrowernumber);
	my $counter = 0;
	while (my $data = $sth->fetchrow_hashref) {
		$data->{'dewey'} =~ s/0*$//;
		($data->{'dewey'} == 0) && ($data->{'dewey'} = '');
		my @datearr = localtime(time());
		my $todaysdate = (1900+$datearr[5]).sprintf ("%0.2d", ($datearr[4]+1)).sprintf ("%0.2d", $datearr[3]);
		my $datedue = $data->{'date_due'};
		$datedue =~ s/-//g;
		if ($datedue < $todaysdate) {$data->{'overdue'} = 1;}
		
		$data->{'idautor'}=$data->{'autor'}; #Paso el id del author para poder buscar.
		#Obtengo los datos del autor
		my $autor=C4::Search::getautor($data->{'autor'});
		$data->{'autor'}=$autor->{'completo'};
		$data->{'edicion'}=C4::AR::Busquedas::buscarDatoDeCampoRepetible($data->{'id2'},"250","a","2");
		$currentissues{$counter} = $data;
		$counter++;
	}
	$sth->finish;

	return(\%currentissues);
}

