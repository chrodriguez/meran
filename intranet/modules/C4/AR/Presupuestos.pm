package C4::AR::Presupuestos;

use strict;
require Exporter;
use DBI;
use C4::Modelo::AdqPresupuestoDetalle;
use C4::Modelo::AdqPresupuestoDetalle::Manager;
use C4::Modelo::AdqRecomendacionDetalle::Manager;



use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(  
    &getAdqPresupuestoDetalle;
    &actualizarPresupuesto;
    &getAdqPresupuestos;
);
  
sub getAdqPresupuestos{
    my $presupuestos = C4::Modelo::AdqPresupuesto::Manager->get_adq_presupuesto;
    my @results;

    foreach my $presupuesto (@$presupuestos) {
        push (@results, $presupuesto);
    }

    return(\@results);
}


sub getAdqPresupuestoDetalle{
    my ( $id_presupuesto, $db) = @_;
  
    $db = $db || C4::Modelo::AdqPresupuestoDetalle->new()->db;

    my $detalle_array_ref = C4::Modelo::AdqPresupuestoDetalle::Manager->get_adq_presupuesto_detalle(   
                                                                    db => $db,
                                                                    query   => [ adq_presupuesto_id => { eq => $id_presupuesto} ],
                                                                );
   
    if(scalar(@$detalle_array_ref) > 0){
        return ($detalle_array_ref);
    }else{
        return 0;
    }
}


sub actualizarPresupuesto{
    
     my ($obj) = @_;

     my $tabla_array_ref = $obj->{'table'};

     my $presupuesto=$obj->{'id_proveedor'};;
  
     my $adq_presupuesto_detalle = C4::Modelo::AdqPresupuestoDetalle->new();
     my $msg_object= C4::AR::Mensajes::create();
     
     my $db = $adq_presupuesto_detalle->db;
     $db->{connect_options}->{AutoCommit} = 0;
     $db->begin_work;
     
     my $pres_detalle = C4::AR::Presupuestos::getAdqPresupuestoDetalle($presupuesto,$db); 
     
     eval{
          my $i=0;
          for my $detalle (@{$pres_detalle}){          
                $detalle->setPrecioUnitario($tabla_array_ref->[$i]->{'PrecioUnitario'});
                $detalle->setCantidad($tabla_array_ref->[$i]->{'Cantidad'});
                $detalle->save(); 
                $i++;
          }

     $msg_object->{'error'}= 0;
     C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A027', 'params' => []});
     $db->commit;

     };
     if ($@){
              &C4::AR::Mensajes::printErrorDB($@, 'A028',"INTRA");
              $msg_object->{'error'}= 1;
              C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A028', 'params' => []} ) ;
              $db->rollback;
     }

     return ($msg_object);

}

END { }       # module clean-up code here (global destructor)

1;
__END__

