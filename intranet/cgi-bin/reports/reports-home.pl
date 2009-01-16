#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;

my $query = new CGI;

my ($template,  $session, $t_params, $cookie)= get_template_and_user({
									template_name => "reports/reports-home.tmpl",
									query => $query,
									type => "intranet",
									authnotrequired => 0,
									flagsrequired => {permissions => 1},
									debug => 1,
                                });

		
C4::Auth::output_html_with_http_headers($query, $template, $t_params, $session);
