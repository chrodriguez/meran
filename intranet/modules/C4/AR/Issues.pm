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
    &IssuesType	
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
    &sepuederenovar2
);
=item
la funcion devolver recibe un itemnumber y un borrowernumber y actualiza la tabla de prestamos,la tabla de reservas y de historicissues. Realiza las comprobaciones para saber si hay reservas esperando en ese momento para ese item, si las hay entonces realiza las actualizaciones y envia un mail a el borrower correspondiente.
=cut 

sub devolver{
	my @resultado;
	my ($itemnumber,$borrowernumber)=@_;
	
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("SET autocommit=0;");
	$sth->execute();
	$sth=$dbh->prepare("select * from issues where itemnumber=? and returndate IS NULL");
	$sth->execute($itemnumber);
	my $iteminformation= $sth->fetchrow_hashref;
	my $returnDate= vencimiento($itemnumber); # tiene que estar aca porque despues ya se marco como devuelto
	$sth=$dbh->prepare("Update issues set returndate=NOW() where itemnumber=? and borrowernumber=? and returndate is NULL");
	$sth->execute($itemnumber,$borrowernumber);
	$sth=$dbh->prepare("Select * from reserves where itemnumber=? and borrowernumber=?");
	$sth->execute($itemnumber,$borrowernumber);
	my $data= $sth->fetchrow_hashref;
	if($data->{'itemnumber'}){
	#Si la reserva que voy a borrar existia realmente sino hubo un error
		my $sth1=$dbh->prepare("Select * from reserves where biblioitemnumber=? and itemnumber is NULL order by timestamp limit 1 ");
		$sth1->execute($data->{'biblioitemnumber'});
		my $data2= $sth1->fetchrow_hashref;
		if ($data2) { #Quiere decir que hay reservas esperando para este mismo grupo
			@resultado= ($itemnumber, $data2->{'biblioitemnumber'}, $data2->{'borrowernumber'});
		}
		#Haya o no uno esperando elimino el que existia porque la reserva se esta cancelando
		$sth=$dbh->prepare("Delete from reserves where itemnumber=? and borrowernumber=?");
		$sth->execute($itemnumber,$borrowernumber);
		if (@resultado) {
		#esto quiere decir que se realizo un movimiento de asignacion de item a una reserva que estaba en espera en la base, hay que actualizar las fechas y notificarle al usuario
			my ($desde,$fecha,$apertura,$cierre)=proximosHabiles(C4::Context->preference("reserveGroup"),1);
			$sth=$dbh->prepare("Update reserves set itemnumber=?,reservedate=?,notificationdate=NOW(),reminderdate=?, branchcode=? where biblioitemnumber=? and borrowernumber=? ");
			$sth->execute($resultado[0], $desde, $fecha,$iteminformation->{'branchcode'},$resultado[1],$resultado[2]);
			C4::AR::Reserves::Enviar_Email($resultado[0],$resultado[2],$desde, $fecha, $apertura,$cierre);
			#Este thread se utiliza para enviar el mail al usuario avisandole de la disponibilidad
			#my $t = Thread->new(\&Enviar_Email, ($resultado[0],$resultado[2],$desde, $fecha, $apertura,$cierre));
			#$t->detach;
			#FALTA ENVIARLE EL MAIL al usuario avisandole de  la disponibilidad del libro mediante un proceso separado, un thread por ej, el problema me parece es que el thread no accede a las bases de datos.

		}
		my $sth3=$dbh->prepare("commit;");
		$sth3->execute();

		$sth3=$dbh->prepare("Insert into historicCirculation (type,borrowernumber,date,biblioitemnumber,itemnumber,branchcode) values (?,?,NOW(),?,?,?) ");
		$sth3->execute('return',$borrowernumber,$data->{'biblioitemnumber'},$itemnumber,$data->{'branchcode'});

### Se sanciona al usuario si es necesario, solo si se devolvio el item correctamente
		my $hasdebts=0;
		my $sanction=0;
		my $enddate;
		if (hasDebts($dbh, $borrowernumber)) {
# El borrower tiene libros vencidos en su poder (es moroso)
			$hasdebts = 1;
		} else {
# Si el usuario no tiene deudas (libros en su poder) hay que ver si devolvio el biblio a termino para, en caso contrario, aplicarle una sancion 	
			my $issuetype=IssueType($iteminformation->{'issuecode'});
			my $daysissue=$issuetype->{'daysissues'}; 
			
			my $gmtime = C4::Date::format_date_in_iso(ParseDate("today"));
                        my $sth=$dbh->prepare("Select categorycode from borrowers where borrowernumber=?");
                        $sth->execute($borrowernumber);
                        my $categorycode= $sth->fetchrow;
                        my $sanctionDays= SanctionDays($dbh, $gmtime, $returnDate, $categorycode, $iteminformation->{'issuecode'});

# open L,'>/tmp/lucho';
# print L $returnDate.'<--->'.$categorycode.'<--->'.$iteminformation->{'issuecode'}.'<--->'.$sanctionDays;
# close L;


			if ($sanctionDays) {
# Se calcula el tipo de sancion que le corresponde segun la categoria del prestamo devuelto tardiamente y la categoria de usuario que tenga
				my $sanctiontypecode = getSanctionTypeCode($dbh, $iteminformation->{'issuecode'}, $categorycode);
				my $err;
# Se calcula la fecha de fin de la sancion en funcion de la fecha actual (hoy + cantidad de dias de sancion)
				$enddate= C4::Date::format_date_in_iso(DateCalc(ParseDate("today"),"+ ".$sanctionDays." days",\$err));
				insertSanction($dbh, $sanctiontypecode, undef, $borrowernumber, $gmtime, $enddate, $sanctionDays);
				$sanction = 1;
#Se borran las reservas del usuario sancionado
				C4::AR::Reserves::cancelar_reservas($borrowernumber);
			}
		}
### Final del tema sanciones


		return(1); # Si la devolucion se pudo realizar
	} else {
		return(0); # Si la devolucion dio error
	}
}


=item
vencimiento recibe un parametro, un itemnumber  lo que hace es devolver la fecha en que vence el prestamo
=cut

sub vencimiento{
my ($itemnumber)=@_;
my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare("Select * from issues where itemnumber=? and returndate is NULL");
$sth->execute($itemnumber);
my $data= $sth->fetchrow_hashref;
if ($data){
		 my $issuetype=IssueType($data->{'issuecode'}); 

	if ($data->{'renewals'}){#quiere decir que ya fue renovado entonces tengo que calcular sobre los dias de un prestamo renovado para saber si estoy en fecha
	 	my $plazo_actual=$issuetype->{'renewdays'};

		return (proximoHabil($plazo_actual,0,$data->{'lastreneweddate'}));
	} 
	else{#es la primer renovacion por lo tanto tengo que ver sobre los dias de un prestamo normal para saber si estoy en fecha de renovacion
		my $plazo_actual=$issuetype->{'daysissues'};
		 
				 
		 return(proximoHabil($plazo_actual,0,$data->{'date_due'}));
		
	}

}
}

=item
sepuederenovar recibe dos parametros un itemnumber y un borrowernumber, lo que hace es si el usario no tiene problemas de multas/sanciones, las fechas del prestamo estan en orden y no hay ninguna reserva pendiente se devuelve true, sino false
=cut


#######********* ESTA FUNCION ESTA IGUAL QUE LA SEPUEDERENOVAR2 SE REDEFINIO PARA OPTIMIZAR EL CODIGO
#######********* HAY QUE SACARLA!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub sepuederenovar{
my ($borrowernumber,$itemnumber)=@_;
my $dbh = C4::Context->dbh;

my $sth=$dbh->prepare(" Select * from reserves inner join issues on issues.itemnumber=reserves.itemnumber 
			and reserves.borrowernumber=issues.borrowernumber  where reserves.itemnumber=? 
			and reserves.borrowernumber=? and reserves.constrainttype='P' ");

$sth->execute($itemnumber,$borrowernumber);
my $data= $sth->fetchrow_hashref;
if ($data){

	my $issuetype=IssueType($data->{'issuecode'});
	
	if ($issuetype->{'renew'} eq 0){ #Si es 0 NO SE RENUEVA NUNCA
					return 0;
					}

	my $sth1=$dbh->prepare("Select * from reserves where biblioitemnumber=? and itemnumber is NULL order by timestamp limit 1;");
	$sth1->execute($data->{'biblioitemnumber'});
	my $data1= $sth1->fetchrow_hashref;
	if ($data1){# esto quiere decir que hay reservas esperando entonces se devuelve un false indicando que no se puede hacer la renovacion del prestamo
		return 0;
	}
	else 
	{#quiere decir que no hay reservas esperando por lo que podemos seguir
		#my @sancion=(0,0); #estasancionado($borrowernumber)
		my @sancion= permitionToLoan($dbh, $borrowernumber, $data->{'issuecode'});
		if ($sancion[0]||$sancion[1]) 
		{ 
			return 0;
		}
		else 
		{#veo si el nro de renovaciones realizadas es mayor al nro maximo de renovaciones posibles permitidas
			my $intervalo_vale_renovacion=$issuetype->{'dayscanrenew'}; #Numero de dias en el que se puede hacer la renovacion antes del vencimiento.
			my $plazo_actual;
			if ($data->{'renewals'}){#quiere decir que ya fue renovado entonces tengo que calcular sobre los dias de un prestamo renovado para saber si estoy en fecha
				my $maximo_de_renovaciones=$issuetype->{'renew'};
				if ($data->{'renewals'} lt $maximo_de_renovaciones) {#quiere decir que no se supero el maximo de renovaciones
					$plazo_actual=$issuetype->{'renewdays'};# Cuantos dias más se renovo el prestamo
					my $vencimiento=proximoHabil($plazo_actual,0,$data->{'lastreneweddate'});
					my $err= "Error con la fecha";
					my $hoy=C4::Date::format_date_in_iso(DateCalc(ParseDate("today"),"+ 0 days",\$err,2));
					my $desde=C4::Date::format_date_in_iso(DateCalc($vencimiento,"- ".$intervalo_vale_renovacion." days",\$err));	
					my $flag = Date_Cmp($desde,$hoy);
				  	#comparo la fecha de hoy con el inicio del plazo de renovacion	
					if ($flag gt 0) { #todavia no estamos en fecha el dia de hoy es anterior al comienzo del plazo en el cual se puede renovar ($hoy es mas temprano que $desde)
						return 0;}
					else {
						#quiere decir que la fecha de hoy es mayor o igual al inicio del plazo de renovacion
						#ahora tengo que ver que la fecha de hoy sea anterior al vencimiento
						$flag=Date_Cmp($vencimiento,$hoy);
						if ($flag lt 0){#la fecha de hoy es mayor a la del vencimiento -> el prestamo esta vencido, hay un problema con las sanciones habria que avisarle al administrador
							return 0;
						}
						else{
							#la fecha esta ok
							return 1;
						}

					}
				}
				else{ #se supero la cantidad maxima de renovaciones
					return 0;
				}	
			} 
				else{#es la primer renovacion por lo tanto tengo que ver sobre los dias de un prestamo normal para saber si estoy en fecha de renovacion
					$plazo_actual= $issuetype->{'daysissues'}; 
					my $vencimiento=proximoHabil($plazo_actual,0,$data->{'date_due'});
					my $err= "Error con la fecha";
					my $hoy=C4::Date::format_date_in_iso(DateCalc(ParseDate("today"),"+ 0 days",\$err,2));
					my $desde=C4::Date::format_date_in_iso(DateCalc($vencimiento,  "- ".$intervalo_vale_renovacion." days",\$err));
					my $flag = Date_Cmp($desde,$hoy);
					#comparo la fecha de hoy con el inicio del plazo de renovacion  
					if ($flag gt 0) { #todavia no estamos en fecha el dia de hoy es anterior al comienzo del plazo en el cual se puede renovar 
						return 0;}
					else {
						#quiere decir que la fecha de hoy es mayor o igual al inicio del plazo de renovacion
                                                #ahora tengo que ver que la fecha de hoy sea anterior al vencimiento
						$flag=Date_Cmp($vencimiento,$hoy);
						if ($flag lt 0){#la fecha de hoy es mayor a la del vencimiento -> el prestamo esta vencido, hay un problema con las sanciones habria que avisarle al administrador ($vencimiento es mas temprano que $hoy)
							return 0;
							
						}
						else{
							#la fecha esta ok
							return 2;
						}
					}

				#quiere decir que no esta sancionado, por lo tanto me fijo en las fechas, la cantidad de items prestados o reservados no me importan porque en realidad no se modifican esos nro

			}
		}#no esta sancionado
	}#no hay reserva
				
}#if ($data-)
return 0;
}
#***************************************Funciones de Prueba VER!!!!!!!!!!!!!!!!!!!!*******

sub sepuederenovar2(){
my ($borrowernumber,$itemnumber)=@_;
my $dbh = C4::Context->dbh;

my $sth=$dbh->prepare(" Select * from reserves inner join issues on 				issues.itemnumber=reserves.itemnumber 
			and reserves.borrowernumber=issues.borrowernumber  where reserves.itemnumber=? 
			and reserves.borrowernumber=? and reserves.constrainttype='P' and returndate is null");

$sth->execute($itemnumber,$borrowernumber);
my $data= $sth->fetchrow_hashref;
if ($data){

	my $issuetype=IssueType($data->{'issuecode'});
	
	if ($issuetype->{'renew'} eq 0){ #Si es 0 NO SE RENUEVA NUNCA
					return 0;
					}

	if (!&hayReservasEsperando($data->{'biblioitemnumber'})){
		#quiere decir que no hay reservas esperando por lo que podemos seguir
		
		if (!estaSancionado($dbh, $borrowernumber, $data->{'issuecode'})){
			#El usuario no tiene sanciones, puede seguir.
			
			#veo si el nro de renovaciones realizadas es mayor al nro maximo de renovaciones posibles permitidas

			my $intervalo_vale_renovacion=$issuetype->{'dayscanrenew'}; #Numero de dias en el que se puede hacer la renovacion antes del vencimiento.
			my $plazo_actual;

			if ($data->{'renewals'}){#quiere decir que ya fue renovado entonces tengo que calcular sobre los dias de un prestamo renovado para saber si estoy en fecha
				my $maximo_de_renovaciones=$issuetype->{'renew'};
				if ($data->{'renewals'} lt $maximo_de_renovaciones) {#quiere decir que no se supero el maximo de renovaciones
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

sub estaSancionado(){
	my ($dbh,$borrowernumber,$issuecode)=@_;
	my @sancion= permitionToLoan($dbh, $borrowernumber, $issuecode);
	if (($sancion[0]||$sancion[1])) { 
		return 1;
	}
}

sub chequeoDeFechas(){
	my ($cantDiasRenovacion,$fechaRenovacion,$intervalo_vale_renovacion)=@_;
	# La $fechaRenovacion es la ultima fecha de renovacion o la fecha del prestamo si nunca se renovo
	my $plazo_actual=$cantDiasRenovacion;# Cuantos dias más se puede renovar el prestamo
	my $vencimiento=proximoHabil($plazo_actual,0,$fechaRenovacion);
	my $err= "Error con la fecha";
	my $hoy=C4::Date::format_date_in_iso(DateCalc(ParseDate("today"),"+ 0 days",\$err));#se saco el 2 para que ande bien.
	my $desde=C4::Date::format_date_in_iso(DateCalc($vencimiento,"- ".$intervalo_vale_renovacion." days",\$err));	
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
 
sub renovar{
	my ($borrowernumber,$itemnumber)=@_;
	my $renovacion= &sepuederenovar2($borrowernumber,$itemnumber);
	if ($renovacion){
#Esto quiere decir que se puede renovar el prestamo, por lo tanto lo renuevo
		my $dbh = C4::Context->dbh;
		my $sth=$dbh->prepare("UPDATE issues SET renewals= IFNULL(renewals,0) + 1, lastreneweddate = now() WHERE itemnumber = ? AND borrowernumber = ?");
		$sth->execute($itemnumber, $borrowernumber);

	my	$sth3=$dbh->prepare("Insert into historicCirculation (type,borrowernumber,date,itemnumber,branchcode) values (?,?,NOW(),?,?,?);");
                $sth3->execute('renew',$borrowernumber,$itemnumber);

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
							$res.=', '.$data->{'itemnumber'};
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


sub verificarTipoPrestamo{
#retorna verdadero si se puede hacer un determinado tipo de prestamo
	my ($issuetype,$notforloan)=@_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("Select * from issuetypes where issuecode = ? and notforloan = ?");
	$sth->execute($issuetype,$notforloan);
	return($sth->fetchrow_hashref);
}


sub IssueType{
#retorna los datos del tipo de prestamo
	my ($issuetype)=@_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("Select *  from issuetypes where issuecode = ?");
	$sth->execute($issuetype);
	return($sth->fetchrow_hashref);
}

sub IssuesType{
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


sub DatosPrestamos {
  #Esta funcion retorna los datos de los prestamos de un usuario
  my ($borrowernumber)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from issues where returndate is NULL and borrowernumber = ?");
  $sth->execute($borrowernumber);
  my $hoy=C4::Date::format_date_in_iso(ParseDate("today"));
  my @result;
  while (my $ref= $sth->fetchrow_hashref) {
    my $fechaDeVencimiento= C4::AR::Issues::vencimiento($ref->{'itemnumber'});
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
  my $sth=$dbh->prepare("Select * from issues where returndate is NULL and borrowernumber = ? and issuecode=?");
  $sth->execute($borrowernumber,$issuetype);
  my $hoy=C4::Date::format_date_in_iso(ParseDate("today"));
  my @result;
  while (my $ref= $sth->fetchrow_hashref) {
    my $fechaDeVencimiento= C4::AR::Issues::vencimiento($ref->{'itemnumber'});
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

