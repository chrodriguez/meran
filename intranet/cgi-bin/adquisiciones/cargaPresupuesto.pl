#!/usr/bin/perl

# use strict;
use C4::Auth;
use CGI;
use C4::AR::Proveedores;


my $input = new CGI;

my $combo_proveedores = &C4::AR::Utilidades::generarComboProveedores();

my ($template, $session, $t_params)= get_template_and_user({
                                template_name => "adquisiciones/cargaPresupuesto.tmpl",
                                query => $input,
                                type => "intranet",
                                authnotrequired => 0,
                                flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},# revisar el entorno
                                debug => 1,
                 });


$t_params->{'combo_proveedores'} = $combo_proveedores;

C4::Auth::output_html_with_http_headers($template, $t_params, $session);