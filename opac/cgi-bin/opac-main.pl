#!/usr/bin/perl
use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::AR::Auth;
use C4::AR::Novedades;
use CGI;
use HTML::Template;

my $query = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
									template_name   => "opac-main.tmpl",
								    query           => $query,
                                    type            => "opac",
									authnotrequired => 0,
									flagsrequired   => {    ui => 'ANY', 
                                                            tipo_documento => 'ANY', 
                                                            accion => 'CONSULTA', 
                                                            entorno => 'undefined'},
            });

my $nro_socio                       = $session->param('nro_socio');            
my ($cantidad,$grupos)              = C4::AR::Nivel1::getUltimosGrupos();
$t_params->{'nro_socio'}            = $nro_socio;
$t_params->{'SEARCH_RESULTS'}       = $grupos;
$t_params->{'cantidad'}             = $cantidad;
$t_params->{'partial_template'}     = "opac-content_data.inc";

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
