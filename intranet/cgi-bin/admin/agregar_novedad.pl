#!/usr/bin/perl

use strict;
use C4::Auth;
use CGI;
use C4::AR::Novedades;
my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
									template_name => "admin/agregar_novedad.tmpl",
									query => $input,
									type => "intranet",
									authnotrequired => 0,
									flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
									debug => 1,
			    });

my $action = $input->param('action') || 0;

if ($action){
    my $status = C4::AR::Novedades::agregar($input);
    if ($status){
        C4::Auth::redirectTo('/cgi-bin/koha/admin/novedades_opac.pl?token'.$input->param('token'));
    }
}


C4::Auth::output_html_with_http_headers($template, $t_params, $session);