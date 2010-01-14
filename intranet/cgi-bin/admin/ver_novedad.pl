#!/usr/bin/perl

use strict;
use C4::Auth;
use CGI;
use C4::AR::Novedades;
my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
									template_name => "admin/ver_novedad.tmpl",
									query => $input,
									type => "intranet",
									authnotrequired => 0,
									flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
									debug => 1,
			    });
my ($id_novedad) = $input->param('id');
my ($novedad) = C4::AR::Novedades::getNovedad($id_novedad);
$t_params->{'novedad'} = $novedad;

C4::Auth::output_html_with_http_headers($template, $t_params, $session);