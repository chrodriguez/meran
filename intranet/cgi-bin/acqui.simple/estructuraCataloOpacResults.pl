#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use C4::Koha; 
use C4::AR::CatalogacionOpac;
use C4::AR::Catalogacion;
use C4::AR::Utilidades;
use HTML::Template::Expr;

my $input = new CGI;

my $url="acqui.simple/estructuraCataloOpacResults.tmpl";


my ($template, $loggedinuser, $cookie)
    = get_templateexpr_and_user({template_name => $url,
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {editcatalogue => 1},
			     debug => 1,
			     });

my $accion=$input->param('accion')||"";
my $tipo=$input->param('tipo')||"";

my $campoX=$input->param('campoX');
my $campo=$input->param('campo');
my $idencabezado=$input->param('encabezados');
my $nivel= $input->param('nivel');
my $id= $input->param('idestcatopac');

if($tipo eq "modificar"){
my ($cant, @result) = &traerVisualizacion($id);



my $textpred= $result[0]->{'textpred'};#$input->param('textpred');
my $textsucc= $result[0]->{'textsucc'};#$input->param('textsucc');
my $separador= $result[0]->{'separador'};#$input->param('separador');

$template->param(	textpred   => "textopred",
			textsucc   => "textsucc",
			separador  => "separador",
);
}


#***********************Filtro de numero de campo*******************************************
my %camposX;
my @values;
push (@values, -1);
$camposX{-1}="Elegir";

my $option;
for (my $i =0 ; $i <= 9; $i++){
	push (@values, $i);
	$option= $i."xx";
	$camposX{$i}=$option;
}

my $selectCampoX=CGI::scrolling_list(  -name      => 'campoX',
			-id	   => 'campoX',
			-values    => \@values,
			-labels    => \%camposX,
			-defaults  => 'Elegir',
			-size      => 1,
			-onChange  => 'eleccionCampoX()',
                        );
$template->param(selectCampoX	  => $selectCampoX);
#***********************FIN filtro de numero de campo********************************************

if($accion eq "seleccionCampo" || $accion eq "seleccionSubCampo"){

	my @campos;
	if($campoX != -1){
# 	traigo todos los campos que estan catalogados en MARC, segun el campo por ej 1xx
#    	y los tipos de items q tiene el encabezado
		@campos= &traerCampos($idencabezado, $campoX, $nivel);
	}
	push (@campos,'Elegir campo');

 	my $selecttagField=CGI::scrolling_list( 
 					-name      => 'campo',
 					-id	   => 'campo',
 					-values    => \@campos,
 					-defaults  => 'Elegir campo',
 					-size      => 1,
 					-onChange  => 'eleccionCampo()',
                                 );
 
 	$template->param(selecttagField    => $selecttagField,);

# Fin Combo numeros de campo
}


if($accion eq "seleccionSubCampo" ){

	my $nombretagCampo=&buscarNombreCampoMarc($campo);#C4::AR::Catalogacion;
	my $itemtype= $input->param('itemtype');
	my @subCampos= &traerSubCampos($idencabezado,$campo,$itemtype);
#Combo para los subcampos
	my @valuesSubCampos;
	my %labelsSubCampos;
	my $default= $input->param('subCampo') || "-1,";
		
	my $selecttagsubField=CGI::scrolling_list( -name      => 'subCampo',
					-id	   => 'subCampo',
					-values    => \@subCampos,
					-defaults  => $default,
                                	-size      => 1,
                                 	);
	$template->param(selecttagsubField    => $selecttagsubField,
			nombreCampo	      => $nombretagCampo,
			);
#FIN combo subcampos
}


output_html_with_http_headers $input, $cookie, $template->output;