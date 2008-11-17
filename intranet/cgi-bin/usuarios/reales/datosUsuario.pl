#!/usr/bin/perl

use strict;
use C4::Auth;
use CGI;

my $input=new CGI;

my ($template, $session, $params) =  C4::Auth::get_template_and_user ({
			template_name	=> 'usuarios/reales/datosUsuario.tmpl',
			query		=> $input,
			type		=> "intranet",
			authnotrequired	=> 0,
			flagsrequired	=> { circulate => 1 },
    });



my $bornum=$input->param('bornum');
my $completo=$input->param('completo');
my $mensaje=$input->param('mensaje');#Mensaje que viene desde libreDeuda si es que no se puede imprimir


$params->{'bornum'}= $bornum;

$params->{'completo'} = $completo;


C4::Auth::output_html_with_http_headers($input, $template, $params);