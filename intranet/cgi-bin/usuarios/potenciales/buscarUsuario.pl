#!/usr/bin/perl

use strict;
use C4::Auth;
use CGI;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                                    template_name => "usuarios/potenciales/buscarUsuario.tmpl",
                                    query => $input,
                                    type => "intranet",
                                    authnotrequired => 0,
                                    flagsrequired => {borrowers => 1},
                                    debug => 1,
                });

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
