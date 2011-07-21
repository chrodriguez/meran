#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use CGI;
use C4::AR::Novedades;
use WWW::Google::URLShortener;
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

my $contenido= Encode::decode('utf8', $input->param('contenido'));

my $cont;
if ($action){
    my $status = C4::AR::Novedades::agregar($input);
   
    my $api_key = C4::AR::Preferencias::getValorPreferencia("google_shortener_api_key");
    my $novedad_url  = WWW::Google::URLShortener->new($api_key);
    my $link= $novedad_url->shorten_url("http://".$ENV{'SERVER_NAME'}.C4::AR::Utilidades::getUrlPrefix().'/ver_novedad.pl?id='.$status->{'id'});

    my $link_lenght= length($link);

#   Se reduce el contenido del post a 140 caracteres para que pueda publicarse en Twitter
    if (length($contenido) > 140){
          $cont= substr($contenido,0,(114 - $link_lenght));
    } else {
          if ((length($contenido) + $link_lenght) > 140){
                $cont= substr($contenido,0,length($contenido) - ($link_lenght + 26));         
          }
    }
   
    my $post= C4::AR::Preferencias::getValorPreferencia('prefijo_twitter')." ".$cont."... Ver mas en: ".$link;


    #  Posteo en twitter. En C4::AR::Social::sendPost se verifica si la preferencia twitter_enabled esta activada
    my $mensaje= C4::AR::Social::sendPost($post);
   
    if ($status){
        C4::AR::Auth::redirectTo(C4::AR::Utilidades::getUrlPrefix().'/admin/novedades_opac.pl?token='.$input->param('token'));
    }
}
 
C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);