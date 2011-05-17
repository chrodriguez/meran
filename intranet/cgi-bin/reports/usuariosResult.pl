#!/usr/bin/perl

use strict;
use C4::AR::Auth;

use CGI;
#use C4::AR::Estadisticas;
use C4::AR::Reportes;
#use C4::Date;
use C4::AR::PdfGenerator;

my $input = new CGI;
my $to_pdf = $input->param('export') || 0;
my ($template, $session, $t_params);

if ($to_pdf){
    ($template, $session, $t_params) = get_template_and_user({
                            template_name => "reports/usuariosResult-export.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {  ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'CONSULTA', 
                                                entorno => 'undefined'},
                            debug => 1,
                });
}else{
    ($template, $session, $t_params) = get_template_and_user({
                            template_name => "reports/usuariosResult.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {  ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'CONSULTA', 
                                                entorno => 'undefined'},
                            debug => 1,
                });
}

my ($ini,$pageNumber,$cantR);
my $obj         = $input->param('obj');
my $ini;

if (!$to_pdf){
    $obj= C4::AR::Utilidades::from_json_ISO($obj);
    $ini= $obj->{'ini'};
}else{
    $obj= $input->Vars;
    $ini= 0;
}
    
($ini,$pageNumber,$cantR)    = C4::AR::Utilidades::InitPaginador($ini);

my $nota        = $obj->{'notas'};
my $id          = $obj->{'id'};
my $funcion     = $obj->{'funcion'};

#Inicializo el inicio y fin de la instruccion LIMIT en la consulta
#FIN inicializacion
$obj->{'cantR'}                 = $cantR;
$obj->{'fin'}                   = $ini;

my $dateformat                  = C4::Date::get_date_format();

my ($cantidad_registros, $usuarios) = C4::AR::Reportes::registroDeUsuarios($obj,$cantR, $ini, $to_pdf);


$t_params->{'usuarios'}    = $usuarios;
$t_params->{'cantidad'}    = $cantidad_registros;

if (!$to_pdf){
    $t_params->{'paginador'}    = C4::AR::Utilidades::crearPaginador($cantidad_registros,$cantR, $pageNumber,$funcion,$t_params);
}

## PARAMETOS PARA ARMAR LA URL DE PDF

$t_params->{'param_anio'}        = $obj->{'year'};
$t_params->{'param_categoria'}   = $obj->{'category'};
$t_params->{'param_ui'}          = $obj->{'ui'};
$t_params->{'param_name_from'}   = $obj->{'name_from'};
$t_params->{'param_name_to'}     = $obj->{'name_to'};

## PARAMETOS PARA OCULTAR CAMPOS DE LA TABLA

$t_params->{'hide_nro_socio'}           = $obj->{'hide_nro_socio'};
$t_params->{'hide_imagen'}              = $obj->{'hide_imagen'};
$t_params->{'hide_nom_ape'}             = $obj->{'hide_nom_ape'};
$t_params->{'hide_categoria_socio_id'}  = $obj->{'hide_categoria_socio_id'};
$t_params->{'hide_id_ui'}               = $obj->{'hide_id_ui'};
$t_params->{'hide_legajo'}              = $obj->{'hide_legajo'};
$t_params->{'hide_year'}                = $obj->{'hide_year'};
$t_params->{'hide_nro_documento'}       = $obj->{'hide_nro_documento'};

if ($to_pdf){
    $t_params->{'exported'} = 1;
    my $out= C4::AR::Auth::get_html_content($template, $t_params, $session);
    my $filename= C4::AR::PdfGenerator::pdfFromHTML($out);

    print C4::AR::PdfGenerator::pdfHeader();

    C4::AR::PdfGenerator::printPDF($filename);
    
    
}else{
    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
}
