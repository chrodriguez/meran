#!/usr/bin/perl


use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Utilidades;

my $input = new CGI;

my ($template, $session, $t_params, $cookie) = get_template_and_user({
								template_name => "reports/availabilityResult.tmpl",
								query => $input,
								type => "intranet",
								authnotrequired => 0,
								flagsrequired => {borrowers => 1},
								debug => 1,
			    });

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));

my $orden = $obj->{'orden'}||'date';
my $ini =$obj->{'ini'};
my $funcion=$obj->{'funcion'};
my $ui = $obj->{'ui'};
my $avail=$obj->{'avail'}||1;
my $fechaIni=$obj->{'fechaIni'};
my $fechaFin=$obj->{'fechaFin'};

#Inicializo el inicio y fin de la instruccion LIMIT en la consulta
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);
#FIN inicializacion
my ($cantidad, @resultsdata)= C4::AR::Estadisticas::disponibilidad($ui,$orden,$avail,$fechaIni,$fechaFin,$ini,$cantR);

$t_params->{'paginador'}= C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);

my $availD;
if ($avail eq 0){
	$availD='Disponible';
}
else{
	my $av=C4::AR::Busquedas::getAvail($avail);
	if ($av){$availD=$av->{'description'};}
}

$t_params->{'resultsloop'}= \@resultsdata;
$t_params->{'cantidad'}= $cantidad;
$t_params->{'ui'}= $ui;
$t_params->{'orden'}= $orden;
$t_params->{'avail'}= $avail;
$t_params->{'availD'}= $availD;
$t_params->{'fechaIni'}= $fechaIni;
$t_params->{'fechaFin'}= $fechaFin;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session, $cookie);
