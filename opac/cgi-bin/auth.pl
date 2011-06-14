#!/usr/bin/perl
use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::AR::Auth;
use CGI;

my $query = new CGI;


my ($template, $t_params)= C4::Output::gettemplate("opac-main.tmpl", 'opac',1);

$t_params->{'type'}='opac';

my $session                 = CGI::Session->load();

my $codMensaje = $query->param('codMSG') || $session->param('codMsg') || $session->param('codMSG') || 0;

if ($session->param('codMsg')){
  $t_params->{'mensaje'}    = C4::AR::Mensajes::getMensaje($session->param('codMsg'),'Opac');
}

my ($session) = C4::AR::Auth::inicializarAuth($t_params);

$t_params->{'partial_template'}= "opac-login.inc";

$t_params->{'sessionClose'} = $query->param('sessionClose') || 0;

if ($t_params->{'sessionClose'}){
  
  $t_params->{'mensaje'} = C4::AR::Mensajes::getMensaje('U358','intranet');
}

$t_params->{'mostrar_captcha'} = $query->param('mostrarCaptcha') || 0;

$t_params->{'loginAttempt'} = $query->param('loginAttempt') || 0;

if ($t_params->{'loginAttempt'} & !($t_params->{'mostrar_captcha'}) ){
  $t_params->{'mensaje'}    = C4::AR::Mensajes::getMensaje('U310','intranet');
}
if (!C4::AR::Utilidades::validateString($t_params->{'mensaje'})){
	
	$t_params->{'mensaje'} = C4::AR::Mensajes::getMensaje($codMensaje,'OPAC') || C4::AR::Mensajes::getMensaje($codMensaje,'INTRA'); 
}

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
