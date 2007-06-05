package C4::AR::Sanctions;

#
# Modulo para hacer calculos de dias a sancionar
#

use strict;
require Exporter;
use C4::Context;
use C4::Date;
use Date::Manip;
use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(	&SanctionDays 
		&isSanction 
		&sanctionSelect 
		&hasDebts 
		&permitionToLoan 
		&insertSanction 
		&getSanctionTypeCode 
		&hasSanctions 
		&getBorrowersSanctions 
		&delSanction
		&sanciones
);

sub SanctionDays {
# Retorna la cantidad de dias de sancion que corresponden a una devolucion
# Si retorna 0 (cero) entonces no corresponde una sancion
# Recibe la fecha de devolucion (returndate), la fecha hasta la que podia devolverse (date_due), la categoria del usuario (categorycode) y el tipo de prestamo (issuecode)
  my ($dbh, $returndate, $date_due, $categorycode, $issuecode)=@_;
  
#open L,">>/tmp/mono";
	 my $late=0; #Se devuelve tarde
	 
  if (Date_Cmp($date_due, $returndate) >= 0) {
    #Si es un prestamo especial debe devolverlo antes de una determinada hora
   if ($issuecode ne 'ES'){return(0);}
   	else{#Prestamo especial
		
	if (Date_Cmp($date_due, $returndate) == 0){#Se tiene que devolver hoy	
	my $begin = ParseDate(C4::Context->preference("open"));
	my $end =calc_endES();
	my $actual=ParseDate("today");
	if (Date_Cmp($actual, $end) <= 0){#No hay sancion se devuelve entre la apertura de la biblioteca y el limite
					return(0);}
						 }else {#Se devuelve antes de la fecha de devolucion
 						return(0);}
	
                
		}#else ES
	}#if Date_Cmp
 

#Corresponde una sancion
  my $sth = $dbh->prepare("select *,issuetypes.description as descissuetype, categories.description as desccategory from sanctiontypes inner join sanctiontypesrules on sanctiontypes.sanctiontypecode = sanctiontypesrules.sanctiontypecode inner join sanctionrules on sanctiontypesrules.sanctionrulecode = sanctionrules.sanctionrulecode inner join issuetypes on sanctiontypes.issuecode = issuetypes.issuecode inner join categories on categories.categorycode = sanctiontypes.categorycode where sanctiontypes.issuecode = ? and sanctiontypes.categorycode = ? 
 order by sanctiontypesrules.order");
  $sth->execute($issuecode, $categorycode);
  my $err;
  my $delta= &DateCalc($date_due,$returndate,\$err);
  my $days= &Delta_Format($delta,0,"%dh");
  
  
  #Si es un prestamo especial, si se pasa de la hora se toma como si se pasara un día
  if ($issuecode eq 'ES'){$days++;}
  #
  
  my $daysExceeded= $days;
  
  my $amountOfDays= 0;
  my $i;

  while ((my $res = $sth->fetchrow_hashref) && ($daysExceeded > 0)) {
	
	my $amount= $res->{'amount'};
        my $sanctiondays= $res->{'sanctiondays'};
        my $delaydays= $res->{'delaydays'};
	
	
	for ($i=0; (($i < $amount) || ($amount==0)) && ($daysExceeded > 0); $i++) {
		$daysExceeded-= $delaydays;
		$amountOfDays+= $sanctiondays;	
	}
  }	
 

  $sth->finish;
  return($amountOfDays);
}

sub hasSanctions {
  #Esta funcion retorna un arreglo con los tipos de prestamo para los que el usuario esta sancionado
  my ($borrowernumber)=@_;
  my $dbh = C4::Context->dbh;
  #Esta primera consulta es por la devolucion atrasada de libros
  my $sth = $dbh->prepare("select * from sanctions 
	inner join sanctiontypes on sanctions.sanctiontypecode = sanctiontypes.sanctiontypecode 
	inner join sanctionissuetypes on sanctiontypes.sanctiontypecode = sanctionissuetypes.sanctiontypecode 
	inner join issuetypes on sanctionissuetypes.issuecode = issuetypes.issuecode 
	where borrowernumber = ? and (now() between startdate and enddate)");
  $sth->execute($borrowernumber);
  my @results;
  while (my $res= $sth->fetchrow_hashref) {
	$res->{'enddate'}=format_date($res->{'enddate'});
        $res->{'startdate'}=format_date($res->{'startdate'});
	push(@results,$res);
  }
  $sth->finish;
  #Esta segunda consulta es por las reservas que fueron retiradas
  my $sth = $dbh->prepare("select * from sanctions 
	where borrowernumber = ? and (now() between startdate and enddate) and  sanctiontypecode is null");
  $sth->execute($borrowernumber);
  while (my $res= $sth->fetchrow_hashref) {
        $res->{'enddate'}=format_date($res->{'enddate'});
        $res->{'startdate'}=format_date($res->{'startdate'});
	$res->{'description'}="Reserva no retirada";
        push(@results,$res);
  }
  $sth->finish;
  return(\@results);
}

sub isSanction {
  #Esta funcion determina si un usuario ($borrowernumber) tiene derecho (o sea no esta sancionado) a retirar un biblio para un tipo de prestamo ($issuecode)
  my ($dbh, $borrowernumber, $issuecode)=@_;
  my $sth = $dbh->prepare("select * from sanctions left join sanctiontypes on sanctions.sanctiontypecode = sanctiontypes.sanctiontypecode left join sanctionissuetypes on sanctiontypes.sanctiontypecode = sanctionissuetypes.sanctiontypecode where borrowernumber = ? and (now() between startdate and enddate) and ((sanctionissuetypes.issuecode = ?) or (sanctionissuetypes.issuecode is null))");
  $sth->execute($borrowernumber, $issuecode);
  return($sth->fetchrow_hashref); 
}

sub hasDebts {
  #Esta funcion determina si un usuario ($borrowernumber) tiene algun biblio vencido que no le permite realizar reservas o prestamos
  my ($dbh, $borrowernumber)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from issues where returndate is NULL and borrowernumber = ?");
  $sth->execute($borrowernumber);
  my $hoy=C4::Date::format_date_in_iso(ParseDate("today"));
  while (my $ref= $sth->fetchrow_hashref) {
    my $fechaDeVencimiento= C4::AR::Issues::vencimiento($ref->{'itemnumber'});
    return(1) if (Date::Manip::Date_Cmp($fechaDeVencimiento,$hoy)<0);
  }
  return(0);
}

sub permitionToLoan {
  #Esta funcion retorna un par donde el primer parametro indica si el usuario puede realizar una reserva o se le puede realizar un prestamo y el segundo indica en caso de estar sancionado la fecha en la que la sancion finaliza
  my ($dbh, $borrowernumber, $issuecode)=@_;
  my $debtOrSanction= 0; #Se supone que no esta sancionado
  my $until= undef;
  if (hasDebts($dbh,$borrowernumber)) {
    $debtOrSanction= 1; #Tiene biblos vencidos 
  } elsif (my $res= isSanction($dbh, $borrowernumber, $issuecode)) {
    $debtOrSanction= 1; #Tiene una sancion vigente
    $until= $res->{'enddate'};
  }
  return($debtOrSanction, $until);
}

sub sanctionSelect {
  my ($dbh, $defaultValue, $onChange,$notforloan)=@_;
  my $sth;
  my $query= "select * from issuetypes";
  if ($notforloan ne undef) {
    $query.=" where notforloan = ? order by description";
    $sth = $dbh->prepare($query);
    $sth->execute($notforloan);
  } else {
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
  my $CGIissuetypes=CGI::scrolling_list(
                        -name => 'issuetype',
                        -values   => \@issuesvalues,
                        -labels   => \%issueslabels,
                        -default => $defaultValue,
                        -onChange => $onChange,
                        -size     => 1,
                        -multiple => 0 );
  return($CGIissuetypes);
}

sub insertSanction {
  #Esta funcion da de alta una sancion
  my ($dbh, $sanctiontypecode, $reservenumber, $borrowernumber, $startdate, $enddate, $delaydays)=@_;
  my $sth=$dbh->prepare("INSERT INTO sanctions (sanctiontypecode,reservenumber,borrowernumber,startdate,enddate,delaydays) VALUES (?,?,?,?,?,?)");
  $sth->execute($sanctiontypecode, $reservenumber, $borrowernumber, $startdate, $enddate, $delaydays);
}

sub getSanctionTypeCode {
  #Esta funcion recupera el sanctiontypecode a partir del issuecode y el categorycode
  my ($dbh, $issuecode, $categorycode)=@_;
  my $sth=$dbh->prepare("select sanctiontypecode from sanctiontypes where issuecode = ? and categorycode = ?");
  $sth->execute($issuecode, $categorycode);
  my $res= $sth->fetchrow_hashref;
  return($res->{'sanctiontypecode'});
}

sub getBorrowersSanctions {
  #Esta funcion retorna un array con todos los borrowernumbers de los usuarios que estan sancionados para un determinado issuecode o cuyo issuecode es null (o sea es una sancion por no retirar una reserva)
  my ($dbh, $issuecode)=@_;
  my $sth = $dbh->prepare("select borrowernumber from sanctions left join sanctiontypes on sanctions.sanctiontypecode = sanctiontypes.sanctiontypecode left join sanctionissuetypes on sanctiontypes.sanctiontypecode = sanctionissuetypes.sanctiontypecode where (now() between startdate and enddate) and ((sanctionissuetypes.issuecode = ?) or (sanctionissuetypes.issuecode is null))");
  $sth->execute($issuecode);
  my @results;
  while (my $data=$sth->fetchrow){
    push (@results,$data);
  }
  return(@results);
}

sub delSanction {
  #Esta funcion elimina una sancion
   my ($dbh,$sanctionnumber)=@_;
   my $sth=$dbh->prepare("delete from sanctions where sanctionnumber = ?");
   $sth->execute($sanctionnumber);
    $sth->finish;
	   }          


sub sanciones{
 #Esta sancion de toda las sanciones que hay
my $linecolor1='par';
my $linecolor2='impar';

my $class='';

my $dbh = C4::Context->dbh;
my $query = "select cardnumber, borrowers.borrowernumber, surname, firstname, documenttype, documentnumber, studentnumber, sanctionnumber ,startdate, enddate, categories.description as categorydescription, issuetypes.description as issuecodedescription 
	from borrowers inner join sanctions on borrowers.borrowernumber = sanctions.borrowernumber 
	inner join categories on categories.categorycode = borrowers.categorycode 
	left join sanctiontypes on sanctiontypes.sanctiontypecode = sanctions.sanctiontypecode 
	left join issuetypes on issuetypes.issuecode = sanctiontypes.issuecode 
	where (startdate <= now()) AND (enddate >= now()) group by cardnumber, borrowers.borrowernumber, surname, firstname, documenttype, documentnumber, studentnumber, startdate, enddate, categories.description, issuetypes.description order by surname, firstname, borrowers.borrowernumber";
my $sth=$dbh->prepare($query);
$sth->execute();
my @sanctionsarray;
my $borrowernumber;
my $res = $sth->fetchrow_hashref;
while ($res) {
	my $res1= $res;
        ($class eq $linecolor1) ? ($class=$linecolor2) : ($class=$linecolor1);
	$res1->{'enddate'}=  format_date($res->{'enddate'});
	$res1->{'startdate'}=  format_date($res->{'startdate'});
	$res1->{'sanctionnumber'}=  $res->{'sanctionnumber'};
	$res1->{'clase'}= $class;
	$borrowernumber= $res->{'borrowernumber'};
	my @issueslist;
	while ($res && ($borrowernumber eq $res->{'borrowernumber'})) {
		push (@issueslist,$res->{'issuecodedescription'});
		$res = $sth->fetchrow_hashref;
	}
	$res1->{'issuecodedescription'}= join(', ',@issueslist);
	push (@sanctionsarray, $res1);
} 
$sth->finish;
return @sanctionsarray;
}