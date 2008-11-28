#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Estadisticas;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/logueoBusquedaResult.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);
#Fechas
my $fechaIni=$obj->{'fechaIni'};
my $fechaFin=$obj->{'fechaFin'};
my $catUsuarios=$obj->{'catUsuarios'}||"SIN SELECCIONAR";
my $orden= $obj->{'orden'}||'surname';
my $funcion=$obj->{'funcion'};

my $ini= $obj->{'ini'};
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);
#historial de busquedas desde OPAC
my ($cantidad, @resultsdata)= &historicoDeBusqueda($ini,$cantR,$fechaIni,$fechaFin,$catUsuarios,$orden);
C4::AR::Utilidades::crearPaginador($template, $cantidad,$cantR, $pageNumber,$funcion,$t_params);



$template->param( 	resultsloop      => \@resultsdata,
			fechaIni	=> $fechaIni,
			fechaFin 	=> $fechaFin,
			catUsuarios	=> $catUsuarios,
		);

output_html_with_http_headers $input, $cookie, $template->output;
