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
use C4::AR::Issues;
use C4::Koha;
use C4::Biblio;

my $input = new CGI;

#Obtengo el Tipo de Item para filtrar
my $tipoItem = $input->param('tiposItems');
my $tipoPrestamo = $input->param('tipoPrestamos');
my $catUsuarios = $input->param('catUsuarios');


my @select_catUsuarios_Values;
my %select_catUsuarios_Labels;
my @select_catUsuarios_Values2;
#Funcion de C4::Koha, traer las categorias de los usuarios
my (@select_catUsuarios_Values2,%catUsuarios)= C4::Koha::borrowercategories(); 

my $theme = $input->param('theme') || "default";
my $campoIso = $input->param('code') || ""; 
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/historico_Prestamos.tmpl",

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

#obtengo el Historico de los Prestamos, esta en C4::AR::Estadisticas
my ($cantidad,@resultsdata)= C4::AR::Estadisticas::historicoPrestamos($orden,$ini,$fin,$tipoItem,$tipoPrestamo,$catUsuarios);

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

#Cargo todos los Select
#*********************************Select de Categoria de Usuarios**********************************
my @select_catUsuarios_Values;
my %select_catUsuarios_Labels;
#Funcion de C4::Koha, traer las categorias de los usuarios
#llamo a la funcion borrowercategories() de C4::Koha
my ($array,$hasheado)=&borrowercategories(); 
push @select_catUsuarios_Values, 'SIN SELECCIONAR';
my $i=0;
my @catUsuarios_Values;

foreach my $codCatUsuario (@$array) {

	push @select_catUsuarios_Values, $codCatUsuario;
	$select_catUsuarios_Labels{$codCatUsuario} = $hasheado->{$codCatUsuario};
	$i++;
}

my $CGISelectCatUsuarios=CGI::scrolling_list(	-name      => 'catUsuarios',
                                        	-id        => 'catUsuarios',
                                        	-values    => \@select_catUsuarios_Values,
                                        	-labels    => \%select_catUsuarios_Labels,
                                        	-size      => 1,
						-defaults  => 'SIN SELECCIONAR'
                                 		);
#Se lo paso al template
$template->param(selectCatUsuarios => $CGISelectCatUsuarios);
#*********************************Fin Select de Categoria de Usuarios******************************

#llamo a la funcion en C4::AR::Issues, traer todos los tipos de prestamos
#*************************************Select de Tipos de Prestamos*******************************
my @select_tiposPrestamos_Values;
my %select_tiposPrestamos_Labels;
my @tipoDePrestamos=&IssuesType(); #Funcion de C4::AR::Issues, traer los tipos de prestamos

push @select_tiposPrestamos_Values, 'SIN SELECCIONAR';
my $i=0;
my $hash;
my $value = "";
my $key = "";
foreach (@tipoDePrestamos) {
	#obtengo el hash
 	$hash = @tipoDePrestamos[$i];
	$value = $hash->{'description'};
	$key = $hash->{'issuecode'};
	push @select_tiposPrestamos_Values, $key;
	$select_tiposPrestamos_Labels{$key} = $value;
	$i++;
}

my $CGISelectTiposPrestamos=CGI::scrolling_list(-name      => 'tipoPrestamos',
                                        	-id        => 'tipoPrestamos',
                                        	-values    => \@select_tiposPrestamos_Values,
                                        	-labels    => \%select_tiposPrestamos_Labels,
                                        	-size      => 1,
						-defaults  => 'SIN SELECCIONAR'
                                 		);
#Se lo paso al template
$template->param(selectTiposPrestamos => $CGISelectTiposPrestamos);
#******************************Fin Select de Tipos de Prestamos***********************************

#************************************Select de Tipos de Items************************************
my @select_tiposItems_Values;
my %select_tiposItems_Labels;
#Funcion de C4::Biblio, trae los tipos de items
my ($cant,@tiposDeItems)=&getitemtypes(); 
my $i=0;
my $hash;
my $value = "";
my $key = "";

push @select_tiposItems_Values, 'SIN SELECCIONAR';

foreach (@tiposDeItems) {
	
	$hash = @tiposDeItems[$i];
	$value = $hash->{'description'};
	$key = $hash->{'itemtype'};
	push @select_tiposItems_Values, $key;
	$select_tiposItems_Labels{$key} = $value;
	$i++;
}

my $CGISelectTiposItems=CGI::scrolling_list(	-name      => 'tiposItems',
                                        	-id        => 'tiposItems',
                                        	-values    => \@select_tiposItems_Values,
                                        	-labels    => \%select_tiposItems_Labels,
                                        	-size      => 1,
						-defaults  => 'SIN SELECCIONAR'
                                 		);
#Se lo paso al template
$template->param(selectTiposItems => $CGISelectTiposItems);
#************************************Fin Select de Tipos de Items*********************************


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
			ini 		 => $ini,
			fin		 => $fin		
		);


output_html_with_http_headers $input, $cookie, $template->output;
