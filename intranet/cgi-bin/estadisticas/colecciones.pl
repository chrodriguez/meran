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

use strict;
use C4::AR::Auth;

use CGI;
use C4::AR::Utilidades;
use C4::AR::Reportes;

my $input = new CGI;
my $obj=$input->param('obj') || 0;


C4::AR::Debug::debug("OBJ ===================================================================>: ".$obj);
my ($template, $session, $t_params, $data_url);

if (!$obj){
        ($template, $session, $t_params) = get_template_and_user({
                                template_name => "estadisticas/colecciones.tmpl",
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
        $obj=C4::AR::Utilidades::from_json_ISO($obj);

        ($template, $session, $t_params) = get_template_and_user({
                                template_name => "includes/partials/reportes/_reporte_colecciones_result.inc",
                                query => $input,
                                type => "intranet",
                                authnotrequired => 0,
                                flagsrequired => {  ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'CONSULTA', 
                                                    entorno => 'undefined'},
                                debug => 1,
                        });

        # $data_url = C4::AR::Utilidades::getUrlPrefix()."/estadisticas/colecciones_data.pl?item_type=".$obj->{'item_type'}."%26ui=".$obj->{'ui'};
        # $t_params->{'data'} = C4::AR::Reportes::getArrayHash('getItemTypes',$obj);
        
        # my ($data,$is_array_of_hash) = C4::AR::Reportes::getItemTypes($obj,1);
        # my ($path,$filename) = C4::AR::Reportes::toXLS($data,$is_array_of_hash,'Pagina 1','Colecciones');
        
        # $t_params->{'filename'} = '/reports/'.$filename;


        my $total_ejemp; 
        if ($obj->{'total_ejemp'}){
            $total_ejemp = $obj->{'total_ejemp'};
        }

        C4::AR::Debug::debug($total_ejemp);

        my ($data, $cant) = C4::AR::Reportes::reporteColecciones($obj);

        $t_params->{'total_ejemp'} = $total_ejemp;
        $t_params->{'data'} = $data;
        $t_params->{'cant'} = $cant;

}

my %params_for_combo = {};
$params_for_combo{'default'} = 'ALL';
$t_params->{'data_url'} = $data_url;
$t_params->{'item_type_combo'} = C4::AR::Utilidades::generarComboTipoNivel3(\%params_for_combo);
$t_params->{'ui_combo'} = C4::AR::Utilidades::generarComboUI();

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);