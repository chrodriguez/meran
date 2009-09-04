#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use JSON;
use CGI;

my $input = new CGI;

if(C4::AR::Preferencias->getValorPreferencia("permite_cambio_password_desde_opac")){
    my ($template, $session, $t_params)= get_template_and_user({
                                    template_name => "opac-changepassword.tmpl",
                                    query => $input,
                                    type => "opac",
                                    authnotrequired => 0,
                                    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                                    changepassword => 1,
        });


    $t_params->{'mensaje'}= C4::AR::Mensajes::getMensaje($session->param("codMsg"),'OPAC',[]);

    &C4::Auth::output_html_with_http_headers($template, $t_params, $session);

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

    C4::Auth::redirectTo('/cgi-bin/koha/opac-user.pl?token='.$session->param('token'));
}




