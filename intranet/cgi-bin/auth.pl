#!/usr/bin/perl

use strict;

use C4::AR::Auth;
use CGI;


my $cgi = new CGI;

my ($template, $t_params)   = C4::Output::gettemplate("auth.tmpl", 'intranet');
my ($session)               = C4::AR::Auth::inicializarAuth($t_params);

$t_params->{'sessionClose'} = $cgi->param('sessionClose') || 0;
if ($t_params->{'sessionClose'}){
  $t_params->{'mensaje'}    = C4::AR::Mensajes::getMensaje('U358','intranet');
}

C4::AR::Debug::debug($cgi->param('loginAttempt'));

$t_params->{'loginAttempt'} = $cgi->param('loginAttempt') || 0;



$t_params->{'mostrar_captcha'} = $cgi->param('mostrarCaptcha') || 0;

if ($t_params->{'loginAttempt'} & !($t_params->{'mostrar_captcha'}) ){
  $t_params->{'mensaje'}    = C4::AR::Mensajes::getMensaje('U357','intranet');
}


if ($session->param('codMsg')){
  $t_params->{'mensaje'}    = C4::AR::Mensajes::getMensaje($session->param('codMsg'),'intranet');
}


C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
