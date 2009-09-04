#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Estadisticas;
use C4::Date;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                            template_name => "reports/registroResult.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                            debug => 1,
                });

my $obj=$input->param('obj');
$obj= C4::AR::Utilidades::from_json_ISO($obj);

my $nota = $obj->{'notas'};
my $id   = $obj->{'id'};
my $funcion = $obj->{'funcion'};

if ($id ne ""){
        insertarNota($id,$nota);
}

#Inicializo el inicio y fin de la instruccion LIMIT en la consulta
my $ini=$obj->{'ini'};
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);
#FIN inicializacion
$obj->{'cantR'} = $cantR;
$obj->{'fin'} = $ini;

my $dateformat = C4::Date::get_date_format();
#Tomo las fechas que setea el usuario y las paso a formato ISO
my $fechaInicio =  format_date_in_iso($obj->{'dateselected'},$dateformat);
my $fechaFin    =  format_date_in_iso($obj->{'dateselectedEnd'},$dateformat);
my $cant;


$obj->{'orden'}|= $obj->{'orden'}||'surname';
$obj->{'fechaInicio'} = $fechaInicio;
$obj->{'fechaFin'} = $fechaFin;

my ($cantidad_registros,$registros) = C4::AR::Estadisticas::registroEntreFechas($obj);


# C4::AR::Utilidades::crearPaginador($cant,$cantR, $pageNumber,$funcion,$t_params);

$t_params->{'registros'}= $registros;
$t_params->{'cant'}= $cantidad_registros;
$t_params->{'paginador'} = C4::AR::Utilidades::crearPaginador($cantidad_registros,$cantR, $pageNumber,$funcion,$t_params);

C4::Auth::output_html_with_http_headers($template, $t_params, $session);
