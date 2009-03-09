#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::AR::Utilidades;
	
my $input = new CGI;

my $textout;
my @result;
	
my $nivelBibliografico = $input->param("q");
if ($nivelBibliografico){
	my($cant, $result) = C4::AR::Utilidades::buscarNivelesBibliograficos($nivelBibliografico);

	$textout= "";

	for (my $i; $i<$cant; $i++){
		$textout.= $result->[$i]->{'code'}."|".$result->[$i]->{'description'}."\n";
 	}
}

print "Content-type: text/html\n\n";
print $textout;

  	 



