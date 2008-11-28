#!/usr/bin/perl

use strict;
use CGI;
use C4::BookShelves;
use C4::Auth;
use C4::Interface::CGI::Output;

my $input=new CGI;

my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{borrow => 1});
my $borrowernumber=getborrowernumber($loggedinuser);

my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);
my $tipo= $obj->{'tipo'};


if($tipo eq "VER_ESTANTE"){

	my ($template, $loggedinuser, $cookie)
	= get_template_and_user({template_name => "opac-verEstanteVirtual.tmpl",
					query => $input,
					type => "opac",
					authnotrequired => 1,
	# 				debug => 1,
					});
	
	my $shelves= $obj->{'shelves'};
	my $funcion= $obj->{'funcion'};
	my $orden=$obj->{'orden'}||'title';
	my $ini= $obj->{'ini'}||'';
	
	my ($ini,$pageNumber,$cantR)= &C4::AR::Utilidades::InitPaginador($ini);
	
	my ($cantidad, @shelvesloop)= C4::BookShelves::viewshelf($shelves,$ini,$cantR);
	
	&C4::AR::Utilidades::crearPaginador($template, $cantidad, $cantR, $pageNumber,$funcion,$t_params);
	
	$template->param(
				shelvesloopshelves => @shelvesloop,
				pagetitle => "Estantes Virtuales",
				shelves => 1,
	);
	
	# print  $template->output;
	output_html_with_http_headers $input, $cookie, $template->output;
}


if($tipo eq "VER_SUBESTANTE"){

	my ($template, $loggedinuser, $cookie)
	= get_template_and_user({template_name => "opac-verSubEstanteVirtual.tmpl",
					query => $input,
					type => "opac",
					authnotrequired => 1,
	# 				debug => 1,
					});
	
	my $shelves= $obj->{'shelves'};
	my $funcion= $obj->{'funcion'};
	my $orden=$obj->{'orden'}||'title';
	my $ini= $obj->{'ini'}||'';
	
	my ($ini,$pageNumber,$cantR)= &C4::AR::Utilidades::InitPaginador($ini);
	
	my ($cantidad, @shelvesloop)= C4::BookShelves::viewshelfContent($shelves,$ini,$cantR,$orden);
	
	&C4::AR::Utilidades::crearPaginador($template, $cantidad, $cantR, $pageNumber,$funcion,$t_params);
	
	$template->param(
				bitemsloop => @shelvesloop,
				pagetitle => "Estantes Virtuales",
				shelves => 1,
	);
	
	# print  $template->output;
	output_html_with_http_headers $input, $cookie, $template->output;
}
