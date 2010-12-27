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
);
  

sub getAdqPresupuestoDetalle{
    my ($id_recomendacion, $id_proveedor, $db) = @_;

    my $presupuesto=1;
  
    $db = $db || C4::Modelo::AdqPresupuestoDetalle->new()->db;

    
    my @detalle_array_ref = C4::Modelo::AdqPresupuestoDetalle::Manager->get_adq_presupuesto_detalle(   
                                                                    db => $db,
                                                                    query   => [ adq_presupuesto_id => { eq => $presupuesto} ],
                                                                );
    if(scalar(@detalle_array_ref) > 0){
        return (@detalle_array_ref);
    }else{
        return 0;
    }
}


sub actualizarPresupuesto{
    
     my ($obj) = @_;

     my $tabla_array_ref = $obj->{'table'};

     my $recomendacion=1;

     my $adq_presupuesto_detalle = C4::Modelo::AdqPresupuestoDetalle->new();
     my $msg_object= C4::AR::Mensajes::create();
     
     my $db = $adq_presupuesto_detalle->db;
     $db->{connect_options}->{AutoCommit} = 0;
     $db->begin_work;
     
     my $pres_detalle = C4::AR::Presupuestos::getAdqPresupuestoDetalle($recomendacion); 
     
     eval{
          my $i=0;
         
          for my $detalle ($pres_detalle){          
                $detalle->setPrecioUnitario($tabla_array_ref->[$i]->{'PrecioUnitario'});
                C4::AR::Debug::debug($i);
                $detalle->save(); 
                $i++;
          }

     $msg_object->{'error'}= 0;
     C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A006', 'params' => []});
     $db->commit;

     };
     if ($@){
              &C4::AR::Mensajes::printErrorDB($@, 'B449',"INTRA");
              $msg_object->{'error'}= 1;
              C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'B449', 'params' => []} ) ;
              $db->rollback;
     }

     return ($msg_object);

}

END { }       # module clean-up code here (global destructor)

1;
__END__

