#!/usr/bin/perl

#Genera un inventario a partir de la busqueda por signatura topografica



use strict;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use HTML::Template;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/inventory-sig-top.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {reports => 1},
			     debug => 1,
			     });

output_html_with_http_headers $input, $cookie, $template->output;
