#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use CGI;
use C4::AR::Reportes;
use C4::AR::Estadisticas;
use C4::AR::Busquedas;

use JSON;
#Genera un inventario a partir de la busqueda por signatura topografica

my $input   = new CGI;

C4::AR::Debug::debug($input->param('obj'));
my $obj= $input->param('obj');
my @results;

$obj = C4::AR::Utilidades::from_json_ISO($obj);

my $sigtop  = $obj->{'sigtop'};
my $barcode = $obj->{'barcode'};
my $desde_barcode  = $obj->{'desde_barcode'};
my $hasta_barcode  = $obj->{'hasta_barcode'};
my $desde_signatura  = $obj->{'desde_signatura'};
my $hasta_signatura  = $obj->{'hasta_signatura'};



my $accion  = $obj->{'accion'};

my $ini     = $obj->{'ini'};
my $funcion = $obj->{'funcion'};



#Buscar
my $cat_nivel3;
my $array_hash_ref;
my $cant_total  = 0;
my $ini = $obj->{'ini'};

my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

my ($template, $session, $t_params);
# $obj->{'fin'}   = $cantR;
# my $ini                         = ($obj->{'ini'}||'');


if ($accion eq "EXPORTAR_XLS") {

    ($template, $session, $t_params) = get_template_and_user({
                        template_name   => "reports/inventory-sig-top-ExportMsj.tmpl",
                        query           => $input,
                        type            => "intranet",
                        authnotrequired => 0,
                        flagsrequired   => {    ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'CONSULTA', 
                                                entorno => 'undefined'},
                        debug           => 1,
             });    

    $t_params->{'ini'}      = $obj->{'ini'}     = $ini;
    $t_params->{'cantR'}    = $obj->{'cantR'}   = $cantR; 
  
    ($cant_total, $cat_nivel3) = C4::AR::Reportes::consultaParaReporte($obj);
   
    my ($path, $filename) = C4::AR::Reportes::toXLS($cat_nivel3,1,'Pagina 1','inventario');   
    
    $t_params->{'filename'}= "/uploads/report/".$filename 

}



if ($accion eq "CONSULTA_POR_SIGNATURA") {

  ($template, $session, $t_params) = get_template_and_user({
                        template_name   => "reports/inventory-sig-topResult.tmpl",
                        query           => $input,
                        type            => "intranet",
                        authnotrequired => 0,
                        flagsrequired   => {    ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'CONSULTA', 
                                                entorno => 'undefined'},
                        debug           => 1,
             });     
    
    $t_params->{'ini'}      = $obj->{'ini'}     = $ini;
    $t_params->{'cantR'}    = $obj->{'cantR'}   = $cantR; 

     if ($sigtop){ 
         ($cant_total, $cat_nivel3, $array_hash_ref)   = C4::AR::Reportes::listarItemsDeInventarioPorSigTop($obj);
     } else {
         ($cant_total, $cat_nivel3, $array_hash_ref)   = C4::AR::Reportes::listarItemsDeInventarioEntreSigTops($obj);
     }
     
    
#     my ($path, $filename)            = C4::AR::Reportes::toXLS($array_hash_ref,1,'Pagina 1','inventario');        
#     $t_params->{'filename'}          = '/uploads/reports/'.$filename;
    $t_params->{'results'} = $cat_nivel3;

}

if ($accion eq "CONSULTA_POR_BARCODE") {
    

    ($template, $session, $t_params) = get_template_and_user({
                        template_name   => "reports/inventory-sig-topResult.tmpl",
                        query           => $input,
                        type            => "intranet",
                        authnotrequired => 0,
                        flagsrequired   => {    ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'CONSULTA', 
                                                entorno => 'undefined'},
                        debug           => 1,
             });

    $t_params->{'ini'}      = $obj->{'ini'}     = $ini;
    $t_params->{'cantR'}    = $obj->{'cantR'}   = $cantR; 


     if ($barcode){ 
         ($cant_total, $cat_nivel3, $array_hash_ref)  = C4::AR::Reportes::listarItemsDeInventarioPorBarcode($obj); 
     } else {
         ($cant_total, $cat_nivel3, $array_hash_ref)  = C4::AR::Reportes::listarItemsDeInventarioEntreBarcodes($obj);
     }
#     
      my $ui_barcode=  $obj->{'id_ui'};
#     my ($path, $filename)           = C4::AR::Reportes::toXLS($array_hash_ref,1,'Pagina 1','inventario');
#     $t_params->{'filename'}         = '/uploads/reports/'.$filename;
      C4::AR::Utilidades::printHASH(@$cat_nivel3[0]);
    $t_params->{'results'}          = $cat_nivel3;
}

$t_params->{'paginador'}            = C4::AR::Utilidades::crearPaginador($cant_total,$cantR, $pageNumber,$funcion,$t_params);

$t_params->{'cantidad'}             = $cant_total;

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
