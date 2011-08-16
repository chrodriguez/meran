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
                                flagsrequired => {  ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'CONSULTA', 
                                                    entorno => 'undefined'},
                 });

$t_params->{'opac'};

$t_params->{'partial_template'}= "opac-ui_info.inc";
$t_params->{'google_map'} = C4::AR::Preferencias::getValorPreferencia('google_map');
$t_params->{'twitter_follow_button'} = C4::AR::Preferencias::getValorPreferencia('twitter_follow_button');

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
