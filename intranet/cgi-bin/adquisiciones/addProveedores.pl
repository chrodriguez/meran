#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Context;
use CGI;
use JSON;


my $input = new CGI;

my $obj=$input->param('obj');

if($obj){
    $obj= C4::AR::Utilidades::from_json_ISO($obj);
    
    my %params = {};
    $params{'nombre'} = $obj->{'nombre'};
    $params{'direccion'} = $obj->{'direccion'};
    $params{'proveedor_activo'} = 1;
    $params{'telefono'} = $obj->{'telefono'};
    $params{'email'} = $obj->{'email'};
    $params{'actionType'} = $obj->{'tipoAccion'};

# no encuentra esta rutina: 
     my ($value) = C4::AR::Proveedores::agregarProveedor(\%params);
#     my $value = C4::AR::Proveedores::agregarProveedor();
}

my ($template, $session, $t_params) = get_template_and_user({
        template_name => "adquisiciones/addProveedores.tmpl",
        query => $input,
        type => "intranet",
        authnotrequired => 0,
        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'ALTA', entorno => 'usuarios'},
        debug => 1,
    });

  $t_params->{'addProveedor'} = 1;
  C4::Auth::output_html_with_http_headers($template, $t_params, $session);