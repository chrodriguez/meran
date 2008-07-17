#!/usr/bin/perl
#script para administrar las tablas de referencia
#escrito el 8/9/2006 por einar@info.unlp.edu.ar
#
#Copyright (C) 2003-2006  Linti, Facultad de Informática, UNLP
#This file is part of Koha-UNLP
#
#This program is free software; you can redistribute it and/or
#modify it under the terms of the GNU General Public License
#as published by the Free Software Foundation; either version 2
#of the License, or (at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software
#Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Utilidades;

my $input = new CGI;
#En la variable volver guardo la accion, si es un 0 se guarda y queda en la misma interface de edicion, si es un 1 se guarda y vuelve al listado de las referencias, si es un 2 directamente vuelve al listado de las referencias sin guardar
my $volver=$input->param('accionvolver');
my ($template, $loggedinuser, $cookie);
if ($volver){
($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "parameters/referencies.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1, });
	}
	else{
 ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "parameters/editref.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1, });
	}
			    

my $tabla=$input->param('editandotabla');
my @campos=obtenerCampos($tabla);
my %valores;

foreach my $campo (@campos){

$valores{$campo->{'campo'}}=$input->param($campo->{'campo'});
}

my $tabla=$input->param('editandotabla');
my $codigo=$input->param('editandocodigo');

my $camporeferencia=$input->param('editandoidentificador');
$valores{$camporeferencia}=$codigo;
if ($volver ne "2"){
actualizarCampos($tabla,$camporeferencia,%valores);}
my $ind=$input->param('editandoind');
($ind||($ind=0)); 
my $cant=$input->param('editandocant');
($cant||($cant=20)); 
my $orden=$input->param('editandoorden');


if ($volver) {
my $valores=buscarTabladeReferencia($tabla);
my $env;
my @campos=obtenerCampos($tabla);
($orden||($orden=$valores->{'orden'})); 

my ($total,@loop)= listadoTabla($tabla,$ind,$cant,$valores->{'camporeferencia'},$orden);
$template->param(camposloop => \@campos,
		loop => \@loop,
		editandoind=>$ind,
		editandocant => $cant,
		editandoorden => $orden,
		editandotabla=>$tabla,
		editandoidentificador=>$valores->{'nomcamporeferencia'},
		editandototal => $total);
		
}
else{
my @loop= valoresTabla($tabla,$camporeferencia,$codigo);
;

$template->param(camposloop => \@campos,
		loop => \@loop,
		editandoind=>$ind,
		editandocant => $cant,
		editandotabla=>$tabla,
		editandoidentificador=>$camporeferencia,
		editandocodigo=>$codigo,
		editandoorden=>$orden,
		editandoMensaje=> '1');
}
output_html_with_http_headers $input, $cookie, $template->output;



