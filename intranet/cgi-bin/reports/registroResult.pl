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

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/registroResult.tmpl",
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
my @resultsdata;
my $cant;


my $orden= $obj->{'orden'}||'surname';
my $tipo = $obj->{'tipo'};
my $operacion = $obj->{'operacion'};
my $user= $obj->{'user'};# 10/04/2007 - Agregado para buscar por responsable.
my $numDesde= $obj->{'numDesde'}; # Agregado para buscar por numero de elemento.
my $numHasta= $obj->{'numHasta'};
my $chkuser= $obj->{'chkuser'}; # checkbox que busca por usuario
my $chknum= $obj->{'chknum'}; # checkbox que busca por numero
my $chkfecha= $obj->{'chkfecha'}; #checkbox que busca por fecha
my $funcion= $obj->{'funcion'};
#Estoy ya en la pagina de registro
	@resultsdata= registroEntreFechas($orden,$chkfecha,$fechaInicio,$fechaFin,$tipo,$operacion,$ini,$cantR,$chkuser,$chknum,$user,$numDesde,$numHasta);
	$cant=cantRegFechas($chkfecha,$fechaInicio,$fechaFin,$tipo,$operacion,$chkuser,$chknum,$user,$numDesde,$numHasta);

C4::AR::Utilidades::crearPaginador($template, $cant,$cantR, $pageNumber,$funcion,$t_params);

$template->param( 
			resultsloop      => \@resultsdata,
                        cant             => $cant,
		);

output_html_with_http_headers $input, $cookie, $template->output;
