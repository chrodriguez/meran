#!/usr/bin/perl

use strict;
use C4::Auth;
use CGI;

my $input=new CGI;

my ($template, $session, $t_params) =  C4::Auth::get_template_and_user ({
			template_name	=> 'usuarios/reales/datosUsuario.tmpl',
			query		=> $input,
			type		=> "intranet",
			authnotrequired	=> 0,
			flagsrequired	=> { circulate => 1 },
    });


my $id_socio= $input->param('id_socio');
my $mensaje=$input->param('mensaje');#Mensaje que viene desde libreDeuda si es que no se puede imprimir

my $socio= C4::AR::Usuarios::getSocioInfo($id_socio);

$t_params->{'nro_socio'}= $socio->getNro_socio;
$t_params->{'id_socio'}= $id_socio;
$t_params->{'completo'} = $socio->persona->getApellido.', '.$socio->persona->getNombre;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);