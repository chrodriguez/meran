#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Catalogacion;
use JSON;

my $input = new CGI;

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));

my $json=$obj->{'json'};
my $id1=$obj->{'id1'};
my $id2=$obj->{'id2'};
my $accion=$obj->{'accion'};
my ($itemtype,$cant,$nivel2Comp)=&buscarNivel2Completo($id2);

if(!$json){
	my ($template, $loggedinuser, $cookie)
   		= get_templateexpr_and_user({template_name => "acqui.simple/editarGrupo.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {editcatalogue => 1},
			     debug => 1,
			     });


	if($accion eq "modNivel2"){
		my $objetosResp= $obj->{'respuesta'};
		&modificarNivel2Completo($id2,$objetosResp);
	}
	else{
		my $nivel=2;
		my $descripcion=C4::AR::Busquedas::getItemType($itemtype);

		$template->param(
			nivel		  => $nivel,
			itemtype	  => $itemtype,
			descripcion	  => $descripcion,
			id1		  => $id1,
			id2		  => $id2,
		);
	}

output_html_with_http_headers $input, $cookie, $template->output;
}
else{
	my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{ editcatalogue => 1});

	my %results = &buscarCamposModificadosYObligatorios(2,$itemtype);
	my ($cantIdsNivel2,@resultsdata)=&crearCatalogo(0,$nivel2Comp,$cant,$itemtype,%results);
	my $resultadoJSON = to_json \@resultsdata;
	
	#Para que no valla a un tmpl
	print $input->header;
	print $resultadoJSON;
}


