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
  
         
        my $renglon;
        my $detalle_renglon;
        my $pres;
        my $cantidad;
        my $precio_unitario;
        my $proveedor= "";
        my @results;
        my $cant_proveedores = 0; 
        my @proveedores; 
        
        my $i=0;
        foreach my $detalle (@$detalle_rec){
            if ($proveedor ne ($detalle->{'ref_presupuesto'})->{'proveedor_id'}){
                    $proveedor= ($detalle->{'ref_presupuesto'})->{'proveedor_id'};
                    
                    if ((($detalle->{'ref_presupuesto'})->{'ref_proveedor'})->{'nombre'} ne "" ) {
                            push(@proveedores, (($detalle->{'ref_presupuesto'})->{'ref_proveedor'})->{'nombre'});
                    } else {
                            push(@proveedores, (($detalle->{'ref_presupuesto'})->{'ref_proveedor'})->{'razon_social'});
                    }
                    $renglon=1;
                    $pres= ($detalle->{'ref_presupuesto'})->{'id'};
            }else{
                 $renglon= $renglon + 1;
            }
            
            $detalle_renglon=($detalle->{'ref_recomendacion_detalle'})->{'titulo'}." - ".($detalle->{'ref_recomendacion_detalle'})->{'autor'};
            $cantidad= $detalle->{'cantidad'};
            $precio_unitario= $detalle->{'precio_unitario'};
            
            my %hash;
            
            %hash= ( renglon => $renglon,
                    proveedor => $proveedor,
                    detalle_renglon => $detalle_renglon,
                    cantidad => $cantidad,
                    precio => $precio_unitario,
                    pres_id => $pres
                  ),
      
            push (@results, \%hash);
           
        }
        
        $t_params->{'presupuestos'} = \@results;
   
        $t_params->{'proveedores'} = \@proveedores;
       
        C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);    
}

