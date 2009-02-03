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
my $id3=$obj->{'id3'};
my $itemtype=$obj->{'itemtype'};
my $accion=$obj->{'accion'};
my $todos=$obj->{'todos'}||0;
my $json=$obj->{'json'};

my @niveles3;
my $cant=0;
my $nivel3Comp;
if($id3 ne ""){
	($cant,$nivel3Comp)=&buscarNivel3Completo($id3);
}
else{
	$todos=1;
	@niveles3=C4::AR::Catalogacion::buscarNivel3PorId2($id2);
}

if(defined($json)){
        my ($template, $session, $t_params) = get_template_and_user({
	             template_name => "catalogacion/estructura/editarEjemplar.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {editcatalogue => 1},
			     debug => 1,
			     });

	my $nivel1=&buscarNivel1($id1);
	my $titulo=$nivel1->{'titulo'};
	my $autor=C4::AR::Busquedas::getautor($nivel1->{'autor'});
	my $cant=0;

	if($accion eq "modNivel3"){
		my $objetosResp= $obj->{'respuesta'};
		if($todos){
			my @ids3=split(/#/,$id3);
			foreach my $idN3 (@ids3){
				&modificarNivel3Completo($idN3,$objetosResp,$todos);
			}
		}
		else{
			&modificarNivel3Completo($id3,$objetosResp,$todos);
		}
	}

    $t_params->{'itemloop'}= \@niveles3;
	$t_params->{'nivel'}= 3;
	$t_params->{'itemtype'}= $itemtype;
	$t_params->{'id1'}= $id1;
	$t_params->{'id2'}= $id2;
	$t_params->{'id3'}= $id3;
	$t_params->{'titulo'}= $titulo;
	$t_params->{'datosautor'}= $autor->{'completo'};
	$t_params->{'todos'}= $todos;
    C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}
else{

	
	my %results = &buscarCamposModificadosYObligatorios(3,$itemtype);
	my ($cantIdsModN3,@resultsdata)=&crearCatalogo(0,$nivel3Comp,$cant,$itemtype,%results);

	my $resultadoJSON = to_json \@resultsdata;
	#Para que no valla a un tmpl
	print $input->header;
	print $resultadoJSON;
}





