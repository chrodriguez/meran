#!/usr/bin/perl

use strict;
use C4::AR::Auth;

use CGI;
use C4::AR::Utilidades;
use C4::AR::Busquedas;

my $input = new CGI;

my ($template, $session, $t_params, $cookie) = get_template_and_user({
								template_name => "reports/reservas.tmpl",
								query => $input,
								type => "intranet",
								authnotrequired => 0,
								flagsrequired => {  ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'CONSULTA', 
                                                    entorno => 'undefined'},
								debug => 1,
			    });



my $ComboUI=C4::AR::Utilidades::generarComboUI();

$t_params->{'unidades'}= $ComboUI;

$t_params->{'page_sub_title'} = C4::AR::Filtros::i18n("Reservas");

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session, $cookie);
