package C4::AR::Presupuestos;

use strict;
require Exporter;
use DBI;
use C4::Modelo::AdqPresupuestoDetalle;
use C4::Modelo::AdqRecomendacionDetalle::Manager;



use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(  
    &getAdqPresupuestoDetalle;
);
  

sub getAdqPresupuestoDetalle{
#     my ($id_recomendacion, $id_proveedor, $db) = @_;
# 
#     my presupuesto=1;
#     
#     $db = $db || C4::Modelo::AdqPresupuesto->new()->db;
# 
#     my $adq_presupuesto= C4::Modelo::AdqPresupuesto::Manager->get_adq_presupuesto(   
#                                                                     db => $db,
#                                                                     query   => [ id => { eq => $presupuesto}, proveedor_id => { eq => $id_proveedor}], 
#                                                                 );
# 
#     $db = $db || C4::Modelo::AdqPresupuestoDetalle->new()->db;
# 
#     
#     my $adq_presupuesto_detalle = C4::Modelo::AdqPresupuestoDetalle::Manager->get_adq_presupuesto_detalle(   
#                                                                     db => $db,
#                                                                     query   => [ adq_presupuesto_id => { eq => 1}, ], 
#                                                                 );
# 
#     if( scalar($adq_recomendacion_detalle) > 0){
# #         for(my $i=0;$i<scalar(@{$adq_recomendacion_detalle});$i++){
# #                 my $detalle = getAdqProveedorTipoMaterial($arreglo_materiales->[$i]->getMaterialId, $params->{'id_proveedor'}, $db);
# #                 $proveedor_material->eliminar();             
# #               }
#         return ($adq_recomendacion_detalle->[0]);
#     }else{
#         return 0;
#     }
}