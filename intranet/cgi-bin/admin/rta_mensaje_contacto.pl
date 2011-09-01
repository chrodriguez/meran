#!/usr/bin/perl

use HTML::Template;
use strict;
require Exporter;
use C4::Output;  # contains gettemplate
use C4::AR::Auth;
use JSON;
use C4::Context;
use C4::AR::Mail;
use CGI;

my $input = new CGI;

my $obj=$input->param('obj')||"";
$obj  = C4::AR::Utilidades::from_json_ISO($obj);
my $asunto  = $obj->{'asunto'};
my $email = $obj->{'email'};
my $texto = $obj->{'texto'};

C4::AR::Debug::debug($email);


    my ($template, $session, $t_params) = get_template_and_user({
                 template_name      => "/admin/mensajes_contacto.tmpl",
                 query              => $input,
                 type               => "intranet",
                 authnotrequired    => 0,
                 flagsrequired      => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                 debug              => 1,
            });
           
    my %mail;

## Datos para el mail
    $mail{'mail_from'}  = Encode::decode_utf8(C4::AR::Preferencias::getValorPreferencia('mailFrom'));
    $mail{'mail_to'}    = $email;
    $mail{'mail_subject'}  = 'Re: '. $asunto;
    

    use C4::Modelo::PrefUnidadInformacion;
    use MIME::Lite::TT::HTML;
    
    my $ui              = C4::AR::Referencias::obtenerDefaultUI();
    my $nombre_ui       = $ui->getNombre();

    my $mailMessage = Encode::decode_utf8($texto);
             
    $mail{'mail_message'}           = $mailMessage;

    my ($ok, $msg_error)            = C4::AR::Mail::send_mail(\%mail);
      
    
    my  $msg = C4::AR::Mensajes::create();
    if ($msg_error){
              C4::AR::Mensajes::add($msg, {'codMsg'=> 'U427', 'params' => []} ) ;
  
    }else{
              C4::AR::Mensajes::add($msg, {'codMsg'=> 'U426', 'params' => []} ) ;
    }

    my $infoOperacionJSON = to_json $msg;
 
    C4::AR::Auth::print_header($session);
    print $infoOperacionJSON;

