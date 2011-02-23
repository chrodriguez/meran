package C4::AR::PedidoCotizacionDetalle;

use strict;
require Exporter;
use DBI;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(  
    &addPedidoCotizacionDetalle;
);

=item
    Esta funcion agrega un pedido cotizacion
    Parametros: (El id es AUTO_INCREMENT y la fecha CURRENT_TIMESTAMP)
        HASH { id_pedido_cotizacion, cantidades_ejemplares }
=cut
sub addPedidoCotizacion{

}



END { }       # module clean-up code here (global destructor)

1;
__END__
