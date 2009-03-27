#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::AR::Utilidades;
use HTML::Template;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user ({
                                                            template_name	=> 'busquedas/filtrado.tmpl',
                                                            query		=> $input,
                                                            type		=> "intranet",
                                                            authnotrequired	=> 0,
                                                            flagsrequired	=> { circulate => 1 },
    					});

#combo itemtype
my %params_combo;
$params_combo{'default'}= 'SIN SELECCIONAR';
my $comboTiposNivel3= &C4::AR::Utilidades::generarComboTipoNivel3(\%params_combo);
$t_params->{'comboTipoDocumento'}= $comboTiposNivel3;
$t_params->{'type'}= 'intranet';


C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
