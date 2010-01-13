#!/usr/bin/perl
use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::Auth;
use C4::AR::Novedades;
use CGI;

my $query = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
									template_name => "opac-main.tmpl",
									query => $query,
                                    type => "opac",
									authnotrequired => 0,
									flagsrequired => {  ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
            });

# my ($template, $t_params)= C4::Output::gettemplate("opac-main.tmpl", 'opac');
# my ($session) = CGI::Session->load();

my ($cantidad,$grupos)= C4::AR::Nivel1::getUltimosGrupos();
my ($cantidad_novedades,$novedades)= C4::AR::Novedades::getUltimasNovedades();

$t_params->{'opac'};
$t_params->{'cantidad'}= $cantidad;
$t_params->{'nro_socio'}= $session->param('nro_socio');
$t_params->{'SEARCH_RESULTS'}= $grupos;
$t_params->{'novedades'}= $novedades;
$t_params->{'not_show_search_details'}= 1;

$t_params->{'partial_template'}= "opac-content_data.inc";
C4::Auth::output_html_with_http_headers($template, $t_params, $session);
