#!/usr/bin/perl

use strict;
require Exporter;# contains gettemplate
use CGI;
use C4::AR::Utilidades;

my $input = new CGI;
my $autorStr=$input->param('q');
my $textout="";


my @result=obtenerAutores($autorStr);

foreach my $autor (@result){
	$textout.=$autor->{'id'}."|".$autor->{'completo'}."\n";
}

print "Content-type: text/html\n\n";
print $textout;
