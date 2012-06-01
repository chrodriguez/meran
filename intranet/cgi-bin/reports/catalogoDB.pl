#!/usr/bin/perl
use strict;
require Exporter;
use C4::AR::Auth;
use C4::AR::PdfGenerator;
use C4::AR::Reportes;
use C4::AR::Busquedas;
use C4::Modelo::RepBusqueda;
use C4::Modelo::RepHistorialBusqueda;
use CGI;
use JSON;




my $input = new CGI;
my $obj;

my ($template, $session, $t_params);

if ($input->param('obj')){
  
  $obj = $input->param('obj');
  $obj = C4::AR::Utilidades::from_json_ISO($obj);

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



} else {
  
    $obj->{'tipoAccion'}= $input->param('accion');
    $obj->{'orden'}= $input->param('orden');
    $obj->{'asc'}= $input->param('asc');
    $obj->{'usuario'}= $input->param('nro_socio');
    $obj->{'categoria'}= $input->param('categoria_socio_id');
    $obj->{'interfaz'}= $input->param('interfaz');
    $obj->{'valor'}= $input->param('valor');
    $obj->{'fecha_inicio'}= $input->param('date-from');
    $obj->{'fecha_fin'}= $input->param('date-to');
    $obj->{'fecha_fin'}= $input->param('date-to');
    $obj->{'is_report'}= "SI";

    ($template, $session, $t_params)= C4::AR::Auth::get_template_and_user({
                                            template_name   => "includes/partials/reportes/_reporte_busquedas_result_export.inc",
                                            query           => $input,
                                            type            => "intranet",
                                            authnotrequired => 0,
                                            flagsrequired   => {  ui            => 'ANY', 
                                                                tipo_documento  => 'ANY', 
                                                                accion          => 'CONSULTA', 
                                                                entorno         => 'undefined'},
    });

}


my $tipoAccion= $obj->{'tipoAccion'}||"";

#     my $orden=$obj->{'orden'}||'fecha';
$obj->{'ini'} = $obj->{'ini'} || 1;
my $ini=$obj->{'ini'};
my $funcion=$obj->{'funcion'};
my $inicial=$obj->{'inicial'};
$obj->{'orden'} = $obj->{'orden'} || 'valor';

if ($obj->{'asc'}){
    $obj->{'orden'}.= ' ASC';
} else {
    $obj->{'orden'}.= ' DESC';
}
#     C4::AR::Validator::validateParams('U389',$obj,['socio','ini','funcion'] );

my ($results, $cantidad, $all_results);

my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

($results, $cantidad, $all_results)= C4::AR::Reportes::getBusquedasDeUsuario($obj,$ini,$cantR);
  

if($tipoAccion eq "BUSQUEDAS"){
    
    $t_params->{'paginador'}= C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);
#     ($results, $cantidad)= C4::AR::Reportes::getBusquedasDeUsuario($obj);

    $t_params->{'cantidad'} = $cantidad;
    $t_params->{'results'} = $results;
    $t_params->{'nro_socio'} = $obj->{'usuario'};
    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);

} elsif ($tipoAccion eq "EXPORTAR_PDF"){
# 
#       my $branchcode=  C4::AR::Referencias::obtenerDefaultUI();
#       $branchcode=  $branchcode->getId_ui;
# 
#       # ESCUDO UI
#       my $escudoUI =
#         C4::Context->config('intrahtdocs') . '/temas/'
#       . 'default'
#       . '/imagenes/escudo-'
#       . $branchcode
#       . '.jpg';

#         $t_params->{'biblio'} = $branchcode;
#         $t_params->{'escudoUI'} = $escudoUI;
#         $t_params->{'cantidad'} = $cantidad;
#         $t_params->{'results'} = $all_results;
# 
#         C4::AR::Reportes::exportarReporte();
#         my $out         = C4::AR::Auth::get_html_content($template, $t_params, $session);
#         my $filename    = C4::AR::PdfGenerator::pdfFromHTML($out, $obj);
#         print C4::AR::PdfGenerator::pdfHeader();
# # 
#         C4::AR::PdfGenerator::printPDF($filename);

} elsif ($tipoAccion eq "REPORTE_GEN_ETIQUETAS") {

      ($template, $session, $t_params)= C4::AR::Auth::get_template_and_user({
                                                template_name   => "includes/partials/reportes/_reporte_gen_etiquetas_result.inc",
                                                query           => $input,
                                                type            => "intranet",
                                                authnotrequired => 0,
                                                flagsrequired   => {  ui            => 'ANY', 
                                                                    tipo_documento  => 'ANY', 
                                                                    accion          => 'CONSULTA', 
                                                                    entorno         => 'undefined'},
      });

      my ($cantidad, $array_nivel1)   = C4::AR::Reportes::reporteGenEtiquetas($obj, $session);

      $obj->{'cantidad'}              = $cantidad;
      $t_params->{'paginador'}        = C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);
      $t_params->{'SEARCH_RESULTS'}   = $array_nivel1;
      $t_params->{'cantidad'}         = $cantidad;


      C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
}



#C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);