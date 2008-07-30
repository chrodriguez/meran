#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Catalogacion;
use JSON;

my $input = new CGI;

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));

my $id1=$obj->{'id1'};
my $id2=$obj->{'id2'};
my $itemtype=$obj->{'itemtype'};
my $accion=$obj->{'accion'};
my $json=$obj->{'json'};

if(!$json){
	my ($template, $loggedinuser, $cookie)
    		= get_templateexpr_and_user({template_name => "acqui.simple/agregarEjemplar.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {editcatalogue => 1},
			     debug => 1,
			     });

	if($accion eq "agregarNivel3"){
		my $barcodes=$obj->{'barcodes'};
		my $cantItems=$obj->{'cantItems'};
		my $nivel2=&buscarNivel2($id2);
		my $tipoDoc=$nivel2->{'tipo_documento'};
		my $nivel3 = $obj->{'respuesta'};
		my $paraMens;
		my ($error,$codMsg)=&guardarNivel3($id1,$id2,$barcodes,$cantItems,$tipoDoc,$nivel3);
		my $mensaje=C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
		$template->param(
			mensaje	  => $mensaje,
		);
	}

	my $nivel=3;
	my $descripcion=C4::AR::Busquedas::getItemType($itemtype);

	$template->param(
		nivel		  => $nivel,
		itemtype	  => $itemtype,
		descripcion	  => $descripcion,
		id1		  => $id1,
		id2		  => $id2,
	);
	output_html_with_http_headers $input, $cookie, $template->output;
}
else{
	my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{ editcatalogue => 1});

	my %null;
	my %results = &buscarCamposModificadosYObligatorios(3,$itemtype);
	my ($cantIdsN3,@resultsdata)=&crearCatalogo(0,\%null,0,$itemtype,%results);
	my $resultadoJSON = to_json \@resultsdata;

	#Para que no valla a un tmpl
	print $input->header;
	print $resultadoJSON;
}





