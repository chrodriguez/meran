#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use JSON;
use CGI;
use CGI::Session;

my $input = new CGI;

if(C4::AR::Preferencias::getValorPreferencia("permite_cambio_password_desde_opac")){
    
=item
    my ($template, $session, $t_params)= get_template_and_user({
                                        template_name   => "opac-main.tmpl",
                                        query           => $input,
                                        type            => "opac",
                                        authnotrequired => 0,
                                        flagsrequired   => {    ui              => 'ANY', 
                                                                tipo_documento  => 'ANY', 
                                                                accion          => 'CONSULTA', 
                                                                entorno         => 'undefined'},
                });
=cut   
    
    
    my $session                     = CGI::Session->load();
    my ($template, $t_params)       = C4::Output::gettemplate("opac-main.tmpl", 'opac');

    $t_params->{'mensaje'}          = C4::AR::Mensajes::getMensaje($session->param("codMsg"),'OPAC',[]);
    $t_params->{'nro_socio'}        = C4::AR::Auth::getSessionNroSocio();
    $t_params->{'partial_template'} = "opac-change-password.inc";
    $t_params->{'noAjaxRequests'}   = 1;
	$t_params->{'nroRandom'}    = C4::AR::Auth::getSessionNroRandom();
	$t_params->{'plainPassword'}= C4::Context->config('plainPassword');

    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);

}else{
    #no se permite el cambio de passoword desde el OPAC
    my $authnotrequired = 0;
    my ($template, $session, $t_params) = checkauth(    $input, 
                                                        $authnotrequired,
                                                        {   ui              => 'ANY', 
                                                            tipo_documento  => 'ANY', 
                                                            accion          => 'CONSULTA', 
                                                            entorno         => 'usuarios'
                                                        },
                                                        "opac",
                            );

    C4::AR::Auth::redirectTo(C4::AR::Utilidades::getUrlPrefix().'/opac-user.pl?token='.$session->param('token'));
}
