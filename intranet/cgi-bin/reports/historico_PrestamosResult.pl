#!/usr/bin/perl

# Miguel 21-05-07
# Se obtiene un Historial de los prestamos realizados por los usuarios

use strict;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use C4::Search;
use HTML::Template;
use C4::AR::Estadisticas;
use C4::AR::Utilidades;
use C4::Koha;


my $input = new CGI;

#Obtengo el Tipo de Item para filtrar

my $tipoItem = $input->param('tiposItems');
my $tipoPrestamo = $input->param('tipoPrestamos');
my $catUsuarios = $input->param('catUsuarios');
 
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/historico_PrestamosResult.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });



my $orden;
if ($input->param('orden') eq ""){
	 $orden='firstname'}
else {$orden=$input->param('orden')};


#Fechas
my $f_ini='';
my $f_fin='';
if($input->param('f_ini')){$f_ini=$input->param('f_ini');}
if($input->param('f_fin')){$f_fin=$input->param('f_fin');}

my $ini= ($input->param('ini'));
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

my $dateformat = C4::Date::get_date_format();
my $fechaIni = C4::Date::format_date_in_iso($f_ini,$dateformat);
my $fechaFin = C4::Date::format_date_in_iso($f_fin,$dateformat);
#obtengo el Historico de los Prestamos, esta en C4::AR::Estadisticas
my ($cantidad,@resultsdata)= C4::AR::Estadisticas::historicoPrestamos($orden,$ini,$cantR,$fechaIni,$fechaFin,$tipoItem,$tipoPrestamo,$catUsuarios);

my ($template, $ini)=C4::AR::Utilidades::crearPaginador($template, $cantidad,$cantR, $pageNumber,"consultar");


$template->param( 
			resultsloop      => \@resultsdata,
			tipoItem	 => $tipoItem,
			tipoPrestamo	 => $tipoPrestamo,
			catUsuarios	 => $catUsuarios,
			orden 		 => $orden, 
			cantidad	 => $cantidad,
			fechaIni	 => $fechaIni,
			fechaFin 	 => $fechaFin,	
		);


output_html_with_http_headers $input, $cookie, $template->output;
