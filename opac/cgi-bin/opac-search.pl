#!/usr/bin/perl
use strict;
require Exporter;

use C4::Auth;

use C4::Context;
use CGI;

my $query = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
						template_name => "opac-search.tmpl",
						query => $query,
						type => "opac",
						authnotrequired => 1,
						flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
             });


my %params_combo;
$params_combo{'id'}= 'id_tipo_documento';
my $comboTipoNivel3Fijo= &C4::AR::Utilidades::generarComboTipoNivel3(\%params_combo);
$t_params->{'comboTipoDocumento'}= $comboTipoNivel3Fijo;


my $virtuallibrary=C4::AR::Preferencias->getValorPreferencia("virtuallibrary");

$t_params->{'virtuallibrary'}= $virtuallibrary;
$t_params->{'pagetitle'}= "Buscar bibliograf&iacute;a";
$t_params->{'LibraryName'}= C4::AR::Preferencias->getValorPreferencia("LibraryName");
$t_params->{'hiddesearch'}= 1;

C4::Auth::output_html_with_http_headers($template, $t_params, $session);
