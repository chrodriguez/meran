#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Utilidades;
use C4::AR::Busquedas;

my $input = new CGI;

my ($template, $session, $t_params, $cookie) = get_template_and_user({
								template_name => "reports/reservas.tmpl",
								query => $input,
								type => "intranet",
								authnotrequired => 0,
								flagsrequired => {borrowers => 1},
								debug => 1,
			    });



my $ComboUI=C4::AR::Utilidades::generarComboUI();
$t_params->{'unidades'}= $ComboUI;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session, $cookie);
