#!/usr/bin/perl

use strict;
use C4::Auth;

use CGI;
use C4::AR::Estadisticas;

my $input = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
                        template_name => "reports/logueoBusquedaResult.tmpl",
			            query => $input,
			            type => "intranet",
			            authnotrequired => 0,
			            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
			            debug => 1,
			     });

my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);
#Fechas
my $fechaIni=$obj->{'fechaIni'};
my $fechaFin=$obj->{'fechaFin'};
my $catUsuarios=$obj->{'catUsuarios'};
my $orden = $obj->{'orden'} = $obj->{'orden'}||'apellido';
my $funcion=$obj->{'funcion'};

my $ini= $obj->{'ini'};
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);
$obj->{'ini'} = $ini;
$obj->{'cantR'} = $cantR;
#historial de busquedas desde OPAC
my ($cantidad, $resultsdata)= C4::AR::Estadisticas::historicoDeBusqueda($obj);

$t_params->{'paginador'}= C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);


$t_params->{'resulsloop'}=$resultsdata;
$t_params->{'cantidad'}= $cantidad;
$t_params->{'fechaIni'}=$fechaIni;
$t_params->{'fechaFin'}=$fechaFin;
$t_params->{'catUsuarios'}=$catUsuarios;

C4::Auth::output_html_with_http_headers($template, $t_params, $session);

