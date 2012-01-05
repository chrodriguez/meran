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
	     
	    my $esquema  = C4::AR::ImportacionIsoMARC::getEsquema($id_esquema);
	    
        $t_params->{'esquema'} = $esquema;
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
        
        C4::AR::ImportacionIsoMARC::addCampo($id_esquema);
        
        my $esquema  = C4::AR::ImportacionIsoMARC::getEsquema($id_esquema);
        
        $t_params->{'esquema'} = $esquema;
		
		
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
