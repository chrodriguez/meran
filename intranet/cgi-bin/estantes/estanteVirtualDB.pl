#!/usr/bin/perl

use strict;
use CGI;
use C4::BookShelves;
use C4::Auth;
use C4::Interface::CGI::Output;

my $input=new CGI;

my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);
my $tipo= $obj->{'tipo'};


if($tipo eq "VER_ESTANTE"){

	my ($template, $session, $t_params)
	= get_template_and_user({template_name => "verEstanteVirtual.tmpl",
					query => $input,
					type => "intranet",
					authnotrequired => 0,
					flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
					});

	
	my $shelves= $obj->{'shelves'};
	my $funcion= $obj->{'funcion'};
	my $orden=$obj->{'orden'}||'title';
	my $ini= $obj->{'ini'}||'';
	
	my ($ini,$pageNumber,$cantR)= &C4::AR::Utilidades::InitPaginador($ini);
	
	my ($cantidad, @shelvesloop)= C4::BookShelves::viewshelf($shelves,$ini,$cantR);
	
	$t_params{'paginador'}= &C4::AR::Utilidades::crearPaginador($template, $cantidad, $cantR, $pageNumber,$funcion,$t_params);
	
	$t_params->{'shelvesloopshelves'}= @shelvesloop;
    $t_params->{'pagetitle'}= "Estantes Virtuales";
    $t_params->{'shelves'}=> 1;

    C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}


if($tipo eq "VER_SUBESTANTE"){

	my ($template, $session, $t_params)
	= get_template_and_user({template_name => "verSubEstanteVirtual.tmpl",
					query => $input,
					type => "intranet",
					authnotrequired => 0,
					flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
					});
	
	my $shelves= $obj->{'shelves'};
	my $funcion= $obj->{'funcion'};
	my $orden=$obj->{'orden'}||'title';
	my $ini= $obj->{'ini'}||'';
	
	my ($ini,$pageNumber,$cantR)= &C4::AR::Utilidades::InitPaginador($ini);
	
	my ($cantidad, @shelvesloop)= C4::BookShelves::viewshelfContent($shelves,$ini,$cantR,$orden);
	
	$t_params{'paginador'}= &C4::AR::Utilidades::crearPaginador($template, $cantidad, $cantR, $pageNumber,$funcion,$t_params);
	
	$t_params{'bitemsloop'}= @shelvesloop;
    $t_params{'pagetitle'}= "Estantes Virtuales";
    $t_params{'shelves'}= 1;
	
	C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}