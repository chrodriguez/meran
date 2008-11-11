#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use Template;
use CGI;


my $input = Template->new({ 	INCLUDE_PATH => ['/usr/local/koha/intranet/htdocs/intranet-tmpl/blue/es2/usuarios/reales','/usr/local/koha/intranet/htdocs/intranet-tmpl/blue/es2/includes/','/usr/local/koha/intranet/htdocs/intranet-tmpl/blue/es2/includes/menu/'],
				ABSOLUTE => 1,

			  });

my $template = "agregarUsuario.tmpl";

my $comboDeCategorias= &C4::AR::Utilidades::generarComboCategorias();

my $comboDeTipoDeDoc= &C4::AR::Utilidades::generarComboTipoDeDoc();

my $comboDeBranches= &C4::AR::Utilidades::generarComboDeBranches();

my $param = {	
		'document'    => $comboDeTipoDeDoc,
		'catcodepopup'	=> $comboDeCategorias,
		'CGIbranch' 	=> $comboDeBranches,
		'addBorrower'	=> 1,
		'type' => "intranet",
		'cgi' =>CGI->new,
		'authnotrequired' => 0,
		'flagsrequired' => {borrowers => 1},
		'debug' => 1,
		'top' => "intranet-top.inc",
		'menuInc' => "menu.inc",
		'themelang' => '/intranet-tmpl/blue/es2/',
	};

print "Content-type: text/html\n\n";

$input->process($template,$param) || die "Template process failed: ", $input->error(), "\n";
