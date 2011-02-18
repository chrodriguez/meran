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

if($tipoAccion eq "MOSTRAR_PRESUPUESTOS_REC"){

        my $id_recomendacion= $obj->{'recomendacion'};

        my ($template, $session, $t_params) =  C4::AR::Auth::get_template_and_user ({
                              template_name   => '/adquisiciones/mostrarComparacion.tmpl',
                              query       => $input,
                              type        => "intranet",
                              authnotrequired => 0,
                              flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
        });
      

        my $detalle_rec = C4::AR::Presupuestos::getDetallePorRenglon($id_recomendacion);
  
#         C4::AR::Utilidades::printARRAY($detalle_rec);

#         
#         my @results;
         
#         my @proveedores; 
#         
#         my $i=0;

         
          


#----------------------------------------------------------------------------


          
          my $renglon;
          my $detalle_renglon;
          my $pres;
          my $cantidad;
          my $precio_unitario;

          my $cant_proveedores = 0; 
          my $proveedor;
          
          # DETERMINO LA CANTIDAD DE PROVEEDORES


          foreach my $detalle (@$detalle_rec){
                      if ($proveedor ne ($detalle->{'ref_presupuesto'})->{'proveedor_id'}){
                            $cant_proveedores= $cant_proveedores + 1;
                            $proveedor= ($detalle->{'ref_presupuesto'})->{'proveedor_id'};
                      }
          }

          #Armo la tabla
        
       
          my @fila_matriz;
          my @fila_renglones;
          my @matriz_comparacion;
  
          my $proveedor;
          my $i_fila=0;
          my $i_col= 1;
          my $detalle;
          my $i=0;
          
          while ($i != scalar(@$detalle_rec)){
                      $detalle= @$detalle_rec[$i];
                      $i = $i + 1;
                      $proveedor= ($detalle->{'ref_presupuesto'})->{'proveedor_id'};
                      while ($proveedor eq ($detalle->{'ref_presupuesto'})->{'proveedor_id'}) {
#                              C4::AR::Debug::debug($proveedor);
                            $renglon= $renglon + 1; 
                            $i_fila= $i_fila + 1;
                            @fila_renglones[$i_fila]=$renglon;
                    
                            $detalle_renglon=($detalle->{'ref_recomendacion_detalle'})->{'titulo'}." - ".($detalle->{'ref_recomendacion_detalle'})->{'autor'};
#                           my $nombre_prov=($detalle{'ref_presupuesto'}->{'proveedor_id'})->{'nombre'} || ($detalle{'ref_presupuesto'}->{'proveedor_id'})->{'razon_social'}, 
                            $cantidad= $detalle->{'cantidad'};
                            $precio_unitario= $detalle->{'precio_unitario'};
        
                            my %hash;
        #             
                            %hash= (  renglon => $renglon,
                                      proveedor_id => $proveedor,
        #                             proveedor_nombre => $nombre_prov,
                                      detalle_renglon => $detalle_renglon,
                                      cantidad => $cantidad,
                                      precio => $precio_unitario,
                                      pres_id => $pres
                                    ),

                            @fila_matriz[$i_fila]= \%hash;
                            $detalle= @$detalle_rec[$i];
                           
                      }
                        
                      @matriz_comparacion[$i_col]=@fila_matriz;
                      $renglon=1;
                      $pres= ($detalle->{'ref_presupuesto'})->{'id'};
                      $i_fila= 0;
                      $i_col= $i_col + 1;
                                         
          }
           
          @matriz_comparacion[0]=@fila_renglones;

          C4::AR::Utilidades::printARRAY(\@matriz_comparacion);
        
          $t_params->{'matriz'} = \@matriz_comparacion;
   
#         $t_params->{'proveedores'} = \@proveedores;
       
        C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);    
}

