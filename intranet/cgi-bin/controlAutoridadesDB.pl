#!/usr/bin/perl

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


my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $tipo = $obj->{'tipo'};
my $tabla = $obj->{'tabla'};
my $seudonimo = $obj->{'tablasSelectSeudonimo'};
my $id = $obj->{'id'};
my $seudonimoDelete = $obj->{'idDelete'};
my $accion = $obj->{'accion'};
my $sinonimoDelete_string = $obj->{'sinonimoDelete_string'};




if($tabla eq 'autores'){
#****************************SEUDONIMOS***************************************
	if($tipo eq 'eliminarSeudonimos'){
		&C4::AR::ControlAutoridades::t_eliminarSeudonimosAutor($id,$seudonimoDelete);
	}

	if($tipo eq 'insertarSeudonimos'){
		my $seudonimos= $obj->{'seudonimos'}||"";
		my $seudonimos_arrayref= from_json_ISO($seudonimos);
		&C4::AR::ControlAutoridades::insertSeudonimosAutor($seudonimos_arrayref, $id);
	}
#******************************SINONIMOS**************************************
	if($tipo eq 'eliminarSinonimos'){
		&C4::AR::ControlAutoridades::eliminarSinonimosAutor($id,$sinonimoDelete_string);
	}
	if($tipo eq 'insertarSinonimos'){
		my $sinonimos= $obj->{'sinonimos'}||" ";
		my $sinonimos_arrayref= from_json_ISO($sinonimos);
		&C4::AR::ControlAutoridades::t_insertSinonimosAutor($sinonimos_arrayref, $id);
	}
	if($tipo eq 'UpdateSinonimo'){
		my $idSinonimo= $obj->{'idSinonimo'}||" ";
		my $nombre= $obj->{'nombre'};
		my $nombreViejo= $obj->{'nombreViejo'};
		&C4::AR::ControlAutoridades::t_updateSinonimosAutores($idSinonimo, $nombre, $nombreViejo);
	}

	print $input->header;
}

if($tabla eq 'temas'){
#****************************SEUDONIMOS***************************************
	if($tipo eq 'eliminarSeudonimos'){
		&C4::AR::ControlAutoridades::t_eliminarSeudonimosTema($id,$seudonimoDelete);
	}

	if($tipo eq 'insertarSeudonimos'){
		my $seudonimos= $obj->{'seudonimos'}||"";
		my $seudonimos_arrayref= from_json_ISO($seudonimos);
		&C4::AR::ControlAutoridades::t_insertSeudonimosTemas($seudonimos_arrayref, $id);
	}
#******************************SINONIMOS**************************************
	if($tipo eq 'eliminarSinonimos'){
		&C4::AR::ControlAutoridades::t_eliminarSinonimosTema($id,$sinonimoDelete_string);
	}

	if($tipo eq 'insertarSinonimos'){
		my $sinonimos= $obj->{'sinonimos'}||" ";
		my $sinonimos_arrayref= from_json_ISO($sinonimos);
		&C4::AR::ControlAutoridades::t_insertSinonimosTemas($sinonimos_arrayref, $id);
	}
	if($tipo eq 'UpdateSinonimo'){
		my $idSinonimo= $obj->{'idSinonimo'}||" ";
		my $nombre= $obj->{'nombre'};
		my $nombreViejo= $obj->{'nombreViejo'};
		&C4::AR::ControlAutoridades::t_updateSinonimosTemas($idSinonimo, $nombre, $nombreViejo);
	}

	print $input->header;
}

if($tabla eq 'editoriales'){
#****************************SEUDONIMOS***************************************
	if($tipo eq 'eliminarSeudonimos'){
		&C4::AR::ControlAutoridades::t_eliminarSeudonimosEditorial($id,$seudonimoDelete);
	}

	if($tipo eq 'insertarSeudonimos'){
		my $seudonimos= $obj->{'seudonimos'}||"";
		my $seudonimos_arrayref= from_json_ISO($seudonimos);
		&C4::AR::ControlAutoridades::t_insertSeudonimosEditoriales($seudonimos_arrayref, $id);
	}
#******************************SINONIMOS**************************************
	if($tipo eq 'eliminarSinonimos'){
		&C4::AR::ControlAutoridades::t_eliminarSinonimosEditorial($id,$sinonimoDelete_string);
	}
	if($tipo eq 'insertarSinonimos'){
		my $sinonimos= $obj->{'sinonimos'}||" ";
		my $sinonimos_arrayref= from_json_ISO($sinonimos);
		&C4::AR::ControlAutoridades::t_insertSinonimosEditoriales($sinonimos_arrayref, $id);
	}
	if($tipo eq 'UpdateSinonimo'){
		my $idSinonimo= $obj->{'idSinonimo'}||" ";
		my $nombre= $obj->{'nombre'};
		my $nombreViejo= $obj->{'nombreViejo'};
		&C4::AR::ControlAutoridades::t_updateSinonimosEditoriales($idSinonimo, $nombre, $nombreViejo);
	}

	print $input->header;
}

#*********************************************Tablas Sinonimos************************************************
my $sinonimo= $obj->{'sinonimo'};
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
my $idSeudonimo= $obj->{'seudonimo'};
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
