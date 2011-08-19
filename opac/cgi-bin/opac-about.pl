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
my $info_about_hash = C4::AR::Preferencias::getInfoAbout();  

$t_params->{'info_about'}     = $info_about_hash;
$t_params->{'partial_template'}= "opac-about.inc";
C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
