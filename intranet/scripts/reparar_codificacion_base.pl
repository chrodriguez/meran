#!/usr/bin/perl
use C4::Context;
use CGI::Session;

my $dbh = C4::Context->dbh;
my @tables = $dbh->tables;

foreach my $table (@tables){
#	print $table."\n"; 
	my @t = split(/\./,$table);
	chop($t[1]);
	my $tabla=substr($t[1],1);

   my $desc = $dbh->selectall_arrayref("DESCRIBE $tabla", { Columns=>{} });
    foreach my $row (@$desc) {
       my $tipo = $row->{'Type'};
       my $columna = $row->{'Field'};
       print $tabla." - ".$columna." - ".$tipo."\n";
   }
}	

