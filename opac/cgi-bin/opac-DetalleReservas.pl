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

my $reservas = C4::AR::Reservas::obtenerReservasDeSocio($session->param('userid'));

my @reservas_asignadas;
my $racount = 0;
my @reservas_espera;
my $recount = 0;


foreach my $reserva (@$reservas) {
	if ($reserva->getId3) {
		#Reservas para retirar
		push @reservas_asignadas, $reserva;
		$racount++;
   	}else{
		#Reservas en espera
		push @reservas_espera, $reserva;
		$recount++;
   	}
}

$t_params->{'RESERVAS_ASIGNADAS'}= \@reservas_asignadas;
$t_params->{'reservas_asignadas_count'}= $racount;
$t_params->{'RESERVAS_ESPERA'}= \@reservas_espera;
$t_params->{'reservas_espera_count'}=$recount;
$t_params->{'LibraryName'}= C4::AR::Preferencias->getValorPreferencia("LibraryName");
$t_params->{'pagetitle'}= "Usuarios";
$t_params->{'CirculationEnabled'}= C4::AR::Preferencias->getValorPreferencia("circulation");

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
