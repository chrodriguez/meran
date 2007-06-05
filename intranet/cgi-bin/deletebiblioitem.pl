#!/usr/bin/perl


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
use C4::Biblio;			# For &deletebiblioitem
use C4::Search;
use C4::Auth;


use CGI;

my $input = new CGI;
my $biblionumber     = $input->param('biblionumber');
my $biblioitemnumber = $input->param('biblioitemnumber');
my $responsable      = $input->param('responsable');
 my $from=$input->param('from');


 my $flagsrequired;
 $flagsrequired->{editcatalogue}=1;
 my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0, $flagsrequired,"intranet");
		 

if (! $biblionumber) {
    print $input->redirect("/catalogue/");

} elsif (! $biblioitemnumber) {
    print $input->param("detail.pl?type=intra&bib=$biblionumber");

} else {
my $msg="";
if (canDeleteBiblioitem($biblioitemnumber) eq 1)
	 {$msg="&msg=nobiblioitemdelete";
		#Matias 
		#Si no se pudo borrar vuelve a donde fue invocado
		if ($from ne 'detail'){
		if ($from ne 'additem'){
        	print $input->redirect("/cgi-bin/koha/moredetail.pl?bi=$biblioitemnumber".$msg); }}
		else {print $input->redirect("/cgi-bin/koha/acqui.simple/additem-nomarc.pl?type=intra&biblionumber=$biblionumber".$msg); }
		#Matias
		} 
	else {	
	
	if (&deletereserves($biblioitemnumber,$responsable) eq 1)
			{$msg="&msg=havereservesgroup";}	
		#Se borra el grupo
		&deletebiblioitem($biblioitemnumber,$responsable);
		}
	if ($from eq 'additem'){print $input->redirect("/cgi-bin/koha/acqui.simple/additem-nomarc.pl?type=intra&biblionumber=$biblionumber".$msg); }
	else { print $input->redirect("detail.pl?type=intra&bib=$biblionumber".$msg);}
} # else
