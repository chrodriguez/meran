#!/usr/bin/perl

require Exporter;
use strict;
use C4::AR::Auth;
use CGI;
use JSON;
use C4::AR::Reportes;
use C4::Modelo::RepBusqueda;
use C4::Modelo::RepHistorialBusqueda;


my $input       = new CGI;
my $obj         = $input->param('obj');
$obj            = C4::AR::Utilidades::from_json_ISO($obj);
my $tipoAccion  = $obj->{'tipoAccion'}||"";

my ($template, $session, $t_params);


if($tipoAccion eq "BUSQUEDAS"){
    ($template, $session, $t_params)= C4::AR::Auth::get_template_and_user({
                                        template_name   => "includes/partials/reportes/_reporte_circulacion_result.inc",
                                        query           => $input,
                                        type            => "intranet",
                                        authnotrequired => 0,
                                        flagsrequired   => {  ui            => 'ANY', 
                                                            tipo_documento  => 'ANY', 
                                                            accion          => 'CONSULTA', 
                                                            entorno         => 'undefined'},
    });

    $obj->{'ini'}   = $obj->{'ini'} || 1;
    my $ini         = $obj->{'ini'};
    my $funcion     = $obj->{'funcion'};
    $obj->{'orden'} = $obj->{'orden'} || 'titulo';
   
    if ($obj->{'asc'}){
       $obj->{'orden'}.= ' ASC';
    } else {
       $obj->{'orden'}.= ' DESC';
    }
                           
    my ($ini,$pageNumber,$cantR)    = C4::AR::Utilidades::InitPaginador($ini);

    my ($results, $cantidad)        = C4::AR::Reportes::getReservasCirculacion($obj,$ini,$cantR);

    $t_params->{'paginador'}        = C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);
    $t_params->{'cantidad'}         = $cantidad;
    $t_params->{'results'}          = $results;

    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
}
# elsif($tipoAccion eq "AGREGAR_AUTORIZADO"){
# }



#C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);