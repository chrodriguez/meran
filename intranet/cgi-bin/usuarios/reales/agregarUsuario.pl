#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Context;
use CGI;


my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                                                                    template_name => "usuarios/reales/agregarUsuario.tmpl",
                                                                    query => $input,
                                                                    type => "intranet",
                                                                    authnotrequired => 0,
                                                                    flagsrequired => {borrowers => 1},
                                                                    debug => 1,
                });

my $comboDeCategorias= &C4::AR::Utilidades::generarComboCategoriasDeSocio();
my $comboDeTipoDeDoc= &C4::AR::Utilidades::generarComboTipoDeDoc();
my $comboDeUI= &C4::AR::Utilidades::generarComboUI();

$t_params->{'combo_tipo_documento'}= $comboDeTipoDeDoc;
$t_params->{'comboDeCategorias'}= $comboDeCategorias;
$t_params->{'comboDeUI'}= $comboDeUI;
$t_params->{'addBorrower'}= 1;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
