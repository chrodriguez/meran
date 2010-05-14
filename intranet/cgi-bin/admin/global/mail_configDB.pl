#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::AR::Preferencias;
use C4::AR::Mail;
use JSON;


my $input = new CGI;
my $authnotrequired = 0;

my ($userid, $session, $flags, $socio) = checkauth(     $input, 
                                                        $authnotrequired, 
                                                        {   ui => 'ANY', 
                                                            tipo_documento => 'ANY', 
                                                            accion => 'CONSULTA', 
                                                            entorno => 'undefined'}, 
                                                        'intranet'
                                );


    my $accion; 
    my $obj             = $input->param('obj');
    my $smtp_server;
    my $smtp_metodo;
    my $port_mail;
    my $username_mail;
    my $password_mail;
    my $mailFrom;
    my $reserveFrom;
    my $smtp_server_sendmail; 
    
    if($obj){
        $obj                     = C4::AR::Utilidades::from_json_ISO($obj);
        $accion                  = $obj->{'accion'};
        $smtp_server             = $obj->{'smtp_server'};
        $smtp_metodo             = $obj->{'smtp_metodo'};
        $port_mail               = $obj->{'port_mail'};
        $username_mail           = $obj->{'username_mail'};
        $password_mail           = $obj->{'password_mail'};
        $mailFrom                = $obj->{'mailFrom'};
        $reserveFrom             = $obj->{'reserveFrom'};
        $smtp_server_sendmail    = $obj->{'smtp_server_sendmail'}||0; 
    }else{
        my %hash_temp            = {};
        $obj                     = \%hash_temp;
        $accion                  = $input->param('accion');
        $smtp_server             = $input->param('smtp_server');
        $smtp_metodo             = $input->param('smtp_metodo');
        $port_mail               = $input->param('port_mail');
        $username_mail           = $input->param('username_mail');
        $password_mail           = $input->param('password_mail');
        $mailFrom                = $input->param('mailFrom');
        $reserveFrom             = $input->param('reserveFrom');
        $smtp_server_sendmail    = $input->param('smtp_server_sendmail')||0; 
    }
   

    my $Message_arrayref        = C4::AR::Preferencias::t_modificarVariable('smtp_server', $smtp_server,'');
    $Message_arrayref           = C4::AR::Preferencias::t_modificarVariable('smtp_metodo', $smtp_metodo, '');
    $Message_arrayref           = C4::AR::Preferencias::t_modificarVariable('port_mail', $port_mail, '');
    $Message_arrayref           = C4::AR::Preferencias::t_modificarVariable('username_mail', $username_mail, '');
    $Message_arrayref           = C4::AR::Preferencias::t_modificarVariable('password_mail', $password_mail, '');
    $Message_arrayref           = C4::AR::Preferencias::t_modificarVariable('mailFrom', $mailFrom, '');
    $Message_arrayref           = C4::AR::Preferencias::t_modificarVariable('reserveFrom', $reserveFrom, '');
    $Message_arrayref           = C4::AR::Preferencias::t_modificarVariable('smtp_server_sendmail', $smtp_server_sendmail, '');


if($accion eq "MODIFICAR_CONFIGURACION"){

    C4::Auth::redirectTo('/cgi-bin/koha/admin/global/mail_config.pl');

} elsif($accion eq "PROBAR_CONFIGURACION"){

#     $obj->{'smtp_server'}           = $obj->{'smtp_server'}             || C4::Context->preference("smtp_server");
#     $obj->{'smtp_metodo'}           = $obj->{'smtp_metodo'}             || C4::Context->preference("smtp_metodo");
#     $obj->{'smtp_port'}             = $obj->{'port_mail'}               || C4::Context->preference("port_mail");
#     $obj->{'smtp_user'}             = $obj->{'username_mail'}           || C4::Context->preference("username_mail");
#     $obj->{'smtp_pass'}             = $obj->{'password_mail'}           || C4::Context->preference("password_mail");
#     $obj->{'smtp_server_sendmail'}  = $obj->{'smtp_server_sendmail'}    || C4::Context->preference("smtp_server_sendmail");
#     $obj->{'mail_from'}             = $obj->{'mail_from'}               || C4::Context->preference("mailFrom");
#     my $reserveFrom                 = $obj->{'reserveFrom'};
#     $obj->{'mail_to'}               = $socio->persona->getEmail();
#     $obj->{'mail_subject'}          = Encode::decode('utf8', "Prueba de configuración de mail");
#     $obj->{'mail_message'}          = Encode::decode('utf8', "Esta es una prueba de configuraci".chr(243)."n del mail");
    my $msg_object                  = C4::AR::Mensajes::create();
  
    my ($ok, $msg_error) = C4::AR::Mail::send_mail_TEST($socio->persona->getEmail());    
    
    if($ok){
        $msg_object->{'error'} = 0;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U413', 'params' => [$obj->{'mail_to'}]} ) ;
    } else {
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U414', 'params' => [$obj->{'mail_to'}, $msg_error]} ) ;
    }

    my $infoOperacionJSON=to_json $msg_object;
    C4::Auth::print_header($session);
    print $infoOperacionJSON;
}