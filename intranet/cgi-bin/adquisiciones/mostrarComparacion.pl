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
# 
#         C4::AR::Debug::debug("CANTIDAD DE PRESUPUESTOS PARA PEDIDO".$id_pedido."= ".scalar(@$presupuestos));
#         C4::AR::Utilidades::printARRAY($presupuestos);
# -----------------------------------------------------------------------------------------------------------

#------------------ Se Recuperan los datos del pedido de cotizacion------------------------------------------

        my $detalle_pedido = C4::AR::PedidoCotizacion::getAdqPedidoCotizacionDetalle($id_pedido);
        
#         C4::AR::Debug::debug("CANTIDAD DE DETALLES PARA PRESUPUESTOS");
#         C4::AR::Utilidades::printARRAY($detalle_pedido);
#         C4::AR::Utilidades::printHASH(@$detalle_pedido[0]);
#         C4::AR::Utilidades::printHASH(@$detalle_pedido[1]);
# -----------------------------------------------------------------------------------------------------------

        
# -----------------Se recuperan los detalles de cada presupuesto obtenido anteriormente----------------------

        
#         my $detalle_presupuesto;
        my $detalles;
#         my @resultado;
        my @resultado;
        my $renglon=0;
      
        foreach my $det (@$detalle_pedido){           
                    
#                     $renglon= $det->getNroRenglon;
                    C4::AR::Debug::debug($renglon);
                    
                    my %hash_detalle;
                    my @array_presupuestos;
                    
                    $hash_detalle{'renglon'} = $renglon + 1;
                    
                    if($det->ref_adq_recomendacion_detalle){    
                              $hash_detalle{'titulo'} = $det->ref_adq_recomendacion_detalle->getTitulo;
                              $hash_detalle{'autor'} = $det->ref_adq_recomendacion_detalle->getAutor;
                    } else {
                              $hash_detalle{'titulo'} = $det->getTitulo;
                              $hash_detalle{'autor'} = $det->getAutor;
                    }   
                    
                    $resultado{'detalle'}=\%hash_detalle; 
                  
                    foreach my $pres (@$presupuestos){
                         
                                  my $detalle_presupuesto= C4::AR::Presupuestos::getAdqPresupuestoDetalle($pres->getId);
                                    
                                   C4::AR::Debug::debug($renglon);
                                  my %hash_presupuesto;
                                
                                  $hash_presupuesto{'proveedor'} = $pres->ref_proveedor->getNombre." ".$pres->ref_proveedor->getApellido; 
                                  $hash_presupuesto{'cant'} = @$detalle_presupuesto[$renglon]->getCantidad;
                                  $hash_presupuesto{'precio_unitario'} = @$detalle_presupuesto[$renglon]->getPrecioUnitario;
                                  $hash_presupuesto{'total'} = (@$detalle_presupuesto[$renglon]->getCantidad) * (@$detalle_presupuesto[$renglon]->getPrecioUnitario);
                                  $resultado{'presup'}=\%hash_detalle;
#                                   push(@array_presupuestos, \%hash_presupuesto);
                                
                         
                     }       
#                     $resultado{'presupuesto'}=\@array_presupuestos;  
                     push(@resultado,\%presupuesto);  
                     $renglon= $renglon + 1;
                           
        }
                   

 
       C4::AR::Utilidades::printHASH(%resultado->{'detalle'});

        $t_params->{'detalle_pedido'} = $detalle_pedido;
#         $t_params->{'detalle_pres'} = \%hash_detalle_pres;
        $t_params->{'presupuestos'} = \@resultado;
        
        C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);    
}

