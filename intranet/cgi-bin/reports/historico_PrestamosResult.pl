#!/usr/bin/perl

# Miguel 21-05-07
# Se obtiene un Historial de los prestamos realizados por los usuarios

use strict;
use C4::AR::Auth;

use CGI;
use C4::AR::Estadisticas;
use C4::AR::Utilidades;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                                template_name => "reports/historico_PrestamosResult.tmpl",
                                query => $input,
                                type => "intranet",
                                authnotrequired => 0,
                                flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                                debug => 1,
            });

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $tipoItem = $obj->{'tiposItems'};
my $tipoPrestamo = $obj->{'tipoPrestamos'};
my $catUsuarios = $obj->{'catUsuarios'};
my $orden = $obj->{'orden'} = $obj->{'orden'}||'firstname';
my $funcion=$obj->{'funcion'};


#Fechas
$obj->{'f_ini'}=$obj->{'f_ini'}||'';
$obj->{'f_fin'}=$obj->{'f_fin'}||'';

my $ini= ($obj->{'ini'});
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);
$obj->{'ini'} = $ini;
$obj->{'cantR'} = $cantR;

my $dateformat = C4::Date::get_date_format();
my $fechaIni = C4::Date::format_date_in_iso($obj->{'f_ini'},$dateformat);
my $fechaFin = C4::Date::format_date_in_iso($obj->{'f_fin'},$dateformat);
#obtengo el Historico de los Prestamos, esta en C4::AR::Estadisticas
my ($cantidad, $historico_prestamos_array_ref)= C4::AR::Estadisticas::historicoPrestamos($obj);

$t_params->{'paginador'}=  C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);


$t_params->{'RESULTSLOOP'}= $historico_prestamos_array_ref;
$t_params->{'tipoItem'}= $tipoItem;
$t_params->{'tipoPrestamo'}= $tipoPrestamo;
$t_params->{'catUsuarios'}= $catUsuarios;
$t_params->{'orden'}= $orden;
$t_params->{'cantidad'}= $cantidad;
$t_params->{'fechaIni'}= $fechaIni;
$t_params->{'fechaFin'}= $fechaFin;


C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
