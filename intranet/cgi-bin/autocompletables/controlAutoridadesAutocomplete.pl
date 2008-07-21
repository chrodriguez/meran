#!/usr/bin/perl

use strict;
require Exporter;# contains gettemplate
use CGI;
use C4::AR::Utilidades;
use C4::AR::ControlAutoridades;

my $input = new CGI;
my $tipo = $input->param('tipo');
my $accion = $input->param('accion');

#*******************************************Autocomplete de Temas*********************************************
my $tema= $input->param('q');
if($accion eq 'autocompleteTemas'){
	
	my ($cant, @results)= &C4::AR::ControlAutoridades::search_temas($tema);

	my $i=0;
	my $resultado="";
	my $field;
	my $data;

	for ($i; $i<$cant; $i++){
		$field=$results[$i]->{'id'};
		$data=$results[$i]->{'nombre'};
  		$resultado .= $field."|".$data. "\n";
	}

	print "Content-type: text/html\n\n";
 	print $resultado;
}
#***************************************Fin****Autocomplete de Temas******************************************
#*******************************************Autocomplete de Autores********************************************
my $autor= $input->param('q');
if($accion eq 'autocompleteAutores'){
	
	my ($cant, @results)= &C4::AR::ControlAutoridades::search_autores($autor);

	my $i=0;
	my $resultado="";
	my $field;
	my $data;

	for ($i; $i<$cant; $i++){
		$field=$results[$i]->{'id'};
		$data=$results[$i]->{'nombre'};
  		$resultado .= $field."|".$data. "\n";
	}

	print "Content-type: text/html\n\n";
 	print $resultado;
}
#***************************************Fin****Autocomplete de Autores*****************************************

#*****************************************Autocomplete de Editoriales******************************************
my $editorial= $input->param('q');
if($accion eq 'autocompleteEditoriales'){
	
	my ($cant, @results)= &C4::AR::ControlAutoridades::search_editoriales($editorial);

	my $i=0;
	my $resultado="";
	my $field;
	my $data;

	for ($i; $i<$cant; $i++){
		$field=$results[$i]->{'id'};
		$data=$results[$i]->{'editorial'};
  		$resultado .= $field."|".$data. "\n";
	}

	print "Content-type: text/html\n\n";
 	print $resultado;
}
#************************************Fin****Autocomplete de Editoriales*****************************************

