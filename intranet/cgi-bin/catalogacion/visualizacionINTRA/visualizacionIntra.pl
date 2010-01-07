#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::VisualizacionOpac;

my $input = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
							template_name => "catalogacion/visualizacionINTRA/visualizacionIntra.tmpl",
							query => $input,
							type => "intranet",
							authnotrequired => 0,
							flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
							debug => 1,
			     });


$t_params->{'onChange'} = "eleccionDeEjemplar()";
$t_params->{'default'} = 'SIN SELECCIONAR';
$t_params->{'combo_ejemplares'} = C4::AR::Utilidades::generarComboTipoNivel3($t_params);
C4::Auth::output_html_with_http_headers($template, $t_params, $session);
