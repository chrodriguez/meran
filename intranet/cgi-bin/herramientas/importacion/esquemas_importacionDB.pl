#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;
use JSON;
use C4::AR::ImportacionIsoMARC;

my $input       = new CGI;
my $obj         = $input->param('obj');
my $editing = $input->param('value') || $input->param('id');
my ($template, $session, $t_params);

if (!$editing){
	$obj=C4::AR::Utilidades::from_json_ISO($obj);
	my $tipoAccion  = $obj->{'accion'}||""; 
	
	if($tipoAccion eq "OBTENER_ESQUEMA"){
	
	
		($template, $session, $t_params)  = get_template_and_user({  
		                    template_name => "herramientas/importacion/detalle_esquema.tmpl",
		                    query => $input,
		                    type => "intranet",
		                    authnotrequired => 0,
		                    flagsrequired => {  ui => 'ANY', 
		                                        tipo_documento => 'ANY', 
		                                        accion => 'MODIFICACION', 
		                                        entorno => 'permisos', 
		                                        tipo_permiso => 'general'},
		                    debug => 1,
		                });
	
	    my $id_esquema = $obj->{'esquema'} || 0;
	     
	    my ($detalle_esquema,$esquema)  = C4::AR::ImportacionIsoMARC::getEsquema($id_esquema);
	    
        $t_params->{'esquema'} = $detalle_esquema;
        $t_params->{'esquema_title'} = $esquema->getNombre;
        $t_params->{'id_esquema'} = $id_esquema;
	}
    elsif($tipoAccion eq "AGREGAR_CAMPO"){
              ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "herramientas/importacion/detalle_esquema.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {  ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'MODIFICACION', 
                                                entorno => 'permisos', 
                                                tipo_permiso => 'general'},
                            debug => 1,
                        });
    
        my $id_esquema = $obj->{'esquema'} || 0;
        
        my ($row,$msg_code) = C4::AR::ImportacionIsoMARC::addCampo($id_esquema);
        
        if ($msg_code){
            my $esquema_added = "ZZZ\$z > ZZZ\$z";
            my @params_mensaje = ();
            
            push (@params_mensaje,($esquema_added));
            
            $t_params->{'table_error_message'} = C4::AR::Mensajes::getMensaje($msg_code,'INTRA',\@params_mensaje);
        }
        my ($detalle_esquema,$esquema)  = C4::AR::ImportacionIsoMARC::getEsquema($id_esquema);
        
        $t_params->{'esquema'} = $detalle_esquema;
        $t_params->{'esquema_title'} = $esquema->getNombre;
        $t_params->{'id_esquema'} = $id_esquema;
        
    }   elsif($tipoAccion eq "ELIMINAR_CAMPO"){
              ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "herramientas/importacion/detalle_esquema.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {  ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'MODIFICACION', 
                                                entorno => 'permisos', 
                                                tipo_permiso => 'general'},
                            debug => 1,
                        });
    
        my $id_row = $obj->{'id_row'} || 0;
        
        my ($id_esquema,$msg_code) = C4::AR::ImportacionIsoMARC::delCampo($id_row);
        
        if ($msg_code){
            $t_params->{'table_error_message'} = C4::AR::Mensajes::getMensaje($msg_code,'INTRA');
        }
        my ($detalle_esquema,$esquema)  = C4::AR::ImportacionIsoMARC::getEsquema($id_esquema);
        
        $t_params->{'esquema'} = $detalle_esquema;
        $t_params->{'esquema_title'} = $esquema->getNombre;
        $t_params->{'id_esquema'} = $id_esquema;
        
    }
    elsif($tipoAccion eq "NUEVO_ESQUEMA"){
              ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "herramientas/importacion/detalle_esquema.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {  ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'MODIFICACION', 
                                                entorno => 'permisos', 
                                                tipo_permiso => 'general'},
                            debug => 1,
                        });
    
        my $title       = $obj->{'esquema_title'};
        my $descripcion = C4::AR::Filtros::i18n("Descripci&oacute;n del esquema");
        my ($esquema,$msg_code) = C4::AR::ImportacionIsoMARC::addEsquema($title,$descripcion);
        
        if ($msg_code){
            $t_params->{'table_error_message'} = C4::AR::Mensajes::getMensaje($msg_code,'INTRA');
        }

        my $detalle_esquema  = C4::AR::ImportacionIsoMARC::getEsquema($esquema->getId);
        
        $t_params->{'esquema'} = $detalle_esquema;
        $t_params->{'esquema_title'} = $esquema->getNombre;
        $t_params->{'id_esquema'} = $esquema->getId;
    }
}else{
    ($template, $session, $t_params)  = get_template_and_user({  
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

    my $string_ref = $input->param('id');
    my $value = $input->param('value');
    
    my $valor = C4::AR::ImportacionIsoMARC::editarValorEsquema($string_ref,$value);


    $t_params->{'value'} = $valor;	
}

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
