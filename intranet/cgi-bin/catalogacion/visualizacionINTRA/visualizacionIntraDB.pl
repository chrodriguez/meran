#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;

use C4::AR::VisualizacionIntra;
use C4::AR::Utilidades;
use JSON;

my $input = new CGI;

my $editing = $input->param('value') && $input->param('id');

if($editing){

    my ($template, $session, $t_params)  = get_template_and_user({  
                        template_name => "includes/partials/modificar_value.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => {  ui => 'ANY', 
                                            tipo_documento => 'ANY', 
                                            accion => 'CONSULTA', 
                                            entorno => 'permisos', 
                                            tipo_permiso => 'general'},
                        debug => 1,
                    });

    my $value = $input->param('value');
    my $vista_id = $input->param('id');
    my ($configuracion) = C4::AR::VisualizacionIntra::editConfiguracion($vista_id,$value);

    $t_params->{'value'} = $configuracion;

    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
}
else{

    my $obj=$input->param('obj');

    $obj=C4::AR::Utilidades::from_json_ISO($obj);

    #tipoAccion = Insert, Update, Select
    my $tipoAccion      = $obj->{'tipoAccion'} || "";
    my $componente      = $obj->{'componente'} || "";
    my $ejemplar        = $obj->{'ejemplar'} || "";
    my $result;
    my %infoRespuesta;
    my $authnotrequired = 0;

    #************************* para cargar la tabla de encabezados*************************************
    if($tipoAccion eq "MOSTRAR_VISUALIZACION"){

        my ($template, $session, $t_params) = get_template_and_user({
                            template_name => "catalogacion/visualizacionINTRA/detalleVisualizacionIntra.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {  ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'CONSULTA', 
                                                entorno => 'undefined'},
                            debug => 1,
        });

        $t_params->{'visualizacion'} = C4::AR::VisualizacionIntra::getConfiguracionByOrder($ejemplar);
        $t_params->{'selectCampoX'} = C4::AR::Utilidades::generarComboCampoX('eleccionCampoX()');

        C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
    }
    elsif($tipoAccion eq "AGREGAR_VISUALIZACION"){

        my ($template, $session, $t_params) = get_template_and_user({
                            template_name => "catalogacion/visualizacionINTRA/detalleVisualizacionIntra.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {  ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'CONSULTA', 
                                                entorno => 'undefined'},
                            debug => 1,
        });

        my ($messages)                  = C4::AR::VisualizacionIntra::addConfiguracion($obj);
        $t_params->{'visualizacion'}    = C4::AR::VisualizacionIntra::getConfiguracion($ejemplar);

        C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
    }
    elsif($tipoAccion eq "ELIMINAR_VISUALIZACION"){

        my ($template, $session, $t_params) = get_template_and_user({
                            template_name => "catalogacion/visualizacionINTRA/detalleVisualizacionIntra.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {  ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'CONSULTA', 
                                                entorno => 'undefined'},
                            debug => 1,
        });

        my ($status) = C4::AR::VisualizacionIntra::deleteConfiguracion($obj);
        $t_params->{'visualizacion'} = C4::AR::VisualizacionIntra::getConfiguracion($ejemplar);

        C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
    }
    elsif($tipoAccion eq "GENERAR_ARREGLO_CAMPOS"){
        my ($user, $session, $flags)= checkauth(    $input, 
                                                  $authnotrequired, 
                                                  {   ui => 'ANY', 
                                                      tipo_documento => 'ANY', 
                                                      accion => 'CONSULTA', 
                                                      entorno => 'datos_nivel1'}, 
                                                  'intranet'
                                      );
      my $campoX = $obj->{'campoX'};

      my ($campos_array) = C4::AR::VisualizacionIntra::getCamposXLike($campoX);

      my $info = C4::AR::Utilidades::arrayObjectsToJSONString($campos_array);

      my $infoOperacionJSON = $info;

      C4::AR::Auth::print_header($session);
      print $infoOperacionJSON;
    }

    elsif($tipoAccion eq "GENERAR_ARREGLO_SUBCAMPOS"){
        my ($user, $session, $flags)= checkauth(    $input, 
                                                  $authnotrequired, 
                                                  {   ui => 'ANY', 
                                                      tipo_documento => 'ANY', 
                                                      accion => 'CONSULTA', 
                                                      entorno => 'datos_nivel1'}, 
                                                  'intranet'
                                      );
      my $campo = $obj->{'campo'};

      my ($campos_array) = C4::AR::VisualizacionIntra::getSubCamposLike($campo);

      my $info = C4::AR::Utilidades::arrayObjectsToJSONString($campos_array);

      my $infoOperacionJSON = $info;

      C4::AR::Auth::print_header($session);
      print $infoOperacionJSON;
    }
    
    elsif($tipoAccion eq "ACTUALIZAR_ORDEN"){
        my ($user, $session, $flags)= checkauth(  $input, 
                                                  $authnotrequired, 
                                                  {   ui                => 'ANY', 
                                                      tipo_documento    => 'ANY', 
                                                      accion            => 'CONSULTA', 
                                                      entorno           => 'datos_nivel1'}, 
                                                  'intranet'
                                      );
        my $newOrderArray       = $obj->{'newOrderArray'};
        my $info                = C4::AR::VisualizacionIntra::updateNewOrder($newOrderArray);
        my $infoOperacionJSON   = to_json $info;
        C4::AR::Auth::print_header($session);
        print $infoOperacionJSON;  
    }
    #**************************************************************************************************
}

