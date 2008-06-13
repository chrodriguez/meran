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

   	&getCountPrestamosDeGrupo
	&prestamosPorUsuario
);





=item
la funcion devolver recibe un itemnumber y un borrowernumber y actualiza la tabla de prestamos,la tabla de reservas y de historicissues. Realiza las comprobaciones para saber si hay reservas esperando en ese momento para ese item, si las hay entonces realiza las actualizaciones y envia un mail a el borrower correspondiente.
=cut 

sub devolver {
	my @resultado;
	my ($id3,$borrowernumber,$loggedinuser)=@_;
	
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
			C4::AR::Reserves::Enviar_Email($resultado[0],$resultado[2],$desde, $fecha, $apertura,$cierre,$loggedinuser);
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
                        my $sanctionDays= SanctionDays($dbh, $fechaHoy, $fechaVencimiento, $categorycode, $iteminformation->{'issuecode'});



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


		return(1); # Si la devolucion se pudo realizar
	} else {
		return(0); # Si la devolucion dio error
	}
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
my ($borrowernumber,$itemnumber)=@_;
my $dbh = C4::Context->dbh;

my $sth=$dbh->prepare(" Select * from reserves inner join issues on 				issues.itemnumber=reserves.itemnumber 
			and reserves.borrowernumber=issues.borrowernumber  where reserves.itemnumber=? 
			and reserves.borrowernumber=? and reserves.constrainttype='P' and returndate is null");

$sth->execute($itemnumber,$borrowernumber);

if (my $data= $sth->fetchrow_hashref){

	my $issuetype=IssueType($data->{'issuecode'});
	
	if ($issuetype->{'renew'} eq 0){ #Si es 0 NO SE RENUEVA NUNCA
					return 0;
					}

	if (!&hayReservasEsperando($data->{'biblioitemnumber'})){
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
	my ($biblioitemnumber)=@_;

	my $dbh = C4::Context->dbh;
	my $sth1=$dbh->prepare("Select * from reserves where biblioitemnumber=? and itemnumber is NULL order by timestamp limit 1;");
	$sth1->execute($biblioitemnumber);
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
	my ($borrowernumber,$id3,$loggedinuser)=@_;
	my $renovacion= &sepuederenovar($borrowernumber,$id3);
	if ($renovacion){
#Esto quiere decir que se puede renovar el prestamo, por lo tanto lo renuevo
		my $dbh = C4::Context->dbh;
		my $sth=$dbh->prepare("UPDATE issues SET renewals= IFNULL(renewals,0) + 1, lastreneweddate = now() WHERE id3 = ? AND borrowernumber = ?");
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

		C4::Circulation::Circ2::insertHistoricCirculation('renew',$borrowernumber,$loggedinuser,$id1,$id2,$id3,$branchcode,$issuetype,$end_date);
#****************************Fin******Se registra el movimiento en historicCirculation*************************

		return 1;
	}else{
#el prestamo no se puede renovar
		return 0;
	}
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




sub reservar {
my ($borrowernumber,$biblioitemnumber)=@_;
my $dbh = C4::Context->dbh;

my $sth=$dbh->prepare("SET autocommit=0;");
$sth->execute();
$sth=$dbh->prepare("Select reserves.itemnumber from reserves where biblioitemnumber=? for update;");
$sth->execute($biblioitemnumber);
my $res;
my $resultado;
if (my $data= $sth->fetchrow_hashref){
					$res=' not in ('.$data->{'itemnumber'};
					while (my $data= $sth->fetchrow_hashref){
							$res.=', '.$data->{'itemnumber'}; &fechaDeVencimiento
					}  
					$res.=')';
					}
					else{ $res='';}

my $sth1=$dbh->prepare("Select items.itemnumber, items.holdingbranch from items where items.biblioitemnumber=? and notforloan='0' and items.itemnumber ". $res. ";");
$sth1->execute($biblioitemnumber);
my $data2= $sth1->fetchrow_hashref;
my ($fecha,$apertura,$cierre);
my $desde;
my $branch='';
if ($data2){
#se encontro algun item que se pudo reservar

$fecha=C4::Context->preference("reserveItem");
($desde,$fecha,$apertura,$cierre)=proximosHabiles($fecha,1);

my $sth2=$dbh->prepare("insert into reserves (itemnumber,biblioitemnumber,borrowernumber,reservedate,notificationdate,reminderdate,branchcode) values (?,?,?,?,NOW(),?,?);");
$sth2->execute($data2->{'itemnumber'},$biblioitemnumber,$borrowernumber,$desde,$fecha,$data2->{'holdingbranch'});
#reminderdate le puse la fecha de vencimiento de la reserva
$resultado=$data2->{'itemnumber'};
#por ahora tiene la unidad que lo tiene al libro pero deberia cambiarse para adecuarse a la que seleccione el usuario
$branch=$data2->{'holdingbranch'};
} else{

#se hace una reserva para el grupo, ya que no hay ningun item libre
my $sth2=$dbh->prepare("insert into reserves (biblioitemnumber,borrowernumber,reservedate) values (?,?,NOW());");
$sth2->execute($biblioitemnumber,$borrowernumber);
$desde='0000-00-00';#FechaFactible(); #la fecha factible en que el libro este disponible, hya que hacer una funcion medio rara
$fecha='0000-00-00';#hasta cuando lo puede retirar es mas subjetivo aun
$resultado=0;
}
my $sth3=$dbh->prepare("commit;");
$sth3->execute();

return ($resultado,$desde,$fecha,$branch,$apertura,$cierre);
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
  	while (my $res = $sth->fetchrow_hashref) {
        	push @issuesvalues, $res->{'issuecode'};
        	$issueslabels{$res->{'issuecode'}} = $res->{'description'};
 	}
  	$sth->finish;
	return(\@issuesvalues,\%issueslabels);
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
	my ($iteminfo,$loggedinuser)=@_;
	my %env;
	my $dateformat = C4::Date::get_date_format();
	my $bornum=$iteminfo->{'borrowernumber'};
	my ($borrower, $flags, $hash) = C4::Circulation::Circ2::getpatroninformation(\%env,$bornum,0);
	my ($librarian, $flags2, $hash2) = C4::Circulation::Circ2::getpatroninformation(\%env,$loggedinuser,0);
	my $ticket_duedate = vencimiento($iteminfo->{'id3'});
	my $ticket_borrower = $borrower;
	my $ticket_string =
		    "?borrowerName=" . CGI::Util::escape($ticket_borrower->{'firstname'} . " " . $ticket_borrower->{'surname'}) .
		    "&borrowerNumber=" . CGI::Util::escape($ticket_borrower->{'cardnumber'}) .
		    "&documentType=" . CGI::Util::escape($ticket_borrower->{'documenttype'}) .
  		    "&documentNumber=" . CGI::Util::escape($ticket_borrower->{'documentnumber'}) .
		    "&author=" . CGI::Util::escape($iteminfo->{'autor'}) .
		    "&bookTitle=" . CGI::Util::escape($iteminfo->{'titulo'}) .
		    "&topoSign=" . CGI::Util::escape($iteminfo->{'bulk'}) .
		    "&barcode=" . CGI::Util::escape($iteminfo->{'barcode'}) .
		    "&volume=" . CGI::Util::escape($iteminfo->{'volume'}) .
		    "&borrowDate=" . CGI::Util::escape(format_date_hour(ParseDate("today")),$dateformat) .
		    "&returnDate=" . CGI::Util::escape(format_date($ticket_duedate),$dateformat) .
		    "&librarian=" . CGI::Util::escape($librarian->{'firstname'} . " " . $librarian->{'surname'}).
		    "&issuedescription=" . CGI::Util::escape($iteminfo->{'issuedescription'}).
		    "&librarianNumber=" . CGI::Util::escape($librarian->{'cardnumber'});
	return ($ticket_string);
}

sub estaVencido(){
	my($id3,$tipoPres)=@_;
	my @datearr = localtime(time);
	my $hoy =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
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
                n3.id1, n2.id2, n3.id3, n3.barcode AS barcode,
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
# 		items.bulk 			AS bulk,
# 		biblio.unititle			AS unititle,
# 		biblioitems.dewey     		AS dewey,
# 		biblioitems.number 		AS redicion,
# 		biblioitems.volume 		AS volume,
# 		biblioitems.volumeddesc 	AS volumeddesc, 
# 		biblioitems.subclass  		AS subclass,
# 		biblioitems.classification 	AS classification,

	#Matias Para mostrar la signatura topografica agrego el bulk como resultado de la consulta #y ademas el nro de grupo y el volumen
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
		
		$data->{'idauthor'}=$data->{'autor'}; #Paso el id del author para poder buscar.
		#Obtengo los datos del autor
		my $autor=C4::Search::getautor($data->{'autor'});
		$data->{'autor'}=$autor->{'completo'};

		$currentissues{$counter} = $data;
		$counter++;
	}
	$sth->finish;

	return(\%currentissues);
}

