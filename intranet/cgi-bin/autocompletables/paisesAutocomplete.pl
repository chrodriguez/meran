#!/usr/bin/perl

use strict;
require Exporter;# contains gettemplate
use CGI;
use C4::AR::Utilidades;

my $input = new CGI;
my $autorStr=$input->param('q');
my $textout="";


my @result=obtenerPaises($autorStr);

foreach my $pais (@result){
	$textout.=$pais->{'printable_name'}."|".$pais->{'iso'}."\n";
}

print "Content-type: text/html\n\n";
print $textout;
