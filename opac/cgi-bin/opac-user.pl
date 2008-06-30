#!/usr/bin/perl
use strict;
require Exporter;
use CGI;

# Agregado por Einar.
#para soportar el tema de las que pueden o no modificar a los socios

use C4::AR::UpdateData;

use C4::Auth;
use C4::Koha;
use C4::Circulation::Circ2;
use C4::Search;
use C4::Interface::CGI::Output;
use HTML::Template;
use C4::Date;
use C4::AR::VirtualLibrary; #Matias
use C4::AR::Reserves; #Matias
use C4::AR::Issues;
use C4::AR::Sanctions;
use Date::Manip;

my $query = new CGI;

my ($template, $borrowernumber, $cookie) 
    = get_template_and_user({template_name => "opac-user.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 0,
			     flagsrequired => {borrow => 1},
			     debug => 1,
			     });


my $dateformat = C4::Date::get_date_format();
# get borrower information ....
my ($borr, $flags) = getpatroninformation(undef, $borrowernumber);

$borr->{'city'}=getcitycategory($borr->{'city'});
$borr->{'streetcity'}=getcitycategory($borr->{'streetcity'});
$borr->{'dateenrolled'} = C4::Date::format_date($borr->{'dateenrolled'},$dateformat);
$borr->{'expiry'}       = C4::Date::format_date($borr->{'expiry'},$dateformat);
$borr->{'dateofbirth'}  = C4::Date::format_date($borr->{'dateofbirth'},$dateformat);
$borr->{'ethnicity'}    = fixEthnicity($borr->{'ethnicity'});
if ($borr->{'amountoutstanding'} > 5) {
    $borr->{'amountoverfive'} = 1;
}
if (5 >= $borr->{'amountoutstanding'} && $borr->{'amountoutstanding'} > 0 ) {
    $borr->{'amountoverzero'} = 1;
}
if ($borr->{'amountoutstanding'} < 0) {
    $borr->{'amountlessthanzero'} = 1;
    $borr->{'amountoutstanding'} = -1*($borr->{'amountoutstanding'});
}

$borr->{'amountoutstanding'} = sprintf "%.02f", $borr->{'amountoutstanding'};

#### Verifica si la foto ya esta cargada
my $picturesDir= C4::Context->config("picturesdir");
my $foto;
if (opendir(DIR, $picturesDir)) {
        my $pattern= $borrowernumber."[.].";
        my @file = grep { /$pattern/ } readdir(DIR);
        $foto= join("",@file);
        closedir DIR;
} else {
        $foto= 0;
}

#### Verifica si hay problemas para subir la foto
my $msgFoto=$query->param('msg');
($msgFoto) || ($msgFoto=0);
####

$borr->{'foto_name'} = $foto;
$borr->{'mensaje_error_foto'} = $msgFoto;
$borr->{'bornum'} = $borrowernumber;
if (C4::Context->preference("UploadPictureFromOPAC") eq 'yes') {
	$borr->{'UploadPictureFromOPAC'}=1;
} else {
	$borr->{'UploadPictureFromOPAC'}=0;
}

my @bordat;
$bordat[0] = $borr;
foreach my $aux (keys (%$borr)) {
		$template->param($aux => ($borr->{$aux}))

}
#$template->param(BORROWER_INFO => \@bordat);
$template->param(borrowernumber => $borrowernumber);

#get issued items ....
my $issues = C4::AR::Issues::prestamosPorUsuario($borrowernumber); #C4 C4::AR::Issues

my $count = 0;
my $overdues_count = 0;
my @overdues;
my @issuedat;
my $venc=0;
# Sanciones
my $sanc= hasSanctions($borrowernumber);

foreach my $san (@$sanc) {
if ($san->{'id3'}) {
	my $aux=itemdata3($san->{'id3'}); 
	$san->{'description'}.=": ".$aux->{'titulo'}." (".$aux->{'autor'}.") "; }
	$san->{'enddate'}=format_date($san->{'enddate'},$dateformat);
	$san->{'startdate'}=format_date($san->{'startdate'},$dateformat);
}
#

foreach my $key (keys %$issues) {
	my $issue = $issues->{$key};
    	$issue->{'date_due'} = format_date($issue->{'date_due'},$dateformat);
    	my $err= "Error con la fecha"; 

     	my $hoy=C4::Date::format_date_in_iso(C4::Date::ParseDate("today"),$dateformat);
     	my  $close = C4::Date::ParseDate(C4::Context->preference("close"));
     	if (Date::Manip::Date_Cmp($close,C4::Date::ParseDate("today"))<0){#Se paso la hora de cierre
     		$hoy=C4::Date::format_date_in_iso(C4::Date::DateCalc($hoy,"+ 1 day",\$err),$dateformat);
     	}
   	my $df=C4::Date::format_date_in_iso(vencimiento($issue->{'id3'}),$dateformat); #C4::AR::Issues
    	$issue->{'date_fin'} = C4::Date::format_date($df,$dateformat);
    	if (Date::Manip::Date_Cmp($df,$hoy)<0){ 
		$venc=1;
	  	$issue->{'color'} ='red';
	}

    	$issue->{'renew'} = &sepuederenovar($borrowernumber, $issue->{'id3'});
    	if ($issue->{'overdue'}) {
		push @overdues, $issue;
		$overdues_count++;
		$issue->{'overdue'} = 1;
    	}else{
		$issue->{'issued'} = 1;
   	}	
    
	push @issuedat, $issue; 
    	$count++;
}

#my $maxissues= C4::Context->preference("maxissues");
#my $available_issues= $maxissues - $count;

$template->param(vencimientos => $venc);
$template->param(sanciones_loop => $sanc);
$template->param(ISSUES => \@issuedat);
$template->param(issues_count => $count);
#$template->param(available_issues => $available_issues);

$template->param(OVERDUES => \@overdues);
$template->param(overdues_count => $overdues_count);
my $branches = getbranches();

# now the reserved items....
my ($rcount, $reserves) = C4::AR::Reservas::DatosReservas($borrowernumber); 

my @realreserves;
$rcount = 0;

my @waiting;
my $wcount = 0;
foreach my $res (@$reserves) {
    if ((Date_Cmp(ParseDate("today"),ParseDate($res->{'rreminderdate'})) > 0))
	{
		$res->{'color'} ='red'; 
	}
    
	$res->{'rreminderdate'} = format_date($res->{'rreminderdate'},$dateformat);
    	$res->{'rnotificationdate'} = format_date($res->{'rnotificationdate'},$dateformat);

 	my $author=getautor($res->{'rautor'}); #llamo a getautor en C4::Search.pm
						#paso como parametro ID de autor de la reserva
	#guardo el Apellido, Nombre del autor
	$res->{'autor'} = $author->{'completo'}; #le paso Apellido y Nombre
	
    if ($res->{'rid3'}) {
	#Reservas para retirar
	$res->{'rbranch'} = $branches->{$res->{'rbranch'}}->{'branchname'};
	push @waiting, $res;
	$wcount++;
    }else{
	push @realreserves, $res;
	$rcount++;
    }
}

$template->param(RESERVES => \@realreserves);
$template->param(reserves_count => $rcount);

#otra vez einar con Guarani

$template->param(updatedata=>checkUpdateData());

$template->param(WAITING => \@waiting);
$template->param(waiting_count => $wcount,
			     LibraryName => C4::Context->preference("LibraryName"),
			     pagetitle => "Usuarios",
);

#No se pudo renovar por no tener el curso?
$template->param(no_user_course => $query->param('no_user_course'));
#
#Miguel para mostrar o no el historico de las Reservas
my $showHistoricReserves= C4::Context->preference("showHistoricReserves");
$template->param(showHistoricReserves => $showHistoricReserves);

output_html_with_http_headers $query, $cookie, $template->output;
