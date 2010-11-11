#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Modelo::AdqProveedor;
use CGI;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                                    template_name => "adquisiciones/listProveedores.tmpl",
                                    query => $input,
                                    type => "intranet",
                                    authnotrequired => 0,
                                    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
                                    debug => 1,
                });


$t_params->{'page_sub_title'}=C4::AR::Filtros::i18n("B&uacute;squeda de Proveedores");

C4::Auth::output_html_with_http_headers($template, $t_params, $session);

1;