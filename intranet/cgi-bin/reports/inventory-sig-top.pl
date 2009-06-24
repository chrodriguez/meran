#!/usr/bin/perl

#Genera un inventario a partir de la busqueda por signatura topografica



use strict;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use HTML::Template;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                        template_name => "reports/inventory-sig-top.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                        debug => 1,
			    });

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
