#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Date;
use C4::AR::Prestamos;
use Date::Manip;

my $input=new CGI;

my ($template, $session, $params) =  get_template_and_user ({
			template_name	=> 'circ/detallePrestamos.tmpl',
			query		=> $input,
			type		=> "intranet",
			authnotrequired	=> 0,
			flagsrequired	=> { circulate => 1 },
    });

my $obj=$input->param('obj');

$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $nro_socio= $obj->{'nro_socio'};
my $prestamos = C4::AR::Prestamos::obtenerPrestamosDeSocio($nro_socio);

$t_params->{'PRESTAMOS'}= $prestamos;
$t_params->{'prestamos_cant'}= scalar(@$prestamos);

my $vencidos=0;
foreach my $prestamo (@$prestamos) {
if($prestamo->estaVencido){$vencidos++;}
}
$t_params->{'vencidos'}= $vencidos;

C4::Auth::output_html_with_http_headers($input, $template, $params);

