#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;
# use C4::Output;
# 
use C4::AR::Utilidades;
use HTML::Template;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user ({
                                template_name   => 'usuarios/reales/settings.tmpl',
                                query           => $input,
                                type            => "intranet",
                                authnotrequired => 0,
                                flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'sistema'},
                        });

#combo itemtype

$t_params->{'languages'} = C4::AR::Filtros::getComboLang();
C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);