#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::Auth;       # get_template_and_user

my $input = new CGI;

##Aca se controlo el cambio de idioma
my $session = CGI::Session->load();

$session->param('usr_locale', $input->param('lang_server') );
# C4::AR::Debug::debug("opac-language => obtengo locale de la session->param(usr_locale) => ".$session->param('usr_locale'));

my $socio = C4::Auth::getSessionNroSocio();
if ($socio){
    $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($socio) || C4::Modelo::UsrSocio->new();
    $socio->setLocale($input->param('lang_server'));
}

#regreso a la pagina en la que estaba
if($session->param('token')){
#si hay sesion se le agrega el token
# 	C4::Auth::redirectTo($input->param('url')."?token=".$session->param('token'));
    C4::Auth::redirectTo($input->param('url'));
}else{
	C4::Auth::redirectTo($input->param('url'));
}




