#!/usr/bin/perl
use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::Auth;
use CGI;

my $query = new CGI;

my ($template, $t_params)= C4::Output::gettemplate("opac-main.tmpl", 'opac',1);

$t_params->{'type'}='opac';
my ($session) = C4::Auth::inicializarAuth($t_params);

$t_params->{'partial_template'}= "opac-login.inc";

$t_params->{'sessionClose'} = $query->param('sessionClose') || 0;

if ($t_params->{'sessionClose'}){
  $t_params->{'mensaje'} = C4::AR::Mensajes::getMensaje('U358','intranet');
}

$t_params->{'loginAttempt'} = $query->param('loginAttempt') || 0;

if ($t_params->{'loginAttempt'}){
  $t_params->{'mensaje'} = C4::AR::Mensajes::getMensaje('U357','intranet');
}

if ($session->param('codMsg')){
  $t_params->{'mensaje'} = C4::AR::Mensajes::getMensaje($session->param('codMsg'),'opac');
}

C4::Auth::output_html_with_http_headers($templates, $t_params, $session);
