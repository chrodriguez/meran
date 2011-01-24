#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::AR::Auth;


my $input=new CGI;

my ($template, $session, $t_params)= get_template_and_user({
								template_name => "opac-main.tmpl",
								query => $input,
								type => "opac",
								authnotrequired => 1,
								flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
			     });


my $idNivel1= $input->param('id1');

C4::AR::Nivel3::detalleCompletoOPAC($idNivel1, $t_params);

$t_params->{'partial_template'}= "opac-detail.inc";
$t_params->{'preferencias'}= C4::AR::Preferencias::getConfigVisualizacionOPAC();
C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
