# -*- tab-width: 8 -*-
# NOTE: This file uses standard 8-character tabs

package C4::AR::Reserves;

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
use C4::Context;
use C4::Search;
use C4::AR::Sanctions;
use C4::AR::Issues;
use Date::Manip;
use Time::HiRes qw(gettimeofday);
use Thread;
use Mail::Sendmail;
use C4::Date;


use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::AR::Reserves

=head1 SYNOPSIS

  use C4::AR::Reserves;

=head1 DESCRIPTION

FIXME

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);

@EXPORT = qw(
    &borrowerissues
    &FindReserves
    &FindNotRegularUsersWithReserves
    &reservar
    &reservaritem
    &DatosReservas
    &cancelar_reserva
    &cancelar_reservas
    &cancelar_reservas_inmediatas
    &efectivizar_reserva
    &Enviar_Email
    &cant_reserves
    &cant_waiting	
    &tiene_reservas 
    &intercambiar_itemnumber
    &eliminarReservasVencidas

);

sub isRegular
{
        my ($bor) = @_;
        my $dbh = C4::Context->dbh;
	my $regular=1; #Regular por defecto
        my $sth = $dbh->prepare("SELECT regular FROM persons WHERE borrowernumber = ? and categorycode='ES'" );
        $sth->execute($bor);
        my $reg = $sth->fetchrow();
	if (($reg eq 1)|| ($reg eq 0)){$regular = $reg;}
        $sth->finish();
	
	return $regular;
	
} # sub getcitycategory

 
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
my ($borrowernumber,$biblioitemnumber,$branch)=@_;
my $dbh = C4::Context->dbh;

#my @sancion=(0,0); #estasancionado($borr); Deberia devolver 2 valores distintos uno si esta sancionado y otro si esta atrasado, y hasta cuando esta sancionado
my @sancion= &permitionToLoan($dbh, $borrowernumber, C4::Context->preference("defaultissuetype"));
#Si esta sancionado devuelvo false
if ($sancion[0]) {return (0,1,$sancion[1]);}

my ($resnum, $reserves) = DatosReservas($borrowernumber);
#my $wcount=0;
#my $rcount=0;
#my $waiting;
#my $realreserves;

=item
foreach my $res (@$reserves) {
    if ($res->{'ritemnumber'}) {
	  push @$realreserves, $res;
        $rcount++;
    }
        else{
  push @$waiting, $res;
        $wcount++;

        }}
=cut

#Si el nro de reservas supera a lo maximo devuelvo false
my $MAXIMUM_NUMBER_OF_RESERVES = C4::Context->preference("maxreserves");
if ($resnum >= $MAXIMUM_NUMBER_OF_RESERVES) {return (0,2,$reserves,$resnum);}

#Si el nro de reservas en espera supera a lo maximo devuelvo false
#my $MAXIMUM_NUMBER_OF_RESERVES_WAITING = C4::Context->preference("maxwaiting");
#if ($wcount >= $MAXIMUM_NUMBER_OF_RESERVES) {return (0,5,$waiting,$wcount);}

#Si el ya tiene una reserva sobre ese grupo
foreach my $resaux (@$reserves){
	if ($resaux->{'rbiblioitemnumber'} eq $biblioitemnumber )
	{
		return (0,3);
	}
}
#Si ya tiene un prestamo sobre el mismo grupo
my ($isunum, $issues) = borrowerissues($borrowernumber);
for (my $i=0;$i<$isunum;$i++){
	if ($issues->[$i]{'biblioitemnumber'} eq $biblioitemnumber) {
		return (0,4);
	}
}

#Si NO es regular
my $regular =  isRegular($borrowernumber);

if ($regular eq 0){return (0,6);}




#Si esta todo ok, trato de reservar
my $sth=$dbh->prepare("SET autocommit=0");
$sth->execute();
$sth=$dbh->prepare("Select reserves.itemnumber from reserves where biblioitemnumber=? for update ");
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

my $sth1=$dbh->prepare("Select items.itemnumber, items.holdingbranch from items where items.biblioitemnumber=? and notforloan='0' and wthdrawn='0' and items.itemnumber ". $res);
$sth1->execute($biblioitemnumber);
my $data2= $sth1->fetchrow_hashref;
my ($fecha,$apertura,$cierre);
my $desde;
if ($data2){
#se encontro algun item que se pudo reservar

#MATIAS: Antes de reservar un item en particular se verifica si el usuario no tiene ya el maximo de prestamos domiciliarios
  my ($cant, @issuetypes) = C4::AR::Issues::PrestamosMaximos ($borrowernumber);
       foreach my $iss (@issuetypes){
	if ($iss->{'issuecode'} eq "DO"){#Domiciliario al maximo
	return (0,9);
	}}
#

$fecha=C4::Context->preference("reserveItem");
($desde,$fecha,$apertura,$cierre)=proximosHabiles($fecha,1);

#**********************************Se registra el movimiento en historicCirculation***************************
my $dataItems= C4::Circulation::Circ2::getDataItems($data2->{'itemnumber'});
my $biblionumber= $dataItems->{'biblionumber'};
my $branchcode= $dataItems->{'homebranch'};

C4::Circulation::Circ2::insertHistoricCirculation('reserve',$borrowernumber,$borrowernumber,$biblionumber,$biblioitemnumber,$data2->{'itemnumber'},$branchcode,'-');
#*******************************Fin***Se registra el movimiento en historicCirculation*************************

my $sth2=$dbh->prepare("insert into reserves (itemnumber,biblioitemnumber,borrowernumber,reservedate,notificationdate,reminderdate,branchcode) values (?,?,?,?,NOW(),?,?) ");
$sth2->execute($data2->{'itemnumber'},$biblioitemnumber,$borrowernumber,$desde,$fecha,$data2->{'holdingbranch'});
#reminderdate le puse la fecha de vencimiento de la reserva
$resultado=$data2->{'itemnumber'};
my $sth3=$dbh->prepare("SELECT LAST_INSERT_ID() ");
$sth3->execute();
my $reservenumber= $sth3->fetchrow;

# Se agrega una sancion que comienza el dia siguiente al ultimo dia que tiene el usuario para ir a retirar el libro
my $err= "Error con la fecha";
my $startdate= DateCalc($fecha,"+ 1 days",\$err);
$startdate= C4::Date::format_date_in_iso($startdate);
my $daysOfSanctions= C4::Context->preference("daysOfSanctionReserves");
my $enddate= DateCalc($startdate, "+ $daysOfSanctions days", \$err);
$enddate= C4::Date::format_date_in_iso($enddate);
insertSanction($dbh, undef, $reservenumber ,$borrowernumber, $startdate, $enddate, undef);

} else{

#**********************************Se registra el movimiento en historicCirculation***************************
my $dataBiblioItems= C4::Circulation::Circ2::getDataBiblioItems($biblioitemnumber);

my $biblionumber= $dataBiblioItems->{'biblionumber'};
my $branchcode= '-';
my $issuetype= '-';
my $itemnumber= 0;
my $loggedinuser= $borrowernumber;

C4::Circulation::Circ2::insertHistoricCirculation('queue',$borrowernumber,$loggedinuser,$biblionumber,$biblioitemnumber,$itemnumber,$branchcode,$issuetype);
#*******************************Fin***Se registra el movimiento en historicCirculation*************************

#se hace una reserva para el grupo, ya que no hay ningun item libre
my $sth2=$dbh->prepare("insert into reserves (biblioitemnumber,borrowernumber,reservedate) values (?,?,NOW()) ");
$sth2->execute($biblioitemnumber,$borrowernumber);
$desde='0000-00-00';#FechaFactible(); #la fecha factible en que el libro este disponible, hya que hacer una funcion medio rara
$fecha='0000-00-00';#hasta cuando lo puede retirar es mas subjetivo aun
$resultado=0;
}
my $sth3=$dbh->prepare("commit ");
$sth3->execute();

return (1,$resultado,$desde,$fecha,$branch,$apertura,$cierre);
}

sub reservaritem {
my ($borrowernumber,$biblioitemnumber,$itemnumber,$branch,$immediateIssue,$issuetype)=@_;

my $dbh = C4::Context->dbh;
my $resultado;
$issuetype = $issuetype || C4::Context->preference("defaultissuetype");

if ($issuetype eq 'ES'){
#Si es un prestamo especial hay que verificar el horario del mismo
my $end = ParseDate(C4::Context->preference("close"));
my $begin =calc_beginES();
my $actual=ParseDate("today");

if ((Date_Cmp($actual, $begin) < 0) || (Date_Cmp($actual, $end) > 0)){return(0,8);}
		}
#

# Si es un prestamo inmediato y ya tiene todos los prestamos para el tipo de prestamo da un error
if ($immediateIssue) {
	my $sth=$dbh->prepare("SELECT maxissues FROM issuetypes WHERE issuecode = ? ");
	$sth->execute($issuetype);
	my $maxissues= $sth->fetchrow;
	$sth->finish;
	my ($cantissues, $issues)= C4::AR::Issues::DatosPrestamosPorTipo($borrowernumber,$issuetype);
	if ($cantissues >= $maxissues) {return(0,7)}
}

my @sancion= &permitionToLoan($dbh, $borrowernumber, $issuetype);
#Si esta sancionado devuelvo false
if ($sancion[0]) {return (0,1,$sancion[1]);}
my $MAXIMUM_NUMBER_OF_RESERVES = C4::Context->preference("maxreserves");
my ($resnum, $reserves) = DatosReservas($borrowernumber);
#Si el nro de reservas supera el maximo y no es un prestamo inmediato => provoca un error
return (0,2,$reserves,$resnum) if (($resnum >= $MAXIMUM_NUMBER_OF_RESERVES) && (!$immediateIssue));

foreach my $resaux (@$reserves){
	#Si ya tiene reservado el ejemplar
	if ($resaux->{'ritemnumber'} eq $itemnumber ){return (0,5);}
	#Si ya tiene una reserva sobre ese grupo
	if ($resaux->{'rbiblioitemnumber'} eq $biblioitemnumber ){return (0,3);}
}
#Si ya tiene un prestamo sobre el mismo grupo
my ($isunum, $issues) = borrowerissues($borrowernumber);
for (my $i=0;$i<$isunum;$i++){
	if ($issues->[$i]{'biblioitemnumber'} eq $biblioitemnumber) {
		return (0,4);
	}
}


#Si NO es regular
my $regular =  isRegular($borrowernumber);
if ($regular eq 0){return (0,6);}


#Si esta todo ok, trato de reservar
my $sth=$dbh->prepare("SET autocommit=0 ");
$sth->execute();


#Veo si es Para sala o no esta disponible
my $sth3=$dbh->prepare("Select items.itemnumber, items.notforloan, items.wthdrawn from items where items.itemnumber = ?");
$sth3->execute($itemnumber);
my $data3= $sth3->fetchrow_hashref;
my $sepuede= (($data3->{'notforloan'} eq 0 )&&($data3->{'wthdrawn'} eq 0));

$sth=$dbh->prepare("Select * from reserves where itemnumber=? ");
$sth->execute($itemnumber);
my $resaux;
if (($resaux=$sth->fetchrow_hashref)||($sepuede)){ #hay una reserva para el item que se quiere prestar, por lo tanto busco alguno del grupo que este disponible
	$sth=$dbh->prepare("Select reserves.itemnumber from reserves where biblioitemnumber=? for update ");
	$sth->execute($biblioitemnumber);
	my $res;
	if (my $data= $sth->fetchrow_hashref){
		$res=' not in ('.$data->{'itemnumber'};
		while (my $data= $sth->fetchrow_hashref){$res.=', '.$data->{'itemnumber'};}  
		$res.=')';
	}else{
		$res='';
	}

	my $sth1=$dbh->prepare("Select items.itemnumber, items.holdingbranch from items where items.biblioitemnumber=? and notforloan='0' and wthdrawn='0' and items.itemnumber ". $res);
	$sth1->execute($biblioitemnumber);
	my $data2= $sth1->fetchrow_hashref;
	my ($fecha,$apertura,$cierre);
	my $desde;
	if ($data2){ #si el itemnumber que se quiere reservar ya esta reservado y hay otro libre => hago el intercambio para que el que quiero quede liberado
		$sth=$dbh->prepare("update reserves set itemnumber= ? where itemnumber = ?");
		$sth->execute($data2->{'itemnumber'}, $itemnumber);
	} elsif($resnum < $MAXIMUM_NUMBER_OF_RESERVES) {
	#se hace una reserva para el grupo, ya que no hay ningun item libre
		my $sth2=$dbh->prepare("insert into reserves (biblioitemnumber,borrowernumber,reservedate) values (?,?,NOW())");
		$sth2->execute($biblioitemnumber,$borrowernumber);
		$desde='0000-00-00';#FechaFactible(); #la fecha factible en que el libro este disponible, hya que hacer una funcion medio rara
		$fecha='0000-00-00';#hasta cuando lo puede retirar es mas subjetivo aun
		$resultado=0;
		my $sth3=$dbh->prepare("commit");
		$sth3->execute();
		return (1,$resultado,$desde,$fecha,$branch,$apertura,$cierre); # si reserve para el grupo entonces devuelve $resultado=0 
		#sino devuelve el itemnumber del libro que se reservo => esto no va mas desde que se puede elegir el item a prestar 
		#Luciano al 23/03/2006
	} else {
		$resultado=-1;
		my $sth3=$dbh->prepare("commit");
		$sth3->execute();
		return (1,$resultado); # si ya no puede hacer mas reservas => devuelve $resultado=-1
	}
}

#el item no esta reservado por lo que el usuario se lo puede llevar inmediatamente
#si el item es para sala viene aca
my ($desde,$fecha,$apertura,$cierre)=proximosHabiles(1,1);
my $sth2=$dbh->prepare("insert into reserves (itemnumber,biblioitemnumber,borrowernumber,reservedate,notificationdate,reminderdate,branchcode) values (?,?,?,?,NOW(),?,?)");
$sth2->execute($itemnumber,$biblioitemnumber,$borrowernumber,$desde,$fecha,$branch);
my $sth3=$dbh->prepare("commit");
$sth3->execute();
return (2,$resultado,$desde,$fecha,$branch,$apertura,$cierre);

}

=item
Funcion que cancela una reserva
Se invoca con dos parametros cancelar-reserva($biblioitem,$borrowernumber);
un biblioitem y un numero de usuario correspondiente al que hizo la reserva, ya que son los dos campos con los que identifico una reserva sin duplicados
=cut

sub cancelar_reserva {

	my ($biblioitemnumber,$borrowernumber,$loggedinuser)=@_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("SET autocommit=0;");
	$sth->execute();
#Primero busco los datos de la reserva que se quiere borrar
	$sth=$dbh->prepare("Select * from reserves where biblioitemnumber=? and borrowernumber=? for update");
	$sth->execute($biblioitemnumber,$borrowernumber);
	my @resultado;
	my $data= $sth->fetchrow_hashref;
	if($data->{'itemnumber'}){ #Si la reserva que voy a cancelar estaba asociada a un item tengo que reasignar ese item a otra reserva para el mismo grupo
		my $sth1=$dbh->prepare("Select * from reserves where biblioitemnumber=? and itemnumber is NULL order by timestamp limit 1");
		$sth1->execute($biblioitemnumber);
# Se borra la sancion correspondiente a la reserva si es que la sancion todavia no entro en vigencia
		my $sth4=$dbh->prepare("Delete from sanctions where reservenumber=? and (now() < startdate)");
		$sth4->execute($data->{'reservenumber'});

		my $data2= $sth1->fetchrow_hashref;

		if ($data2) { #Quiere decir que hay reservas esperando para este mismo grupo
			@resultado= ($data->{'itemnumber'}, $data2->{'biblioitemnumber'}, $data2->{'borrowernumber'}, $data2->{'reservenumber'});
		}
	}

#Actualizo la sancion para que refleje el itemnumber y asi poder informalo
	my $sth6=$dbh->prepare(" UPDATE sanctions SET itemnumber = ? WHERE reservenumber = ? ");
	$sth6->execute($data->{'itemnumber'},$data->{'reservenumber'});

#Haya o no uno esperando elimino el que existia porque la reserva se esta cancelando
	$sth=$dbh->prepare("Delete from reserves where biblioitemnumber=? and borrowernumber=?");
	$sth->execute($biblioitemnumber,$borrowernumber);

	if (@resultado) {#esto quiere decir que se realizo un movimiento de asignacion de item a una reserva que estaba en espera en la base, hay que actualizar las fechas y notificarle al usuario
		my ($desde,$fecha,$apertura,$cierre)=proximosHabiles(C4::Context->preference("reserveGroup"),1);
		$sth=$dbh->prepare("Update reserves set itemnumber=?,reservedate=?,notificationdate=NOW(),reminderdate=?,branchcode=? where biblioitemnumber=? and borrowernumber=? ");
		$sth->execute($resultado[0], $desde, $fecha,$data->{'branchcode'},$resultado[1],$resultado[2]);

# Se agrega una sancion que comienza el dia siguiente al ultimo dia que tiene el usuario para ir a retirar el libro
		my $err= "Error con la fecha";
		my $startdate= DateCalc($fecha,"+ 1 days",\$err);
		$startdate= C4::Date::format_date_in_iso($startdate);
		my $daysOfSanctions= C4::Context->preference("daysOfSanctionReserves");
		my $enddate= DateCalc($startdate, "+ $daysOfSanctions days", \$err);
		$enddate= C4::Date::format_date_in_iso($enddate);
		insertSanction($dbh, undef, $resultado[3] ,$borrowernumber, $startdate, $enddate, undef);

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

	if($data->{'itemnumber'}){

		my $dataItems= C4::Circulation::Circ2::getDataItems($data->{'itemnumber'});
		$biblionumber= $dataItems->{'biblionumber'};
		$branchcode= $dataItems->{'homebranch'};
	}else{
		my $dataBiblioItems= C4::Circulation::Circ2::getDataBiblioItems($biblioitemnumber);
		$biblionumber= $dataBiblioItems->{'biblionumber'};
		$branchcode= 0;
	}
	
	my $issuetype= '-';
	my $loggedinuser= $borrowernumber;
	
	C4::Circulation::Circ2::insertHistoricCirculation('cancel',$borrowernumber,$loggedinuser,$biblionumber,$biblioitemnumber,$data->{'itemnumber'},$branchcode,$issuetype); #C4::Circulation::Circ2
#******************************Fin****Se registra el movimiento en historicCirculation*************************
}







=item

Funcion que efectiviza una reserva
Se invoca con dos parametros efectivizar_reserva($biblioitem,$borrowernumber);
un biblioitem y un numero de usuario correspondiente al que hizo la reserva, ya que son los dos campos con los que identifico una reserva sin duplicacos

=cut

sub efectivizar_reserva{

	my $dbh = C4::Context->dbh;
	my ($borrowernumber,$biblioitemnumber,$issuecode,$loggedinuser)=@_;
	my @sancion= permitionToLoan($dbh, $borrowernumber, $issuecode);
	if ($sancion[0]||$sancion[1]) {
		return 0;
	} else {

		#Si NO es regular
		my $regular =  isRegular($borrowernumber);
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
		if($data->{'itemnumber'}){ #Si la reserva que voy a efectivizar estaba asociada a un item se puede sino hubo un error
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
	
			C4::Circulation::Circ2::insertHistoricCirculation('issue',$data->{'borrowernumber'},$loggedinuser,$biblionumber,$biblioitemnumber,$data->{'itemnumber'},$data->{'branchcode'},$issuecode);
#********************************Fin**Se registra el movimiento en historicCirculation*************************

			$sth3=$dbh->prepare("commit;");
			$sth3->execute();

		}

		return 1;
	}
}

#para enviar un mail cuando al usuario se le vence la reserva
sub Enviar_Email{

my ($itemnumber,$bor,$desde, $fecha, $apertura,$cierre,$loggedinuser)=@_;

if (C4::Context->preference("EnabledMailSystem")){

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

my $mailFrom=C4::Context->preference("reserveFrom");
my $mailSubject =C4::Context->preference("reserveSubject");
my $mailMessage =C4::Context->preference("reserveMessage");
my $branchname= C4::Search::getbranchname($borrower->{'branchcode'});
$res->{'rauthor'}=(C4::Search::getautor($res->{'rauthor'}))->{'completo'};

$mailSubject =~ s/BRANCH/$branchname/;
$mailMessage =~ s/BRANCH/$branchname/;
$mailMessage =~ s/FIRSTNAME/$borrower->{'firstname'}/;
$mailMessage =~ s/SURNAME/$borrower->{'surname'}/;
$mailMessage =~ s/UNITITLE/$res->{'runititle'}/;
$mailMessage =~ s/TITLE/$res->{'rtitle'}/;
$mailMessage =~ s/AUTHOR/$res->{'rauthor'}/;
$mailMessage =~ s/EDICION/$res->{'redicion'}/;
$mailMessage =~ s/a2/$apertura/;
$desde=format_date($desde);
$mailMessage =~ s/a1/$desde/;
$mailMessage =~ s/a3/$cierre/;
$fecha=format_date($fecha);
$mailMessage =~ s/a4/$fecha/;
my %mail = ( To => $borrower->{'emailaddress'},
                        From => $mailFrom,
                        Subject => $mailSubject,
                        Message => $mailMessage);
my $resultado='ok';
if ($borrower->{'emailaddress'} && $mailFrom ){
	sendmail(%mail) or die $resultado='error';
}else {$resultado='';}

#**********************************Se registra el movimiento en historicCirculation***************************
my $issuetype= '-';
my $dataItems= C4::Circulation::Circ2::getDataItems($itemnumber);
my $branchcode= $dataItems->{'homebranch'};
C4::Circulation::Circ2::insertHistoricCirculation('notification',$bor,$loggedinuser,$res->{'rbiblionumber'},$res->{'rbiblioitemnumber'},$itemnumber,$branchcode,$issuetype);
#*******************************Fin***Se registra el movimiento en historicCirculation*************************

	}#end if (C4::Context->preference("EnabledMailSystem"))
}



=item FindReserves

  ($count, $results) = &FindReserves($biblionumber, $borrowernumber);

Looks books up in the reserves. C<$biblionumber> is the biblionumber
of the book to look up. C<$borrowernumber> is the borrower number of a
patron whose books to look up.

Either C<$biblionumber> or C<$borrowernumber> may be the empty string,
but not both. If both are specified, C<&FindReserves> looks up the
given book for the given patron. If only C<$biblionumber> is
specified, C<&FindReserves> looks up that book for all patrons. If
only C<$borrowernumber> is specified, C<&FindReserves> looks up all of
that patron's reserves. If neither is specified, C<&FindReserves>
barfs.

For each book thus found, C<&FindReserves> checks the reserve
constraints and does something I don't understand.

C<&FindReserves> returns a two-element array:

C<$count> is the number of elements in C<$results>.

C<$results> is a reference-to-array; each element is a
reference-to-hash, whose keys are (I think) all of the fields of the
reserves, borrowers, and biblio tables of the Koha database.

=cut
#'

sub FindReserves {
	my ($bib,$bor)=@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT 	*
		FROM 	reserves";
	$query .= " where reserves.borrowernumber = ?
					and cancellationdate is NULL and
					(found <> 'F' or found is NULL) and 
					reserves.constrainttype is NULL";
	my $sth=$dbh->prepare($query);
	$sth->execute($bor);
	my @results;
	while (my $data=$sth->fetchrow_hashref){
	
	push (@results,$data);
	}
	
	$sth->finish;
	return($#results+1,\@results);
}

sub FindNotRegularUsersWithReserves {
	my $dbh = C4::Context->dbh;
        my $query="SELECT reserves.borrowernumber FROM reserves inner join persons
			on reserves.borrowernumber = persons.borrowernumber
			where regular = '0'
			and cancellationdate is NULL
			and (found <> 'F' or found is NULL)
			and reserves.constrainttype is NULL";
        my $sth=$dbh->prepare($query);
        $sth->execute();
        my @results;
        while (my $data=$sth->fetchrow){
		push (@results,$data);
        }
        $sth->finish;
        return(@results);
}

sub DatosReservas {
	my ($bor)=@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT biblio.title as rtitle, biblio.unititle as runititle, biblio.biblionumber as rbiblionumber,biblio.author as rauthor, reserves.biblioitemnumber as rbiblioitemnumber,reserves.notificationdate as rnotificationdate,reserves.reservedate as rreservedate, reserves.reminderdate as rreminderdate, biblioitems.volume as volume, biblioitems.number as redicion, biblioitems.publicationyear as rpublicationyear, reserves.itemnumber as ritemnumber, reserves.branchcode as rbranch
	FROM reserves
	inner join biblioitems on  biblioitems.biblioitemnumber = reserves.biblioitemnumber
	inner join biblio on biblioitems.biblionumber = biblio.biblionumber";
	$query .= " WHERE  reserves.borrowernumber =? 
					and cancellationdate is NULL and
					(found <> 'F' or found is NULL) and reserves.constrainttype is NULL";
#13/03/2007 se agrego el a�o de publicacion (rpublicationyear) para mostrar en la interfaz - Damian
	my $sth=$dbh->prepare($query);
	$sth->execute($bor);
	my @results;
	while (my $data=$sth->fetchrow_hashref){

		push (@results,$data);
	}
	
	$sth->finish;
	return($#results+1,\@results);
}

sub cant_reserves
{
#Cantidad de reservas reales
        my ($bor)=@_;
        my $dbh = C4::Context->dbh;
        my $query="SELECT count(*) as cant from reserves"; 
        $query .= " WHERE  reserves.borrowernumber =? 
                                        and cancellationdate is NULL and
                                        (found <> 'F' or found is NULL) and reserves.constrainttype is NULL
					and itemnumber is not Null ";
        my $sth=$dbh->prepare($query);
        $sth->execute($bor);
        my $result=$sth->fetchrow_hashref;
        $sth->finish;
        return($result);
}

sub tiene_reservas {
  my ($itemnum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("SELECT * FROM reserves  WHERE 
				cancellationdate is NULL and
                                (found <> 'F' or found is NULL) and reserves.constrainttype is NULL
                                        and itemnumber = ?");
    $sth->execute($itemnum);

 my $result="";
        if (my $data = $sth->fetchrow_hashref)
                { $result=1} else { $result=0}
        return($result);

}

sub cant_waiting
{
#Cantidad de reservas en espera
        my ($bor)=@_;
        my $dbh = C4::Context->dbh;
        my $query="SELECT count(*) as cant from reserves";
        $query .= " WHERE  reserves.borrowernumber = ?
                                        and cancellationdate is NULL and
                                        (found <> 'F' or found is NULL) and reserves.constrainttype is NULL
                                        and itemnumber is Null ";
        my $sth=$dbh->prepare($query);
        $sth->execute($bor);
        my $result=$sth->fetchrow_hashref;
        $sth->finish;
        return($result);
}


sub cancelar_reservas{
# Este procedimiento cancela todas las reservas de los usuarios recibidos como parametro
	my ($loggedinuser,@borrowersnumbers)= @_;
        my $dbh = C4::Context->dbh;
	foreach (@borrowersnumbers) {
		my $sth=$dbh->prepare("SELECT biblioitemnumber FROM reserves where borrowernumber = ? and constrainttype is NULL");
		$sth->execute($_);
		while (my $biblioitemnumber= $sth->fetchrow){
			&cancelar_reserva($biblioitemnumber, $_,$loggedinuser);
		}
		$sth->finish;
	}
}


sub cancelar_reservas_inmediatas{
	my ($loggedinuser)=@_;
# Este procedimiento cancela todas las reservas con item ya asignado de los usuarios recibidos como parametro
	my @borrowersnumbers= @_;
        my $dbh = C4::Context->dbh;
	foreach (@borrowersnumbers) {
		my $sth=$dbh->prepare("SELECT biblioitemnumber FROM reserves where borrowernumber = ? and constrainttype is NULL and itemnumber is not NULL ");
		$sth->execute($_);
		while (my $biblioitemnumber= $sth->fetchrow){
			&cancelar_reserva($biblioitemnumber, $_,$loggedinuser);
		}
		$sth->finish;
	}
}

sub intercambiar_itemnumber{
	my ($borrowernumber, $biblioitemnumber, $itemnumber, $olditemnumber)= @_;
        my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("SET autocommit=0");
	$sth->execute();
	$sth=$dbh->prepare("Select reserves.itemnumber from reserves where itemnumber=? for update ");
	$sth->execute($itemnumber);
	
	if (my $data= $sth->fetchrow_hashref){ #quiere decir que hay una reserva sobre el itemnumber
		$sth=$dbh->prepare("update reserves set itemnumber= ? where itemnumber = ?");
		$sth->execute($olditemnumber, $itemnumber);
	}
	#actualizo la reserva con el nuevo itemnumber
	$sth=$dbh->prepare("update reserves set itemnumber= ? where biblioitemnumber=? and borrowernumber=?");
	$sth->execute($itemnumber, $biblioitemnumber, $borrowernumber);

	my $sth3=$dbh->prepare("commit ");
	$sth3->execute();
}

sub eliminarReservasVencidas(){
	my ($loggedinuser)=@_;
	my $dbh = C4::Context->dbh;

	my $sth=$dbh->prepare("SET autocommit=0");
	$sth->execute();
	my $query= "SELECT * FROM reserves WHERE constrainttype IS NULL AND reminderdate < NOW() AND itemnumber IS NOT NULL";
	my $sth=$dbh->prepare($query);
	$sth->execute();
	#Se buscan si hay reservas esperando sobre el grupo que se va a elimninar la reservas vencidas
	my @resultado;
	while(my $data=$sth->fetchrow_hashref){
		my $sth1=$dbh->prepare("Select * from reserves where biblioitemnumber=? and itemnumber is NULL order by timestamp limit 1 ");
		$sth1->execute($data->{'biblioitemnumber'});
		my $data2= $sth1->fetchrow_hashref;
		if ($data2) { #Quiere decir que hay reservas esperando para este mismo grupo
			@resultado= ($data->{'itemnumber'}, $data2->{'biblioitemnumber'}, $data2->{'borrowernumber'});
		}

		#Actualizo la sancion para que refleje el itemnumber y asi poder informalo
		my $sth6=$dbh->prepare(" UPDATE sanctions SET itemnumber = ? WHERE reservenumber = ? ");
		$sth6->execute($data->{'itemnumber'},$data->{'reservenumber'});

		#Haya o no uno esperando elimino el que existia porque la reserva se esta cancelando
		my $sth3=$dbh->prepare("DELETE FROM reserves WHERE reservenumber=? ");
		$sth3->execute($data->{'reservenumber'});


		if (@resultado){
		#esto quiere decir que se realizo un movimiento de asignacion de item a una reserva que estaba en espera en la base, hay que actualizar las fechas y notificarle al usuario
			my ($desde,$fecha,$apertura,$cierre)=proximosHabiles(C4::Context->preference("reserveGroup"),1);
			my $sth4=$dbh->prepare("Update reserves set itemnumber=?,reservedate=?,notificationdate=NOW(),reminderdate=? where biblioitemnumber=? and borrowernumber=? ");
			$sth4->execute($resultado[0], $desde, $fecha,$resultado[1],$resultado[2]);
			C4::AR::Reserves::Enviar_Email($resultado[0],$resultado[2],$desde, $fecha, $apertura,$cierre,$loggedinuser);
		}
	}
	my $sth5=$dbh->prepare("commit ");
	$sth5->execute();
}

1;
