#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use CGI;
use C4::AR::ImportacionXML;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                                    template_name   => "catalogacion/visualizacionOPAC/visualizacionOpac.tmpl",
                                    query           => $input,
                                    type            => "intranet",
                                    authnotrequired => 0,
                                    flagsrequired   => {  ui    => 'ANY', 
                                                        accion  => 'CONSULTA', 
                                                        entorno => 'undefined'},
                                    debug => 1,
                });

my $obj     = $input->Vars; 

my $accion  = $obj->{'tipoAccion'} || undef;

if ($accion eq "IMPORT"){

    C4::AR::Debug::debug("antessss");
    my $msg_object  = C4::AR::ImportacionXML::importarVisualizacion($obj,$input->upload('fileImported'));

    my $codMsg      = C4::AR::Mensajes::getFirstCodeError($msg_object);
    
    $t_params->{'mensaje'} = C4::AR::Mensajes::getMensaje($codMsg,'INTRA');

    if (C4::AR::Mensajes::hayError($msg_object)){
        $t_params->{'mensaje_class'} = "alert-error";
    }else{
        $t_params->{'mensaje_class'} = "alert-success";
    }
}

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);