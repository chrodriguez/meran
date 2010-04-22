#!/usr/bin/perl
use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::Auth;
use CGI;

my $query = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
									template_name => "main.tmpl",
									query => $query,
									type => "intranet",
									authnotrequired => 0,
                                    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
			});

use C4::AR::Usuarios;
my $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio('kohaadmin');

$socio->persona->getNombre;
$socio->persona->getNombre;
$socio->persona->getNombre;
$socio->persona->getApellido;



C4::Auth::output_html_with_http_headers($template, $t_params, $session);
