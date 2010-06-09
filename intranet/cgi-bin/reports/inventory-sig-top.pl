#!/usr/bin/perl

use strict;
use C4::Auth;
use CGI;

#Genera un inventario a partir de la busqueda por signatura topografica

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                        template_name   => "reports/inventory-sig-top.tmpl",
                        query           => $input,
                        type            => "intranet",
                        authnotrequired => 0,
                        flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                        debug           => 1,
			    });


my ($signatura_min, $signatura_max) = C4::AR::Estadisticas::getMinYMaxSignaturaTopografica();
$t_params->{'signatura_min'}        = $signatura_min;
$t_params->{'signatura_max'}        = $signatura_max;

my ($barcode_min, $barcode_max)     = C4::AR::Estadisticas::getMinYMaxBarcode();
$t_params->{'barcode_min'}          = $barcode_min;
$t_params->{'barcode_max'}          = $barcode_max;
$t_params->{'page_sub_title'}       = C4::AR::Filtros::i18n("Signatura topografica");

C4::Auth::output_html_with_http_headers($template, $t_params, $session);
