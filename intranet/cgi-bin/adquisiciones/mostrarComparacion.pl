#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use C4::AR::Presupuestos;
use C4::AR::Recomendaciones;
use CGI;
use JSON;

# -------------------------  VA EN RecomendacionesDB ----------------------


my $input = new CGI;
my $authnotrequired= 0;

my $obj=$input->param('obj');

$obj = C4::AR::Utilidades::from_json_ISO($obj);

my $tipoAccion  = $obj->{'tipoAccion'}||"";

if($tipoAccion eq "MOSTRAR_PRESUPUESTOS_PEDIDO"){

        my $id_pedido= $obj->{'pedido_cotizacion'};

        my ($template, $session, $t_params) =  C4::AR::Auth::get_template_and_user ({
                              template_name   => '/adquisiciones/mostrarComparacion.tmpl',
                              query       => $input,
                              type        => "intranet",
                              authnotrequired => 0,
                              flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
        });
      

#------------------ Se Recuperan los presupuestos para un pedido de cotizacion dado--------------------------

       
        my $presupuestos = C4::AR::PedidoCotizacion::getPresupuestosPedidoCotizacion($id_pedido);

        C4::AR::Debug::debug("PRES PARA PEDIDO". scalar(@$presupuestos));
# -----------------------------------------------------------------------------------------------------------

#------------------ Se Recuperan los datos del pedido de cotizacion------------------------------------------

        my $detalle_pedido = C4::AR::PedidoCotizacion::getAdqPedidoCotizacionDetalle($id_pedido);
        
        C4::AR::Debug::debug("DETALES PEDIDO:". scalar(@$detalle_pedido));

        
# -----------------------------------------------------------------------------------------------------------

        
# -----------------Se recuperan los detalles de cada presupuesto obtenido anteriormente----------------------

     
#         
#         foreach my $pres (@$presupuestos){           
#                     my @array_presupuestos;
#                     $detalle_presupuesto= C4::AR::Presupuestos::getAdqPresupuestoDetalle($pres->getId);
#                     foreach my $renglon (@$detalle_pedido){
#                         
#                                    my %hash_presupuesto;
#                                    $hash_presupuesto{'proveedor'} = $pres->ref_proveedor->id;
#                                    $hash_presupuesto{'cant'} = @$detalle_presupuesto[$renglon->getRenglon]->getCantidad;
#                                    $hash_presupuesto{'precio_unitario'} = @$detalle_presupuesto[$renglon->getRenglon]->getPrecioUnitario;
#                                    $hash_presupuesto{'total'} = (@$detalle_presupuesto[$renglon->getRenglon]->getCantidad) * (@$detalle_presupuesto[$renglon->getRenglon]->getPrecioUnitario);
#                                    push(@array_presupuestos, \%hash_presupuesto);
#                     }             
#                     
#          }
#                    
        
        
#         my $detalle_presupuesto;
        my $detalles;
        my @resultado;
        my $renglon= 0;
      
        foreach my $det (@$detalle_pedido){           
                   
                    my @array_presupuestos;
                    foreach my $pres (@$presupuestos){
                         
                                  my $detalle_presupuesto= C4::AR::Presupuestos::getAdqPresupuestoDetalle($pres->getId);
                                   
                                
                              
                                  my %hash_presupuesto;
#                                   $detalle_presupuesto =$det_pres;
                                
                                  $hash_presupuesto{'proveedor'} = $pres->ref_proveedor->id;
                                  $hash_presupuesto{'cant'} = @$detalle_presupuesto[$renglon]->getCantidad;
                                  $hash_presupuesto{'precio_unitario'} = @$detalle_presupuesto[$renglon]->getPrecioUnitario;
                                  $hash_presupuesto{'total'} = (@$detalle_presupuesto[$renglon]->getCantidad) * (@$detalle_presupuesto[$renglon]->getPrecioUnitario);
                                  push(@array_presupuestos, \%hash_presupuesto);
                                
                         
                      }       
                      push(@resultado,\@array_presupuestos);  
                      $renglon= $renglon + 1;
                           
        }
                   
        C4::AR::Utilidades::printARRAY(@resultado);

        $t_params->{'detalle_pedido'} = $detalle_pedido;
#         $t_params->{'detalle_pres'} = \%hash_detalle_pres;
        $t_params->{'presupuestos'} = \@resultado;
        
        C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);    
}

