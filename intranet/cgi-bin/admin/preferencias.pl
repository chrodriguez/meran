#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
						template_name => "admin/preferencias.tmpl",
						query => $input,
						type => "intranet",
						authnotrequired => 0,
						flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
						debug => 1,
			    });

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
