#!/usr/bin/perl

# $Id: addbiblio.pl,v 1.32.2.7 2004/03/19 08:21:01 tipaul Exp $

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

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use C4::Koha; 
use C4::AR::Utilidades;
use HTML::Template::Expr;
use C4::AR::Catalogacion;


#Este archivo es llamado por los archivos estructuraCataloResults.pl y agregarItemResults.pl.

my $input = new CGI;
my $tmpl=$input->param('tmpl');
my $url;
if($tmpl eq 'agregar'){
	$url="acqui.simple/agregarItemResults3.tmpl";
}
else{
	$url="acqui.simple/estructuraCataloResults2.tmpl"
}

my ($template, $loggedinuser, $cookie)
    = get_templateexpr_and_user({template_name => $url,
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {editcatalogue => 1},
			     debug => 1,
			     });

my $nivel=$input->param('nivel');
my $itemtype=$input->param('itemtype');
my $accion=$input->param('accion2')||$input->param('accion')||-1;

my $campoX=$input->param('campoX');
my $tagField=$input->param('tagField');

#Variable que sirve para identificar el tipo o nivel de consulta
	
=item 
$accion=0 => es la eleccion del nivel en que se van a modificar los campos (Combo Nivel)
$accion=1 => es la eleccion de agregar un nuevo campo a la catalogacion(Boton agregar).
$accion=2 => es la eleccion del campoX que sirve para fitrar a los campos marc (Combo seleccion)
$accion=3 => es la eleccion del tagfield que da como resultado todos los subcampos marc de es campo menos lo que ya estan modificados y no son repetibles (Combo campo).
$accion=4 => es la eleccion de la tabla referecia, a la cual se le esta asociando el campo y subcampo, muestra los input necesarios para llenar la tabla informacion_referencia (Combo tabla de referecia).
=cut

if($accion eq "agregar" || $accion > 0){

#Filtro de numero de campo
	my %camposX;
	my @values;

	push (@values, -1);
	$camposX{-1}="Elegir";

	my $option;
	for (my $i =0 ; $i <= 9; $i++){
		push (@values, $i);
		$option= $i."xx";
		$camposX{$i}=$option;
	}

	my $selectCampoX=CGI::scrolling_list(  -name      => 'campoX',
				-id	   => 'campoX',
				-values    => \@values,
				-labels    => \%camposX,
				-defaults  => 'Elegir',
				-size      => 1,
				-onChange  => 'eleccionCampoX(2)',
                                 );
	$template->param(selectCampoX	  => $selectCampoX);
#FIN filtro de numero de campo
}

if($accion > 1){
# Combo de numeros de campo
	my @campos;
	if($campoX != -1){
		@campos= &buscarCamposMARC($campoX,$nivel);
	}
	push (@campos,'Elegir campo');

	my $selecttagField=CGI::scrolling_list( 
					-name      => 'tagField',
					-id	   => 'tagField',
					-values    => \@campos,
					-defaults  => 'Elegir campo',
					-size      => 1,
					-onChange  => 'eleccionCampo(3)',
                                );

	$template->param(selecttagField    => $selecttagField,);
# Fin Combo numeros de campo
}

if($accion > 2 ){
	my $nombretagField=&buscarNombreCampoMarc($tagField);
	my $subCampos=&buscarSubCampo($tagField,$nivel,$itemtype);
#Combo para los subcampos
	my @valuesSubCampos;
	my %labelsSubCampos;
	my $lib;
	my $default= $input->param('tagsubField') || "-1, ";

	push(@valuesSubCampos, "-1, ");
	$labelsSubCampos{"-1, "}="Elegir subcampo";
	
	foreach my $subField (keys %$subCampos){
		$lib =$subCampos->{$subField}->{'tagsubfield'}.",".$subCampos->{$subField}->{'liblibrarian'}.",".$subCampos->{$subField}->{'obligatorio'};
		push (@valuesSubCampos,$lib);
		$labelsSubCampos{$lib}=$subCampos->{$subField}->{'tagsubfield'};
	}
	
	my $selecttagsubField=CGI::scrolling_list( 
					-name      => 'tagsubField',
					-id	   => 'tagsubField',
					-values    => \@valuesSubCampos,
					-labels	   => \%labelsSubCampos,
					-defaults  => $default,
                                	-size      => 1,
					-onChange  => 'eleccionSubCampo(3)',
                                 	);
	$template->param(selecttagsubField    => $selecttagsubField,
			 nombretagField       => $nombretagField,
			);
#FIN combo subcampos
	my $subcampo= $input->param('subcampo');
	my $tablaRef=-1;
	my $habilitado;
	my $ok=1;
	my $hayDatos=&buscarDatosCampoMARC($nivel,$tagField,$subcampo,"");
	if($hayDatos){
		$ok=0;
	}
	if($default ne "-1, "){
		($tablaRef,$habilitado)=&buscarInfoRefCampoSubcampo($tagField,$subcampo);
		if($tablaRef != -1 && $habilitado){
			$ok=0;
			$accion=4;
		}
		else{$accion=4;}
	}
	#Tablas de refencias
	my %tablas=buscarTablasdeReferencias();
	$tablas{-1}="Elegir tabla";
	my $lista_Refs=CGI::scrolling_list(
					-id	   => 'tabla',
					-name      => 'tabla',
                                        -values    => \%tablas,
                                        -defaults  => $tablaRef,
					-size	   => 1,
					-onChange  => 'eleccionTabla(4,"Agregar")'
                                 );
	#Fin tabla de referencia
	$template->param( lista  => $lista_Refs,
			  ok	 => $ok,
			  tagsubField=>$default,
			);

	my $tagsubfield = $input->param('subcampo');
	my $textoLib = &C4::AR::Utilidades::UTF8toISO($input->param('lib'));
	my $obligatorio=$input->param('obligatorio');
	my $tipoInput= $input->param('tipoInput');
	my $tabla = $input->param('tabla')||$tablaRef;
	if($accion==4){
		#Select para los campos de la tabla de referencia
		if($tabla != -1){		
			my ($ejemplo,%camposTablas)=&obtenerCamposTablaRef($tabla);
			my $stringCampos = join ",", values %camposTablas;
			my $selectOrden=CGI::scrolling_list(
				-id	   => 'orden',
				-name      => 'orden',
				-values    => \%camposTablas,
				-size	   => 1,
				);
			$template->param(
					selectOrden  => $selectOrden,
					stringCampos => $stringCampos,
					ejemplo      => $ejemplo,
					);
		}

		$template->param( tabla        => $tabla,
				  lib	       => $textoLib,
				  obligatorio  => $obligatorio,
				  tagsubField  => $tagsubfield,
				  tipoInput    => $tipoInput,
				);
	}
		

}
$template->param( accion  => $accion,
		  nivel	  => $nivel,
		  itemtype=> $itemtype);


output_html_with_http_headers $input, $cookie, $template->output;