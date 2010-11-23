#!/usr/bin/perl

use strict;
use C4::Auth;

use CGI;
use C4::AR::Estadisticas;
use C4::AR::StatGraphs;
use C4::AR::Busquedas;

my $input = new CGI;

my ($template, $session, $t_params, $cookie)= get_template_and_user({
                            template_name => "reports/itemtypes.tmpl",
			                query => $input,
			                type => "intranet",
			                authnotrequired => 0,
			                flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
			                debug => 1,
			     });


my $ui= $input->param('id_ui') || C4::AR::Preferencias->getValorPreferencia("defaultUI");
my %params;
$params{'onChange'}= 'hacerSubmit()';
my $ComboUI=C4::AR::Utilidades::generarComboUI(\%params);
my ($cantidad,$resultsdata)= C4::AR::Estadisticas::tiposDeItem_reporte($ui); 
# my $torta=&itemtypesPie($ui,$cantidad, @resultsdata);
# my $barras=&itemtypesHBars($ui,$cantidad, @resultsdata);

$t_params->{'unidades'}= $ComboUI;
$t_params->{'resultsloop'}=$resultsdata;
$t_params->{'cantidad'}=$ui;
# $t_params->{'barras'}=$barras;
# $t_params->{'torta'}=$torta;

C4::Auth::output_html_with_http_headers($template, $t_params, $session, $cookie);

