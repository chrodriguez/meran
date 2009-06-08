#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::VisualizacionOpac;
use C4::AR::Utilidades;
use JSON;

my $input = new CGI;
my ($userid, $session, $flags) = checkauth($input, 0,{ editcatalogue => 1});


my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);


#tipoAccion = Insert, Update, Select
my $tipoAccion= $obj->{'tipoAccion'}||"";
my $componente= $obj->{'componente'}||"";
my $tabla= $obj->{'tabla'}||"";
my $result;
my %infoRespuesta;


#************************* para cargar la tabla de encabezados*************************************
if(($tipoAccion eq "SELECT")&&($componente eq "CARGAR_TABLA_ENCABEZADOS")){

	my ($template, $session, $t_params) = get_template_and_user({
										template_name => "catalogacion/visualizacionOPAC/visualizacionOpacTablaEncabezados.tmpl",
										query => $input,
										type => "intranet",
										authnotrequired => 0,
										flagsrequired => {borrowers => 1},
										debug => 1,
	});

	my $nivel =$obj->{'nivel'};
	my $itemtype =$obj->{'itemtype'};

	my ($cant,@results)= &C4::AR::VisualizacionOpac::buscarEncabezados($nivel, $itemtype);

	$t_params->{'RESULTSLOOP'}= \@results;

	C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);

}
#**************************************************************************************************

#***********************************Cambio Visibilidad en OPAC**********************************
if($tipoAccion eq "CAMBIAR_VISIBILIDAD"){

	my $idestcat =$obj->{'id'};
	my $visible =$obj->{'visible'};
	
	&modificarVisulizacion($idestcat, $visible);
	
    C4::Output::printHeader($session);
}
#**************************************************************************************************

#******* Se arma una tabla con la Visualizacion de OPAC y se muestra con un tmpl********************
if(($tipoAccion eq "MOSTAR_TABLA_VISUALIZACION")&&($componente eq "CLOSE_UP_COMBO_ENCABEZADO")){
	
	my ($template, $session, $t_params)= get_template_and_user({
												template_name => "catalogacion/visualizacionOPAC/visualizacionOpacTabla.tmpl",
												query => $input,
												type => "intranet",
												authnotrequired => 0,
												flagsrequired => {borrowers => 1},
												debug => 1,
	});
	
	my $idencabezado =$obj->{'encabezados'};
	my $result;

	my ($cant, @resultsCatalogacion)= &traerVisualizacion($idencabezado);
	
	$t_params->{'RESULTSLOOP'}= \@resultsCatalogacion;	
	
	C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}
#**********************************************************************************************************

#********************** gurado el encabezado en la tabla encabezado_campo_opac*****************************
if(($tipoAccion eq "INSERT")&&($tabla eq "ENCABEZADO")){

	my $encabezado= $obj->{'encabezado'};
# 	my $nivel= $obj->{'nivel2'};	#para probar los mensajes de error
	my $nivel= $obj->{'nivel'};
	my $itemtypes= $obj->{'itemtypes'};
	my $itemtypes_arrayref= from_json_ISO($itemtypes);
	
	my ($error, $codMsg, $message)= &t_insertEncabezado($encabezado, $nivel, $itemtypes_arrayref);
	
    C4::Output::printHeader($session);
	($error)?print $message:'';
}
#*******************FIN *** gurado el encabezado en la tabla encabezado_campo_opac*****************************

#******************** actualizo el nombre del encabezado en la tabla encabezado_campo_opac***********************
if( ($tipoAccion eq "UPDATE")&&($tabla eq "ENCABEZADO") ){
			
	my $encabezado= $obj->{'encabezado'};
	my $nombre= $obj->{'nombre'};
	
	&modificarNombreEncabezado($encabezado, $nombre);
	
    C4::Output::printHeader($session);
}
#****************FIN**** actualizo el nombre del encabezado en la tabla encabezado_campo_opac******************

#*********************************se actualiza el campo linea del encabezado*********************************
if(($tipoAccion eq "UPDATE")&&($tabla eq "ENCABEZADO")){

	my $idencabezado= $obj->{'encabezado'};
	my $linea= $obj->{'linea'};
	
	&modificarLineaEncabezado($idencabezado, $linea);
	
    C4::Output::printHeader($session);
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
	
    C4::Output::printHeader($session);
}
#**************************************************************************************************

#**************** gurado la configuracion de la visualizacion en estructura_catalogacion_opac******************
if(($tipoAccion eq "INSERT")&&($tabla eq "ESTRUCTURA_VISUALIZACION")){

	my $textoPred =$obj->{'textoPredecesor'};
	my $textoSucc =$obj->{'textoSucesor'};
	my $campo =$obj->{'campo'};
	my $subcampo =$obj->{'subCampo'};
	my $separador =$obj->{'separador'};
	my $idencabezado =$obj->{'encabezados'};
	
	my ($error, $codMsg, $message)= &C4::AR::VisualizacionOpac::t_insertConfVisualizacion(	$campo, 
												$subcampo, 
												$textoPred, 
												$textoSucc, 
												$separador, 
												$idencabezado
					);
	
	#se arma el mensaje
	$infoRespuesta{'error'}= $error;
	$infoRespuesta{'codMsg'}= $codMsg;
	$infoRespuesta{'message'}= $message;

	#se convierte el arreglo de respuesta en JSON
	my $infoRespuestaJSON = to_json \%infoRespuesta;
    C4::Output::printHeader($session);
	#se envia en JSON al cliente
	print $infoRespuestaJSON;
}
#**************************************************************************************************

#**************** gurado la catalogacion en estructura_catalogacion_opac**************************
if(($tipoAccion eq "UPDATE")&&($tabla eq "ESTRUCTURA_VISUALIZACION")){

	my $textoPred =$obj->{'textoPredecesor'};
	my $textoSucc =$obj->{'textoSucesor'};
	my $separador =$obj->{'separador'};
	my $idestcatopac =$obj->{'idestcatopac'};
	
	&UpdateCatalogacion($textoPred, $textoSucc, $separador, $idestcatopac);
	
    C4::Output::printHeader($session);
}

#**************** elimino una tupla en estructura_catalogacion_opac**************************
if(($tipoAccion eq "DELETE")&&($tabla eq "ESTRUCTURA_VISUALIZACION")){

	my $idestcatopac =$obj->{'idestcatopac'};
	
	my ($error, $codMsg, $message)= &C4::AR::VisualizacionOpac::t_deleteConfVisualizacion($idestcatopac);
	
	#se arma el mensaje
	$infoRespuesta{'error'}= $error;
	$infoRespuesta{'codMsg'}= $codMsg;
	$infoRespuesta{'message'}= $message;

	#se convierte el arreglo de respuesta en JSON
	my $infoRespuestaJSON = to_json \%infoRespuesta;
    C4::Output::printHeader($session);
	#se envia en JSON al cliente
	print $infoRespuestaJSON;

}
#**************************************************************************************************

#********************************* elimino un Encabezado*******************************************
if(($tipoAccion eq "DELETE")&&($tabla eq "ENCABEZADO_CAMPO_OPAC")){

	my $encabezado =$obj->{'encabezado'};
	
	my ($error, $codMsg, $message)= &C4::AR::VisualizacionOpac::t_deleteEncabezado($encabezado);
	
	#se arma el mensaje
	$infoRespuesta{'error'}= $error;
	$infoRespuesta{'codMsg'}= $codMsg;
	$infoRespuesta{'message'}= $message;

	#se convierte el arreglo de respuesta en JSON
	my $infoRespuestaJSON = to_json \%infoRespuesta;
    C4::Output::printHeader($session);
	#se envia en JSON al cliente
	print $infoRespuestaJSON;
}
#**************************************************************************************************


