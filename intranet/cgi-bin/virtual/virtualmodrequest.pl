#!/usr/bin/perl

#script to modify reserves/requests
#written 2/1/00 by chris@katipo.oc.nz
#last update 27/1/2000 by chris@katipo.co.nz


# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
#use DBI;
use C4::Search;
use CGI;
use C4::Output;
use C4::AR::VirtualLibrary;

my $input = new CGI;
#print $input->header;

#print $input->Dump;

my $biblio=$input->param('biblio');
my $borrower=$input->param('borrowernumber');
my $biblioitemnumber=$input->param('biblioitemnumber');
my $timestamp=$input->param('timestamp');
my $branch=$input->param('branch');
my $op=$input->param('op');


open (FILE,'>>/tmp/fines');

print FILE "-----op";
print FILE  $op."   ";

print FILE $branch."   ";



if($op eq 'del'){
DeleteVirtualRequest($borrower,$biblioitemnumber,$timestamp ); #from C4::AR::VirtualLibrary
		}
else {
  my @datearr = localtime(time);
  my $today =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
	if($op eq 'comp'){
  CompleteVirtualRequest($borrower,$biblioitemnumber,$timestamp,$branch,$today ); #from C4::AR::VirtualLibrary
		}
	else { 
	if ($op eq 'condition'){
		#Cambiar condiciones

	foreach ($input->param) {
        	if (/COND-(\d+)/) {
            	my $timestamp=$1;
		print FILE  $timestamp." nada  ";

        	ConditionVirtualRequest($timestamp); 
        			}
    				}
					}
	else { AquireVirtualRequest($borrower,$biblioitemnumber,$timestamp,$branch,$today ); #from C4::AR::VirtualLibrary 
		}
	
		}
}

my $from=$input->param('from');
if ($from eq 'borrower'){
  print $input->redirect("/cgi-bin/koha/moremember.pl?bornum=$borrower");
 } elsif ($from eq 'report'){
	   print $input->redirect("/cgi-bin/koha/virtual/virtualreport.pl?branch=$branch");
	 }
	else{
   print $input->redirect("/cgi-bin/koha/virtual/virtualrequest.pl?bib=$biblio");
}
