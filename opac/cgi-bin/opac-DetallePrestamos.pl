#!/usr/bin/perl

use strict;
require Exporter;
use CGI;
use C4::AR::Auth;
use C4::Date;
use C4::AR::Reservas; 
use Date::Manip;

my $input = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
								template_name => "opac-DetallePrestamos.tmpl",
								query => $input,
								type => "opac",
								authnotrequired => 0,
								flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
								debug => 1,
			     });



my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $prestamos = C4::AR::Prestamos::obtenerPrestamosDeSocio($session->param('userid'));
my $vencidos=0;
foreach my $prestamo (@$prestamos) {
if($prestamo->estaVencido){$vencidos++;}
}

$t_params->{'vencidos'}= $vencidos;
$t_params->{'PRESTAMOS'}= $prestamos;
$t_params->{'prestamos_cant'}= scalar(@$prestamos);

$t_params->{'CirculationEnabled'}= C4::AR::Preferencias::getValorPreferencia("circulation");


C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
