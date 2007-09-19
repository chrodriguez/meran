#!/usr/bin/perl

use strict;
require Exporter;
use C4::Context;

 my $dbh = C4::Context->dbh;
 my @results;
 my $cant=0;
open (L,">/tmp/habilitar_persons");


my $personas = " SELECT *  FROM persons  WHERE borrowernumber IS NOT NULL ";
 my $sth3=$dbh->prepare($personas);
  $sth3->execute();
  
  while (my $per=$sth3->fetchrow_hashref){
  
  my $borrower = " SELECT *  FROM borrowers  WHERE borrowernumber = ? ";
  my $sth4=$dbh->prepare($borrower);
  $sth4->execute($per->{'borrowernumber'});

  if (my $error= $sth4->fetchrow_hashref){}
  else {
   $cant ++;

   push (@results,$per->{'personnumber'});
   print $per->{'surname'}."  ".$per->{'cardnumber'}." \n";
   printf L $per->{'personnumber'}."  \n";
  }

$sth4->finish();
  }

close L;
$sth3->finish();


print "Cantidad:  ".$cant;
