#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;


my $input = new CGI;

my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "searchcity.tmpl",
                                query => $input,
                                type => "opac",
                                authnotrequired => 0,
                                flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                                debug => 1,
                                });


my $ciudad = $input->param("ciudad");
if ($ciudad){
$template->param(
		ciudades => C4::AR::Utilidades::buscarCiudades($ciudad),
		);
	}

output_html_with_http_headers $cookie, $template->output;
