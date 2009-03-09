#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::AR::Utilidades;
	
my $input = new CGI;

my $textout;
my @result;
	
my $soporte = $input->param("q");
if ($soporte){
	my($cant, $result) = C4::AR::Utilidades::buscarSoportes($soporte);# agregado sacar

	$textout= "";

	for (my $i; $i<$cant; $i++){
		$textout.= $result->[$i]->{'idSupport'}."|".$result->[$i]->{'description'}."\n";
 	}
}

print "Content-type: text/html\n\n";
print $textout;

  	 



