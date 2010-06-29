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
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Utilidades;
use C4::AR::Reportes;

my $input = new CGI;
my $obj=$input->param('obj') || 0;
$obj=C4::AR::Utilidades::from_json_ISO($obj);

my ($template, $session, $t_params, $data_url);


        if (!$obj){
            ($template, $session, $t_params) = get_template_and_user({
                                    template_name => "estadisticas/busquedas_opac.tmpl",
                                    query => $input,
                                    type => "intranet",
                                    authnotrequired => 0,
                                    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                                    debug => 1,
              });
        }else{
            ($template, $session, $t_params) = get_template_and_user({
                                template_name => "estadisticas/busquedas_opac_result.tmpl",
                                query => $input,
                                type => "intranet",
                                authnotrequired => 0,
                                flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                                debug => 1,
            });
            my $ini= $obj->{'ini'};
            my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);
            my ($cantidad,$data,$is_hash) = C4::AR::Reportes::getBusquedasOPAC($obj,$cantR,$ini);

            my ($cantidad,$data_xls,$is_hash) = C4::AR::Reportes::getBusquedasOPAC($obj,0,0);
            my ($path,$filename) = C4::AR::Reportes::toXLS($data_xls,$is_hash,'Pagina 1','busquedas_opac');
            
            $t_params->{'paginador'}= C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$obj->{'funcion'},$t_params);
            $t_params->{'filename'} = '/reports/'.$filename;
            $t_params->{'logs_busqueda'} = $data;
            $t_params->{'cantidad'} = $cantidad;
        }

my %params_for_combo = {};
$params_for_combo{'default'} = '';

$t_params->{'logueo_opac'} = C4::AR::Preferencias->getValorPreferencia("logSearchOPAC");;
$t_params->{'categorias_usuario'} = C4::AR::Utilidades::generarComboCategoriasDeSocio(\%params_for_combo);

C4::Auth::output_html_with_http_headers($template, $t_params, $session);