#!/usr/bin/perl
use strict;
require Exporter;
use C4::AR::Auth;
use CGI;
use JSON;
use C4::AR::Reportes;
use C4::Modelo::RepBusqueda;
use C4::Modelo::RepHistorialBusqueda;


my $input = new CGI;
my $obj=$input->param('obj');

$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $tipoAccion= $obj->{'tipoAccion'}||"";

my ($template, $session, $t_params);


if($tipoAccion eq "BUSQUEDAS"){
    ($template, $session, $t_params)= C4::AR::Auth::get_template_and_user({
                                        template_name   => "includes/partials/reportes/_reporte_busquedas_result.inc",
                                        query           => $input,
                                        type            => "intranet",
                                        authnotrequired => 0,
                                        flagsrequired   => {  ui            => 'ANY', 
                                                            tipo_documento  => 'ANY', 
                                                            accion          => 'CONSULTA', 
                                                            entorno         => 'undefined'},
    });
    

    my $results= C4::AR::Reportes::getBusquedasDeUsuario($obj);

     $t_params->{'results'} = $results;

    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);

}
# elsif($tipoAccion eq "AGREGAR_AUTORIZADO"){
# }



#C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);