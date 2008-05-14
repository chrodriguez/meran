package C4::Date;

use strict;
use C4::Context;
use Date::Manip;

require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = 0.01;

@ISA = qw(Exporter);

@EXPORT = qw(
             &display_date_format
             &format_date
             &format_date_hour
             &format_date_in_iso
	     &updateForHoliday
	     &updateForNonHoliday
	     &calc_beginES
	     &calc_endES
	     &proximosHabiles
	     &proximoHabil
	     &mesString
	     &Date_Init
	     &ParseDate
	     &UnixDate
);

sub get_date_format
{
	#Get the database handle
	my $dbh = C4::Context->dbh;
	return C4::Context->preference('dateformat');
}

sub display_date_format
{
# 	my $dateformat = get_date_format();
	my ($dateformat)=@_;

	if ( $dateformat eq "us" )
	{
		return "mm/dd/aaaa";
	}
	elsif ( $dateformat eq "metric" )
	{
		return "dd/mm/aaaa";
	}
	elsif ( $dateformat eq "iso" )
	{
		return "aaaa-mm-dd";
	}
	else
	{
		return "Invalid date format: $dateformat. Please change in system preferences";
	}
}

=item
sub format_date
{
	my $olddate = shift;
	my $newdate;

	if ( ! $olddate )
	{
		return "";
	}

	my $dateformat = get_date_format();

	if ( $dateformat eq "us" )
	{
		Date_Init("DateFormat=US");
		$olddate = ParseDate($olddate);
		$newdate = UnixDate($olddate,'%m/%d/%Y');
	}
	elsif ( $dateformat eq "metric" )
	{
		Date_Init("DateFormat=metric");
		$olddate = ParseDate($olddate);
		$newdate = UnixDate($olddate,'%d/%m/%Y');
	}
	elsif ( $dateformat eq "iso" )
	{
		Date_Init("DateFormat=iso");
		$olddate = ParseDate($olddate);
		$newdate = UnixDate($olddate,'%Y-%m-%d');
	}
	else
	{
		return "Invalid date format: $dateformat. Please change in system preferences";
	}
}
=cut

sub format_date
{

	my ($olddate, $dateformat)=@_;

	my $newdate;

	if ( ! $olddate )
	{
		return "";
	}

# 	my $dateformat = get_date_format();

	if ( $dateformat eq "us" )
	{
		Date_Init("DateFormat=US");
		$olddate = ParseDate($olddate);
		$newdate = UnixDate($olddate,'%m/%d/%Y');
	}
	elsif ( $dateformat eq "metric" )
	{
		Date_Init("DateFormat=metric");
		$olddate = ParseDate($olddate);
		$newdate = UnixDate($olddate,'%d/%m/%Y');
	}
	elsif ( $dateformat eq "iso" )
	{
		Date_Init("DateFormat=iso");
		$olddate = ParseDate($olddate);
		$newdate = UnixDate($olddate,'%Y-%m-%d');
	}
	else
	{
		return "Invalid date format: $dateformat. Please change in system preferences";
	}
}


sub format_date_hour
{
# 	my $olddate = shift;
	my ($olddate, $dateformat)=@_;

	my $newdate;

	if ( ! $olddate )
	{
		return "";
	}

# 	my $dateformat = get_date_format();

	if ( $dateformat eq "us" )
	{
		Date_Init("DateFormat=US");
		$olddate = ParseDate($olddate);
		$newdate = UnixDate($olddate,'%m/%d/%Y %H:%M');
	}
	elsif ( $dateformat eq "metric" )
	{
		Date_Init("DateFormat=metric");
		$olddate = ParseDate($olddate);
		$newdate = UnixDate($olddate,'%d/%m/%Y %H:%M');
	}
	elsif ( $dateformat eq "iso" )
	{
		Date_Init("DateFormat=iso");
		$olddate = ParseDate($olddate);
		$newdate = UnixDate($olddate,'%Y-%m-%d %H:%M');
	}
	else
	{
		return "Invalid date format: $dateformat. Please change in system preferences";
	}
}

sub calc_beginES
{
	my $close = C4::Context->preference("close");
	my $beginESissue = C4::Context->preference("beginESissue");
	my $err;
	my  $time = ParseDate($close);
	my $hour = DateCalc($close,"- $beginESissue minutes",\$err);	
	return $hour;
}


sub calc_endES
{
	my $open = C4::Context->preference("open");
	my $endESissue = C4::Context->preference("endESissue");
	my $err;
	my  $time = ParseDate($open);
	my $hour = DateCalc($open,"+ $endESissue minutes",\$err);
			      
	return $hour;
}




sub format_date_in_iso
{
#         my $olddate = shift;
	my ($olddate, $dateformat)=@_;
        my $newdate;

        if ( ! $olddate )
        {
                return "";
        }
                
#         my $dateformat = get_date_format();

        if ( $dateformat eq "us" )
        {
                Date_Init("DateFormat=US");
                $olddate = ParseDate($olddate);
        }
        elsif ( $dateformat eq "metric" )
        {
                Date_Init("DateFormat=metric");
                $olddate = ParseDate($olddate);
        }
        elsif ( $dateformat eq "iso" )
        {
                Date_Init("DateFormat=iso");
                $olddate = ParseDate($olddate);
        }
        else
        {
                return "9999-99-99";
        }

	$newdate = UnixDate($olddate, '%Y-%m-%d');

	return $newdate;
}

sub updateForHoliday{
#Recibe una fecha que es la que se puso o se saco como feriado
#Si $sign es "+" entonces se puso como feriado
#Si $sign es "-" entonces se saco como feriado
#Este procedimiento actualiza las fechas que corresponden cuando se setea/dessetea un feriado
	my ($fecha,$sign)= @_;
	my $err= "Error con la fecha";
	my $fecha_nueva_inicio = C4::Date::format_date_in_iso(DateCalc($fecha,"$sign 1 business days",\$err));
	my $daysOfSanctions= C4::Context->preference("daysOfSanctionReserves");
	my $fecha_nueva_fin = C4::Date::format_date_in_iso(DateCalc($fecha_nueva_inicio,"+ $daysOfSanctions days",\$err));
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("update sanctions set startdate=?, enddate=? where sanctiontypecode is null and startdate = ?");
	$sth->execute($fecha_nueva_inicio,$fecha_nueva_fin,$fecha);
}



#30/03/2007 - Damian - Se Agregaron las dos funciones proximoHabil y proximosHabiles porque se repetia en dos modulos Issues.pm y Reserves.pm.

sub proximoHabil{
#funcion que recibe como parametro una cantidad de dias y devuelve el proximo d�a h�bil a partir de hoy + esa cantidad, ejemplo si recibe 2, devuelve el dia habil que sigue a pasado ma�ana. El segundo parametro que recibe es una variable que indica si todos los dias dentro del rango deben ser habiles o no. El tercer parametro es opcional, si se recibe se calcula el perido desde ese dia, sino se hace desde el dia de hoy
	my ($cantidad,$todosHabiles,$desde)=@_;
	my $err= "Error con la fecha";
	my $hoy= (ParseDate($desde) || ParseDate("today"));
	my $hasta;

	if ($todosHabiles) {#esto es si todos los dias del periodo deben ser habiles
#Los dias Habiles se controlan desde el archivo .DateManip.pm que lee el modulo Date.pm, habria que ver como esquematizarlo
	
	
	$hasta=DateCalc($hoy,"+ ".$cantidad. " days",\$err,2);  
	}
	else{#esto es si no importa que todos los dias del periodo sean habiles, los que deben ser habiles son el 1ero y el ultimo
		$hasta=DateCalc($hoy,"+ ".$cantidad. " days",\$err);  
		$hasta=DateCalc($hasta,"+ 0 days",\$err,2);  
	}

	######Damian- 26/03/2007 ----Agregado para que se sume un dia si es feriado el ultimo dia.
	$hasta = C4::Date::format_date_in_iso($hasta);
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("SELECT * FROM feriados WHERE fecha >= ?");
	$sth->execute($hasta);
	while ((my $date= $sth->fetchrow_hashref)) {
		if( C4::Date::format_date_in_iso($hasta) eq $date->{'fecha'}) {
			$hasta=DateCalc($hasta,"+ 1 days",\$err,2);
		}
	}
	#######hasta aca

	return (C4::Date::format_date_in_iso($hasta));
}

sub proximosHabiles{
#funcion que recibe como parametro una cantidad de dias y devuelve el proximo d�a h�bil a partir de hoy y el dia habil correspondiente a esa cantidad, ejemplo si recibe 2, devuelve el dia habil que corresponde a hoy y el que corresponde a 2 dias siguientes. El segundo parametro que recibe es una variable que indica si todos los dias dentro del rango deben ser habiles.
	my ($cantidad,$todosHabiles)=@_;
	my $apertura=C4::Context->preference("open");
	my $cierre=C4::Context->preference("close");
	my ($actual,$min,$hora)= localtime;
	$actual=$hora.':'.$min;
	Date_Init("WorkDayBeg=".$apertura,"WorkDayEnd=".$cierre);
#proximoHabil es una funcion que devuelve la fecha del proximo dia habil y un numero que indica la cantidad de dias que faltan para el proximo habil, si es 0 quiere decir que hoy es habil, la voy a poner aca para evitar invocar una nueva funcion. 
# begin proximoHabil
	my $err= "Error con la fecha";
#Esto habria que ver si es mejor sacarlo de la exclusion para no trabar todo.
	my $desde= DateCalc("today","+ 0 days",\$err,2);  
	my $hoy=ParseDate("today");

	if ($desde eq $hoy && $apertura gt $actual) {#entonces hoy no es habil, o la biblioteca no abrio aun
#si todavia no abrio el usuario tiene desde el dia de hoy para retirar, asi que le resto 1 a la cantidad de dias que ser� valido el pedido
		$cantidad--;
	} 
	elsif($cierre lt $actual){#si ya paso el horario de cierre entonces lo tengo que tener disponible desde el dia siguiente
		$desde= DateCalc("today","+ 0 days",\$err,2);
		$cantidad--;
	}
	else {$apertura=$actual;}

	my $hasta;

	if ($todosHabiles) {#esto es si todos los dias del periodo deben ser habiles
#Los dias Habiles se contolan desde el archivo .DateManip.pm que lee el modulo Date.pm, habria que ver como esquematizarlo
		$hasta=DateCalc($desde,"+ ".$cantidad. " days",\$err,2);  

	}
	else{#esto es si no importa quetodos los dias del periodo sean habiles, los que deben ser habiles son el 1ero y el ultimo
		$hasta=DateCalc($desde,"+ ".$cantidad. " days",\$err);  
		$hasta=DateCalc($hasta,"+ 0 days",\$err,2);  
	}

	#Damian- 26/03/2007 ----Agregado para que se sume un dia si es feriado el ultimo dia.
	$hasta = C4::Date::format_date_in_iso($hasta);
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("SELECT * FROM feriados WHERE fecha >= ?");
	$sth->execute($hasta);
	while ((my $date= $sth->fetchrow_hashref)) {
		if( C4::Date::format_date_in_iso($hasta) eq $date->{'fecha'}) {
			$hasta=DateCalc($hasta,"+ 1 days",\$err,2);
			
		}
	}
	#######hasta aca


return (C4::Date::format_date_in_iso($desde),C4::Date::format_date_in_iso($hasta),$apertura,$cierre);
}

sub mesString(){
	my ($mes)=@_;
	if ($mes eq "1") {$mes='Enero'}
	elsif ($mes eq "2") {$mes='Febrero'}
	elsif ($mes eq "3") {$mes='Marzo'}
	elsif ($mes eq "4") {$mes='Abril'}
	elsif ($mes eq "5") {$mes='Mayo'}
	elsif ($mes eq "6") {$mes='Junio'}
	elsif ($mes eq "7") {$mes='Julio'}
	elsif ($mes eq "8") {$mes='Agosto'}
	elsif ($mes eq "9") {$mes='Septiembre'}
	elsif ($mes eq "10") {$mes='Octubre'}
	elsif ($mes eq "11") {$mes='Noviembre'}
	elsif ($mes eq "12") {$mes='Diciembre'};
	return ($mes);
}
1;
