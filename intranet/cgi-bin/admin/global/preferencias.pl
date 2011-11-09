#!/usr/bin/perl

use strict;
use C4::AR::Auth;

use CGI;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
						template_name => "admin/global/preferencias.tmpl",
						query => $input,
						type => "intranet",
						authnotrequired => 0,
						flagsrequired => {  ui => 'ANY', 
                                            tipo_documento => 'ANY', 
                                            accion => 'CONSULTA', 
                                            entorno => 'preferencias',
						                    tipo_permiso => 'general'
						},
						debug => 1,
			    });

$t_params->{'page_sub_title'}=C4::AR::Filtros::i18n("Preferencias del sistema ");

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
