#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use C4::Context;
use C4::AR::Proveedores;
use C4::AR::Recomendaciones;
use CGI;
#use C4::AR::PdfGenerator;

my $input = new CGI;
my $to_pdf = $input->param('export') || 0;

my ($template, $session, $t_params) = get_template_and_user({
    template_name => "adquisiciones/pedidosCotizacion.tmpl",
    query => $input,
    type => "intranet",
    authnotrequired => 0,
    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'ALTA', entorno => 'usuarios'},
    debug => 1,
});

my $combo_proveedores         = &C4::AR::Utilidades::generarComboProveedoresMultiple();

$t_params->{'combo_proveedores'}             = $combo_proveedores;

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
