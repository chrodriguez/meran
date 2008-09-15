#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Utilidades;
use C4::AR::Catalogacion;


#Este archivo es llamado por los archivos estructuraCataloResults.pl y agregarItemResults.pl.

my $input = new CGI;

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));

my $tmpl=$obj->{'tmpl'};
my $url;
if($tmpl eq 'agregar'){
	$url="catalogacion/estructura/agregarItemResults3.tmpl";
}
else{
	$url="catalogacion/estructura/estructuraCataloResults2.tmpl"
}

my ($template, $loggedinuser, $cookie)
    = get_templateexpr_and_user({template_name => $url,
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {editcatalogue => 1},
			     debug => 1,
			     });

my $nivel=$obj->{'nivel'};
my $itemtype=$obj->{'itemtype'};
my $accion=$obj->{'accion2'}||$obj->{'accion'}||-1;

my $campoX=$obj->{'campoX'};
my $tagField=$obj->{'tagField'};

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
	my $defaulCX=($campoX >=0)? $campoX : 'Elegir';
	my $selectCampoX=CGI::scrolling_list(  -name      => 'campoX',
				-id	   => 'campoX',
				-values    => \@values,
				-labels    => \%camposX,
				-defaults  => $defaulCX,
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
	my $defaultTF=$tagField||'Elegir campo';
	my $selecttagField=CGI::scrolling_list( 
					-name      => 'tagField',
					-id	   => 'tagField',
					-values    => \@campos,
					-defaults  => $defaultTF,
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
	my $default= $obj->{'tagsubField'} || "-1, ";

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
	my $subcampo= $obj->{'subcampo'};
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
	my $defaultT=$obj->{'tabla'}||$tablaRef;
	my %tablas=buscarTablasdeReferencias();
	$tablas{-1}="Elegir tabla";
	my $lista_Refs=CGI::scrolling_list(
					-id	   => 'tabla',
					-name      => 'tabla',
                                        -values    => \%tablas,
                                        -defaults  => $defaultT,
					-size	   => 1,
					-onChange  => 'eleccionTabla(4,"Agregar")'
                                 );
	#Fin tabla de referencia
	$template->param( lista  => $lista_Refs,
			  ok	 => $ok,
			  tagsubField=>$default,
			);

	my $tagsubfield = $obj->{'subcampo'};
	my $textoLib = $obj->{'lib'};
	my $obligatorio=$obj->{'obligatorio'};
	my $tipoInput= $obj->{'tipoInput'};
	my $tabla = $obj->{'tabla'}||$tablaRef;
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