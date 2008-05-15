#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use C4::Search;
use HTML::Template;
use C4::AR::Estadisticas;
use C4::Koha;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/logueoBusquedaResult.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });


#Fechas
my $fechaIni='';
my $fechaFin='';
my $catUsuarios="SIN SELECCIONAR";

if($input->param('fechaIni')){$fechaIni=$input->param('fechaIni');}
if($input->param('fechaFin')){$fechaFin=$input->param('fechaFin');}
if($input->param('catUsuarios')){$catUsuarios= $input->param('catUsuarios');}

#************************************ prueba de paginador *******************************************
my $ini= ($input->param('ini'));
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);
#historial de busquedas desde OPAC
my ($cantidad, @resultsdata)= &historicoDeBusqueda($ini,$cantR,$fechaIni,$fechaFin,$catUsuarios);
my ($template, $ini)=C4::AR::Utilidades::crearPaginador($template, $cantidad,$cantR, $pageNumber,"consultar");
#************************************ prueba de paginador *******************************************


$template->param( 	resultsloop      => \@resultsdata,
			fechaIni	=> $fechaIni,
			fechaFin 	=> $fechaFin,
			catUsuarios	=> $catUsuarios,
		);

output_html_with_http_headers $input, $cookie, $template->output;
