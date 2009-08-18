#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use JSON;
use CGI;

my $input = new CGI;

my $authnotrequired= 0;
my $change_password = 1;

my ($template, $session, $t_params) = checkauth(    $input, 
                                                    $authnotrequired,
                                                    {   ui => 'ANY', 
                                                        tipo_documento => 'ANY', 
                                                        accion => 'MODIFICACION', 
                                                        entorno => 'usuarios'
                                                    },
                                                    "intranet",
                                                    $change_password,
                            );

my %params;
$params{'nro_socio'}= $input->param('usuario');
$params{'actualPassword'}= $input->param('actual_password');
$params{'newpassword'}= $input->param('new_password1');
$params{'newpassword1'}= $input->param('new_password2');
$params{'changePassword'}= $input->param('changePassword');
$params{'token'}= $input->param('token');


my ($Message_arrayref)= C4::AR::Usuarios::cambiarPassword(\%params);

if(C4::AR::Mensajes::hayError($Message_arrayref)){
    $session->param('codMsg', C4::AR::Mensajes::getFirstCodeError($Message_arrayref));
    #hay error vulve al mismo
    C4::Auth::redirectTo('/cgi-bin/koha/usuarios/change_password.pl?token='.$input->param('token'));
}else{
    #se cambio la password exitosamente, se destruye la sesion y se obliga al socio a ingresar nuevamente
    C4::Auth::session_destroy();
    $session->param('codMsg', 'U400');
    #redirecciono a auth.pl
    C4::Auth::redirectTo('/cgi-bin/koha/auth.pl');
}
