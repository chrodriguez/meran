#!/usr/bin/perl

use strict;
use C4::AR::Auth;

use JSON;
use CGI;
use CGI::Session;

my $input = new CGI;

if(C4::AR::Preferencias::getValorPreferencia("permite_cambio_password_desde_opac")){
    
    my ($template, $t_params)= C4::Output::gettemplate("opac-changepassword.tmpl", 'intranet');

    $t_params->{'mensaje'}= C4::AR::Mensajes::getMensaje($session->param("codMsg"),'OPAC',[]);
    $t_params->{'noAjaxRequests'}= 1;

    my $session = CGI::Session->load();
    
    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);

}else{
    #no se permite el cambio de passoword desde el OPAC
    my $authnotrequired = 0;
    my ($template, $session, $t_params) = checkauth(    $input, 
                                                        $authnotrequired,
                                                        {   ui => 'ANY', 
                                                            tipo_documento => 'ANY', 
                                                            accion => 'MODIFICACION', 
                                                            entorno => 'usuarios'
                                                        },
                                                        "opac",
                            );

    C4::AR::Auth::redirectTo(C4::AR::Utilidades::getUrlPrefix().'/opac-user.pl?token='.$session->param('token'));
}




