#!/usr/bin/perl


use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Catalogacion;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                template_name => "catalogacion/estructura/estructuraCatalo.tmpl",
			    query => $input,
			    type => "intranet",
			    authnotrequired => 0,
			    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'estructura_catalogacion_n1'},
			    debug => 1,
	    });

my %params_combo;
$params_combo{'onChange'}       = 'eleccionDeNivel()';
$params_combo{'class'}          = 'horizontal';
my $comboTiposNivel3            = &C4::AR::Utilidades::generarComboTipoNivel3(\%params_combo);
$t_params->{'selectItemType'}   = $comboTiposNivel3;

my %params_combo;
$params_combo{'onChange'}       = 'eleccionDeNivel()';
$params_combo{'class'}          = 'horizontal';
my $selectNivel                 = &C4::AR::Utilidades::generarComboNiveles(\%params_combo);

$t_params->{'selectNivel'}      = $selectNivel;


C4::Auth::output_html_with_http_headers($template, $t_params, $session);
