#!/usr/bin/perl

use strict;
require Exporter;# contains gettemplate
use CGI;
use C4::AR::Utilidades;

my $input = new CGI;
my $autorStr=$input->param('q');
my $textout="";


my $autores_array_ref= C4::AR::Referencias::obtenerAutoresLike($autorStr);

foreach my $autor (@$autores_array_ref){
	$textout.= $autor->getId."|".$autor->getCompleto."\n";
}

print $input->header;
print $textout;
