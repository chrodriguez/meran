#!/usr/bin/perl

use strict;
use C4::AR::Auth;

use CGI;
use C4::AR::Estadisticas;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                            template_name => "reports/reservasResult.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {  ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'CONSULTA', 
                                                entorno => 'undefined'},
                            debug => 1,
                });

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $branch=$obj->{'id_ui'};
my $orden = $obj->{'orden'} || 'cardnumber';
my $tipoReserva=$obj->{'tipoReserva'}; # Tipo de reserva

C4::AR::Validator::validateParams('VA001',$obj,['id_ui','tipoReserva','funcion']);

my $funcion=$obj->{'funcion'};
#Inicializo el inicio y fin de la instruccion LIMIT en la consulta
my $ini=$obj->{'ini'};
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);
#FIN inicializacion



my ($cantidad,$resultsdata)= C4::AR::Estadisticas::reservas($branch,$orden,$ini,$cantR,$tipoReserva);

C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);

$t_params->{'reservas'}= $resultsdata;
$t_params->{'cantidad'}= $cantidad;

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
