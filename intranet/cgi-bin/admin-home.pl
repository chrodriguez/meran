#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;


my $query = new CGI;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "admin/admin-home.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
			     debug => 1,
			     });

output_html_with_http_headers $cookie, $template->output;
