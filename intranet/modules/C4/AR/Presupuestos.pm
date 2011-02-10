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
    &addPresupuesto;
);

# =item
#   Esta funcion agrega un Presupuesto
#       Parametros: HASH   { id_proveedor , id_recomendacion }     
# =cut
sub addPresupuesto{

    my ($param)         = @_;
    my $presupuesto     = C4::Modelo::AdqPresupuesto->new();
    my $msg_object      = C4::AR::Mensajes::create();
    my $db              = $presupuesto->db;

#   _verificarDatosPresupuesto($param,$msg_object); TODO

    if (!($msg_object->{'error'})){
        # entro si no hay algun error, todos los campos ingresados son validos
        $db->{connect_options}->{AutoCommit} = 0;
        $db->begin_work;
          
      #  eval{              
            my %parametros;
            $parametros{'id_proveedor'}                     = $param->{'id_proveedor'};
            $parametros{'ref_estado_presupuesto_id'}        = '1';
                   
            # agrega un presupuesto y tiene que hacer: por cada recomendacion hacer un presupuesto_detalle
            $presupuesto->addPresupuesto(\%parametros);
               
            # aca agregar presupuesto_detalle con el id del presupuesto recien ingresado
            my $id_presupuesto = $presupuesto->getId();                
            
            # presupuesto_detalle
            for(my $i=0;$i<scalar(@{$param->{'recomendaciones_array'}});$i++){
                my %param;
                $param{'id_presupuesto'}                    = $id_presupuesto;
                $param{'id_recomendacion_detalle'}          = $param->{'recomendaciones_array'}->[$i];  
                
                #TODO ver la cantidad de recomendacion_detalle, si traerla aca antes o pasarla desde el cliente 
                
                #C4::AR::Debug::debug('entroo');
                       
                my $presupuesto_detalle                     = C4::Modelo::AdqPresupuestoDetalle->new(db => $db);    
                $presupuesto_detalle->addPresupuestoDetalle(\%param);
            }
            
            
    
            $msg_object->{'error'} = 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A029', 'params' => []});
            $db->commit;
        #};
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

  
     my $adq_presupuesto_detalle = C4::Modelo::AdqPresupuestoDetalle->new();
     my $msg_object= C4::AR::Mensajes::create();
     
     my $db = $adq_presupuesto_detalle->db;
     $db->{connect_options}->{AutoCommit} = 0;
     $db->begin_work;
     
     my $pres_detalle = C4::AR::Presupuestos::getAdqPresupuestoDetalle($pres,$db); 
      eval{
          my $i=0;
          for my $detalle (@$pres_detalle){ 
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

