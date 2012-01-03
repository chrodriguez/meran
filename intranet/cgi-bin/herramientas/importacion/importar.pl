#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::AR::Auth;
use CGI;

my $query = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
                                    template_name => "/herramientas/importacion/importar.tmpl",
                                    query => $query,
                                    type => "intranet",
                                    authnotrequired => 0,
                                    flagsrequired => {  ui => 'ANY',
                                                        tipo_documento => 'ANY',
                                                        accion => 'ALTA',
                                                        entorno => 'undefined'},
                                    debug => 1,
            });
$t_params->{'combo_formatos'}          = C4::AR::Utilidades::generarComboFormatosImportacion();
$t_params->{'combo_esquemas'}          = C4::AR::Utilidades::generarComboEsquemasImportacion();

C4::AR::Auth::output_html_with_http_headers($template, $t_params,$session);
