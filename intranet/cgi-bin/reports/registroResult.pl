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
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use C4::Search;
use HTML::Template;
use C4::AR::Estadisticas;
use C4::Koha;
use C4::Date;

my $input = new CGI;

my $theme = $input->param('theme') || "default";
my $campoIso = $input->param('code') || ""; 
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/registroResult.tmpl",

			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $nota = $input->param('notas');
my $id   = $input->param('id');
if ($id ne ""){
        insertarNota($id,$nota);
}

my $orden= "fecha";

###Marca la Fecha de Hoy
                                                                                
my @datearr = localtime(time);
my $today =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
$template->param( todaydate => format_date($today));
                                                                                
###

#Inicializo el inicio y fin de la instruccion LIMIT en la consulta
my $ini;
my $pageNumber;
my $cantR=cantidadRenglones();

if (($input->param('ini') eq "")){
        $ini=0;
	$pageNumber=1;
}
else {
	$ini= ($input->param('ini')-1)* $cantR;
	$pageNumber= $input->param('ini');
};

#FIN inicializacion
#Tomo las fechas que setea el usuario y las paso a formato ISO
my $fechaInicio =  format_date_in_iso($input->param('dateselected'));
my $fechaFin    =  format_date_in_iso($input->param('dateselectedEnd'));
my @resultsdata;
my $cant;

my $tipo = $input->param('tipo');
my $operacion = $input->param('operacion');
my $user= $input->param('user');# 10/04/2007 - Agregado para buscar por responsable.
my $numDesde= $input->param('numDesde'); # Agregado para buscar por numero de elemento.
my $numHasta= $input->param('numHasta');
my $chkuser= $input->param('chkuser'); # checkbox que busca por usuario
my $chknum= $input->param('chknum'); # checkbox que busca por numero
my $chkfecha= $input->param('chkfecha'); #checkbox que busca por fecha

#Estoy ya en la pagina de registro
	@resultsdata= registroEntreFechas($orden,$chkfecha,$fechaInicio,$fechaFin,$tipo,$operacion,$ini,$cantR,$chkuser,$chknum,$user,$numDesde,$numHasta);
	$cant=cantRegFechas($chkfecha,$fechaInicio,$fechaFin,$tipo,$operacion,$chkuser,$chknum,$user,$numDesde,$numHasta);



my @numeros=armarPaginas($cant,$pageNumber);
my $paginas = scalar(@numeros)||1;
my $pagActual = $input->param('ini')||1;
$template->param( paginas   => $paginas,
		  actual    => $pagActual);

if ( $cant > $cantR ){#Seteo las flechas de siguiente y anterior
       	my $sig = $pageNumber+1;;
        if ($sig <= $paginas){
       	         $template->param(
               	                ok    =>'1',
                       	        sig   => $sig);
        };
	if ($sig > 2 ){
               my $ant = $pageNumber-1;
               $template->param(
                               ok2     => '1',
                               ant     => $ant)}
}
	$template->param(
			numeros => \@numeros);

$template->param( 
			resultsloop      => \@resultsdata,
                        cant             => $cant,
		);

output_html_with_http_headers $input, $cookie, $template->output;
