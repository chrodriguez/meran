#!/usr/bin/perl

use strict;
use C4::Auth;

use C4::Context;
use C4::AR::Proveedores;
use CGI;
use JSON;


my $input = new CGI;

my $comboDeTipoDeDoc = &C4::AR::Utilidades::generarComboTipoDeDoc();

my $obj=$input->param('obj');

my ($template, $session, $t_params) = get_template_and_user({
    template_name => "adquisiciones/addProveedores.tmpl",
    query => $input,
    type => "intranet",
    authnotrequired => 0,
    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'ALTA', entorno => 'usuarios'},
    debug => 1,
});

if($obj){
    $obj= C4::AR::Utilidades::from_json_ISO($obj);
    
    my %params = {};

    $params{'tipo_proveedor'}       = $obj->{'tipo_proveedor'};

#   dependiendo del tipo se guarda ciertos campos
    if($params{'tipo_proveedor'} eq "persona_fisica"){

        $params{'apellido'}         = $obj->{'apellido'};
        $params{'nombre'}           = $obj->{'nombre'};   
        $params{'tipo_doc'}         = $obj->{'tipo_doc'};
        $params{'nro_doc'}          = $obj->{'nro_doc'};  
      
    }else{

        $params{'razon_social'}     = $obj->{'razon_social'}; 
    }

    $params{'cuit_cuil'}            = $obj->{'cuit_cuil'};     
    $params{'pais'}                 = $obj->{'pais'};
    $params{'provincia'}            = $obj->{'provincia'};
    $params{'ciudad'}               = $obj->{'ciudad'};   
    $params{'domicilio'}            = $obj->{'domicilio'};
    $params{'telefono'}             = $obj->{'telefono'};
    $params{'fax'}                  = $obj->{'fax'};
    $params{'email'}                = $obj->{'email'};
    $params{'plazo_reclamo'}        = $obj->{'plazo_reclamo'};

# TODO AGREGAR TIPOS DE MATERIALES, FORMAS DE ENVIO!!!

    $params{'proveedor_activo'}     = 1; 
    $params{'actionType'}           = $obj->{'tipoAccion'};

# Monedas:

    $params{'monedas_array'}           = $obj->{'monedas_array'}; 

# FIXME pueden pasar directamente $obj a agregarProveedor es una HASH = a $params

    my ($message) = C4::AR::Proveedores::agregarProveedor(\%params);
    my $infoOperacionJSON=to_json $message;

    C4::Auth::print_header($session);
    print $infoOperacionJSON;

}else{

  $t_params->{'addProveedor'} = 1;
  $t_params->{'combo_tipo_documento'} = $comboDeTipoDeDoc; 

  C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}
