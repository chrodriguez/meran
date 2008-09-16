#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::VisualizacionOpac;
use C4::AR::Catalogacion;
use C4::AR::Utilidades;

my $input = new CGI;


my ($template, $loggedinuser, $cookie)
    = get_templateexpr_and_user({template_name => "catalogacion/visualizacionOPAC/visualizacionOpacResults.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {editcatalogue => 1},
			     debug => 1,
			     });


my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $accion= $obj->{'accion'}||"";
my $tipoAccion= $obj->{'tipoAccion'}||"";
my $componente= $obj->{'componente'};
my $campoX= $obj->{'campoX'};
my $defaultCampoX= ($campoX >= 0)?$campoX:'Elegir';
my $campo= $obj->{'campo'};
my $defaultCampo= ($campo >= 0)?$campo:'Elegir campo';
my $idencabezado= $obj->{'encabezados'};
my $nivel= $obj->{'nivel'};


#***************************** Mostrar configuracion de campo, subcampo*****************************
if( ($tipoAccion eq "SELECT")&&($componente eq "CONF_CAMPO_SUBCAMPO") ){
	my $id= $obj->{'idestcatopac'};

	my ($cant, @result) = &C4::AR::VisualizacionOpac::traerVisualizacion($id);
	
	my $textpred= $result[0]->{'textpred'};
	my $textsucc= $result[0]->{'textsucc'};
	my $separador= $result[0]->{'separador'};
	
	$template->param(	textpred   => "textopred",
				textsucc   => "textsucc",
				separador  => "separador",
	);
}
#****************************Fin**Mostrar configuracion de campo, subcampo***************************

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

my $selectCampoX=CGI::scrolling_list( 	-name      => 'campoX',
					-id	   => 'campoX',
					-values    => \@values,
					-labels    => \%camposX,
					-defaults  => $defaultCampoX,
					-size      => 1,
					-onChange  => 'eleccionCampoX()',
                        );


$template->param(selectCampoX	  => $selectCampoX);
#***********************FIN filtro de numero de campo********************************************

if( ($accion eq "SELECCION_CAMPO") || ($accion eq "SELECCION_SUB_CAMPO") ){

	my @campos;
	if($campoX != -1){
# 	traigo todos los campos que estan catalogados en MARC, segun el campo por ej 1xx
#    	y los tipos de items q tiene el encabezado
		@campos= &C4::AR::VisualizacionOpac::traerCampos($idencabezado, $campoX, $nivel);
	}
	push (@campos,'Elegir campo');

 	my $selecttagField=CGI::scrolling_list( 
						-name      => 'campo',
						-id	   => 'campo',
						-values    => \@campos,
						-defaults  => $defaultCampo,
						-size      => 1,
						-onChange  => 'eleccionCampo()',
                                 );
 
 	$template->param(selecttagField    => $selecttagField,);

# Fin Combo numeros de campo
}


if($accion eq "SELECCION_SUB_CAMPO" ){

	my $nombretagCampo=&C4::AR::Catalogacion::buscarNombreCampoMarc($campo);
	my $itemtype= $obj->{'itemtype'};
	my @subCampos= &C4::AR::VisualizacionOpac::traerSubCampos($idencabezado,$campo,$itemtype);
#Combo para los subcampos
	my @valuesSubCampos;
# 	my %labelsSubCampos;
	my $default= $obj->{'subCampo'} || "-1,";
		
	my $selecttagsubField=CGI::scrolling_list( 	-name      => 'subCampo',
							-id	   => 'subCampo',
							-values    => \@subCampos,
							-defaults  => $default,
							-size      => 1,
                                 	);

	$template->param(
			selecttagsubField    => $selecttagsubField,
			nombreCampo	      => $nombretagCampo,
			);
#FIN combo subcampos
}


output_html_with_http_headers $input, $cookie, $template->output;
