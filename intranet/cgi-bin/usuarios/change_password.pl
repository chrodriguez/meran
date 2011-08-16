#!/usr/bin/perl

use strict;
use C4::AR::Auth;

use JSON;
use CGI;

my $input = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
                                    template_name => "changepassword.tmpl",
                                    query => $input,
                                    type => "intranet",
                                    authnotrequired => 0,
                                    flagsrequired => { 
                                                        ui => 'ANY', 
                                                        tipo_documento => 'ANY', 
                                                        accion => 'CONSULTA', 
                                                        entorno => 'undefined'},
                                    changepassword => 1,
                              });


my $nro_socio = C4::AR::Auth::getSessionNroSocio();
my $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);

if ( $socio->getChange_password() ){
    $t_params->{'cambioForzado'}=1;
}

if ($input->param('error')){
    $t_params->{'mensaje'}= C4::AR::Mensajes::getMensaje($session->param("codMsg"),'INTRA',[]);
}
$t_params->{'plainPassword'}= C4::Context->config('plainPassword');
$t_params->{'nroRandom'}    = C4::AR::Auth::getSessionNroRandom();
C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);




