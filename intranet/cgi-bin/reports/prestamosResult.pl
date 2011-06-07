#!/usr/bin/perl


use strict;
use C4::AR::Auth;

use CGI;
use C4::AR::Estadisticas;
use C4::AR::SxcGenerator;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                        template_name => "reports/prestamosResult.tmpl",
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


my $branch = $obj->{'id_ui'};
my $orden = $obj->{'orden'} = $obj->{'orden'} || 'cardnumber';
my $estado = $obj->{'estado'} = $obj->{'estado'}|| 'TO';

#Fechas
$obj->{'fechaIni'} = $obj->{'begindate'};
$obj->{'fechaFin'} = $obj->{'enddate'};

C4::AR::Validator::validateParams('VA001',$obj,['id_ui','fechaIni','fechaFin']);


my $nro_socio = $session->param('nro_socio');

my $ini= $obj->{'ini'};


my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);


$obj->{'ini'} = $ini;
$obj->{'cantR'} = $cantR;



if ($obj->{'renglones'}){
   $cantR=$obj->{'renglones'};
}

my ($cantidad,$resultsdata)= C4::AR::Estadisticas::prestamos($obj);#Prestamos sin devolver (vencidos y no vencidos)

my $funcion=$obj->{'funcion'};


$t_params->{'paginador'} = C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);


# La planilla se debe generar si se la pide explicitamente!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


$t_params->{'estado'}= $estado;
$t_params->{'resultsloop'}= $resultsdata;
$t_params->{'cantidad'}= $cantidad;
$t_params->{'renglones'}= $cantR;
# $t_params->{'planilla'}= $planilla;

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
