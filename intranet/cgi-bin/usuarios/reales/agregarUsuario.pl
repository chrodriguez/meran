#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use CGI;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                    template_name   => "usuarios/reales/agregarUsuario.tmpl",
                    query           => $input,
                    type            => "intranet",
                    authnotrequired => 0,
                    flagsrequired   => {    ui => 'ANY', 
                                            tipo_documento => 'ANY', 
                                            accion => 'ALTA', 
                                            entorno => 'usuarios'},
                    debug           => 1,
                });

my $comboDeCategorias           = &C4::AR::Utilidades::generarComboCategoriasDeSocio();
my $comboDeTipoDeDoc            = &C4::AR::Utilidades::generarComboTipoDeDoc();
my $comboDeUI                   = &C4::AR::Utilidades::generarComboUI();
my $comboDeCredentials          = &C4::AR::Utilidades::generarComboDeCredentials();

$t_params->{'combo_temas'}          = C4::AR::Utilidades::generarComboTemasINTRA();
$t_params->{'combo_tipo_documento'} = $comboDeTipoDeDoc;
$t_params->{'comboDeCategorias'}    = $comboDeCategorias;
$t_params->{'comboDeCredentials'}   = $comboDeCredentials;
$t_params->{'comboDeUI'}            = $comboDeUI;
$t_params->{'addBorrower'}          = 1;

$t_params->{'page_sub_title'}   = C4::AR::Filtros::i18n("Agregar Usuario");
C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
