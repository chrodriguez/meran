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
    &getPresupuestoPorID;
);
  
sub getAdqPresupuestos{
    my $presupuestos = C4::Modelo::AdqPresupuesto::Manager->get_adq_presupuesto;
    my @results;

    foreach my $presupuesto (@$presupuestos) {
        push (@results, $presupuesto);
    }

    return(\@results);
}


sub getPresupuestoPorID{
     my ( $id_presupuesto, $db) = @_;
     my @result;
     
#     C4::AR::Debug::debug($id_presupuesto);
  
     $db = $db || C4::Modelo::AdqPresupuesto->new()->db;

     my $presupuesto= C4::Modelo::AdqPresupuesto::Manager->get_adq_presupuesto(   
                                                                    db => $db,
                                                                    query   => [ id => { eq => $id_presupuesto} ],
                                                                );

     return $presupuesto->[0];  
}


sub getAdqPresupuestoDetalle{
    my ( $id_presupuesto, $db) = @_;
    my @results; 

    $db = $db || C4::Modelo::AdqPresupuestoDetalle->new()->db;

    my $detalle_array_ref = C4::Modelo::AdqPresupuestoDetalle::Manager->get_adq_presupuesto_detalle(   
                                                                    db => $db,
                                                                    query   => [ adq_presupuesto_id => { eq => $id_presupuesto} ],
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


sub actualizarPresupuesto{
    
     my ($obj) = @_;

     my $tabla_array_ref = $obj->{'table'};
     my $pres=$obj->{'id_presupuesto'};

     my $msg_object= C4::AR::Mensajes::create();
    
     my $adq_presupuesto_detalle = C4::Modelo::AdqPresupuestoDetalle->new();
         
     
     my $db = $adq_presupuesto_detalle->db;
     $db->{connect_options}->{AutoCommit} = 0;
     $db->begin_work;
    
     my $pres_detalle = C4::AR::Presupuestos::getAdqPresupuestoDetalle($pres,$db); 
     eval{
              my $i=0;
              for my $detalle (@$pres_detalle){ 
#                     my $cantidad= $tabla_array_ref->[$i]->{'Cantidad'};
#                     my $precio_unitario= $tabla_array_ref->[$i]->{'PrecioUnitario'};
#                     
#                     if($cantidad ne "") {
#                           if (!($msg_object->{'error'}) && ( ((&C4::AR::Validator::countAlphaChars($cantidad) != 0)) || (&C4::AR::Validator::countSymbolChars($cantidad) != 0) || (&C4::AR::Validator::countNumericChars($cantidad) == 0))){
#                                   $msg_object->{'error'}= 1;
#                                   C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A029', 'params' => []} ) ;
#                           }
#                     } else {
#                         $msg_object->{'error'}= 1;
#                         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A030', 'params' => []} ) ;       
#                     }
#                         
#                     if($precio_unitario ne "") {
#                           if (!($msg_object->{'error'}) && ( ((&C4::AR::Validator::countAlphaChars($precio_unitario) != 0)) || (&C4::AR::Validator::isValidReal($precio_unitario) != 1) || (&C4::AR::Validator::countNumericChars($precio_unitario == 0)))){
#                                   $msg_object->{'error'}= 1;
#                                   C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A031', 'params' => []} ) ;
#                           }
#                     } else {
#                           $msg_object->{'error'}= 1;
#                           C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A032', 'params' => []} ) ;       
#                     }
                    $detalle->setPrecioUnitario($tabla_array_ref->[$i]->{'PrecioUnitario'});
                    $detalle->setCantidad($tabla_array_ref->[$i]->{'Cantidad'});
                    $detalle->save(); 
                    $i++;     
#               }
#               if (!($msg_object->{'error'})){
                  $msg_object->{'error'}= 0;
                  C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A027', 'params' => []});
                  $db->commit;
#               }
#             return ($msg_object);
        };
        if ($@){
                    &C4::AR::Mensajes::printErrorDB($@, 'A028',"INTRA");
                    $msg_object->{'error'}= 1;
                    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A028', 'params' => []} ) ;
                    $db->rollback;
        }
        return ($msg_object);
}}

       
END { }       # module clean-up code here (global destructor)

1;
__END__

