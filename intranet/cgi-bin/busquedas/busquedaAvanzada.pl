#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Busquedas;
use C4::AR::Utilidades;
# use C4::AR::Catalogacion;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user ({
                                                            template_name  => 'busquedas/busquedaResult.tmpl',
                                                            query    => $input,
                                                            type     => "intranet",
                                                            authnotrequired   => 0,
                                                            flagsrequired  => { circulate => 1 },
                  });

my $obj=$input->param('obj');

if($obj ne ""){
   $obj=from_json_ISO($obj);
}

my $funcion= $obj->{'funcion'};
my $ini= ($obj->{'ini'}||'');

my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

$obj->{'type'} = 'INTRA';

my ($cantidad, $array_nivel1)= C4::AR::Busquedas::busquedaAvanzada_newTemp($ini,$cantR,$obj,$session);

C4::AR::Debug::debug("cant: ".$cantidad);
#se arma el arreglo con la info para mostrar en el template
$obj->{'cantidad'}= $cantidad;
$obj->{'loggedinuser'}= $session->param('nro_socio');
#se loguea la busqueda

$t_params->{'paginador'}= C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);
$t_params->{'SEARCH_RESULTS'}= $array_nivel1;
$t_params->{'cantidad'}= $cantidad;
$t_params->{'buscoPor'}= C4::AR::Busquedas::armarBuscoPor($obj);

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
