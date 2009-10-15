#!/usr/bin/perl

use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::Auth;
use C4::Context;
use CGI::Session;

my ($template, $t_params)= C4::Output::gettemplate("opac-auth.tmpl", 'opac');

#se inicializa la session y demas parametros para autenticar
$t_params->{'opac'};
my ($session)= C4::Auth::inicializarAuth($t_params);

C4::Auth::output_html_with_http_headers($template, $t_params, $session);