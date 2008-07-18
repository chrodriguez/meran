#!/usr/bin/perl

# Miguel 21-05-07
# Se obtiene un Historial de los prestamos realizados por los usuarios

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Issues;
use C4::Biblio;
use C4::AR::Busquedas;

my $input = new CGI;

my @select_catUsuarios_Values;
my %select_catUsuarios_Labels;
my @select_catUsuarios_Values2;
my (@select_catUsuarios_Values2,%catUsuarios)= C4::AR::Usuarios::obtenerCategorias(); 

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



#Cargo todos los Select
#*********************************Select de Categoria de Usuarios**********************************
my @select_catUsuarios_Values;
my %select_catUsuarios_Labels;
my ($array,$hasheado)=C4::AR::Usuarios::obtenerCategorias();

push @select_catUsuarios_Values, '-1';
$select_catUsuarios_Labels{'-1'}= 'SIN SELECCIONAR';
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

push @select_tiposPrestamos_Values, '-1';
$select_tiposPrestamos_Labels{'-1'}= 'SIN SELECCIONAR';

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
my ($cant,@tiposDeItems)=&C4::AR::Busquedas::getItemTypes(); 
my $i=0;
my $hash;
my $value = "";
my $key = "";

push @select_tiposItems_Values, '-1';
$select_tiposItems_Labels{'-1'}= 'SIN SELECCIONAR';

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


$template->param( 
			orden 		 => $orden, 
		);


output_html_with_http_headers $input, $cookie, $template->output;
