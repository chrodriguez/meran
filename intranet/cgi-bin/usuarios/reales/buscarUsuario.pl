#!/usr/bin/perl

use strict;
use C4::Auth;
use CGI;

my $input = new CGI;

my ($template, $session, $params) = get_template_and_user({
									template_name => "usuarios/reales/buscarUsuario.tmpl",
									query => $input,
									type => "intranet",
									authnotrequired => 0,
									flagsrequired => {borrowers => 1},
									debug => 1,
			    });

C4::Auth::output_html_with_http_headers($input, $template, $params, $session);