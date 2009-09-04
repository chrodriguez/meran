#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::VisualizacionOpac;
use C4::AR::Utilidades;
use JSON;

my $input = new CGI;



my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);


#tipoAccion = Insert, Update, Select
my $tipoAccion= $obj->{'tipoAccion'}||"";
my $componente= $obj->{'componente'}||"";
my $tabla= $obj->{'tabla'}||"";
my $result;
my %infoRespuesta;
my $authnotrequired = 0;

#************************* para cargar la tabla de encabezados*************************************
if($tipoAccion eq "CARGAR_TABLA_ENCABEZADOS"){

	my ($template, $session, $t_params) = get_template_and_user({
		                template_name => "catalogacion/visualizacionOPAC/visualizacionOpacTablaEncabezados.tmpl",
		                query => $input,
		                type => "intranet",
		                authnotrequired => 0,
		                flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
		                debug => 1,
	});

	my ($encabezados_opac_array_ref)= &C4::AR::VisualizacionOpac::getEncabezadosOpac($obj);

	$t_params->{'RESULTSLOOP'}= $encabezados_opac_array_ref;

	C4::Auth::output_html_with_http_headers($template, $t_params, $session);

}
#**************************************************************************************************

#***********************************Cambio Visibilidad en OPAC**********************************
if($tipoAccion eq "CAMBIAR_VISIBILIDAD"){
  my ($userid, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'MODIFICACION', 
                                                entorno => 'undefined'},
                                            "intranet"
                                );

	
	C4::AR::Validator::validateParams('U389',$obj,['id']);
	my  $visualizacionOPAC= C4::AR::VisualizacionOpac::getVisualizacionOpac($obj);

	$visualizacionOPAC->cambiarVisibilidad();
	
    C4::Output::printHeader($session);
}
#**************************************************************************************************

#******* Se arma una tabla con la Visualizacion de OPAC y se muestra con un tmpl********************
if($tipoAccion eq "MOSTAR_TABLA_VISUALIZACION"){


	my ($template, $session, $t_params)= get_template_and_user({
						template_name => "catalogacion/visualizacionOPAC/visualizacionOpacTabla.tmpl",
						query => $input,
						type => "intranet",
						authnotrequired => 0,
						flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
						debug => 1,
	});
	
	my $idencabezado =$obj->{'encabezados'};
	my $result;

	my ($cant, @resultsCatalogacion)= &traerVisualizacion($idencabezado);
	
	$t_params->{'RESULTSLOOP'}= \@resultsCatalogacion;	
	
	C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}


if($tipoAccion eq "CAMBIAR_LINEA_ENCABEZADO"){
  my ($userid, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'MODIFICACION', 
                                                entorno => 'undefined'},
                                            "intranet"
                                );
	C4::AR::Validator::validateParams('U389',$obj,['encabezado']);
	my  $visualizacionOPAC= C4::AR::VisualizacionOpac::getEncabezadoOpac($obj);
	$visualizacionOPAC->cambiarLinea();
	
    C4::Output::printHeader($session);
}

if($tipoAccion eq "CAMBIAR_NOMBRE_ENCABEZADO"){
  my ($userid, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'MODIFICACION', 
                                                entorno => 'undefined'},
                                            "intranet"
                                );
	C4::AR::Validator::validateParams('U389',$obj,['encabezado', 'nombre']);
	my  $visualizacionOPAC= C4::AR::VisualizacionOpac::getEncabezadoOpac($obj);
	$visualizacionOPAC->cambiarNombre($obj->{'nombre'});
	
    C4::Output::printHeader($session);
}

if($tipoAccion eq "CAMBIAR_VISIBILIDAD_ENCABEZADO"){
  my ($userid, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'MODIFICACION', 
                                                entorno => 'undefined'},
                                            "intranet"
                                );

	C4::AR::Validator::validateParams('U389',$obj,['encabezado']);
	my  $visualizacionOPAC= C4::AR::VisualizacionOpac::getEncabezadoOpac($obj);
	$visualizacionOPAC->cambiarVisibilidad();
	
    C4::Output::printHeader($session);
}

#*********************************se actualiza el campo linea del encabezado*********************************
if(($tipoAccion eq "UPDATE")&&($tabla eq "ENCABEZADO")){
  my ($userid, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'MODIFICACION', 
                                                entorno => 'undefined'},
                                            "intranet"
                                );

	my $idencabezado= $obj->{'encabezado'};
	my $linea= $obj->{'linea'};
	
	&modificarLineaEncabezado($idencabezado, $linea);
	
    C4::Output::printHeader($session);
}

#*********************************se actualiza el campo linea del encabezado*********************************

if($tipoAccion eq "CAMBIAR_ORDEN_ENCABEZADO"){
  my ($userid, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'MODIFICACION', 
                                                entorno => 'undefined'},
                                            "intranet"
                                );

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

if($tipoAccion eq "ESTRUCTURA_VISUALIZACION"){
  my ($userid, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'ALTA', 
                                                entorno => 'undefined'},
                                            "intranet"
                                );

	my ($Message_arrayref)=  &C4::AR::VisualizacionOpac::t_insertConfVisualizacion($obj);
	
	my $infoOperacionJSON=to_json $Message_arrayref;
    
    C4::Output::printHeader($session);
    print $infoOperacionJSON;
}

if($tipoAccion eq "GUARDAR_ENCABEZADO_VISUALIZACION_OPAC"){
  my ($userid, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'MODIFICACION', 
                                                entorno => 'undefined'},
                                            "intranet"
                                );

	my ($Message_arrayref)=  &C4::AR::VisualizacionOpac::t_insertEncabezado($obj);
	
	my $infoOperacionJSON=to_json $Message_arrayref;
    
    C4::Output::printHeader($session);
    print $infoOperacionJSON;
}
if(($tipoAccion eq "UPDATE")&&($tabla eq "ESTRUCTURA_VISUALIZACION")){
  my ($userid, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'MODIFICACION', 
                                                entorno => 'undefined'},
                                            "intranet"
                                );

	my ($Message_arrayref)=  &C4::AR::VisualizacionOpac::t_updateConfVisualizacion($obj);
	
	my $infoOperacionJSON=to_json $Message_arrayref;
    
    C4::Output::printHeader($session);
    print $infoOperacionJSON;
}
if($tipoAccion eq "AGREGAR_CONFIGURACION_VISUALIZACION"){
  my ($userid, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'ALTA', 
                                                entorno => 'undefined'},
                                            "intranet"
                                );

	my ($template, $session, $t_params)= get_template_and_user({
						template_name => "catalogacion/visualizacionOPAC/agregarVisualizacionOpac.tmpl",
						query => $input,
						type => "intranet",
						authnotrequired => 0,
						flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
						debug => 1,
	});
	
	
	$t_params->{'agregar'}= 1; #seteo flag para indicar que se va a agregar una configuracion
	$t_params->{'selectCampoX'}= C4::AR::Utilidades::generarComboCampoX('eleccionCampoX()');
    
	C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}

if($tipoAccion eq "AGREGAR_ENCABEZADO_VISUALIZACION_OPAC"){

	my ($template, $session, $t_params)= get_template_and_user({
					template_name => "includes/popups/agregarEncabezado.inc",
					query => $input,
					type => "intranet",
					authnotrequired => 0,
					flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'ALTA', entorno => 'undefined'},
					debug => 1,
	});
	
	
	my %params_combo;
	$params_combo{'default'}= 'LIB';
	$params_combo{'id'}= 'tipo_documento';
    $params_combo{'class'}= 'inline_input';    
	my $comboTiposNivel3= &C4::AR::Utilidades::generarComboTipoNivel3(\%params_combo);
	$t_params->{'combo_tipos_documento'}= $comboTiposNivel3;
    
	C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}

if($tipoAccion eq "MODIFICAR_CONFIGURACION_VISUALIZACION"){


	my ($template, $session, $t_params)= get_template_and_user({
						template_name => "catalogacion/visualizacionOPAC/agregarVisualizacionOpac.tmpl",
						query => $input,
						type => "intranet",
						authnotrequired => 0,
						flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'MODIFICACION', entorno => 'undefined'},
						debug => 1,
	});
	
	
	$t_params->{'visualizacion'}= C4::AR::VisualizacionOpac::getVisualizacionOpac($obj);
    
	C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}
#**************** gurado la catalogacion en estructura_catalogacion_opac**************************
if(($tipoAccion eq "UPDATE")&&($tabla eq "ESTRUCTURA_VISUALIZACION")){
  my ($userid, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'MODIFICACION', 
                                                entorno => 'undefined'},
                                            "intranet"
                                );

	my $textoPred =$obj->{'textoPredecesor'};
	my $textoSucc =$obj->{'textoSucesor'};
	my $separador =$obj->{'separador'};
	my $idestcatopac =$obj->{'idestcatopac'};
	
	&UpdateCatalogacion($textoPred, $textoSucc, $separador, $idestcatopac);
	
    C4::Output::printHeader($session);
}

#**************** elimino una tupla en estructura_catalogacion_opac**************************
if(($tipoAccion eq "DELETE")&&($tabla eq "ESTRUCTURA_VISUALIZACION")){
  my ($userid, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'BAJA', 
                                                entorno => 'undefined'},
                                            "intranet"
                                );

	C4::AR::Validator::validateParams('U389',$obj,['idestcatopac']);
	my ($Message_arrayref)= &C4::AR::VisualizacionOpac::t_deleteConfVisualizacion($obj);
    
    my $infoOperacionJSON=to_json $Message_arrayref;
    
    C4::Output::printHeader($session);
    print $infoOperacionJSON;

}
#**************************************************************************************************

#********************************* elimino un Encabezado*******************************************
if(($tipoAccion eq "DELETE")&&($tabla eq "ENCABEZADO_CAMPO_OPAC")){
  my ($userid, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'BAJA', 
                                                entorno => 'undefined'},
                                            "intranet"
                                );

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


