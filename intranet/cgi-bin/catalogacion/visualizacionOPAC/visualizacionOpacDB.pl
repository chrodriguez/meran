#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::VisualizacionOpac;
use C4::AR::Utilidades;
use JSON;

my $input = new CGI;
my $obj=$input->param('obj');

$obj=C4::AR::Utilidades::from_json_ISO($obj);

#tipoAccion = Insert, Update, Select
my $tipoAccion= $obj->{'tipoAccion'} || "";
my $componente= $obj->{'componente'} || "";
my $perfil= $obj->{'perfil'} || "";
my $result;
my %infoRespuesta;
my $authnotrequired = 0;

#************************* para cargar la tabla de encabezados*************************************
if($tipoAccion eq "MOSTRAR_VISUALIZACION"){

	my ($template, $session, $t_params) = get_template_and_user({
		                template_name => "catalogacion/visualizacionOPAC/detalleVisualizacionOpac.tmpl",
		                query => $input,
		                type => "intranet",
		                authnotrequired => 0,
		                flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
		                debug => 1,
	});

    $t_params->{'visualizacion'} = C4::AR::VisualizacionOpac::getConfiguracion($perfil);
    $t_params->{'selectCampoX'} = C4::AR::Utilidades::generarComboCampoX('eleccionCampoX()');

	C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}
elsif($tipoAccion eq "AGREGAR_VISUALIZACION"){

    my ($template, $session, $t_params) = get_template_and_user({
                        template_name => "catalogacion/visualizacionOPAC/detalleVisualizacionOpac.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                        debug => 1,
    });

    my ($messages) = C4::AR::VisualizacionOpac::addConfiguracion($obj);
    $t_params->{'visualizacion'} = C4::AR::VisualizacionOpac::getConfiguracion($perfil);

    C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}
#**************************************************************************************************


