#!/usr/bin/perl

use strict;
use warnings;
require Exporter;
use C4::Context;
use CGI;

my $input = new CGI;


my $files_location;  
my $ID;  
my @fileholder;

$files_location = ".";
$ID = $input->param('name').".sxc";

open(DLFILE, "<$files_location/$ID") || Error('open', 'file');  
@fileholder = <DLFILE>;  
close (DLFILE) || Error ('close', 'file');  

print "Content-Type:application/vnd.sun.xml.calc\n";  
print "Content-Disposition:attachment;filename=$ID\n\n";
print @fileholder
