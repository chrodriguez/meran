#!/usr/bin/perl

use strict;
use CGI;
use C4::Output;
use C4::Auth;
use C4::Interface::CGI::Output;
use HTML::Template;
use C4::AR::Estantes;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user ({
                                        template_name   => 'estantes/estante.tmpl',
                                        query       => $input,
                                        type        => "intranet",
                                        authnotrequired => 0,
                                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                                        debug => 1,
                 });

my $obj=$input->param('obj');
if($obj ne ""){	$obj=C4::AR::Utilidades::from_json_ISO($obj); }

my $estantes_publicos = C4::AR::Estantes::getListaEstantesPublicos();
$t_params->{'ESTANTES'}= $estantes_publicos;

C4::Auth::output_html_with_http_headers($template, $t_params, $session);