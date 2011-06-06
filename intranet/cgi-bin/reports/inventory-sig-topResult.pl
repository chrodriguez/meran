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

my $accion  = $obj->{'accion'};
my $orden   = $obj->{'orden'} || 'barcode';
my $ini     = $obj->{'ini'};
my $funcion = $obj->{'funcion'};

my ($template, $session, $t_params) = get_template_and_user({
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

#Buscar
my $cat_nivel3;
my $array_hash_ref;
my $cant_total  = 0;
my $ini = $obj->{'ini'};

my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

$t_params->{'ini'}      = $obj->{'ini'}     = $ini;
$t_params->{'cantR'}    = $obj->{'cantR'}   = $cantR;
# $obj->{'fin'}   = $cantR;
# my $ini                         = ($obj->{'ini'}||'');

if ($accion eq "EXPORTARXLS"){


        my $tabla_array_ref = $obj->{'table'}; 

        my ($template, $session, $t_params) =  C4::AR::Auth::get_template_and_user ({
                              template_name   => "reports/inventory-sig-topResult.tmpl",
                              query       => $input,
                              type        => "intranet",
                              authnotrequired => 0,
                              flagsrequired   => {  ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'CONSULTA', 
                                                    entorno => 'usuarios'}, # FIXME
        });

        my @reporte;
        my $headers_tabla;
        my $message;    

        push(@$headers_tabla, 'C�digo de barra');
        push(@$headers_tabla, 'Signatura Topogr�fica');
        push(@$headers_tabla, 'Autor');
        push(@$headers_tabla, 'Editor');
        push(@$headers_tabla, 'Edici�n');
        push(@$headers_tabla, 'UI Origen');
        push(@$headers_tabla, 'UI Poseedora');
   
        foreach my $celda (@$tabla_array_ref){
              my $celda_xls; 
              
              push(@$celda_xls, $celda->{'C�digo de barra'});
              push(@$celda_xls, $celda->{'Signatura Topogr�fica'});
              push(@$celda_xls, $celda->{'Autor'});
              push(@$celda_xls, $celda->{'Editor'});
              push(@$celda_xls, $celda->{'Edici�n'});
              push(@$celda_xls, $celda->{'UI Origen'});
              push(@$celda_xls, $celda->{'UI Poseedora'});

              push (@reporte, $celda_xls);
        }
 
   
        $message= C4::AR::XLSGenerator::exportarMejorPresupuesto(\@reporte, $headers_tabla);

#         C4::AR::Debug::debug($message->{'codMsg'});


        my $infoOperacionJSON   = to_json $message;
        C4::AR::Auth::print_header($session);
        print $infoOperacionJSON;

#         C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session); 
}


if ($accion eq "CONSULTA_POR_SIGNATURA") {

     if ($sigtop){ 
         ($cant_total, $cat_nivel3, $array_hash_ref)   = C4::AR::Reportes::listarItemsDeInventarioPorSigTop($obj);
     } else {
         ($cant_total, $cat_nivel3, $array_hash_ref)   = C4::AR::Reportes::listarItemsDeInventarioEntreSigTops($obj);
     }

#     my ($path, $filename)            = C4::AR::Reportes::toXLS($array_hash_ref,1,'Pagina 1','inventario');        
#     $t_params->{'filename'}          = '/reports/'.$filename;
     $t_params->{'results'} = $cat_nivel3;

}

if ($accion eq "CONSULTA_POR_BARCODE") {
    
     if ($barcode){ 
         ($cant_total, $cat_nivel3, $array_hash_ref)  = C4::AR::Reportes::listarItemsDeInventarioPorBarcode($obj); 
     } else {
         ($cant_total, $cat_nivel3, $array_hash_ref)  = C4::AR::Reportes::listarItemsDeInventarioEntreBarcodes($obj);
     }
    
#     my ($path, $filename)           = C4::AR::Reportes::toXLS($array_hash_ref,1,'Pagina 1','inventario');
#     $t_params->{'filename'}         = '/reports/'.$filename;
    $t_params->{'results'}          = $cat_nivel3;
}

$t_params->{'paginador'}            = C4::AR::Utilidades::crearPaginador($cant_total,$cantR, $pageNumber,$funcion,$t_params);

$t_params->{'cantidad'}             = $cant_total;

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
