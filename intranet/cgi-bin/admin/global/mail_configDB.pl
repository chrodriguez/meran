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

    } else {

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
   

    my $categoria               = 'sistema';
    my $Message_arrayref        = C4::AR::Preferencias::t_modificarVariable('smtp_server', $smtp_server,'',$categoria);
    $Message_arrayref           = C4::AR::Preferencias::t_modificarVariable('smtp_metodo', $smtp_metodo, '',$categoria);
    $Message_arrayref           = C4::AR::Preferencias::t_modificarVariable('port_mail', $port_mail, '',$categoria);
    $Message_arrayref           = C4::AR::Preferencias::t_modificarVariable('username_mail', $username_mail, '',$categoria);
    $Message_arrayref           = C4::AR::Preferencias::t_modificarVariable('password_mail', $password_mail, '',$categoria);
    $Message_arrayref           = C4::AR::Preferencias::t_modificarVariable('mailFrom', $mailFrom, '',$categoria);
    $Message_arrayref           = C4::AR::Preferencias::t_modificarVariable('reserveFrom', $reserveFrom, '',$categoria);
    $Message_arrayref           = C4::AR::Preferencias::t_modificarVariable('smtp_server_sendmail', $smtp_server_sendmail, '',$categoria);


if($accion eq "MODIFICAR_CONFIGURACION"){

    C4::Auth::redirectTo('/cgi-bin/koha/admin/global/mail_config.pl');

} elsif($accion eq "PROBAR_CONFIGURACION"){

    my $msg_object          = C4::AR::Mensajes::create();
  
    my $mail_to             = $socio->persona->getEmail();
    my ($ok, $msg_error)    = C4::AR::Mail::send_mail_TEST($mail_to);    
    
    if($ok){
        $msg_object->{'error'}  = 0;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U413', 'params' => [$mail_to]} ) ;
    } else {
        $msg_object->{'error'}  = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U414', 'params' => [$mail_to, $msg_error]} ) ;
    }

    my $infoOperacionJSON       = to_json $msg_object;
    C4::Auth::print_header($session);
    print $infoOperacionJSON;
}