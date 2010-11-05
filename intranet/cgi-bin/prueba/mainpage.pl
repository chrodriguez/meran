#!/usr/bin/perl
use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::Auth;
use CGI;

my $query = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
									template_name => "/prueba/main.tmpl",
									query => $query,
									type => "intranet",
									authnotrequired => 0,
                                    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
			});
$t_params->{'test'} = "HOLA";
 

C4::Auth::output_html_with_http_headers($template, $t_params, $session);
