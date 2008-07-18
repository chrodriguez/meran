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
use C4::Interface::CGI::Output;
use C4::AR::Utilidades;
use C4::AR::Catalogacion;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_templateexpr_and_user({template_name => "acqui.simple/estructuraCataloResults.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {editcatalogue => 1},
			     debug => 1,
			     });

#FUNCIONES INTERNAS
#Genera el input select para la interface, tanto en la parte de agregar como de modificar. Los parametros que recibe es el id que va a llevar el input y el onchange que es el evento que se ejecuta cuando cambia el combo.
sub generarSelectTabla(){
	my($idInput,$default,$onchange,$disable)=@_;
	#Tablas de refencias
	my %tablas=buscarTablasdeReferencias();
	$tablas{-1}="Elegir tabla";
	my $selectTabla;
	if($default ne "" && $disable){
		$selectTabla=CGI::scrolling_list(      
					-id	   => $idInput,
					-name      => $idInput,
                                        -values    => \%tablas,
                                        -defaults  => $default,
					-size	   => 1,
					-onChange  => $onchange,
					-disabled   => "disabled",
				);
	}
	else{
		$selectTabla=CGI::scrolling_list(      
					-id	   => $idInput,
					-name      => $idInput,
                                        -values    => \%tablas,
                                        -defaults  => $default,
					-size	   => 1,
					-onChange  => $onchange,
                                 );
	}
	#Fin tabla de referencia
	return($selectTabla);
}

#Genera el input select con los campos de la tabla de referencia para obtener el orden en el que se quieren las tuplas de esa tabla.
sub generarSelectOrden(){
	my($idInput,$default,$tabla)=@_;
	my ($ejemplo,%camposTablas)=&obtenerCamposTablaRef($tabla);
	my $stringCampos = join",", values %camposTablas;
	my $default2=$default;
	my $selectOrden=CGI::scrolling_list(      
			-id	   => $idInput,
			-name      => $idInput,
			-defaults  => $default2,
			-values    => \%camposTablas,
			-size	   => 1,
			);
	return($ejemplo,$stringCampos,$selectOrden);
}
#FIN DE FUNCIONES INTERNAS



my $nivel=$input->param('nivel');
my $campoX=$input->param('campoX');
my $tagField=$input->param('tagField');
my $itemType='ALL';
if($nivel > 1){
	$itemType=$input->param('itemtype');
}

#Variable que sirve para identificar la accion que se realizo.
my $accion = $input->param('accion'); 
=item 
$accion=0 => es la eleccion del nivel en que se van a modificar los campos (Combo Nivel)
$accion=1 => es la eleccion de agregar un nuevo campo a la catalogacion(Boton agregar).

Las siguientes acciones estan en el archivo seleccionCamposMarc.pl
$accion=2 => es la eleccion del campoX que sirve para fitrar a los campos marc (Combo seleccion)
$accion=3 => es la eleccion del tagfield que da como resultado todos los subcampos marc de es campo menos lo que 	ya estan modificados y no son repetibles (Combo campo).
$accion=4 => es la eleccion de la tabla referecia, a la cual se le esta asociando el campo y subcampo, muestra 		los input necesarios para llenar la tabla informacion_referencia 
(Combo tabla de referecia).
Hasta aca!

$accion=5 => se guerdan el nuevo campo para la catalogacion, y si se eligio un tabla se guarda la referecia con 	todos los datos (Boton guardar del paso de agregado).
$accion=6 => se actualiza el campo eliminado con el intranet_habilitado=0 (Boton eliminar).
$accion=7 => sube el orden del campo seleccionado, baja el numero de intra_hab en 1 
	(Boton flecha para arriba).
$accion=8 => baja el orden del campo seleccionado, sube el numero de intra_hab en 1 
	(Boton flecha para abajo).
$accion=9 => Activa la parte de modificacion de un campo que ya esta en la catalogacion 
	(Boton modificar).
$accion=10 => se guardan las modificaciones hechas a los campos ya modificados por parte del usuario.
	(Boton guardar del paso de modificacion).
=cut
my $obj=$input->param('objeto');
my $tagsubfield;
my $textoLib;
my $tabla;
my $ok=0;
my $error;
if( $accion==5 && $obj ne ""){
	$obj=from_json_ISO($obj);
	$tagField=$obj->{'campo'};
	$tagsubfield = $obj->{'subcampo'};
	$textoLib = $obj->{'lib'};
	$tabla = $obj->{'tabla'};
	$ok=1;

	if ($tagsubfield != -1 && $textoLib ne ''){
		my $hayDatos=&buscarDatosCampoMARC($nivel,$tagField,$tagsubfield,"");
		my $tablaRef=-1;
		my $hab;
		my $tablasIguales=0;
		if($hayDatos){
			($tablaRef,$hab)=&buscarInfoRefCampoSubcampo($tagField,$tagsubfield,"");
			$tablasIguales=($tabla == $tablaRef);
		}
		if(($tablasIguales || !$hayDatos) && $ok){
			my $id = -1;
			$id=&guardarCamposModificados($nivel,$itemType,$obj);
			if($id == -1){ $error = "Error en el guardado del campo, intentelo otra vez."}
=item		if($id != -1 && $tabla != -1){
			my $orden= $input->param('orden');
			my $campoRef= $input->param('camposRef');
			my $separador = $input->param('separador');
			if($tabla!= -1 && $campoRef ne '' && $separador ne ''){
				&guardarInfoReferencia($id,$tabla,$orden,$campoRef,$separador);
			}
		}
		else{#error
=cut		}
		}
		else{$error="Error en la información de referencia.";}
		$accion=1;
	}
	elsif($tagsubfield == -1){
		$error= "Error - Seleccione un subcampo Marc";
	}
	else{
		$error= "Error - Ingrese un nombre para el campo Marc";
	}
}	
elsif($accion ==5){$error="Error en el pasaje de parametros";}
#Se deshabilita el campo seleccionado para la vista en intranet
if($accion==6){
	my $id=$input->param('idMod');
	my $intra=$input->param('intra');
	&eliminarNivelIntranet($id,$intra,$nivel,$itemType);
	$accion=0;
}

#Sube el orden en la vista del campo seleccionado
if($accion==7){
	my $id=$input->param('idMod');
	my $intra = $input->param('intra');
	&subirOrden($id,$intra,$nivel,$itemType);
	$accion=0;
}

#Baja el orden en la vista del campo seleccionado
if($accion==8){
	my $id=$input->param('idMod');
	my $intra = $input->param('intra');
	&bajarOrden($id,$intra,$nivel,$itemType);
	$accion=0;
}

#Modificacion de un campo ya ingresado para la catalogacion
if($accion == 9){
	my $nivel=$input->param('nivel');
	my $id= $input->param('idMod');
# 	my $disable=$input->param('disable');
	my $result= &buscarCampo($id);
	$result->[0]->{'tipoInput'}=$result->[0]->{'tipo'};
	my $tabla= $input->param('tablaMod')||$result->[0]->{'tabla'}||-1;
	my $campo=$result->[0]->{'campo'};
	my $subcampo=$result->[0]->{'subcampo'};
	my $hayDatos=&buscarDatosCampoMARC($nivel,$campo,$subcampo,"");
	if(!$hayDatos){
		my ($tablaRef,$hab)=&buscarInfoRefCampoSubcampo($campo,$subcampo,$itemType);
		if($tablaRef != -1){$hayDatos=1;}
	}
	my $tablaMod=&generarSelectTabla('tablaMod',$tabla,'eleccionTabla(9,"Modificar")',$hayDatos);
	if($tabla){
		my $ordDef=$result->[0]->{'orden'};
		my($ejemplo,$stringCampos,$ordenMod)=&generarSelectOrden('ordenMod',$ordDef,$tabla);
		$template->param(selectordenMod	 => $ordenMod,
				stringCamposMod  => $stringCampos,
				ejemploMod       => $ejemplo,
				);
	}
	$template->param(modificacion    => $result,
			idMod		 => $id,
			selecttablaMod   => $tablaMod,
			tablaMod         => $tabla,
			campo		 => $campo,
			subcampo	 => $subcampo,
			);

}

#Se actualizan los campos marc ya modificados por el usuario.
if($accion==10){
	my $id=$input->param('idMod');
	my $idinforef=$input->param('idinforef');
	my $obj=$input->param('objeto');
	if( $obj ne ""){
		$obj=from_json_ISO($obj);
		my $campo=$obj->{'campo'};
		my $subcampo=$obj->{'subcampo'};
		my $tabla=$obj->{'tabla'};
		my $hayDatos=&buscarDatosCampoMARC($nivel,$campo,$subcampo,"");
		my $tablaRef=-1;
		my $hab;
		my $tablasIguales=0;
		if($hayDatos){
			($tablaRef,$hab)=&buscarInfoRefCampoSubcampo($campo,$subcampo,"");
			$tablasIguales=($tabla == $tablaRef);
		}
		if($tablasIguales || !$hayDatos){
			&modificarCampo($id,$obj);
		}
		else{$error="Error en la información de referencia.";}
	}
	else{$error="Error en el pasaje de parametros"}
# 	my $ref=0;
# 	if($tabla != -1){
# 		$ref=1;
# 		&guardarInfoReferencia($id,$tabla,$ordenMod,$camposRefMod,$separadorMod);
# 	}
# 	&actualizarCamposModificados($id,$textoMod,$selectInput,0,$ref);
	$accion=0;
}

#Se cambia la visibilidad del campo.
if($accion==11){
	my $visible=$input->param('visible');
	my $idestcat=$input->param('id');
	&actualizarVisibilidad($idestcat,$visible);
	$accion=0;
}

#Busqueda de campos modificados para mostrar en el tmpl, se muestra siempre no depende de la
#variable tipo
my @results = &buscarCamposModificados($nivel,$itemType);
#fin busqueda
my $cant= scalar(@results); #Para ver si se muestar la tabla o no en el template

$template->param(
			RESULTDATA	  => \@results,
			accion		  => $accion,
			nivel		  => $nivel,
			cant		  => $cant,
			error		  => $error,
			);

output_html_with_http_headers $input, $cookie, $template->output;
