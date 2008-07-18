#!/usr/bin/perl

# $Id: actualizarPersonas.pl,v 1.0 2005/05/3 10:44:45 tipaul Exp $

#script para actualizar los datos de los posibles usuarios
#written 3/05/2005  by einar@info.unlp.edu.ar

#En este modulo se va hacer los llamados a funciones para insertar los sinonimos de
#autores, temas, ..

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::ControlAutoridades;
use C4::AR::Utilidades;

my $input = new CGI;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{ editcatalogue => 1});

my $tipo = $input->param('tipo');
my $tabla = $input->param('tabla');
my $seudonimo = $input->param('tablasSelectSeudonimo');
my $id = $input->param('id');
my $seudonimoDelete = $input->param('idDelete');
my $accion = $input->param('accion');

my $sinonimoDelete_string = $input->param('sinonimoDelete_string');
my $Existe;

#*******************************************Autocomplete de Temas*********************************************
my $tema= $input->param('q');
if($accion eq 'autocompleteTemas'){
	
	my ($cant, @results)= &search_temas($tema);

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
	
	my ($cant, @results)= &search_autores($autor);

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
	
	my ($cant, @results)= &search_editoriales($editorial);

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


if($tabla eq 'autores'){
#****************************SEUDONIMOS***************************************
	if($tipo eq 'eliminarSeudonimos'){
		&eliminarSeudonimosAutor($id,$seudonimoDelete);
	}

	if($tipo eq 'insertarSeudonimos'){
		my $seudonimos= $input->param('seudonimos')||"";
		my $seudonimos_arrayref= from_json_ISO($seudonimos);
		&insertSeudonimosAutor($seudonimos_arrayref, $id);
	}
#******************************SINONIMOS**************************************
	if($tipo eq 'eliminarSinonimos'){
		&eliminarSinonimosAutor($id,$sinonimoDelete_string);
	}
	if($tipo eq 'insertarSinonimos'){
		my $sinonimos= $input->param('sinonimos')||" ";
		my $sinonimos_arrayref= from_json_ISO($sinonimos);
		&insertSinonimosAutor($sinonimos_arrayref, $id);
	}
	if($tipo eq 'UpdateSinonimo'){
		my $idSinonimo= $input->param('idSinonimo')||" ";
		my $nombre= $input->param('nombre');
		my $nombreViejo= $input->param('nombreViejo');
		&updateSinonimosAutores($idSinonimo, $nombre, $nombreViejo);
	}

	print $input->header;
}

if($tabla eq 'temas'){
#****************************SEUDONIMOS***************************************
	if($tipo eq 'eliminarSeudonimos'){
		&eliminarSeudonimosTema($id,$seudonimoDelete);
	}

	if($tipo eq 'insertarSeudonimos'){
		my $seudonimos= $input->param('seudonimos')||"";
		my $seudonimos_arrayref= from_json_ISO($seudonimos);
		&insertSeudonimosTemas($seudonimos_arrayref, $id);
	}
#******************************SINONIMOS**************************************
	if($tipo eq 'eliminarSinonimos'){
		&eliminarSinonimosTema($id,$sinonimoDelete_string);
	}

	if($tipo eq 'insertarSinonimos'){
		my $sinonimos= $input->param('sinonimos')||" ";
		my $sinonimos_arrayref= from_json_ISO($sinonimos);
		&insertSinonimosTemas($sinonimos_arrayref, $id);
	}
	if($tipo eq 'UpdateSinonimo'){
		my $idSinonimo= $input->param('idSinonimo')||" ";
		my $nombre= $input->param('nombre');
		my $nombreViejo= $input->param('nombreViejo');
		&updateSinonimosTemas($idSinonimo, $nombre, $nombreViejo);
	}

	print $input->header;
}

if($tabla eq 'editoriales'){
#****************************SEUDONIMOS***************************************
	if($tipo eq 'eliminarSeudonimos'){
		&eliminarSeudonimosEditorial($id,$seudonimoDelete);
	}

	if($tipo eq 'insertarSeudonimos'){
		my $seudonimos= $input->param('seudonimos')||"";
		my $seudonimos_arrayref= from_json_ISO($seudonimos);
		&insertSeudonimosEditoriales($seudonimos_arrayref, $id);
	}
#******************************SINONIMOS**************************************
	if($tipo eq 'eliminarSinonimos'){
		&eliminarSinonimosEditorial($id,$sinonimoDelete_string);
	}
	if($tipo eq 'insertarSinonimos'){
		my $sinonimos= $input->param('sinonimos')||" ";
		my $sinonimos_arrayref= from_json_ISO($sinonimos);
		&insertSinonimosEditoriales($sinonimos_arrayref, $id);
	}
	if($tipo eq 'UpdateSinonimo'){
		my $idSinonimo= $input->param('idSinonimo')||" ";
		my $nombre= $input->param('nombre');
		my $nombreViejo= $input->param('nombreViejo');
		&updateSinonimosEditoriales($idSinonimo, $nombre, $nombreViejo);
	}

	print $input->header;
}

#*********************************************Tablas Sinonimos************************************************
my $sinonimo= $input->param('sinonimo');
#Para consultar los sinonimos de un Autor
if( (($tipo eq 'consultaTablasSinonimos')||($tipo eq 'eliminarSinonimos'))&&($tabla eq 'autores')){

my ($template, $loggedinuser, $cookie)= get_templateexpr_and_user(
			{template_name => "controlAutoridadesSinonimosResult.tmpl",
			query => $input,
			type => "intranet",
			authnotrequired => 0,
			flagsrequired => {borrowers => 1},
			debug => 1,
});

	my ($cant, @results) = &traerSinonimosAutor($sinonimo);

	$template->param( 	
	  			RESULTSLOOP      => \@results,
		);

print  $template->output;

}
#Para consultar los sinonimos de un Autor
if((($tipo eq 'consultaTablasSinonimos')||($tipo eq 'eliminarSinonimos'))&&($tabla eq 'temas')){

my ($template, $loggedinuser, $cookie)= get_templateexpr_and_user({
 		template_name => "controlAutoridadesSinonimosResult.tmpl",
		query => $input,
		type => "intranet",
		authnotrequired => 0,
		flagsrequired => {borrowers => 1},
		debug => 1,
});


	my ($cant, @results) = &traerSinonimosTemas($sinonimo);

	$template->param( 	
	  			RESULTSLOOP      => \@results,
		);

print  $template->output;

}


#Para consultar los sinonimos de un Autor
if( (($tipo eq 'consultaTablasSinonimos')||($tipo eq 'eliminarSinonimos'))&&($tabla eq 'editoriales')){

my ($template, $loggedinuser, $cookie)= get_templateexpr_and_user({
		template_name => "controlAutoridadesSinonimosResult.tmpl",
		query => $input,
		type => "intranet",
		authnotrequired => 0,
		flagsrequired => {borrowers => 1},
		debug => 1,
});


	#Armo el combo para mostrar los sinonimos de los autores
	my ($cant, @results) = &traerSinonimosEditoriales($sinonimo);

	$template->param( 	
	  			RESULTSLOOP      => \@results,
		);

print  $template->output;
}

#***********************************************************************************************



#*********************************************Tablas Seudonimos************************************************
my $idSeudonimo= $input->param('seudonimo');
#Para consultar los seudonimos de un Autor
if( (($tipo eq 'consultaTablasSeudonimos')||($tipo eq 'eliminarSeudonimos'))&&($tabla eq 'autores')){

	my ($template, $loggedinuser, $cookie)= get_templateexpr_and_user(
			{template_name => "controlAutoridadesSeudonimosResult.tmpl",
			query => $input,
			type => "intranet",
			authnotrequired => 0,
			flagsrequired => {borrowers => 1},
			debug => 1,
	});

	my (@results) = &traerSeudonimosAutor($idSeudonimo);

	$template->param( 	
	  			RESULTSLOOP      => \@results,
		);

print  $template->output;
}

#Para consultar los seudonimos de un Tema
if((($tipo eq 'consultaTablasSeudonimos')||($tipo eq 'eliminarSeudonimos'))&&($tabla eq 'temas')){

my ($template, $loggedinuser, $cookie)= get_templateexpr_and_user({
		template_name => "controlAutoridadesSeudonimosResult.tmpl",
		query => $input,
		type => "intranet",
		authnotrequired => 0,
		flagsrequired => {borrowers => 1},
		debug => 1,
});


	my (@results) = &traerSeudonimosTemas($idSeudonimo);

	$template->param( 	
	  			RESULTSLOOP      => \@results,
		);

print  $template->output;

}


#Para consultar los seudonimos de una Editorial
if( (($tipo eq 'consultaTablasSeudonimos')||($tipo eq 'eliminarSeudonimos'))&&($tabla eq 'editoriales')){

my ($template, $loggedinuser, $cookie)= get_templateexpr_and_user({
		template_name => "controlAutoridadesSeudonimosResult.tmpl",
		query => $input,
		type => "intranet",
		authnotrequired => 0,
		flagsrequired => {borrowers => 1},
		debug => 1,
});

	#Armo el combo para mostrar los sinonimos de los autores
	my (@results) = &traerSeudonimosEditoriales($idSeudonimo);

	$template->param( 	
	  			RESULTSLOOP      => \@results,
		);

print  $template->output;
}

#***********************************************************************************************
