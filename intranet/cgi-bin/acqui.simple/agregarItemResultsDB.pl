#!/usr/bin/perl


use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Catalogacion;
use JSON;

my $input = new CGI;

my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{ editcatalogue => 1});

my $paso=$input->param('paso');
my $itemtype=$input->param('itemtype');
my $accion=$input->param('accion');
my $id1=$input->param('id1');

#BUSQUEDA de campos modificados que se generan dinamicamente para mostrar en el tmpl
my $modificar;
my $cant=0;
if($accion eq "modificarN1"){
	($cant,$modificar)=&buscarNivel1Completo($id1);
}

my %results = &buscarCamposModificadosYObligatorios($paso,$itemtype);
my ($cantIds,@resultsdata)=&crearCatalogo(0,$modificar,$cant,$itemtype,%results);

my @resultsdata2;
if($paso >= 2){
	my %results2=&buscarCamposModificadosYObligatorios(3,$itemtype);
	($cantIds,@resultsdata2)=&crearCatalogo($cantIds,$modificar,$cant,$itemtype,%results2);
	push(@resultsdata,@resultsdata2);
}


# my $resultadoJSON = encode_json \@resultsdata;
my $resultadoJSON = to_json \@resultsdata;#PARA QUE MUESTRE BIEN LOS ACENTOS.

#Para que no valla a un tmpl
print $input->header;
print $resultadoJSON;
