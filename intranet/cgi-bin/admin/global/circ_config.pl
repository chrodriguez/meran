#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;
use C4::Context;

my $input = new CGI;

my ($template, $session, $t_params, $socio)  = get_template_and_user({
                            template_name => "admin/global/circConfig.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {  ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'CONSULTA', 
                                                entorno => 'undefined'},
                            debug => 1,
                 });

#my $preferencias_circulacion  = C4::AR::Preferencias::getPreferenciasByCategoria('circulacion');
#$t_params->{'preferencias'}   = $preferencias_circulacion;

$t_params->{'page_sub_title'} = C4::AR::Filtros::i18n("Configuraci&oacute;n Circulaci&oacute;n");
C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
