#!/usr/bin/perl

# use strict;
use C4::AR::Auth;
use C4::AR::Utilidades;
use CGI;

my $input = new CGI;

my $combo_recomendaciones = &C4::AR::Utilidades::generarComboRecomendaciones();

my ($template, $session, $t_params)= get_template_and_user({
                                template_name => "adquisiciones/compararPresupuestos.tmpl",
                                query => $input,
                                type => "intranet",
                                authnotrequired => 0,
                                flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},# revisar el entorno
                                debug => 1,
                 });

$t_params->{'combo_recomendaciones'} = $combo_recomendaciones;


C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);