#!/usr/bin/perl

use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::Auth;
use C4::Context;
use CGI;
use CGI::Session;

my $query = new CGI;

my ($template, $t_params)= C4::Output::gettemplate("login/opac-auth.tmpl", 'opac');

#se inicializa la session y demas parametros para autenticar
$t_params->{'opac'};
my ($session)= C4::Auth::inicializarAuth($query, $t_params);

C4::Auth::output_html_with_http_headers($query, $template, $t_params, $session);