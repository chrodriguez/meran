#!/usr/bin/perl

use strict;
use C4::AR::Auth;

use CGI;
use C4::AR::Estadisticas;
use C4::AR::Busquedas;

my $input = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
                            template_name => "reports/analiticas.tmpl",
			                query => $input,
			                type => "intranet",
			                authnotrequired => 0,
			                flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
			                debug => 1,
			     });

my  $ui= $input->param('ui_name') || C4::AR::Preferencias::getValorPreferencia("defaultUI");

my %params;
$params{'onChange'}= 'hacerSubmit()';
my $ComboUI=C4::AR::Utilidades::generarComboUI(\%params);

my @resultsdata= cantidadAnaliticas();#Cantidad de analiticas

$t_params->{'resultsloop'}= \@resultsdata;
$t_params->{'unidades'}= $ComboUI;
$t_params->{'ui'}= $ui;

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
