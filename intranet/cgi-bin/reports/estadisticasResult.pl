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
    = get_template_and_user({template_name => "reports/estadisticasResult.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });


my $chkfecha= $input->param('chkfecha');
my @chck= split(",",$input->param('chck'));
my $chkuser= $input->param('chkuser');

my $dateformat = C4::Date::get_date_format();
#Tomo las fechas que setea el usuario y las paso a formato ISO
my $fechaInicio =  format_date_in_iso($input->param('dateselected'),$dateformat);
my $fechaFin    =  format_date_in_iso($input->param('dateselectedEnd'),$dateformat);

my $domiTotal;
my $renovados;
my $devueltos;
my $foto;
my $sala;
my $especial;
my $cantUsuPrest;
my $cantUsuRenov;
my $cantUsuReser;
my $checkbox=scalar(@chck);

if( $checkbox>0 || ($checkbox==0 && $chkuser eq "false")){
	($domiTotal,$renovados,$devueltos,$sala,$foto,$especial)=estadisticasGenerales($fechaInicio, $fechaFin, $chkfecha, @chck);
}

if(($chkuser eq "false" && $checkbox==0)||$chkuser ne "false"){
	$cantUsuPrest=cantidadUsuariosPrestamos($fechaInicio, $fechaFin, $chkfecha);
	$cantUsuRenov=cantidadUsuariosRenovados($fechaInicio, $fechaFin, $chkfecha);
	$cantUsuReser=cantidadUsuariosReservas($fechaInicio, $fechaFin, $chkfecha);
}

$template->param( 	
# 			Esta variables que se pasan son para poder imprimir los resultados
			chck             => $input->param('chck'),
			chkfecha         => $chkfecha,
			chkuser		 => $chkuser,
			dateselected     => $input->param('dateselected'),
		        dateselectedEnd  => $input->param('dateselectedEnd'),
#			Variables que se muestran en el tmpl
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
