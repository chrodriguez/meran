#!/usr/bin/perl

use strict;
use C4::Auth;
use CGI;
use C4::AR::Novedades;
my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
									template_name => "admin/feriados.tmpl",
									query => $input,
									type => "intranet",
									authnotrequired => 0,
									flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
									debug => 1,
			    });


$t_params->{'dates'} = C4::AR::Utilidades::getFeriados();

C4::Auth::output_html_with_http_headers($template, $t_params, $session);