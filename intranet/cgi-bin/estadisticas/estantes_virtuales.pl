#!/usr/bin/perl
# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA
#
#

# use strict;
# use C4::AR::Auth;

# use CGI;
# use C4::AR::Utilidades;
# use C4::AR::Reportes;

# my $input = new CGI;
# my $obj=$input->param('obj') || 0;

# my ($template, $session, $t_params, $data_url);

# if (!$obj){
#         ($template, $session, $t_params) = get_template_and_user({
#                                 template_name => "estadisticas/estantes_virtuales.tmpl",
#                                 query => $input,
#                                 type => "intranet",
#                                 authnotrequired => 0,
#                                 flagsrequired => {  ui => 'ANY', 
#                                                     tipo_documento => 'ANY', 
#                                                     accion => 'CONSULTA', 
#                                                     entorno => 'undefined'},
#                                 debug => 1,
# 			            });
# }else{
#         $obj=C4::AR::Utilidades::from_json_ISO($obj) || 0;
        
#         if ($obj->{"is_report"}){

#                 ($template, $session, $t_params) = get_template_and_user({
#                                                 template_name => "includes/partials/reportes/_reporte_disponibilidad_result.inc",
#                                                 query => $input,
#                                                 type => "intranet",
#                                                 authnotrequired => 0,
#                                                 flagsrequired => {  ui => 'ANY', 
#                                                                     tipo_documento => 'ANY', 
#                                                                     accion => 'CONSULTA', 
#                                                                     entorno => 'undefined'},
#                                                 debug => 1,
#                                         });

#         }


#         my ($data,$is_array_of_hash) = C4::AR::Reportes::getEstantes($obj,1);

#         # ($template, $session, $t_params) = get_template_and_user({
#         #                         template_name => "estadisticas/partial_swf.tmpl",
#         #                         query => $input,
#         #                         type => "intranet",
#         #                         authnotrequired => 0,
#         #                         flagsrequired => {  ui => 'ANY', 
#         #                                             tipo_documento => 'ANY', 
#         #                                             accion => 'CONSULTA', 
#         #                                             entorno => 'undefined'},
#         #                         debug => 1,
#         #                 });

#         # $data_url = C4::AR::Utilidades::getUrlPrefix()."/estadisticas/estantes_virtuales_data.pl?estante=".$obj->{'estante'};
#         # $t_params->{'data'} = C4::AR::Reportes::getArrayHash('getEstantes',$obj);

#         my ($data,$is_array_of_hash) = C4::AR::Reportes::getEstantes($obj,1);
#         my ($path,$filename) = C4::AR::Reportes::toXLS($data,$is_array_of_hash,'Pagina 1','Estantes Virtuales');
        
#         $t_params->{'filename'} = '/reports/'.$filename;


# }

# my %params_for_combo = {};
# $t_params->{'data_url'} = $data_url;
# $t_params->{'estante_combo'} = C4::AR::Utilidades::generarComboEstantes(\%params_for_combo);

# C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);



#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use CGI;
use C4::AR::Utilidades;
use C4::AR::Reportes;
use C4::AR::PdfGenerator;


my $input = new CGI;
my $obj=$input->param('obj');

if ($obj){
    $obj=C4::AR::Utilidades::from_json_ISO($obj);
}else{ 
    $obj = $input->Vars;
    $obj->{'estante'}= $obj->{'name_estante'};     
}

my ($template, $session, $t_params, $data_url);

($template, $session, $t_params) = get_template_and_user({
                                            template_name => "includes/partials/reportes/_reporte_estantes_virtuales_result.inc",
                                            query => $input,
                                            type => "intranet",
                                            authnotrequired => 0,
                                            flagsrequired => {  ui => 'ANY', 
                                                                tipo_documento => 'ANY', 
                                                                accion => 'CONSULTA', 
                                                                entorno => 'undefined'},
                                            debug => 1,
                });


my $ini                         = $obj->{'ini'};     
my ($ini,$pageNumber,$cantR)    = C4::AR::Utilidades::InitPaginador($ini);

$t_params->{'ini'}= $obj->{'ini'}       = $ini;
$t_params->{'cantR'}= $obj->{'cantR'}   = $cantR;


my ($data, $cant)         = C4::AR::Reportes::reporteEstantesVirtuales($obj);

$t_params->{'data'} = $data;

if ($obj->{'exportar'}) {

    $t_params->{'cant'} = $cant;
    $t_params->{'exportar'} = 1;

    $obj->{'is_report'}="SI";

    my $out= C4::AR::Auth::get_html_content($template, $t_params);
    my $filename= C4::AR::PdfGenerator::pdfFromHTML($out,$obj);
    print C4::AR::PdfGenerator::pdfHeader(); 
    C4::AR::PdfGenerator::printPDF($filename);

} else {

    $t_params->{'paginador'}= C4::AR::Utilidades::crearPaginador($cant,$cantR, $pageNumber,$obj->{'funcion'},$t_params);
    $t_params->{'cant'} = $cant;

    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
}
    

