#!/usr/bin/perl
use strict;
require Exporter;
use C4::AR::Auth;
use CGI;
use C4::AR::MensajesContacto;

my $query = new CGI;

my ($template, $session, $t_params)= C4::AR::Auth::get_template_and_user({
									template_name => "main.tmpl",
									query => $query,
									type => "intranet",
									authnotrequired => 0,
                                    flagsrequired => {  ui => 'ANY', 
                                                        tipo_documento => 'ANY', 
                                                        accion => 'CONSULTA', 
                                                        entorno => 'undefined'},
});

my ($msjNoLeidos, $cant)= C4::AR::MensajesContacto::noLeidos();


$t_params->{'no_leios'}= $msjNoLeidos;
$t_params->{'cant_noleidos'}= $cant;

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
