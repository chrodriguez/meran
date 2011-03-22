#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use C4::AR::Recomendaciones;
use CGI;
use JSON;

my $input               = new CGI;
my $obj                 = $input->param('obj')||"";

my ($template, $session, $t_params);

if($obj){
#   trabajamos con JSON

    $obj                    = C4::AR::Utilidades::from_json_ISO($obj);
    my $tipoAccion          = $obj->{'tipoAccion'};
    
    if($tipoAccion eq "ACTUALIZAR_RECOMENDACION"){
    
        ($template, $session, $t_params) =  C4::AR::Auth::get_template_and_user ({
            template_name       => '/adquisiciones/datosRecomendacion.tmpl',
            query               => $input,
            type                => "intranet",
            authnotrequired     => 0,
            flagsrequired       => { ui => 'ANY', tipo_documento => 'ANY', accion => 'MODIFICAR', entorno => 'adquisiciones'},
        });   
           
    my ($ok) = C4::AR::Recomendaciones::updateRecomendacionDetalle($obj);
    
    my $infoOperacionJSON = to_json $ok;
 
    C4::AR::Auth::print_header($session);
    print $infoOperacionJSON;
    
    }

}else{
#   trabajamos con CGI

    my $id_recomendacion    = $input->param('id_recomendacion');
    my $tipoAccion          = $input->param('action')||"";

    if($tipoAccion eq "EDITAR_RECOMENDACION"){

        ($template, $session, $t_params) =  C4::AR::Auth::get_template_and_user ({
            template_name       => '/adquisiciones/datosRecomendacion.tmpl',
            query               => $input,
            type                => "intranet",
            authnotrequired     => 0,
            flagsrequired       => { ui => 'ANY', tipo_documento => 'ANY', accion => 'MODIFICAR', entorno => 'adquisiciones'},
        });   
           
        my $recomendaciones             = C4::AR::Recomendaciones::getRecomendacionDetallePorId($id_recomendacion);
        
        $t_params->{'recomendaciones'}  = $recomendaciones;
    }
    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
}
