#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::AR::Utilidades;
#Este pl se usa para autocompletar la busqueda de una ciudad
#Agregar Usuario
#Agregar Organizacion
	
my $input = new CGI;

my $textout;
my @result;
	
my $lenguaje = $input->param("q");
if ($lenguaje){
	my($cant, $result) = C4::AR::Utilidades::buscarLenguajes($lenguaje);# agregado sacar

	$textout= "";

	for (my $i; $i<$cant; $i++){
		$textout.= $result->[$i]->{'idLanguage'}."|".$result->[$i]->{'description'}."\n";
 	}
}

print "Content-type: text/html\n\n";
print $textout;

  	 



