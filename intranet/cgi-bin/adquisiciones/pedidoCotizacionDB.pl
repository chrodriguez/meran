#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use C4::AR::PedidoCotizacion;
use C4::AR::Recomendaciones;
use CGI;
use JSON;

my $input = new CGI;
my $authnotrequired= 0;

my $obj=$input->param('obj');

$obj = C4::AR::Utilidades::from_json_ISO($obj);

my $tipoAccion  = $obj->{'tipoAccion'}||"";

if($tipoAccion eq "AGREGAR_PEDIDO_COTIZACION"){
    
    for(my $i=0; $i<scalar(@{$obj->{'recomendaciones_array'}}); $i++){
    
        my %params = {};
        
        $params{'id_recomendacion'}       = $obj->{'recomendaciones_array'}->[$i];
        $params{'cantidad_ejemplares'}    = $obj->{'cantidades_array'}->[$i];
        
        my $message = C4::AR::PedidoCotizacion::addPedidoCotizacion(\%params);   
    }

    
    my $recomendacion_detalle   = C4::AR::Recomendaciones::getRecomendacionDetallePorId($obj);
}
