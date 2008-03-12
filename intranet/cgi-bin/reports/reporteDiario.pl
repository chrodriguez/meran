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

my $theme = $input->param('theme') || "default";
my $campoIso = $input->param('code') || ""; 
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/reporteDiario.tmpl",
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
# if($input->param('tiposPrestamo')){$catUsuarios= $input->param('catUsuarios');}
my $tipoPrestamo= $input->param('tiposPrestamos');

#Inicializo el inicio y fin de la instruccion LIMIT en la consulta
my $ini;
my $pageNumber;
my $cantR=cantidadRenglones();

if (($input->param('ini') eq "")){
        $ini=0;
	$pageNumber=1;
} else {
	$ini= ($input->param('ini')-1)* $cantR;
	$pageNumber= $input->param('ini');
};
#FIN inicializacion

# my ($cantidad, @resultsdata)= &reporteDiario($ini,$cantR,$fechaIni,$fechaFin,$catUsuarios);#historial de busquedas desde OPAC

my ($cantidad, @resultsdata)= &reporteDiario($ini,$cantR,$tipoPrestamo);

#para la zebra$tipoPrestamo
my $num= 1;
foreach my $res (@resultsdata) {
	((($num % 2) && ($res->{'clase'} = 'par' ))|| ($res->{'clase'}='impar'));
    	$num++;
}

my @numeros=armarPaginas($cantidad);
my $paginas = scalar(@numeros)||1;
my $pagActual = $input->param('ini')||1;

$template->param( paginas   => $paginas,
		  actual    => $pagActual,
		);

if ( $cantidad > $cantR ){#Para ver si tengo que poner la flecha de siguiente pagina o la de anterior
        my $sig = $pagActual+1;
        if ($sig <= $paginas){
                 $template->param(
                                ok    =>'1',
                                sig   => $sig);
        };
        if ($sig > 2 ){
                my $ant = $pagActual-1;
                $template->param(
                                ok2     => '1',
                                ant     => $ant)}
}


#*********************************Select Tipos de Prestamos*****************************************
#Miguel no se si existe una funcion q devuelva los tipos de items, si esta vuela
my $dbh= C4::Context->dbh;
	
my $query= "SELECT * FROM issuetypes ";
my $sth= $dbh->prepare($query);
$sth->execute();

my @select_tiposPrestamos_Values;
my %select_tiposPrestamos_Labels;

push @select_tiposPrestamos_Values, 'SIN SELECCIONAR';
my @result;

while (my $data=$sth->fetchrow_hashref){
	push @result, $data;
}

foreach my $tipoPrestamo (@result) {
	push @select_tiposPrestamos_Values, $tipoPrestamo->{'issuecode'};
  	$select_tiposPrestamos_Labels{$tipoPrestamo->{'issuecode'}} = $tipoPrestamo->{'description'};
}

my $CGISelectTiposPrestamos=CGI::scrolling_list(	-name      => 'tiposPrestamos',
                                        		-id        => 'tiposPrestamos',
                                        		-values    => \@select_tiposPrestamos_Values,
                                        		-labels    => \%select_tiposPrestamos_Labels,
                                        		-size      => 1,
							-defaults  => 'SIN SELECCIONAR'
                                 		);
#Se lo paso al template
$template->param(selectTiposPrestamos => $CGISelectTiposPrestamos);
#*******************************Fin**Select Tipos de Prestamos***************************************


$template->param( 	resultsloop      => \@resultsdata,
			cantidad         => $cantidad,
			numeros		 => \@numeros,
			fechaIni	=> $fechaIni,
			fechaFin 	=> $fechaFin,
			catUsuarios	=> $catUsuarios,
		);

output_html_with_http_headers $input, $cookie, $template->output;
