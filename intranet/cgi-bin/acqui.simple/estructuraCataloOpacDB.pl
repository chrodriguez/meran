#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::CatalogacionOpac;
use C4::AR::Utilidades;

my $input = new CGI;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{ editcatalogue => 1});


my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);


#tipoAccion = Insert, Update, Select
my $tipoAccion= $obj->{'tipoAccion'}||"";
my $componente= $obj->{'componente'}||"";
my $tabla= $obj->{'tabla'}||"";
my $result;


#************************* para cargar la tabla de encabezados*************************************
if(($tipoAccion eq "SELECT")&&($componente eq "CARGAR_TABLA_ENCABEZADOS")){

	my ($template, $loggedinuser, $cookie) = get_templateexpr_and_user({
				template_name => "acqui.simple/estructuraCataloOpacTablaEncabezados.tmpl",
				query => $input,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {borrowers => 1},
				debug => 1,
	});

	my $nivel =$obj->{'nivel'};
	my $itemtype =$obj->{'itemtype'};

	my ($cant,@results)= &C4::AR::CatalogacionOpac::buscarEncabezados($nivel, $itemtype);

	$template->param( 	
				RESULTSLOOP      => \@results,
			);

	print  $template->output;

}
#**************************************************************************************************

#***********************************Cambio Visibilidad en OPAC**********************************
if($tipoAccion eq "CAMBIAR_VISIBILIDAD"){

	my $idestcat =$obj->{'id'};
	my $visible =$obj->{'visible'};
	
	&modificarVisulizacion($idestcat, $visible);
	
	print $input->header;
}
#**************************************************************************************************

#******* Se arma una tabla con la Visualizacion de OPAC y se muestra con un tmpl********************
if(($tipoAccion eq "MOSTAR_TABLA_VISUALIZACION")&&($componente eq "CLOSE_UP_COMBO_ENCABEZADO")){
	
	my ($template, $loggedinuser, $cookie)= get_templateexpr_and_user({
				template_name => "acqui.simple/estructuraCataloOpacTabla.tmpl",
				query => $input,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {borrowers => 1},
				debug => 1,
	});
	
	my $idencabezado =$obj->{'encabezados'};
	my $result;

	my ($cant, @resultsCatalogacion)= &traerVisualizacion($idencabezado);
	
	$template->param( 	
				RESULTSLOOP      => \@resultsCatalogacion,
			);
	
	print  $template->output;
}
#**********************************************************************************************************

#********************** gurado el encabezado en la tabla encabezado_campo_opac*****************************
if(($tipoAccion eq "INSERT")&&($tabla eq "ENCABEZADO")){

	my $encabezado= $obj->{'encabezado'};
# 	my $nivel= $obj->{'nivel2'};	#para probar los mensajes de error
	my $nivel= $obj->{'nivel'};
	my $itemtypes= $obj->{'itemtypes'};
	my $itemtypes_arrayref= from_json_ISO($itemtypes);
	
	my ($error, $codMsg, $message)= &t_insertarEncabezado($encabezado, $nivel, $itemtypes_arrayref);
	
	print $input->header;
	($error)?print $message:'';
}
#*******************FIN *** gurado el encabezado en la tabla encabezado_campo_opac*****************************

#******************** actualizo el nombre del encabezado en la tabla encabezado_campo_opac***********************
if( ($tipoAccion eq "UPDATE")&&($tabla eq "ENCABEZADO") ){
			
	my $encabezado= $obj->{'encabezado'};
	my $nombre= $obj->{'nombre'};
	
	&modificarNombreEncabezado($encabezado, $nombre);
	
	print $input->header;
}
#****************FIN**** actualizo el nombre del encabezado en la tabla encabezado_campo_opac******************

#*********************************se actualiza el campo linea del encabezado*********************************
if(($tipoAccion eq "UPDATE")&&($tabla eq "ENCABEZADO")){

	my $idencabezado= $obj->{'encabezado'};
	my $linea= $obj->{'linea'};
	
	&modificarLineaEncabezado($idencabezado, $linea);
	
	print $input->header;
}

#*********************************se actualiza el campo linea del encabezado*********************************

if($tipoAccion eq "CAMBIAR_ORDEN_ENCABEZADO"){

	my $idencabezado= $obj->{'encabezado'};
	my $orden= $obj->{'orden'};
	my $itemtype =$obj->{'itemtype'};
	my $action= $obj->{'action'};
	
	if($action eq "up"){
		&subirOrden($idencabezado, $orden, $itemtype, $action);
	}else{
		&bajarOrden($idencabezado, $orden, $itemtype, $action);
	}
	
	print $input->header;
}
#**************************************************************************************************

#**************** gurado la catalogacion en estructura_catalogacion_opac**************************
if(($tipoAccion eq "INSERT")&&($tabla eq "ESTRUCTURA_CATALOGACION")){

	my $textoPred =$obj->{'textoPredecesor'};
	my $textoSucc =$obj->{'textoSucesor'};
	my $campo =$obj->{'campo'};
	my $subcampo =$obj->{'subCampo'};
	my $separador =$obj->{'separador'};
	my $idencabezado =$obj->{'encabezados'};
	
	my $cant= 0;
	$cant= &verificarExistenciaCatalogacion($idencabezado, $campo, $subcampo);
	if($cant == 0){

		&insertarCatalogacion(	$campo, 
					$subcampo, 
					$textoPred, 
					$textoSucc, 
					$separador, 
					$idencabezado
				);
	}
	
	print $input->header;
}
#**************************************************************************************************

#**************** gurado la catalogacion en estructura_catalogacion_opac**************************
if(($tipoAccion eq "UPDATE")&&($tabla eq "ESTRUCTURA_CATALOGACION")){

	my $textoPred =$obj->{'textoPredecesor'};
	my $textoSucc =$obj->{'textoSucesor'};
	my $separador =$obj->{'separador'};
	my $idestcatopac =$obj->{'idestcatopac'};
	
	&UpdateCatalogacion($textoPred, $textoSucc, $separador, $idestcatopac);
	
	print $input->header;
}

#**************** elimino una tupla en estructura_catalogacion_opac**************************
if(($tipoAccion eq "DELETE")&&($tabla eq "ESTRUCTURA_CATALOGACION")){

	my $idestcatopac =$obj->{'idestcatopac'};
	
	&deleteCatalogacion($idestcatopac);
	
	print $input->header;
}
#**************************************************************************************************

#********************************* elimino un Encabezado*******************************************
if(($tipoAccion eq "DELETE")&&($tabla eq "ENCABEZADO_CAMPO_OPAC")){

	my $encabezado =$obj->{'encabezado'};
	
	my ($error, $codMsg, $message)= &C4::AR::CatalogacionOpac::t_deleteEncabezado($encabezado);
	
	print $input->header;
	($error)?print $message:'';
}
#**************************************************************************************************


