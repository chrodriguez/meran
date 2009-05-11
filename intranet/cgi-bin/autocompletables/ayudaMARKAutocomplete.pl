#!/usr/bin/perl

use strict;
require Exporter;# contains gettemplate
use CGI;
use C4::AR::Utilidades;
use C4::AR::VisualizacionOpac;

my $input = new CGI;

my $tipoAccion= $input->param('tipoAccion')||"";
my $componente= $input->param('componente')||"";


#******************** para Ayuda de campos MARK*************************************
if(($tipoAccion eq "Select")&&($componente eq "ayudaCampoMARK")){

 	my $campo= $input->param('q');
	my ($cant,@results)= &C4::AR::VisualizacionOpac::buscarInfoCampo($campo); 
	my $i=0;
	my $resultAyudaMARK="";
	my $field;
	my $data;

	for ($i; $i<$cant; $i++){
		$field=$results[$i]->{'tagfield'};
		$data=$results[$i]->{'liblibrarian'};
  		$resultAyudaMARK .= $field."|".$data. "\n";
	}

 	print $resultAyudaMARK;
}
#**************************************************************************************************

#******************** para Ayuda de campos MARK*************************************
if(($tipoAccion eq "Select")&&($componente eq "ayudaCampoMARKsubcampo")){
	my $campo= $input->param('campo');
	my $subcampo= $input->param('subcampo');

	my ($cant,@results)= &C4::AR::VisualizacionOpac::buscarInfoSubCampo($campo);
	my $i=0;
	my $resultAyudaMARK="";
	my $field;
	my $data;

	for ($i; $i<$cant; $i++){
	$resultAyudaMARK .= $results[$i]->{'tagsubfield'}."/".$results[$i]->{'subcampo'}."#";
	}

	print "Content-type: text/html\n\n";
 	print $resultAyudaMARK;
}
#**************************************************************************************************


