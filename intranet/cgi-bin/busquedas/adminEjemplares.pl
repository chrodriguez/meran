#!/usr/bin/perl


use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user ({
                                        template_name	=> 'busquedas/adminEjemplares.tmpl',
                                        query		=> $input,
                                        type		=> "intranet",
                                        authnotrequired	=> 0,
                                        flagsrequired	=> { circulate => 1 },
    			 });


C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
