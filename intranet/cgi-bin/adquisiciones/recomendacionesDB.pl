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
                              template_name   => '/adquisiciones/compararPresupuestos.tmpl',
                              query       => $input,
                              type        => "intranet",
                              authnotrequired => 0,
                              flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
        });
      

        
        my $detalle_rec = C4::AR::Presupuestos::getDetallePorRenglon($id_recomendacion);
  
#         my $detalle_pres = C4::AR::Presupuestos::getAdqPresupuestos();

        C4::AR::Debug::debug($detalle_rec);
    
#         foreach my $detalle ($detalle_rec){
#                 push(@detalle_pres, C4::AR::Presupuestos::getAdqPresupuestoDetalle($pres->[0]->getId));
#         }
         
         C4::AR::Utilidades::printHASH(@$detalle_rec->[0]);
       
        my %hash;
#         $i=0;
#         foreach my $pres (@detalle_pres){
#             %hash{'pres'.$i}   =    $pres;
#              $i= $i + 1;
#         }
        
        $t_params->{'pres'} =  \%hash;
       
        C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);    
}

