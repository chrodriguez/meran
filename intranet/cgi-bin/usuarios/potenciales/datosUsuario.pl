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


my $id_persona= $input->param('id_persona');
my $mensaje=$input->param('mensaje');#Mensaje que viene desde libreDeuda si es que no se puede imprimir

my $persona=C4::AR::Usuarios::getPersonaInfo($id_persona);
$t_params->{'id_persona'}= $id_persona;
$t_params->{'persona'}= $persona;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session, $cookie);