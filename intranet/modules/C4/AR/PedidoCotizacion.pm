package C4::AR::PedidoCotizacion;

use strict;
require Exporter;
use DBI;
use C4::AR::Recomendaciones;
use C4::AR::PedidoCotizacion;
use C4::Modelo::AdqPedidoCotizacion;
use C4::Modelo::AdqPedidoCotizacion::Manager;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(  
    &addPedidoCotizacion;
);

=item
    Esta funcion agrega un pedido cotizacion
    Parametros: (El id es AUTO_INCREMENT y la fecha CURRENT_TIMESTAMP)
        HASH { id_recomendacion, cantidades_array }
=cut
sub addPedidoCotizacion{

# recomendaciones_array, asi obtenemos las recomendaciones y las clonamos en la tabla pedido_cotizacion_detalle

    my ($param)             = @_;
    my $id_recomendacion    = $param->{'id_recomendacion'};
    my $pedido_cotizacion   = C4::Modelo::AdqPedidoCotizacion->new();
    my $msg_object          = C4::AR::Mensajes::create();
    my $db                  = $pedido_cotizacion->db;

    if (!($msg_object->{'error'})){
        $db->{connect_options}->{AutoCommit} = 0;
        $db->begin_work;
    
      #  eval{
            my %params;  
            
            my %parametros;
            $parametros{'id_recomendacion'}                     = $param->{'id_recomendacion'};
            $parametros{'cantidad_ejemplares'}                  = $param->{'cantidad_ejemplares'};                 
        
            $pedido_cotizacion->addPedidoCotizacion(\%parametros);

            my $id_pedido_cotizacion = $pedido_cotizacion->getId();
            
            
            $params{'id_pedido_recomendacion'}         = $id_pedido_cotizacion;
                               
            # obtenemos una recomendacion_detalle. Para clonar en pedido_cotitazion_detalle
C4::AR::Debug::debug("id_rec  ".$id_recomendacion);
            my $recomendacion_detalle = C4::AR::Recomendaciones::getRecomendacionDetallePorId($id_recomendacion);
                            
            $params{'cantidad_ejemplares'}              = $recomendacion_detalle; 
                  
            my $pedido_cotizacion_detalle               = C4::Modelo::AdqPedidoCotizacionDetalle->new(db => $db);    
            $pedido_cotizacion_detalle->addPedidoCotizacionDetalle(\%params);                         
            
            $msg_object->{'error'} = 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A033', 'params' => []});
            $db->commit;         
       # };
        
        if ($@){
         # TODO falta definir el mensaje "amigable" para el usuario informando que no se pudo agregar el proveedor
            &C4::AR::Mensajes::printErrorDB($@, 'B449',"INTRA");
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'B449', 'params' => []} ) ;
            $db->rollback;
        }

        $db->{connect_options}->{AutoCommit} = 1;
    }
    return ($msg_object);
    
}





END { }       # module clean-up code here (global destructor)

1;
__END__
