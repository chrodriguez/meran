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

my $input = new CGI;
my $obj=$input->param('obj') || 0;

$obj=C4::AR::Utilidades::from_json_ISO($obj);
my ($template, $session, $t_params, $data_url);

if (!$obj){
        ($template, $session, $t_params) = get_template_and_user({
                                template_name => "estadisticas/colecciones.tmpl",
                                query => $input,
                                type => "intranet",
                                authnotrequired => 0,
                                flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                                debug => 1,
			            });
}else{
        ($template, $session, $t_params) = get_template_and_user({
                                template_name => "estadisticas/partial_swf.tmpl",
                                query => $input,
                                type => "intranet",
                                authnotrequired => 0,
                                flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                                debug => 1,
                        });

        $data_url = "/cgi-bin/koha/estadisticas/colecciones_data.pl?item_type=".$obj->{'item_type'}."%26ui=".$obj->{'ui'};

}

my %params_for_combo = {};
$params_for_combo{'default'} = 'ALL';
$t_params->{'data_url'} = $data_url;
$t_params->{'item_type_combo'} = C4::AR::Utilidades::generarComboTipoNivel3(\%params_for_combo);
$t_params->{'ui_combo'} = C4::AR::Utilidades::generarComboUI();

C4::Auth::output_html_with_http_headers($template, $t_params, $session);