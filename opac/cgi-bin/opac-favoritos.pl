#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use Mail::Sendmail;
use C4::Auth;         # checkauth, getnro_socio.
use C4::Circulation::Circ2;
use C4::Interface::CGI::Output;
use C4::Date;

my $query = new CGI;

my $input = $query;

my ($template, $session, $t_params)= get_template_and_user({
                                    template_name => "opac-main.tmpl",
                                    query => $query,
                                    type => "opac",
                                    authnotrequired => 1,
                                    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
             });


my $nro_socio = C4::Auth::getSessionNroSocio();

my ($socio, $flags) = C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);

C4::AR::Validator::validateObjectInstance($socio);


my ($cantidad,$resultsarray)= C4::AR::Nivel1::getFavoritos($nro_socio);

$t_params->{'cantidad'}= $cantidad;
$t_params->{'nro_socio'}= $session->param('nro_socio');
$t_params->{'SEARCH_RESULTS'}= $resultsarray;
$t_params->{'partial_template'}= "opac-busquedaResult.inc";

C4::Auth::output_html_with_http_headers($template, $t_params, $session);

1;
