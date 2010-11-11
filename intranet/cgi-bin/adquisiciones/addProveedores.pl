#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Context;
use C4::AR::Proveedores;
use CGI;
use JSON;


my $input = new CGI;

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
    $params{'nombre'} = $obj->{'nombre'};
    $params{'direccion'} = $obj->{'direccion'};
    $params{'proveedor_activo'} = 1;
    $params{'telefono'} = $obj->{'telefono'};
    $params{'email'} = $obj->{'email'};
    $params{'actionType'} = $obj->{'tipoAccion'};

# no encuentra esta rutina: 
    my ($message) = C4::AR::Proveedores::agregarProveedor(\%params);
#     my $value = C4::AR::Proveedores::agregarProveedor();
#     C4::AR::Debug::debug($message);
#     C4::AR::Debug::_printHASH($message);
    my $infoOperacionJSON=to_json $message;

    C4::Auth::print_header($session);
    print $infoOperacionJSON;
}else{

  $t_params->{'addProveedor'} = 1;

  C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}
