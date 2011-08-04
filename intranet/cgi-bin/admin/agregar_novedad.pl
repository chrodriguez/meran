#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use CGI;
use C4::AR::Novedades;
use Encode;
use C4::AR::Social;
my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
									template_name => "admin/agregar_novedad.tmpl",
									query => $input,
									type => "intranet",
									authnotrequired => 0,
									flagsrequired => {  ui => 'ANY', 
                                                        tipo_documento => 'ANY', 
                                                        accion => 'CONSULTA', 
                                                        entorno => 'usuarios'},
									debug => 1,
			    });

my $action = $input->param('action') || 0;

# Se arma el texto que va a mostrarse en Twitter

my $twitter_enabled=C4::AR::Social::twitterEnabled();

my $contenido= Encode::decode('utf8', $input->param('contenido'));

my $cont;
if ($action){
    my $status = C4::AR::Novedades::agregar($input);
   
    if ($input->param('check_publicar')){

          my $link = C4::AR::Social::shortenUrl($status->{'id'});

          my $link_lenght= length($link);

          C4::AR::Debug::debug($contenido);
      #   Se reduce el contenido del post a 140 caracteres para que pueda publicarse en Twitter
          if (length($contenido) > 140){
                $cont= substr($contenido,0,(114 - $link_lenght));
          } else {
                if ((length($contenido) + $link_lenght) > 140){
                      $cont= substr($contenido,0,length($contenido) - ($link_lenght + 26));         
                } else {
                      $cont=$contenido;
                }
          }
        
          my $post= C4::AR::Preferencias::getValorPreferencia('prefijo_twitter')." ".$cont."... Ver mas en: ".$link;


          #  Posteo en twitter. En C4::AR::Social::sendPost se verifica si la preferencia twitter_enabled esta activada
          my $mensaje= C4::AR::Social::sendPost($post);
    }

    if ($status){
        C4::AR::Auth::redirectTo(C4::AR::Utilidades::getUrlPrefix().'/admin/novedades_opac.pl?token='.$input->param('token'));
    }
}

$t_params->{'twitter_enabled'} = $twitter_enabled; 
C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);