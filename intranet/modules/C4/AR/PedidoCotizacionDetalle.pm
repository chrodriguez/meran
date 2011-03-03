package C4::AR::PedidoCotizacionDetalle;

use strict;
require Exporter;
use DBI;
use C4::Modelo::AdqPedidoCotizacionDetalle;
use C4::Modelo::AdqPedidoCotizacionDetalle::Manager;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(  
    &addPedidoCotizacionDetalle;
    &getPedidoCotizacionConDetallePorId;
    &getPedidosCotizacionPorPadre;
);

=item
    Esta funcion agrega un pedido cotizacion
    Parametros: (El id es AUTO_INCREMENT y la fecha CURRENT_TIMESTAMP)
        HASH { id_pedido_cotizacion, cantidades_ejemplares }
=cut
sub addPedidoCotizacionDetalle{
#TODO 
# un clon de addRecomendacionDetalle    
#   _verificarDatosPedidoCotizacion
}

=item
    Esta funcion devuelve el pedido_cotizacion_detalle por su id
    Parametros: id_pedido_cotizacion_detalle
=cut
sub getPedidoCotizacionConDetallePorId{

    my ($params) = @_;
    my @filtros;

    my $db                           = C4::Modelo::AdqPedidoCotizacionDetalle->new()->db;
    push (@filtros, ( id => { eq => $params}));
    
    my $pedido_cotizacion            = C4::Modelo::AdqPedidoCotizacionDetalle::Manager->get_adq_pedido_cotizacion_detalle(   
                                                                    db => $db,
                                                                    query => \@filtros,
                                                                );
    return $pedido_cotizacion->[0];
}


=item
    Esta funcion devuelve los pedidos_cotizacion_detalle que tengan el pedido_cotizacion (padre) 
    con el id recibido como parametro
    Parametros: id_pedido_cotizacion (padre)
=cut
sub getPedidosCotizacionPorPadre{

    my ($params) = @_;
    my @filtros;

    my $db = C4::Modelo::AdqPedidoCotizacionDetalle->new()->db;
    push (@filtros, ( adq_pedido_cotizacion_id => { eq => $params}));
    
    my $pedido_cotizacion            = C4::Modelo::AdqPedidoCotizacionDetalle::Manager->get_adq_pedido_cotizacion_detalle(   
                                                                    db => $db,
                                                                    query => \@filtros,
                                                                );
    return $pedido_cotizacion;
}


END { }       # module clean-up code here (global destructor)

1;
__END__
