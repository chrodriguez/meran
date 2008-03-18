#!/usr/bin/perl

# $Id: updateitem.pl,v 1.8.2.1 2004/01/08 16:34:36 slef Exp $

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
use CGI;
use C4::Output;
use C4::Auth;
use C4::Interface::CGI::Output;
use HTML::Template;
use C4::Koha;
use Date::Manip;
use C4::Date;
use C4::Search;
use C4::AR::Sanctions;


#my $env;
my $input= new CGI;
my $dbh = C4::Context->dbh;
my $responsable=$input->param('userloggedname');
my $flags= &getuserflags($responsable ,$dbh);

if (($responsable eq 'kohaadmin')||($flags->{'superlibrarian'})||($flags->{'updatesanctions'})){
my $query = "select * from sanctions"; 					
my $sth=$dbh->prepare($query);
$sth->execute();
my @sanctionsarray;
my $count=0;
while (my $sanction=$sth->fetchrow_hashref){
	 my $temp="check_group_".$sanction->{'sanctionnumber'};
	 my $sanctionnumber=$input->param($temp);
	 if($sanctionnumber){
		#logueo la sacion que se elimina
		my $borrowernumber= $sanction->{'borrowernumber'};
		my $dateEnd= $sanction->{'enddate'};
		my $issueType= '??';
		logSanction('Delete',$borrowernumber,$responsable,$dateEnd,$issueType);
		&delSanction($dbh,$sanction->{'sanctionnumber'});
	}
	 				  }
    
}
print $input->redirect("sanctions.pl");

