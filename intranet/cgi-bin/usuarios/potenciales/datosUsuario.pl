#!/usr/bin/perl

# use strict;
use C4::Auth;
use CGI;

my $input=new CGI;

my ($template, $session, $t_params) =  C4::Auth::get_template_and_user ({
			                    template_name	=> 'usuarios/potenciales/datosUsuario.tmpl',
			                    query		=> $input,
			                    type		=> "intranet",
			                    authnotrequired	=> 0,
			                    flagsrequired	=> { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
                    });


# FIXME en el cliente, siempre queda PERSONA para que se entienda, pero aca no es más que un socio DESHABILITADO
my $nro_socio= $input->param('nro_socio');
my $mensaje=$input->param('mensaje');#Mensaje que viene desde libreDeuda si es que no se puede imprimir

$t_params->{'nro_socio'}= $nro_socio;

C4::AR::Validator::validateParams('U389',$t_params,['nro_socio'] );

my $socio=C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);

$t_params->{'socio'}= $socio;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);