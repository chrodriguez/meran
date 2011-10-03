#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::AR::Auth;


my $input=new CGI;
my $ajax = $input->param('ajax') || 0;
my ($template, $session, $t_params)= get_template_and_user({
								template_name => ($ajax?"includes/opac-detail.inc":"opac-main.tmpl"),
								query => $input,
								type => "opac",
								authnotrequired => 1,
								flagsrequired => {  ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'CONSULTA', 
                                                    entorno => 'undefined'},
			     });

my $idNivel1= $input->param('id1');

$t_params->{'page'} = $input->param('page') || 0;
my $cant_total      = 0;

eval{ 
    ($cant_total)    =   C4::AR::Nivel3::detalleCompletoOPAC($idNivel1, $t_params);
    $t_params->{'cant_total'}           = $cant_total;
};

$t_params->{'partial_template'}     = "opac-detail.inc";
$t_params->{'preferencias'}         = C4::AR::Preferencias::getConfigVisualizacionOPAC();
$t_params->{'per_page'}             = C4::Context->config("cant_grupos_per_query") || 5;
$t_params->{'ajax'}                 = $ajax;
$t_params->{'pref_e_documents'}     = C4::AR::Preferencias::getValorPreferencia("e_documents");
$t_params->{'mostrar_ui_opac'}      = C4::AR::Preferencias::getValorPreferencia("mostrar_ui_opac");

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
