#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use Template;
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

my $comboDeCategorias= &C4::AR::Utilidades::generarComboCategorias();

my $comboDeTipoDeDoc= &C4::AR::Utilidades::generarComboTipoDeDoc();

my $comboDeBranches= &C4::AR::Utilidades::generarComboDeBranches();

$t_params->{'document'}= $comboDeTipoDeDoc;
$t_params->{'catcodepopup'}=$comboDeCategorias;
$t_params->{'CGIbranch'}= $comboDeBranches;
$t_params->{'addBorrower'}= 1;
$t_params->{'type'}= "intranet";
$t_params->{'cgi'}=new CGI;
$t_params->{'authnotrequired'}= 0;
$t_params->{'flagsrequired'}= {borrowers => 1};
$t_params->{'debug'}= 1;
$t_params->{'top'}= "intranet-top.inc";
$t_params->{'menuInc'}= "menu.inc";
$t_params->{'themelang'}= '/intranet-tmpl/blue/es2/';

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
