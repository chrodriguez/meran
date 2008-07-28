#!/usr/bin/perl


use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Utilidades;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/availabilityResult.tmpl",
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

my $branch = $obj->{'branch'};
my $avail=$obj->{'avail'}||1;
my $fechaIni=$obj->{'fechaIni'};
my $fechaFin=$obj->{'fechaFin'};

#Inicializo el inicio y fin de la instruccion LIMIT en la consulta
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);
#FIN inicializacion
my ($cantidad, @resultsdata)= C4::AR::Estadisticas::disponibilidad($branch,$orden,$avail,$fechaIni,$fechaFin,$ini,$cantR);

C4::AR::Utilidades::crearPaginador($template, $cantidad,$cantR, $pageNumber,$funcion);

my $availD;
if ($avail eq 0){
	$availD='Disponible';
}
else{
	my $av=C4::AR::Busquedas::getAvail($avail);
	if ($av){$availD=$av->{'description'};}
}

$template->param( 
			resultsloop      => \@resultsdata,
			cantidad	 => $cantidad,
			branch           => $branch,
			orden 		 => $orden,
			avail		 => $avail,
			availD		 => $availD,
			fechaIni	 => $fechaIni,
			fechaFin	 => $fechaFin,
		);

output_html_with_http_headers $input, $cookie, $template->output;
