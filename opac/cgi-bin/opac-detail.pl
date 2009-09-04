#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;

my $input=new CGI;

my ($template, $session, $t_params)= get_template_and_user({
								template_name => "opac-detail.tmpl",
								query => $input,
								type => "opac",
								authnotrequired => 1,
								flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
			     });


my $idNivel1= $input->param('id1');

C4::AR::Nivel3::detalleCompletoOPAC($idNivel1, $t_params);

$t_params->{'CirculationEnabled'}= C4::AR::Preferencias->getValorPreferencia("circulation");

C4::Auth::output_html_with_http_headers($template, $t_params, $session);
