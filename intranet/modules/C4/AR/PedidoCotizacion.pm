package C4::AR::PedidoCotizacion;

use strict;
require Exporter;
use DBI;
use C4::Modelo::AdqPedidoCotizacion;
use C4::Modelo::AdqPedidoCotizacion::Manager;
use C4::Modelo::AdqPedidoCotizacionDetalle;
use C4::Modelo::AdqPedidoCotizacionDetalle::Manager;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(  
            &getAdqPedidosCotizacion;
            &getPresupuestosPedidoCotizacion;
            &getAdqPedidoCotizacionDetalle;
);


sub getPresupuestosPedidoCotizacion{
      my ($params)        =@_;
      
      my $db = C4::Modelo::AdqPresupuesto->new()->db;
      my $presupuestos = C4::Modelo::AdqPresupuesto::Manager->get_adq_presupuesto(   
                                                                    db => $db,
                                                                    query  => [ ref_pedido_cotizacion_id => $params],
                                                                );
      my @results;

      foreach my $pres (@$presupuestos) {
          push (@results, $pres);
      }

      return(\@results);

}


sub getAdqPedidoCotizacionDetalle{
    my ( $id_pedido, $db) = @_;
    
    my @results; 

    $db = $db || C4::Modelo::AdqPedidoCotizacionDetalle->new()->db;

    my $detalle_array_ref = C4::Modelo::AdqPedidoCotizacionDetalle::Manager->get_adq_pedido_cotizacion_detalle(   
                                                                    db => $db,
                                                                    query   => [ adq_pedido_cotizacion_id => { eq => $id_pedido} ],
                                                                );
      
     foreach my $detalle_pres (@$detalle_array_ref) {
        push (@results, $detalle_pres);
     } 
    
    
    if(scalar(@results) > 0){
        return (\@results);
    }else{
        return 0;
    }
}


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

