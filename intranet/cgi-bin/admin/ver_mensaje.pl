#!/usr/bin/perl

use strict;
use C4::Auth;
use CGI;
use C4::AR::MensajesContacto;
my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
									template_name => "admin/ver_mensaje.tmpl",
									query => $input,
									type => "intranet",
									authnotrequired => 0,
									flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
									debug => 1,
			    });
my ($id_mensaje) = $input->param('id');
my ($mensaje) = C4::AR::MensajesContacto::ver($id_mensaje);
$t_params->{'mensaje'} = $mensaje;

C4::Auth::output_html_with_http_headers($template, $t_params, $session);