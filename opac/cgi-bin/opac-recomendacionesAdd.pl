#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Context;
use C4::AR::Recomendaciones;
use CGI;
use JSON;

my $input = new CGI;



my $obj=$input->param('obj');

my ($template, $session, $t_params) = get_template_and_user({
    template_name => "opac-main.tmpl",
    query => $input,
    type => "opac",
    authnotrequired => 0,
    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'ALTA', entorno => 'undefined'},
    debug => 1,
});

my $action = $input->param('action') || 0;

if ($action){

    my $status = C4::AR::Recomendaciones::agregarRecomendacion($input, C4::AR::Usuarios::getSocioInfoPorNroSocio(C4::Auth::getSessionUserID($session))->getId_socio());
    if ($status){
        C4::Auth::redirectTo('/cgi-bin/koha/opac-recomendaciones.pl?token'.$input->param('token'));
    }
}


C4::Auth::output_html_with_http_headers($template, $t_params, $session);