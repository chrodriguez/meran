#!/usr/bin/perl

use strict;
use CGI;
use C4::Output;
use C4::AR::Auth;

use HTML::Template;
use C4::AR::Estantes;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user ({
                                        template_name   => 'opac-estante.tmpl',
                                        query       => $input,
                                        type => "opac",
                                        authnotrequired => 1,
                                        flagsrequired => {  ui => 'ANY', 
                                                            tipo_documento => 'ANY', 
                                                            accion => 'CONSULTA', 
                                                            entorno => 'undefined'},
                                        debug => 1,
                 });

my $estantes_publicos = C4::AR::Estantes::getListaEstantesPublicos();
$t_params->{'cant_estantes'}= @$estantes_publicos;
$t_params->{'ESTANTES'}= $estantes_publicos;

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);