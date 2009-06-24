#!/usr/bin/perl

# Miguel 21-05-07
# Se obtiene un Historial de los prestamos realizados por los usuarios

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Prestamos;
use C4::Biblio;
use C4::AR::Busquedas;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                            template_name => "reports/historico_Prestamos.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                            debug => 1,
			    });


my $orden;
if ($input->param('orden') eq ""){
	 $orden='firstname'}
else {$orden=$input->param('orden')};

my %params;
$params{'default'}= 'SIN SELECCIONAR';
my $comboCategoriasDeSocio= C4::AR::Utilidades::generarComboCategoriasDeSocio(\%params);

#llamo a la funcion en C4::AR::Prestamos, traer todos los tipos de prestamos
#*************************************Select de Tipos de Prestamos*******************************
my @select_tiposPrestamos_Values;
my %select_tiposPrestamos_Labels;
my @tipoDePrestamos=&IssuesType(); #Funcion de C4::AR::Prestamos, traer los tipos de prestamos

push @select_tiposPrestamos_Values, '-1';
$select_tiposPrestamos_Labels{'-1'}= 'SIN SELECCIONAR';

my $i=0;
my $hash;
my $value = "";
my $key = "";

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

my $CGISelectTiposPrestamos=C4::AR::Utilidades::generarComboTipoPrestamo();


# CGI::scrolling_list(	-name      => 'tiposItems',
#                                         	-id        => 'tiposItems',
#                                         	-values    => \@select_tiposItems_Values,
#                                         	-labels    => \%select_tiposItems_Labels,
#                                         	-size      => 1,
# 						-defaults  => 'SIN SELECCIONAR'
#                                  		);
#************************************Fin Select de Tipos de Items*********************************

my $comboCategoriasDeSocio = C4::AR::Utilidades::generarComboCategoriasDeSocio();
my $CGISelectTiposItems = C4::AR::Utilidades::generarComboTipoNivel3();
$t_params->{'orden'}= $orden;
$t_params->{'selectTiposItems'}= $CGISelectTiposItems;
$t_params->{'selectCatUsuarios'}= $comboCategoriasDeSocio;
$t_params->{'selectTiposPrestamos'}= $CGISelectTiposPrestamos;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
