#!/usr/bin/perl

use strict;
use C4::Auth;
use CGI;

my $input = new CGI;

my ($template, $loggedinuser, $cookie, $params)
    = get_template_and_user({
				template_name => "usuarios/reales/buscarUsuario.tmpl",
			     	query => $input,
			     	type => "intranet",
			     	authnotrequired => 0,
			     	flagsrequired => {borrowers => 1},
			     	debug => 1,
			     });


$template->process($params->{'template_name'},$params) || die "Template process failed: ", $template->error(), "\n";