#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use CGI;
use C4::AR::Proveedores;
use C4::AR::PedidoCotizacionDetalle;


my $input                   = new CGI;
my $id_pedido_cotizacion    = $input->param('id_pedido_cotizacion');
my $tipoAccion              = $input->param('action');

my ($template, $session, $t_params);

my $pedidos_cotizacion               = C4::AR::PedidoCotizacionDetalle::getPedidosCotizacionPorPadre($id_pedido_cotizacion);

if ($tipoAccion eq "EDITAR") {
# se edita la informacion del pedido_cotizacion
 
    ($template, $session, $t_params) =  C4::AR::Auth::get_template_and_user ({
        template_name   => '/adquisiciones/datosPedidoCotizacion.tmpl',
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
    });
    
    $t_params->{'pedido_cotizacion'}    = $pedidos_cotizacion;
    $t_params->{'edit'}                 = 1;

}else{
# se muestran los detalles del pedido_cotizacion

    ($template, $session, $t_params) =  C4::AR::Auth::get_template_and_user ({
        template_name   => '/adquisiciones/datosPedidoCotizacion.tmpl',
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
    });   
          
    $t_params->{'pedido_cotizacion'}    = $pedidos_cotizacion;
    $t_params->{'detalle'}              = 1; 
}


C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);