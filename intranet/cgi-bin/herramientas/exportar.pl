#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::Auth;
use CGI;

my $query = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
									template_name => "/herramientas/exportar.tmpl",
									query => $query,
									type => "intranet",
									authnotrequired => 0,
                                    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'ALTA', entorno => 'undefined'},
									debug => 1,
			});


my %params_combo;
$params_combo{'default'}                    = C4::AR::Preferencias->getValorPreferencia("defaultTipoNivel3");
$t_params->{'combo_tipo_documento'}         = C4::AR::Utilidades::generarComboTipoNivel3(\%params_combo);

my %params_combo;
$params_combo{'default'}                    = C4::AR::Preferencias->getValorPreferencia("defaultUI");
$t_params->{'combo_ui'}                     = C4::AR::Utilidades::generarComboUI(\%params_combo);

my %params_combo;
$params_combo{'default'}                    = C4::AR::Preferencias->getValorPreferencia("defaultUI");
$t_params->{'combo_nivel_bibliogratico'}    = C4::AR::Utilidades::generarComboNivelBibliografico(\%params_combo);

C4::Auth::output_html_with_http_headers($template, $t_params,$session);
