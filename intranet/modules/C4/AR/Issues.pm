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
use C4::AR::Reserves;
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
    &devolver
    &renovar
    &borrowerissues
    &DatosPrestamos
    &DatosPrestamosPorTipo
    &sepuederenovar
    &vencimiento
    &verificarTipoPrestamo
    &PrestamosMaximos
    &IssueType
    &IssuesType
    &IssuesType2
    &fechaDeVencimiento
    &enviar_recordatorios_prestamos
    &crearTicket
    &IssuesType3
    &estaVencido

   	&getCountPrestamosDeGrupo
	&prestamosPorUsuario
);





=item
la funcion devolver recibe un itemnumber y un borrowernumber y actualiza la tabla de prestamos,la tabla de reservas y de historicissues. Realiza las comprobaciones para saber si hay reservas esperando en ese momento para ese item, si las hay entonces realiza las actualizaciones y envia un mail a el borrower correspondiente.
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
	
	my @resultado;
	my $dateformat = C4::Date::get_date_format();

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
<<<<<<< .mine
		
		C4::Circulation::Circ2::insertHistoricCirculation('return',$borrowernumber,$loggedinuser,$id1,$data->{'id2'},$id3,$data->{'branchcode'},$iteminformation->{'issuecode'},$end_date);
=======
		C4::Circulation::Circ2::insertHistoricCirculation('return',$borrowernumber,$loggedinuser,$id1,$reserva->{'id2'},$id3,$reserva->{'branchcode'},$prestamo->{'issuecode'},$end_date);
>>>>>>> .r543
#*******************************Fin***Se registra el movimiento en historicCirculation*************************

### Se sanciona al usuario si es necesario, solo si se devolvio el item correctamente
		my $hasdebts=0;
		my $sanction=0;
		my $fechaFinSancion;

# Hay que ver si devolvio el biblio a termino para, en caso contrario, aplicarle una sancion 	
		my $issuetype=IssueType($prestamo->{'issuecode'});
		my $daysissue=$issuetype->{'daysissues'}; 
		my $fechaHoy = C4::Date::format_date_in_iso(ParseDate("today"),$dateformat);
		my $dbh=C4::Context->dbh;
                my $sth=$dbh->prepare("Select categorycode from borrowers where borrowernumber=?");
                $sth->execute($borrowernumber);
                my $categorycode= $sth->fetchrow;
                my $sanctionDays= SanctionDays($fechaHoy, $fechaVencimiento, $categorycode, $prestamo->{'issuecode'});

		if ($sanctionDays gt 0) {
# Se calcula el tipo de sancion que le corresponde segun la categoria del prestamo devuelto tardiamente y la categoria de usuario que tenga
			my $sanctiontypecode = getSanctionTypeCode($dbh, $prestamo->{'issuecode'}, $categorycode);

			if (tieneLibroVencido($dbh, $borrowernumber)) {
# El borrower tiene libros vencidos en su poder (es moroso)
				$hasdebts = 1;
			 	insertPendingSanction($dbh,$sanctiontypecode, undef, $borrowernumber, $sanctionDays);
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
				C4::AR::Reserves::cancelar_reservas($loggedinuser,$borrowernumber);
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

sub devolverVieja {
	my ($params)=@_;

	my $borrowernumber= $params->{'borrowernumber'};
	my $id3= $params->{'id3'};
	my $tipo= $params->{'tipo'};
	my $loggedinuser= $params->{'loggedinuser'};
	my $codMsg;
	my $error;
	my $paraMens;
	#se setea el barcode para informar al usuario en la renovacion	
	$paraMens->[0]= $params->{'barcode'};	
	
	my @resultado;
	my $dbh = C4::Context->dbh;
	my $dateformat = C4::Date::get_date_format();
	my $sth=$dbh->prepare("SET autocommit=0;");
	$sth->execute();
	$sth=$dbh->prepare("select * from issues where id3=? and returndate IS NULL");
	$sth->execute($id3);
	my $iteminformation= $sth->fetchrow_hashref;
	my $fechaVencimiento= vencimiento($id3); # tiene que estar aca porque despues ya se marco como devuelto
	$sth=$dbh->prepare("Update issues set returndate=NOW() where id3=? and borrowernumber=? and returndate is NULL");
	$sth->execute($id3,$borrowernumber);
	#verifico que el item no sea para sala
	$sth=$dbh->prepare("Select notforloan from nivel3 where id3=?");
	$sth->execute($id3);
	my $notforloan= $sth->fetchrow_hashref;
	
	$sth=$dbh->prepare("Select * from reserves where id3=? and borrowernumber=?");
	$sth->execute($id3,$borrowernumber);
	my $data= $sth->fetchrow_hashref;
	if($data->{'id3'}){
	#Si la reserva que voy a borrar existia realmente sino hubo un error
		if($notforloan->{'notforloan'} eq 'DO'){#si no es para sala
			my $sth1=$dbh->prepare("Select * from reserves where id2=? and id3 is NULL order by timestamp limit 1 ");
			$sth1->execute($data->{'id2'});
			my $data2= $sth1->fetchrow_hashref;
			if ($data2) { #Quiere decir que hay reservas esperando para este mismo grupo
				@resultado= ($id3, $data2->{'id2'}, $data2->{'borrowernumber'});
			}
		}
		#Haya o no uno esperando elimino el que existia porque la reserva se esta cancelando
		$sth=$dbh->prepare("Delete from reserves where id3=? and borrowernumber=?");
		$sth->execute($id3,$borrowernumber);
		if (@resultado) {
		#esto quiere decir que se realizo un movimiento de asignacion de item a una reserva que estaba en espera en la base, hay que actualizar las fechas y notificarle al usuario
			my ($desde,$fecha,$apertura,$cierre)=proximosHabiles(C4::Context->preference("reserveGroup"),1);
			$sth=$dbh->prepare("Update reserves set id3=?,reservedate=?,notificationdate=NOW(),reminderdate=?, branchcode=? where id2=? and borrowernumber=? ");
			$sth->execute($resultado[0], $desde, $fecha,$iteminformation->{'branchcode'},$resultado[1],$resultado[2]);
			C4::AR::Reservas::Enviar_Email($resultado[0],$resultado[2],$desde, $fecha, $apertura,$cierre,$loggedinuser);
			#Este thread se utiliza para enviar el mail al usuario avisandole de la disponibilidad
			#my $t = Thread->new(\&Enviar_Email, ($resultado[0],$resultado[2],$desde, $fecha, $apertura,$cierre));
			#$t->detach;
			#FALTA ENVIARLE EL MAIL al usuario avisandole de  la disponibilidad del libro mediante un proceso separado, un thread por ej, el problema me parece es que el thread no accede a las bases de datos.

		}# end if (@resultado) 

#**********************************Se registra el movimiento en historicCirculation***************************
		my $dataItems= C4::Circulation::Circ2::getDataItems($id3);

		my $id1= $dataItems->{'id1'};
		my $end_date= "null";
		C4::Circulation::Circ2::insertHistoricCirculation('return',$borrowernumber,$loggedinuser,$id1,$data->{'id2'},$id3,$data->{'branchcode'},$iteminformation->{'issuecode'},$end_date);
#*******************************Fin***Se registra el movimiento en historicCirculation*************************


		my $sth3=$dbh->prepare("commit;");
		$sth3->execute();

### Se sanciona al usuario si es necesario, solo si se devolvio el item correctamente
		my $hasdebts=0;
		my $sanction=0;
		my $fechaFinSancion;

# Hay que ver si devolvio el biblio a termino para, en caso contrario, aplicarle una sancion 	
			my $issuetype=IssueType($iteminformation->{'issuecode'});
			my $daysissue=$issuetype->{'daysissues'}; 
			my $fechaHoy = C4::Date::format_date_in_iso(ParseDate("today"),$dateformat);
                        my $sth=$dbh->prepare("Select categorycode from borrowers where borrowernumber=?");
                        $sth->execute($borrowernumber);
                        my $categorycode= $sth->fetchrow;
                        my $sanctionDays= SanctionDays($fechaHoy, $fechaVencimiento, $categorycode, $iteminformation->{'issuecode'});



			if ($sanctionDays gt 0) {
# Se calcula el tipo de sancion que le corresponde segun la categoria del prestamo devuelto tardiamente y la categoria de usuario que tenga
				my $sanctiontypecode = getSanctionTypeCode($dbh, $iteminformation->{'issuecode'}, $categorycode);



			if (tieneLibroVencido($dbh, $borrowernumber)) {
# El borrower tiene libros vencidos en su poder (es moroso)
			$hasdebts = 1;
			 insertPendingSanction($dbh,$sanctiontypecode, undef, $borrowernumber, $sanctionDays);
			}
			else
			{
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
				C4::AR::Reserves::cancelar_reservas($loggedinuser,$borrowernumber);
			}
			}
		
### Final del tema sanciones

		# Si la devolucion se pudo realizar
		$error= 0;
		$codMsg= 'P109';
	} else {
		# Si la devolucion dio error
		$error= 1;
		$codMsg= 'P110';
	}

	#se obtiene el mensaje para el usuario
	my $message=C4::AR::Mensajes::getMensaje($codMsg,$tipo,$paraMens);

	return ($error,$codMsg, $message);
}


=item
fechaDeVencimiento recibe dos parametro, un id3 y la fecha de prestamo lo que hace es devolver la fecha en que vence o vencio ese prestamo
=cut

sub fechaDeVencimiento {
my ($id3,$date_due)=@_;
my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare("Select * from issues where id3 = ? and date_due = ? ");
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
my $sth=$dbh->prepare("Select * from issues where id3=? and returndate is NULL");
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

my $sth=$dbh->prepare(" Select * from reserves inner join issues on issues.id3=reserves.id3 
			and reserves.borrowernumber=issues.borrowernumber  where reserves.id3=? 
			and reserves.borrowernumber=? and reserves.estado='P' and returndate is null");

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
	my $sth1=$dbh->prepare("Select * from reserves where id2=? and id3 is NULL order by timestamp limit 1;");
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
	my $plazo_actual=$cantDiasRenovacion;# Cuantos dias m�s se puede renovar el prestamo
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

#borrowerissues retorna todos los prestamos que tiene actualmente un borrower, recibe el nro de borrower y devuelve la cantidad de prestamos actuales y el arreglo de los prestamos actuales
sub borrowerissues {
  my ($bornum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select *, issues.renewals as renewals2
        from issues left join items  on items.itemnumber=issues.itemnumber
        inner join  biblioitems on items.biblioitemnumber=biblioitems.biblioitemnumber
         where borrowernumber=?
        and issues.returndate is NULL order by date_due");
    $sth->execute($bornum);
  my @result;
  while (my $data = $sth->fetchrow_hashref) {
    push @result, $data;
  }
  $sth->finish;
  return(scalar(@result), \@result);
}


sub verificarTipoPrestamo {
#retorna verdadero si se puede hacer un determinado tipo de prestamo
	my ($issuetype,$notforloan)=@_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("Select * from issuetypes where issuecode = ? and notforloan = ?");
	$sth->execute($issuetype,$notforloan);
	return($sth->fetchrow_hashref);
}


sub IssueType {
#retorna los datos del tipo de prestamo
	my ($issuetype)=@_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("Select *  from issuetypes where issuecode = ?");
	$sth->execute($issuetype);
	return($sth->fetchrow_hashref);
}

sub IssuesType {
#Trae todos los tipos de Prestamos existentes
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("Select issuecode, description  From issuetypes Order By description");
	$sth->execute();

	my @result;
	while (my $ref= $sth->fetchrow_hashref) {
    		push @result, $ref;
  	}

	return(@result);
}

#Miguel - estoy probando esta funcion, para que muestre los tipos de prestamos en los que el usuario no 
#esta sancionado, esta es una copia de IssuesType3, ver si queda y sacar la otra
sub IssuesType3 {
 	my ($notforloan, $borrowernumber)=@_;
	my $dbh = C4::Context->dbh;
  	my $sth;
#Trae todos los tipos de prestamos que estan habilitados
  	my $query= " SELECT * from issuetypes WHERE enabled = 1 ";

#Miguel Agregado ver!!!!!!!!!!!!11
$query .= " AND issuecode NOT IN (select issuetypes.issuecode from sanctions 
	inner join sanctiontypes on sanctions.sanctiontypecode = sanctiontypes.sanctiontypecode 
	inner join sanctionissuetypes on sanctiontypes.sanctiontypecode = sanctionissuetypes.sanctiontypecode 
	inner join issuetypes on sanctionissuetypes.issuecode = issuetypes.issuecode 
	where borrowernumber = ? and (now() between startdate and enddate)) ";

  	if ($notforloan ne undef){
#     		$query.=" where notforloan = ? order by description";
		$query.=" AND notforloan = ? ORDER BY description";
    		$sth = $dbh->prepare($query);
    		$sth->execute($borrowernumber, $notforloan);
  	} 
	else{
    		$query.=" order by description";
    		$sth = $dbh->prepare($query);
    		$sth->execute($borrowernumber);
  	}

  	my %issueslabels;
 	my @issuesvalues;
	my @issuesType;
	my $i=0;
  	while (my $res = $sth->fetchrow_hashref) {
#         	push @issuesvalues, $res->{'issuecode'};
#         	$issueslabels{$res->{'issuecode'}} = $res->{'description'};
		$issuesType[$i]->{'value'}=$res->{'issuecode'};
		$issuesType[$i]->{'label'}=$res->{'description'};
		$i++;
		
 	}
  	$sth->finish;
# 	return(\@issuesvalues,\%issueslabels);
	return(\@issuesType);
}

sub IssuesType2 {
 	my ($notforloan)=@_;
	my $dbh = C4::Context->dbh;
  	my $sth;
#Trae todos los tipos de prestamos que estan habilitados
  	my $query= " SELECT * from issuetypes WHERE enabled = 1 ";
  	if ($notforloan ne undef){
#     		$query.=" where notforloan = ? order by description";
		$query.=" AND notforloan = ? ORDER BY description";
    		$sth = $dbh->prepare($query);
    		$sth->execute($notforloan);
  	} 
	else{
    		$query.=" order by description";
    		$sth = $dbh->prepare($query);
    		$sth->execute();
  	}

  	my %issueslabels;
 	my @issuesvalues;
  	while (my $res = $sth->fetchrow_hashref) {
        	push @issuesvalues, $res->{'issuecode'};
        	$issueslabels{$res->{'issuecode'}} = $res->{'description'};
 	}
  	$sth->finish;
	return(\@issuesvalues,\%issueslabels);
}

=item
VER LA DE PRESTAMOSPORUSUARIO EN USUARIOS.PM SON =?????!!!!!!!!!!!!!!
=cut
sub DatosPrestamos {
  #Esta funcion retorna los datos de los prestamos de un usuario
  my ($borrowernumber)=@_;
  my $dbh = C4::Context->dbh;
  my $dateformat = C4::Date::get_date_format();
  my $sth=$dbh->prepare("Select * from issues where returndate is NULL and borrowernumber = ?");
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


sub DatosPrestamosPorTipo {
  #Esta funcion retorna los datos de los prestamos de un usuario por tipo de prestam
  my ($borrowernumber,$issuetype)=@_;
  my $dbh = C4::Context->dbh;
  my $dateformat = C4::Date::get_date_format();
  my $sth=$dbh->prepare("Select * from issues where returndate is NULL and borrowernumber = ? and issuecode=?");
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
  
    my $sth=$dbh->prepare("Select * from issuetypes;");
    $sth->execute();
    my @result;
   my $cant=0;	
	my @result;	
    while (my $iss= $sth->fetchrow_hashref) {
    	my $issuetype=$iss->{'issuecode'};
  	my $sth1=$dbh->prepare("Select count(*) as prestamos from issues where returndate is NULL and borrowernumber = ? and issuecode=?");
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
mail de recordatorio envia los mails a los due�os de los items que vencen el proximo dia habil
=cut

sub Enviar_Recordatorio{

my ($itemnumber,$bor,$vencimiento)=@_;

if ((C4::Context->preference("EnabledMailSystem"))&&(C4::Context->preference("reminderMail"))){

my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare("Select * from borrowers where borrowernumber=?;");
$sth->execute($bor);
my $borrower= $sth->fetchrow_hashref;
$sth=$dbh->prepare("SELECT biblio.title as rtitle, biblio.biblionumber as rbiblionumber,biblio.author as rauthor, biblio.unititle as runititle, reserves.biblioitemnumber as rbiblioitemnumber, biblioitems.number as redicion			FROM reserves
			inner join biblioitems on  biblioitems.biblioitemnumber = reserves.biblioitemnumber
			INNER JOIN biblio on biblioitems.biblionumber = biblio.biblionumber WHERE  reserves.borrowernumber =? and reserves.itemnumber= ?  
					");
$sth->execute($bor,$itemnumber);
my $res= $sth->fetchrow_hashref;	

my $mailFrom=C4::Context->preference("mailFrom");
my $mailSubject =C4::Context->preference("reminderSubject");
my $mailMessage =C4::Context->preference("reminderMessage");
my $branchname= C4::Search::getbranchname($borrower->{'branchcode'});

$res->{'rauthor'}=(C4::Search::getautor($res->{'rauthor'}))->{'completo'};


$mailFrom =~ s/BRANCH/$branchname/;
$mailSubject =~ s/BRANCH/$branchname/;
$mailMessage =~ s/BRANCH/$branchname/;
$mailMessage =~ s/FIRSTNAME/$borrower->{'firstname'}/;
$mailMessage =~ s/SURNAME/$borrower->{'surname'}/;
$mailMessage =~ s/UNITITLE/$res->{'runititle'}/;
$mailMessage =~ s/TITLE/$res->{'rtitle'}/;
$mailMessage =~ s/AUTHOR/$res->{'rauthor'}/;
$mailMessage =~ s/EDICION/$res->{'redicion'}/;
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
	my $dataItems= C4::Circulation::Circ2::getDataItems($itemnumber);
	my $biblionumber= $dataItems->{'biblionumber'};
	my $biblioitemnumber= $dataItems->{'biblioitemnumber'};
	my $branchcode= $dataItems->{'homebranch'};
	my $borrowernumber= $bor;
	my $loggedinuser= $bor;
	my $issuecode= '-';
	my $end_date= "null";
		
	C4::Circulation::Circ2::insertHistoricCirculation('reminder',$borrowernumber,$loggedinuser,$biblionumber,$biblioitemnumber,$itemnumber,$branchcode,$issuecode,$end_date);
#*******************************Fin***Se registra el movimiento en historicCirculation**********************

	}#end if (C4::Context->preference("EnabledMailSystem"))

}



sub enviar_recordatorios_prestamos {
my $dbh = C4::Context->dbh;
my $dateformat = C4::Date::get_date_format();
my $sth=$dbh->prepare("Select * from issues left join issuetypes on issues.issuecode=issuetypes.issuecode where issues.returndate is NULL and issuetypes.notforloan = 0");
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
	$loggedinuser = C4::Auth::getborrowernumber($loggedinuser);
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

	my $query= "	SELECT count(*) as cantPrestamos
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

		$currentissues{$counter} = $data;
		$counter++;
	}
	$sth->finish;

	return(\%currentissues);
}

