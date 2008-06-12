#!/usr/bin/perl

use strict;
require Exporter;# contains gettemplate
use CGI;
use C4::AR::Usuarios;

my $input = new CGI;
my $usuarioStr=$input->param('q');
my $textout="";


my @result= C4::AR::Usuarios::buscarBorrower($usuarioStr);

foreach my $usuario (@result){
	$textout.=$usuario->{'surname'}.", ".$usuario->{'firstname'}."|".$usuario->{'borrowernumber'}."\n";
}

print "Content-type: text/html\n\n";
print $textout;
