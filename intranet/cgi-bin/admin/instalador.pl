#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;

my $input=new CGI;

my ($template, $loggedinuser, $cookie) = get_template_and_user ({
	template_name	=> 'admin/instalador.tmpl',
	query		=> $input,
	type		=> "intranet",
	authnotrequired	=> 0,
	flagsrequired	=> { circulate => 1 },
    });



$template->param(
# 	usuarioID   => $usuarioID,
);

output_html_with_http_headers $input, $cookie, $template->output;
