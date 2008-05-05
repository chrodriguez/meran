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

my $theme = $input->param('theme') || "default";
my $campoIso = $input->param('code') || ""; 
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

#Inicializo avail
my $avail;
if ($input->param('avail') eq ""){
         $avail=1}
else {$avail=$input->param('avail')};
#fin

#Fechas
my $ini='';
my $fin='';
if($input->param('ini')){$ini=$input->param('ini');}
if($input->param('fin')){$fin=$input->param('fin');}

#Inicializo el inicio y fin de la instruccion LIMIT en la consulta
my $iniPag;
my $pageNumber;
my $cantR=cantidadRenglones();

if (($input->param('iniPag') eq "")){
        $iniPag=0;
	$pageNumber=1;
} else {
	$iniPag= ($input->param('iniPag')-1)* $cantR;
	$pageNumber= $input->param('iniPag');
};
#FIN inicializacion


my $fechaInicio = C4::Date::format_date_in_iso($ini);
my $fechaFin = C4::Date::format_date_in_iso($fin);
#obtengo el Historico de los Prestamos, esta en C4::AR::Estadisticas
my ($cantidad,@resultsdata)= C4::AR::Estadisticas::historicoPrestamos($orden,$fechaInicio,$fechaFin,$tipoItem,$tipoPrestamo,$catUsuarios);

my @numeros=armarPaginas($cantidad,$pageNumber);
my $paginas = scalar(@numeros)||1;
my $pagActual = $input->param('iniPag')||1;
$template->param( paginas   => $paginas,
		  actual    => $pagActual,
		  );

if ( $cantidad > $cantR ){#Para ver si tengo que poner la flecha de siguiente pagina o la de anterior
        my $sig = $pageNumber+1;
        if ($sig <= $paginas){
                 $template->param(
                                ok    =>'1',
                                sig   => $sig);
        };
        if ($sig > 2 ){
                my $ant = $pageNumber-1;
                $template->param(
                                ok2     => '1',
                                ant     => $ant)}
}


my $availD;
if ($avail eq 0){$availD='Disponible';}else{	my $av=getAvail($avail);
						if ($av){$availD=$av->{'description'};}
						}

$template->param( 
			resultsloop      => \@resultsdata,
			tipoItem	 => $tipoItem,
			tipoPrestamo	 => $tipoPrestamo,
			catUsuarios	 => $catUsuarios,
			orden 		 => $orden, 
			pageNumber	 => $pageNumber,
			cantR		 => $cantR,
			paginas          => $paginas,
			cantidad	 => $cantidad,
			numeros		 => \@numeros,
			ini 		 => $ini,
			fin		 => $fin		
		);


output_html_with_http_headers $input, $cookie, $template->output;
