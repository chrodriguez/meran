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
use HTML::Template;
use C4::AR::Estadisticas;
use C4::Koha;
use C4::Date;

my $input = new CGI;

my $theme = $input->param('theme') || "default";
my $campoIso = $input->param('code') || ""; 
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/estadisticas.tmpl",

			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });


###Marca la Fecha de Hoy
                                                                                
my @datearr = localtime(time);
my $today =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
$template->param( todaydate => format_date($today));
                                                                                
###

my $chkfecha= $input->param('chkfecha');
my @chck= $input->param('chck');
my $chkuser= $input->param('chkuser');


#Tomo las fechas que setea el usuario y las paso a formato ISO
my $fechaInicio =  format_date_in_iso($input->param('dateselected'));
my $fechaFin    =  format_date_in_iso($input->param('dateselectedEnd'));

my $domiTotal;
my $renovados;
my $devueltos;
my $foto;
my $sala;
my $especial;
my $cantUsuPrest;
my $cantUsuRenov;
my $cantUsuReser;

($domiTotal,$renovados,$devueltos,$sala,$foto,$especial)=estadisticasGenerales($fechaInicio, $fechaFin, $chkfecha, @chck);

if(($chkuser eq "" && scalar(@chck)==0)||$chkuser ne ""){
	$cantUsuPrest=cantidadUsuariosPrestamos($fechaInicio, $fechaFin, $chkfecha);
	$cantUsuRenov=cantidadUsuariosRenovados($fechaInicio, $fechaFin, $chkfecha);
	$cantUsuReser=cantidadUsuariosReservas($fechaInicio, $fechaFin, $chkfecha);
}

$template->param( 	chck             => join(",",$input->param('chck')),
			chkfecha         => $chkfecha,
			chkuser		 => $chkuser,
			fechaFin         => $fechaFin,
			fechaInicio      => $fechaInicio,
			dateselected     => $input->param('dateselected'),
		        dateselectedEnd  => $input->param('dateselectedEnd'),
			domiTotal        => $domiTotal,
			renovados        => $renovados,
			devueltos        => $devueltos,
			foto             => $foto,
			sala             => $sala,
			especial         => $especial,
			cantUsuPrest	 => $cantUsuPrest,
			cantUsuRenov	 => $cantUsuRenov,
			cantUsuReser	 => $cantUsuReser,
		);

output_html_with_http_headers $input, $cookie, $template->output;
