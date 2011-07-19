#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use CGI;
use C4::AR::Novedades;
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

# Arma el texto que va a mostrarse en Twitter
my $contenido= $input->param('contenido');
my $post= C4::AR::Preferencias::getValorPreferencia('prefijo_twitter')." ".$contenido;


if ($action){
    my $status = C4::AR::Novedades::agregar($input);
    #  Posteo en twitter
    my $mensaje= C4::AR::Social::sendPost($post);
   
    if ($status){
        C4::AR::Auth::redirectTo(C4::AR::Utilidades::getUrlPrefix().'/admin/novedades_opac.pl?token='.$input->param('token'));
    }
}
 
C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);