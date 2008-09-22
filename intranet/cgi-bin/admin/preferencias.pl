#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;

my $input = new CGI;

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "admin/preferencias.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });


output_html_with_http_headers $input, $cookie, $template->output;
