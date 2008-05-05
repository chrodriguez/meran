#!/usr/bin/perl

use strict;
require Exporter;# contains gettemplate
use CGI;
use C4::AR::Utilidades;

my $input = new CGI;
my $biblioStr=$input->param('q');
my $textout="";


my @result=&obtenerBiblios($biblioStr);

foreach my $biblio (@result){
	$textout.=$biblio->{'branchname'}."|".$biblio->{'id'}."\n";
}

print "Content-type: text/html\n\n";
print $textout;
