#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
# use CGI;
use C4::Context;
use C4::Koha; 
use HTML::Template;
use C4::AR::CatalogacionOpac;
use C4::AR::Validaciones;
use C4::AR::Utilidades;

my $input = new CGI;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{ editcatalogue => 1});

#tipoAccion = Insert, Update, Select
my $tipoAccion= $input->param('tipoAccion')||"";
my $componente= $input->param('componente')||"";
my $tabla= $input->param('tabla')||"";
my $result;
my $mensajeError= "";


#******************** para Ayuda de campos MARK*************************************
if(($tipoAccion eq "Select")&&($componente eq "ayudaCampoMARK")){

 	my $campo= $input->param('q');
	my ($cant,@results)= &buscarInfoCampo($campo); #C4::AR::CatalogacionOpac
	my $i=0;
	my $resultAyudaMARK="";
	my $field;
	my $data;

	for ($i; $i<$cant; $i++){
		$field=$results[$i]->{'tagfield'};
		$data=$results[$i]->{'liblibrarian'};
  		$resultAyudaMARK .= $field."|".$data. "\n";
	}

	print "Content-type: text/html\n\n";
 	print $resultAyudaMARK;
}
#**************************************************************************************************

#******************** para Ayuda de campos MARK*************************************
if(($tipoAccion eq "Select")&&($componente eq "ayudaCampoMARKsubcampo")){
	my $campo= $input->param('campo');
	my $subcampo= $input->param('subcampo');

	my ($cant,@results)= &buscarInfoSubCampo($campo); #C4::AR::CatalogacionOpac
	my $i=0;
	my $resultAyudaMARK="";
	my $field;
	my $data;

	for ($i; $i<$cant; $i++){
	$resultAyudaMARK .= $results[$i]->{'tagsubfield'}."/".$results[$i]->{'subcampo'}."#";
	}

	print "Content-type: text/html\n\n";
 	print $resultAyudaMARK;
}
#**************************************************************************************************

#************************* para cargar la tabla de encabezados*************************************
if(($tipoAccion eq "Select")&&($componente eq "cargarTablaEncabezados")){

my ($template, $loggedinuser, $cookie) = get_templateexpr_and_user({
			template_name => "acqui.simple/estructuraCataloOpacTablaEncabezados.tmpl",
			query => $input,
			type => "intranet",
			authnotrequired => 0,
			flagsrequired => {borrowers => 1},
			debug => 1,
});

	my $nivel =$input->param('nivel');
	my $itemtype =$input->param('itemtype');

	my ($cant,@results)= &buscarEncabezados($nivel, $itemtype); #C4::AR::CatalogacionOpac

$template->param( 	
 			RESULTSLOOP      => \@results,
		);

# output_html_with_http_headers $input, $cookie, $template->output;
print  $template->output;

}
#**************************************************************************************************

#***********************************Cambio Visibilidad en OPAC**********************************
if($tipoAccion eq "cambiarVisibilidad"){

my $idestcat =$input->param('id');
my $visible =$input->param('visible');

&modificarVisulizacion($idestcat, $visible);

print $input->header;
}
#**************************************************************************************************
#******* Se arma una tabla con la Visualizacion de OPAC y se muestra con un tmpl********************
if(($tipoAccion eq "MostrarTablaVisualizacion")&&($componente eq "closeUpComboEncabezado")){

my ($template, $loggedinuser, $cookie)= get_templateexpr_and_user({
			template_name => "acqui.simple/estructuraCataloOpacTabla.tmpl",
			query => $input,
			type => "intranet",
			authnotrequired => 0,
			flagsrequired => {borrowers => 1},
			debug => 1,
});

	my $idencabezado =$input->param('encabezados');
	my $result;

	my ($cant, @resultsCatalogacion)= &traerVisualizacion($idencabezado);

$template->param( 	
 			RESULTSLOOP      => \@resultsCatalogacion,
		);

# output_html_with_http_headers $input, $cookie, $template->output;
print  $template->output;
}
#**********************************************************************************************************
#********************** gurado el encabezado en la tabla encabezado_campo_opac*****************************
if(($tipoAccion eq "Insert")&&($tabla eq "encabezado")){
my $encabezado= $input->param('encabezado');
my $nivel= $input->param('nivel');
my $itemtypes= $input->param('itemtypes');
# my $itemtypes_arrayref= decode_json $itemtypes;
my $itemtypes_arrayref= from_json_ISO($itemtypes);

my $cant= 0;
$cant= &verificarExistenciaEncabezado($encabezado);

if($cant eq 0){
 	&insertarEncabezado($encabezado, $nivel, $itemtypes_arrayref);
}
else{$mensajeError= "Error al ingresar los datos";}

print $input->header;
print $mensajeError;
# print encode_json $itemtypes_arrayref;
}
#*******************FIN *** gurado el encabezado en la tabla encabezado_campo_opac*****************************

#******************** actualizo el nombre del encabezado en la tabla encabezado_campo_opac***********************
if($tipoAccion eq "UpdateEncebezdo"){
			
my $encabezado= $input->param('encabezado');
my $nombre= $input->param('nombre');

&modificarNombreEncabezado($encabezado, $nombre);

print $input->header;
# print encode_json $itemtypes_arrayref;
}
#****************FIN**** actualizo el nombre del encabezado en la tabla encabezado_campo_opac******************

#*********************************se actualiza el campo linea del encabezado*********************************
if(($tipoAccion eq "Update")&&($tabla eq "encabezado")){
my $idencabezado= $input->param('encabezado');
my $linea= $input->param('linea');

&modificarLineaEncabezado($idencabezado, $linea);

print $input->header;
print $mensajeError;
}

#*********************************se actualiza el campo linea del encabezado*********************************

if($tipoAccion eq "cambiarOrdenEncabezado"){
my $idencabezado= $input->param('encabezado');
my $orden= $input->param('orden');
my $itemtype =$input->param('itemtype');
my $action= $input->param('action');

if($action eq "up"){
	&subirOrden($idencabezado, $orden, $itemtype, $action);
}else{
	&bajarOrden($idencabezado, $orden, $itemtype, $action);
}

print $input->header;
print $mensajeError;
}
#**************************************************************************************************
#**************** gurado la catalogacion en estructura_catalogacion_opac**************************
if(($tipoAccion eq "Insert")&&($tabla eq "estructuraCatalogacion")){
my $textoPred =$input->param('textoPredecesor');
my $textoSucc =$input->param('textoSucesor');
my $campo =$input->param('campo');
my $subcampo =$input->param('subCampo');
my $separador =$input->param('separador');
my $idencabezado =$input->param('encabezados');

if(&is_Number($idencabezado)){
	my $cant= 0;
	$cant= &verificarExistenciaCatalogacion($idencabezado, $campo, $subcampo);
	if($cant == 0){
 		&insertarCatalogacion($campo, $subcampo, $textoPred, $textoSucc, $separador, $idencabezado);
	}
}else{$mensajeError= "Error al ingresar los datos";}

print $input->header;
print $mensajeError;
}
#**************************************************************************************************

#**************** gurado la catalogacion en estructura_catalogacion_opac**************************
if(($tipoAccion eq "Update")&&($tabla eq "estructuraCatalogacion")){
my $textoPred =$input->param('textoPredecesor');
my $textoSucc =$input->param('textoSucesor');
my $separador =$input->param('separador');
my $idestcatopac =$input->param('idestcatopac');

&UpdateCatalogacion($textoPred, $textoSucc, $separador, $idestcatopac);

print $input->header;
print $mensajeError;
}

#**************** elimino una tupla en estructura_catalogacion_opac**************************
if(($tipoAccion eq "Delete")&&($tabla eq "estructuraCatalogacion")){
my $idestcatopac =$input->param('idestcatopac');


if(&is_Number($idestcatopac)){
	&deleteCatalogacion($idestcatopac);
}else{$mensajeError= "Error al eliminar los datos";}

print $input->header;
print $mensajeError;
}
#**************************************************************************************************

#**************** elimino un Encabezado**************************
if(($tipoAccion eq "Delete")&&($tabla eq "encabezadoCampoOpac")){

my $encabezado =$input->param('encabezado');

&deleteEncabezado($encabezado);

print $input->header;
}
#**************************************************************************************************


