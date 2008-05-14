#!/usr/bin/perl

# $Id: request.pl,v 1.26.2.1 2004/02/29 07:03:32 acli Exp $

#script to place reserves/requests
#writen 2/1/00 by chris@katipo.oc.nz


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

use C4::AR::VirtualLibrary;
use C4::Interface::CGI::Output;
use C4::Auth;
use C4::Search;
use C4::Date;
use C4::Koha;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Circulation::Circ2;
use C4::Catalogue;
use HTML::Template;
use CGI;
my $input = new CGI;

# get biblio information....
my $bib = $input->param('bib');
my $dat = bibdata($bib);

# todays date
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime(time);
$year=$year+1900;
$mon++;
my $dateformat = C4::Date::get_date_format();
my $date=format_date("$year-$mon-$mday",$dateformat);

# get biblioitem information and build rows for form
my ($count2,@data) =virtualBibitems($bib);

my @bibitemloop;
my @requestloop;
my $branches = getbranches();

my $dateformat = C4::Date::get_date_format();
foreach my $dat (@data) {
###MATIAS###
       $dat->{'bibitemtype'}=$dat->{'biblioitemnumber'}." GRUPO - ". $dat->{'description'};
	$dat->{'requesttype'}=$dat->{'requesttype'};
	my %abibitem;
    
    $abibitem{'itemlost'}=(($dat->{'notforloan'})|| ($dat->{'itemlost'} == 1)) ;
	$abibitem{'biblioitemnumber'}=$dat->{'biblioitemnumber'};
	$abibitem{'description'}=$dat->{'bibitemtype'};

   if ($dat->{'requesttype'} eq 'copy'){$abibitem{'copy'}=1}else{$abibitem{'print'}=1}


	if ($dat->{'volume'}){
		$abibitem{'volumeddesc'}=$dat->{'volume'}.": ".$dat->{'volumeddesc'};}
	else { $abibitem{'volumeddesc'}="-";}
	
	
my ($cant,@request) = virtualRequests($dat->{'biblioitemnumber'});
foreach my $req  (@request){
my %request;	
	
	$request{'branchname'}=$req->{'branchname'};
 	$request{'date'} = format_date($req->{'date_request'},$dateformat);
        $request{'borrowernumber'}=$req->{'borrowernumber'};
        $request{'firstname'}=$req->{'firstname'};
        $request{'surname'}=$req->{'surname'};
        $request{'voldesc'}=$req->{'volumeddesc'};
        $request{'itemtype'}=$req->{'itemtype'};
	($request{'itemtype'},$request{'description'}) = FindItemType($req->{'biblioitemnumber'});
 	($request{'volumeddesc'},$request{'volume'})   = FindVol($req->{'biblioitemnumber'});
	$request{'biblioitemnumber'}= $req->{'biblioitemnumber'};
	$request{'timestamp'}= $req->{'timestamp'};
       
	 if ($req->{'requesttype'} eq 'copy'){$request{'copy'}=1}else{$request{'print'}=1}
	
	if ($req->{'date_complete'} ne ''){$request{'complete'}=1;
						$request{'date_complete'}=format_date($req->{'date_complete'},$dateformat);}

        push(@requestloop,\%request);

	}
push(@bibitemloop,\%abibitem);

}

my @branches;
my @select_branch;
my %select_branches;
my ($count2,@branches)=branches();

for (my $i=0;$i<$count2;$i++){
	push @select_branch, $branches[$i]->{'branchcode'};#
	$select_branches{$branches[$i]->{'branchcode'}} = $branches[$i]->{'branchname'};
}

#agregado por Einar para que quede el branch por defecto
my $branch=$input->param('branch');
unless ($branch) {$branch=(split("_",(split(";",$cookie))[0]))[1];}

#hasta aca y la linea adentro del pasaje por parametros a la CGIbranch

my $CGIbranch=CGI::scrolling_list( -name     => 'pickup',
			-values   => \@select_branch,
			-defaults => $branch, #agregado por Einar para setear la opcion por defecto
			-labels   => \%select_branches,
			-size     => 1,
			-multiple => 0 );

#get the time for the form name...
my $time = time();

#setup colours
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "virtual/virtualrequest.tmpl",
			query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {parameters => 1},
                         });
$template->param(						
#optionloop =>\@optionloop,
	 							CGIbranch => $CGIbranch,
								requestloop => \@requestloop,
								'time' => $time,
								bibitemloop => \@bibitemloop,
								date => $date,
								bib => $bib,
								title =>$dat->{title});
# printout the page
print $input->header(
	-type => C4::Interface::CGI::Output::guesstype($template->output),
	-expires=>'now'
), $template->output;
