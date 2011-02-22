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

# -----------------------------------------------------------------------------------------------------------

#------------------ Se Recuperan los datos del pedido de cotizacion------------------------------------------

        my $detalle_pedido = C4::AR::PedidoCotizacion::getAdqPedidoCotizacionDetalle($id_pedido);

# -----------------------------------------------------------------------------------------------------------

        
# -----------------Se recuperan los detalles de cada presupuesto obtenido anteriormente----------------------

        my @detalle_pres;

        foreach my $pres (@$presupuestos){
                     push(@detalle_pres,C4::AR::Presupuestos::getAdqPresupuestoDetalle($pres->getId));
        }
      
# -----------------------------------------------------------------------------------------------------------

            
        $t_params->{'presupuestos'} = $presupuestos;
        $t_params->{'detalle_pedido'} = $detalle_pedido;
        $t_params->{'detalle_pres'} = \@detalle_pres;
        

       
        C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);    
}

