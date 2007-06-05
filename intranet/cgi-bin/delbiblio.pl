#!/usr/bin/perl

#script to delete biblios
#written 2/5/00
#by chris@katipo.co.nz


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

use C4::Search;
use CGI;
use C4::Output;
use C4::Biblio;
use HTML::Template;
use C4::Interface::CGI::Output;
use C4::Output;
use C4::Auth;


my $input = new CGI;

my $flagsrequired;
$flagsrequired->{editcatalogue}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0, $flagsrequired,"intranet");
			

#print $input->header;


my $biblio=$input->param('biblio');
my $from=$input->param('from');

# check no items attached
my $count=C4::Biblio::itemcount($biblio);


#print $count;
if ($count > 0){
	if ($from eq 'additem'){
		print $input->redirect("/cgi-bin/koha/acqui.simple/additem-nomarc.pl?type=intra&biblionumber=$biblio&msg=noempty&noemptycount=$count");}
	else {print $input->redirect("/cgi-bin/koha/detail.pl?type=intra&bib=$biblio&msg=noempty&count=$count");}
} else {
	delbiblio($biblio,$loggedinuser);
	print $input->redirect("/cgi-bin/koha/loadmodules.pl?module=search");
}
