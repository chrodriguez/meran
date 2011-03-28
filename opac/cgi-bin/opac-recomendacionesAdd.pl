#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use C4::Context;
use C4::AR::Recomendaciones;
use CGI;


my $input = new CGI;
# 
# C4::AR::Debug::debug("=================================DATOS================");
# C4::AR::Utilidades::printHASH($input->{'param'});
# C4::AR::Debug::debug("=================================FIN DATOS================");
# 
# C4::AR::Utilidades::printARRAY(($input->{'param'})->{'titulo'});

my ($template, $session, $t_params) = get_template_and_user({
    template_name => "opac-main.tmpl",
    query => $input,
    type => "opac",
    authnotrequired => 0,
    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'ALTA', entorno => 'undefined'},
    debug => 1,
});


my $status = C4::AR::Recomendaciones::agregarRecomendacion($input->{'param'}, C4::AR::Usuarios::getSocioInfoPorNroSocio(C4::AR::Auth::getSessionUserID($session))->getId_socio());
if ($status){
    C4::AR::Auth::redirectTo('/cgi-bin/koha/opac-recomendaciones.pl?token'.$input->param('token'));
}


C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);