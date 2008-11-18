#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use Template;
use CGI;


my $input = new CGI;

my ($template, $session, $params) = get_template_and_user({
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

$params->{'document'}= $comboDeTipoDeDoc;
$params->{'catcodepopup'}=$comboDeCategorias;
$params->{'CGIbranch'}= $comboDeBranches;
$params->{'addBorrower'}= 1;
$params->{'type'}= "intranet";
$params->{'cgi'}=new CGI;
$params->{'authnotrequired'}= 0;
$params->{'flagsrequired'}= {borrowers => 1};
$params->{'debug'}= 1;
$params->{'top'}= "intranet-top.inc";
$params->{'menuInc'}= "menu.inc";
$params->{'themelang'}= '/intranet-tmpl/blue/es2/';

C4::Auth::output_html_with_http_headers($input, $template, $params);
