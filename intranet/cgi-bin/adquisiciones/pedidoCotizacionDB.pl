#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use C4::AR::PedidoCotizacion;
use C4::AR::Recomendaciones;
use CGI;
use JSON;

my $input           = new CGI;
my $authnotrequired = 0;
my $obj             = $input->param('obj');
$obj                = C4::AR::Utilidades::from_json_ISO($obj);
my $tipoAccion      = $obj->{'tipoAccion'}||"";

if($tipoAccion eq "AGREGAR_PEDIDO_COTIZACION"){

    my %params = {};
        
    $params{'recomendaciones_array'}       = $obj->{'recomendaciones_array'};
    $params{'cantidad_ejemplares_array'}   = $obj->{'cantidades_array'};
        
    my ($message) = C4::AR::PedidoCotizacion::addPedidoCotizacion(\%params);  


    my ($userid, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'BAJA', 
                                                entorno => 'usuarios'},
                                                "intranet"
                                            );                              
    my $infoOperacionJSON = to_json $message;
    
    C4::AR::Auth::print_header($session);
    print $infoOperacionJSON;                        
}

elsif($tipoAccion eq "PRESUPUESTAR"){

    # se devuelve el combo de proveedores para poder presupuestarlos
    
    my ($template, $session, $t_params) = get_template_and_user({
                                    template_name => "adquisiciones/generatePresupuesto.tmpl",
                                    query => $input,
                                    type => "intranet",
                                    authnotrequired => 0,
                                    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
                                    debug => 1,
                });
    
    my $combo_proveedores               = &C4::AR::Utilidades::generarComboProveedoresMultiple();
    $t_params->{'pedido_cotizacion_id'} = $obj->{'pedido_cotizacion_id'};
    $t_params->{'combo_proveedores'}    = $combo_proveedores;

    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
}