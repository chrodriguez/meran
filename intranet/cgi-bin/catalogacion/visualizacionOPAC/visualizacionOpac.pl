#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::VisualizacionOpac;

my $input = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
							template_name => "catalogacion/visualizacionOPAC/visualizacionOpac.tmpl",
							query => $input,
							type => "intranet",
							authnotrequired => 0,
							flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
							debug => 1,
			     });



my %params_combo;
$params_combo{'onChange'}= 'changeTipoItem()';
$params_combo{'default'}= 'SIN SELECCIONAR';
$params_combo{'id'}= 'comboTiposItems';
my $comboTiposNivel3= &C4::AR::Utilidades::generarComboTipoNivel3(\%params_combo);
$t_params->{'selectItemType'}= $comboTiposNivel3;

$params_combo{'default'}= 'LIB';
$params_combo{'id'}= 'comboTiposItemsAltaEncabezado';
my $comboTiposNivel3= &C4::AR::Utilidades::generarComboTipoNivel3(\%params_combo);
$t_params->{'selectItemTypeAltaEncabezado'}= $comboTiposNivel3;

C4::Auth::output_html_with_http_headers($template, $t_params, $session);
