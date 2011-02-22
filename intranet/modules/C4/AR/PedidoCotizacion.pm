package C4::AR::PedidoCotizacion;

use strict;
require Exporter;
use DBI;
use C4::Modelo::AdqPedidoCotizacion;
use C4::Modelo::AdqPedidoCotizacion::Manager;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(  
            &getAdqPedidosCotizacion;

);


sub getAdqPedidosCotizacion{
    
    my $db = C4::Modelo::AdqPedidoCotizacion->new()->db;
    my $pedidos_cotizacion = C4::Modelo::AdqPedidoCotizacion::Manager->get_adq_pedido_cotizacion(   
                                                                    db => $db,
                                                                );

    my @results;

    foreach my $pedido (@$pedidos_cotizacion) {
        push (@results, $pedido);
    }

    return(\@results);
}

END { }       # module clean-up code here (global destructor)

1;
__END__

