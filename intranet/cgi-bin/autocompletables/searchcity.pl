#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
# use C4::Interface::CGI::Output;
use C4::Context;
# use HTML::Template;
# use C4::Koha;
use C4::Search;
#Este pl se usa para autocompletar la busqueda de una ciudad
#Agregar Usuario
#Agregar Organizacion
	
my $input = new CGI;

my $textout;
my @result;
	
my $ciudad = $input->param("q");
if ($ciudad){
	my($cant, $result) = &buscarCiudades($ciudad);# agregado sacar

	$textout= "";

	for (my $i; $i<$cant; $i++){
		$textout.= $result->[$i]->{'localidad'}."|".$result->[$i]->{'nombre'}."\n";
 	}
}

print "Content-type: text/html\n\n";
print $textout;

  	 



