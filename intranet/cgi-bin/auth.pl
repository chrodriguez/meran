#!/usr/bin/perl

use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::Auth;
use C4::Context;
use CGI::Session;
use CGI;

my $cgi = new CGI;

my ($template, $t_params)   = C4::Output::gettemplate("auth.tmpl", 'intranet');

#se inicializa la session y demas parametros para autenticar
my ($session)               = C4::Auth::inicializarAuth($t_params);

$t_params->{'sessionClose'} = $cgi->param('sessionClose') || 0;

if ($t_params->{'sessionClose'}){
  $t_params->{'mensaje'}    = C4::AR::Mensajes::getMensaje('U358','intranet');
}

$t_params->{'loginAttempt'} = $cgi->param('loginAttempt') || 0;

if ($t_params->{'loginAttempt'}){
  $t_params->{'mensaje'}    = C4::AR::Mensajes::getMensaje('U357','intranet');
}


if ($session->param('codMsg')){
  $t_params->{'mensaje'}    = C4::AR::Mensajes::getMensaje($session->param('codMsg'),'intranet');
}


C4::Auth::output_html_with_http_headers($template, $t_params, $session);
