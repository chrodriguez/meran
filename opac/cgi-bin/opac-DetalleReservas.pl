#!/usr/bin/perl
use strict;
require Exporter;

use CGI;
use C4::Auth;
use C4::Date;;
use Date::Manip;
use C4::AR::Busquedas;

my $input = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
									template_name => "opac-DetalleReservas.tmpl",
									query => $input,
									type => "opac",
									authnotrequired => 0,
									flagsrequired => {borrow => 1},
									debug => 1,
			     });



my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $dateformat = C4::Date::get_date_format();
my $branches = C4::AR::Busquedas::getBranches();

my ($rcount, $reserves) = C4::AR::Reservas::DatosReservas($session->param('nro_socio')); 

my @realreserves;
$rcount = 0;

my @waiting;
my $wcount = 0;
foreach my $res (@$reserves) {
	if ((Date_Cmp(ParseDate("today"),ParseDate($res->{'rreminderdate'})) > 0)){
		$res->{'color'} ='red'; 
	}
    
	$res->{'rreminderdate'} = format_date($res->{'rreminderdate'},$dateformat);
    	$res->{'rnotificationdate'} = format_date($res->{'rnotificationdate'},$dateformat);

 	my $author= C4::AR::Busquedas::getautor($res->{'rautor'});
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

$t_params->{'RESERVES'}= \@realreserves;
$t_params->{'reserves_count'}= $rcount;
$t_params->{'WAITING'}= \@waiting;
$t_params->{'waiting_count'}=$wcount;
$t_params->{'LibraryName'}= C4::AR::Preferencias->getValorPreferencia("LibraryName");
$t_params->{'pagetitle'}= "Usuarios";
$t_params->{'CirculationEnabled'}= C4::AR::Preferencias->getValorPreferencia("circulation");

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
