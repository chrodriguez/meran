#!/usr/bin/perl

# $Id: moremember.pl,v 1.33.2.1 2003/12/22 10:40:55 tipaul Exp $

# script to do a borrower enquiry/bring up borrower details etc
# Displays all the details about a borrower
# written 20/12/99 by chris@katipo.co.nz
# last modified 21/1/2000 by chris@katipo.co.nz
# modified 31/1/2001 by chris@katipo.co.nz
#   to not allow items on request to be renewed
#
# needs html removed and to use the C4::Output more, but its tricky
#


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
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Interface::CGI::Template;
use CGI;
use C4::Search;
use Date::Manip;
use C4::Date;
use C4::Reserves2;
use C4::AR::Reserves;
use C4::Circulation::Renewals2;
use C4::Circulation::Circ2;
use C4::Koha;
use HTML::Template;
use C4::AR::VirtualLibrary; #Matias

my $dbh = C4::Context->dbh;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/moremember.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $bornum=$input->param('bornum');

#start the page and read in includes

my $data=borrdata('',$bornum);

$data->{'updatepassword'}= $data->{'changepassword'};

$template->param($data->{'categorycode'} => 1); # in template <TMPL_IF name="I"> => instutitional (A for Adult & C for children)

$data->{'dateenrolled'} = format_date($data->{'dateenrolled'});
$data->{'expiry'} = format_date($data->{'expiry'});
$data->{'dateofbirth'} = format_date($data->{'dateofbirth'});
$data->{'IS_ADULT'} = ($data->{'categorycode'} ne 'I');

$data->{'ethnicity'} = fixEthnicity($data->{'ethnicity'});

$data->{&expand_sex_into_predicate($data->{'sex'})} = 1;
$data->{'city'}=&getcitycategory($data->{'city'});
$data->{'streetcity'}=&getcitycategory($data->{'streetcity'});

if ($data->{'categorycode'} eq 'C'){
	my $data2=borrdata('',$data->{'guarantor'});
	$data->{'streetaddress'}=$data2->{'streetaddress'};
	$data->{'city'}=&getcitycategory($data2->{'city'});
	$data->{'physstreet'}=$data2->{'physstreet'};
	$data->{'streetcity'}=&getcitycategory($data2->{'streetcity'});
	$data->{'phone'}=$data2->{'phone'};
	$data->{'phoneday'}=$data2->{'phoneday'};
	$data->{'zipcode'} = $data2->{'zipcode'};
}


if ($data->{'ethnicity'} || $data->{'ethnotes'}) {
	$template->param(printethnicityline => 1);
}

if ($data->{'categorycode'} ne 'C'){
	$template->param(isguarantee => 1);
	# FIXME
	# It looks like the $i is only being returned to handle walking through
	# the array, which is probably better done as a foreach loop.
	#
	my ($count,$guarantees)=findguarantees($data->{'borrowernumber'});
	my @guaranteedata;
	for (my $i=0;$i<$count;$i++){
		push (@guaranteedata, {borrowernumber => $guarantees->[$i]->{'borrowernumber'},
					cardnumber => $guarantees->[$i]->{'cardnumber'},
					name => $guarantees->[$i]->{'firstname'} . " " . $guarantees->[$i]->{'surname'}});
	}
	$template->param(guaranteeloop => \@guaranteedata);

} else {
	my ($guarantor)=findguarantor($data->{'borrowernumber'});
	unless ($guarantor->{'borrowernumber'} == 0){
		$template->param(guarantorborrowernumber => $guarantor->{'borrowernumber'}, guarantorcardnumber => $guarantor->{'cardnumber'});
	}
}

my %bor;
$bor{'borrowernumber'}=$bornum;

# Converts the branchcode to the branch name
$data->{'branchcode'} = &getbranchname($data->{'branchcode'});

# Converts the categorycode to the description
$data->{'categorycode'} = &getborrowercategory($data->{'categorycode'});

my ($numaccts,$accts,$total)=getboracctrecord('',\%bor);

my ($count,$issue)=borrissues($bornum);
my $today=ParseDate('today');
my @issuedata;
for (my $i=0;$i<$count;$i++){
	my $datedue=ParseDate($issue->[$i]{'date_due'});
	$issue->[$i]{'date_due'} = format_date($issue->[$i]{'date_due'});
	my %row = %{$issue->[$i]};
	if ($datedue < $today){
		$row{'red'}=1; #print "<font color=red>";
	}
	#find the charge for an item
	# FIXME - This is expecting
	# &C4::Circulation::Renewals2::calc_charges, but it's getting
	# &C4::Circulation::Circ2::calc_charges, which only returns one
	# element, so itemtype isn't being set.
	# But &C4::Circulation::Renewals2::calc_charges doesn't appear to
	# return the correct item type either (or a properly-formatted
	# charge, for that matter).
	my ($charge,$itemtype)=calc_charges(undef,$dbh,$issue->[$i]{'itemnumber'},$bornum);
	$row{'itemtype'}=&ItemType($itemtype);
	$row{'charge'}=$charge;

	#Matias pasa la cantidad de renovaciones realizadas 
	if ($issue->[$i]{'renewals2'}){ $row{'renewals'}=$issue->[$i]{'renewals2'}; }else  { $row{'renewals'}=0; }

	#check item is not reserved
	my ($restype,$reserves)=CheckReserves($issue->[$i]{'itemnumber'});

	$row{'norenew'}=1;


	if ($restype){
		$row{'why'}= "<a href=/cgi-bin/koha/request.pl?bib=".$issue->[$i]{'biblionumber'}.">Reservado";

	} elsif ($issue->[$i]{'renewals2'} eq  getmaxrenewals()) {
                      $row{'why'}="<font color='red'><b>No puede renovar m&aacute;s este ejemplar</b></font>";}

	else {$row{'norenew'}=0;}
	push (@issuedata, \%row);
}

my ($rescount,$reserves)=FindReserves('',$bornum); #From C4::Reserves2

my @reservedata;
foreach my $reserveline (@$reserves) {
	$reserveline->{'reservedate2'} = format_date($reserveline->{'reservedate'});
	my $restitle;
	my %row = %$reserveline;
	if ($reserveline->{'constrainttype'} eq 'o'){
		$restitle=getreservetitle($reserveline->{'bbiblionumber'},$reserveline->{'bborrowernumber'},$reserveline->{'reservedate'},$reserveline->{'rtimestamp'});
#MAtias
my ( $volumeddesc, $volume) = FindVol($reserveline->{'bbiblioitemnumber'});
		$restitle->{'volume'}=$volume;
		$restitle->{'volumeddesc'}=$volumeddesc;
##
		%row =  (%row , %$restitle ) if $restitle;
	}
	push (@reservedata, \%row);
}

###Einar  Los libros en espera
my ($rcount, $reserves) = DatosReservas($bornum);
my @realreserves;
my @waiting;
my $rcount = 0;
my $wcount = 0;
foreach my $res (@$reserves) {
    if ($res->{'ritemnumber'}) {
        #$res->{'rbranch'} = $branches->{$res->{'rbranch'}}->{'branchname'};
        push @waiting, $res;
        $wcount++;
    }
        else{
        push @realreserves, $res;
        $rcount++;
        }
}
#my ($waitcount,$waitings)=CheckWaiting($bornum);
#my @waitingdata;

#foreach my $waitline (@$waitings) 
#{	
# my %row = %$waitline;
#        push (@waitingdata, \%row);
#
#	}


###

#Matias: Esta habilitada la Biblioteca Virtual?
my $virtuallibrary=C4::Context->preference("virtuallibrary");
$template->param(virtuallibrary => $virtuallibrary);
if ($virtuallibrary eq 1)
{
	my ($count2,@requestdata) = allRequests($bornum);
	if ($count2 ne 0){
		$template->param( vrequest => 1, 
				 requestloop     => \@requestdata);
			}

}
#

#### Verifica si la foto ya esta cargada
my $picturesDir= C4::Context->config("picturesdir");
my $foto;
if (opendir(DIR, $picturesDir)) {
	my $pattern= $bornum."[.].";





	my @file = grep { /$pattern/ } readdir(DIR);
	$foto= join("",@file);
	closedir DIR;
} else {
	$foto= 0;
}
####

#### Verifica si hay problemas para subir la foto
my $msgFoto=$input->param('msg');
($msgFoto) || ($msgFoto=0);
####

#### Verifica si hay problemas para borrar un usuario
my $msgError=$input->param('error');
($msgError) || ($msgError=0);
####

$template->param($data);
$template->param(
		bornum          => $bornum,
		totaldue          =>$total,
#los libros que tiene "en espera"
		waiting=> \@waiting,
###
		issueloop       => \@issuedata,
		realreserves     => \@realreserves,
		foto_name => $foto,
		mensaje_error_foto => $msgFoto,
		mensaje_error_borrar => $msgError,
	);
output_html_with_http_headers $input, $cookie, $template->output;
