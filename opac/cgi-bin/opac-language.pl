#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::AR::Auth;       # get_template_and_user

my $input = new CGI;

##Aca se controlo el cambio de idioma
my $session = CGI::Session->load();

$session->param('usr_locale', $input->param('lang_server') );
my $referer = $ENV{'HTTP_REFERER'};

my $socio = C4::AR::Auth::getSessionNroSocio();
if ($socio){
    $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($socio) || C4::Modelo::UsrSocio->new();
    $socio->setLocale($input->param('lang_server'));
}

#regreso a la pagina en la que estaba

if($session->param('token')){
    C4::AR::Auth::redirectTo($referer);
}else{
	C4::AR::Auth::redirectTo($referer);
}




