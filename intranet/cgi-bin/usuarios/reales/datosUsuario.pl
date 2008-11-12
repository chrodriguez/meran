#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use Template;
my $input = new CGI;

my $bornum=$input->param('bornum');
my $completo=$input->param('completo');
my $mensaje=$input->param('mensaje');#Mensaje que viene desde libreDeuda si es que no se puede imprimir


my $template = Template->new({ 	INCLUDE_PATH => ['/usr/local/koha/intranet/htdocs/intranet-tmpl/blue/es2/usuarios/reales','/usr/local/koha/intranet/htdocs/intranet-tmpl/blue/es2/includes/','/usr/local/koha/intranet/htdocs/intranet-tmpl/blue/es2/includes/menu/'],
				ABSOLUTE => 1,

			  });

my $templateName = "datosUsuario.tmpl";



my $param = {
			'bornum'          => $bornum,
			'completo'	=> $completo,
			'top' => "intranet-top.inc",
			'menuInc' => "menu.inc",
			'themelang' => '/intranet-tmpl/blue/es2/',
	};

print "Content-type: text/html\n\n";

$template->process($templateName,$param) || die "Template process failed: ", $template->error(), "\n";