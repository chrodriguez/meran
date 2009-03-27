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

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Estadisticas;
use C4::Date;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                                                            template_name => "reports/registroResult.tmpl",
                                                            query => $input,
                                                            type => "intranet",
                                                            authnotrequired => 0,
                                                            flagsrequired => {borrowers => 1},
                                                            debug => 1,
                                                       });

my $obj=$input->param('obj');
$obj= C4::AR::Utilidades::from_json_ISO($obj);

my $nota = $obj->{'notas'};
my $id   = $obj->{'id'};

if ($id ne ""){
        insertarNota($id,$nota);
}

#Inicializo el inicio y fin de la instruccion LIMIT en la consulta
my $ini=$obj->{'ini'};
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);
#FIN inicializacion

my $dateformat = C4::Date::get_date_format();
#Tomo las fechas que setea el usuario y las paso a formato ISO
my $fechaInicio =  format_date_in_iso($obj->{'dateselected'},$dateformat);
my $fechaFin    =  format_date_in_iso($obj->{'dateselectedEnd'},$dateformat);
my $cant;


$obj->{'orden'}|= $obj->{'orden'}||'surname';
$obj->{'fechaInicio'} = $fechaInicio;
$obj->{'fechaFin'} = $fechaFin;

# FIXME lo comente hasta q se suba el PM C4/Modelo/RepRegistroModificacion/Manager.pm
# my ($cant,$resultsdata) = C4::AR::Estadisticas::registroEntreFechas($obj);
my ($cant,$resultsdata);


# C4::AR::Utilidades::crearPaginador($cant,$cantR, $pageNumber,$funcion,$t_params);

$t_params->{'resultsloop'}= $resultsdata;
$t_params->{'cant'}= $cant;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
