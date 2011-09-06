#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use C4::Modelo::AdqRecomendacion;
use CGI;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                                    template_name   => "adquisiciones/recomendaciones.tmpl",
                                    query           => $input,
                                    type            => "intranet",
                                    authnotrequired => 0,
                                    flagsrequired   => {    ui => 'ANY', 
                                                            tipo_documento => 'ANY', 
                                                            accion => 'CONSULTA', 
                                                            entorno => 'usuarios'}, # FIXME
                                    debug           => 1,
                });


# my $ini  = 1;
# 
# my ($ini,$pageNumber,$cantR) = C4::AR::Utilidades::InitPaginador($ini);

# my $funcion   = $obj->{'funcion'};

my $recomendaciones= C4::AR::Recomendaciones::getRecomendaciones();
# my $cantidad= scalar(@$recomendaciones);

$t_params->{'page_sub_title'} = C4::AR::Filtros::i18n("Listado de Recomendaciones");
# $t_params->{'paginador'} = C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);

$t_params->{'recom_activas'} = $recomendaciones;
$t_params->{'cantidad'} = scalar(@$recomendaciones);

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
1;