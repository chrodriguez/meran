#!/usr/bin/perl

use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::AR::Auth;
use C4::Context;
use CGI::Session;
use CGI;

my $cgi = new CGI;

my ($template, $t_params)   = C4::Output::gettemplate("splash.tmpl", 'intranet');

#se inicializa la session y demas parametros para autenticar
my ($session)               = C4::AR::Auth::inicializarAuth($t_params);


C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
