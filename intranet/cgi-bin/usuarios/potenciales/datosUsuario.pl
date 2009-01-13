#!/usr/bin/perl

# use strict;
use C4::Auth;
use CGI;

my $input=new CGI;

my ($template, $session, $t_params, $cookie) =  C4::Auth::get_template_and_user ({
			                                                                        template_name	=> 'usuarios/potenciales/datosUsuario.tmpl',
			                                                                        query		=> $input,
			                                                                        type		=> "intranet",
			                                                                        authnotrequired	=> 0,
			                                                                        flagsrequired	=> { circulate => 1 },
    });


# FIXME en el cliente, siempre queda PERSONA para que se entienda, pero aca no es más que un socio DESHABILITADO
my $id_socio= $input->param('id_socio');
my $mensaje=$input->param('mensaje');#Mensaje que viene desde libreDeuda si es que no se puede imprimir

my $socio=C4::AR::Usuarios::getSocioInfo($id_socio);
$t_params->{'id_socio'}= $id_socio;
$t_params->{'socio'}= $socio;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session, $cookie);