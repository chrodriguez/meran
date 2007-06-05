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
#
use strict;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use C4::Search;
use HTML::Template;
use C4::AR::VirtualLibrary;
use C4::Koha;
use C4::Date;
use Date::Manip;
use Date::Calc;

my $input = new CGI;

my $DC=C4::Context->preference("daysvirtualcomplete");
my $DR=C4::Context->preference("daysvirtualrequest");


my @datearr = localtime(time);
my $today =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
$today = C4::Date::format_date_in_iso($today);

#my $err= "Error con la fecha";
#my $ultimoDiaR = DateCalc($today,"+ ".$DR." days",\$err);
#my $ultimoDiaC = DateCalc($today,"+ ".$DC." days",\$err);

my $theme = $input->param('theme') || "default";
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "virtual/virtualreport.tmpl",

			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });


#Por los braches
my @branches;
my @select_branch;
my %select_branches;
my $branches=getbranches();
foreach my $branch (keys %$branches) {
        push @select_branch, $branch;
        $select_branches{$branch} = $branches->{$branch}->{'branchname'};
}
#agregado por Einar para que quede el branch por defecto
my $branch=$input->param('branch');
unless ($branch) {$branch=(split("_",(split(";",$cookie))[0]))[1];}

#hasta aca y la linea adentro del pasaje por parametros a la CGIbranch
                                                                                                                             
my $CGIbranch=CGI::scrolling_list(      -name      => 'branch',
                                        -id        => 'branch',
                                        -values    => \@select_branch,
                                        -defaults  => $branch,
                                        -labels    => \%select_branches,
                                        -size      => 1,
                                        -multiple  => 0,
					-onChange  => 'cambioUnidadDeInformacion()'

                                 );
#Fin: Por los branches
 
my ($cant,@request)= requestsReport($branch);
my @noconditionloop;
my @conditionloop;
foreach my $req  (@request){
my %request;
                                                                                                                             
        $request{'branchname'}=$req->{'branchname'};
	$request{'branchcode'}=$branch;
	$request{'emailaddress'}=$req->{'emailaddress'};  
	$request{'title'}=$req->{'title'};
	$request{'author'}=$req->{'author'};
	$request{'authorhtmlescaped'}=$req->{'author'};
	$request{'authorhtmlescaped'}=~s/ /%20/g;
	if ($req->{'requesttype'} eq 'copy'){$request{'copy'}=1}else{$request{'print'}=1}
 	$request{'bib'}=$req->{'biblionumber'};
	$request{'date'} = format_date($req->{'date_request'});
        $request{'borrowernumber'}=$req->{'borrowernumber'};
        $request{'firstname'}=$req->{'firstname'};
        $request{'surname'}=$req->{'surname'};
        $request{'voldesc'}=$req->{'volumeddesc'};
        $request{'itemtype'}=$req->{'itemtype'};
        ($request{'itemtype'},$request{'description'}) = FindItemType($req->{'biblioitemnumber'});
        ($request{'volumeddesc'},$request{'volume'})   = FindVol($req->{'biblioitemnumber'});
        $request{'biblioitemnumber'}= $req->{'biblioitemnumber'};
        $request{'timestamp'}= $req->{'timestamp'};

#Verifica la fecha de pedido
        my $err= "Error con la fecha";
	my $reqD=C4::Date::format_date_in_iso($req->{'date_request'});
	my $ultimoDiaR = DateCalc($reqD,"+ ".$DR." days",\$err);

	$ultimoDiaR = C4::Date::format_date_in_iso($ultimoDiaR);	
	if (ParseDate($ultimoDiaR)  < ParseDate($today)){   
	 $request{'red'}=1;  
	}
##
                                                                                     
      if ($req->{'condition'} eq 0) {

#Verifica Deuda (como en moremember.pl)
	my %bor;
	$bor{'borrowernumber'}=$req->{'borrowernumber'};
	my ($numaccts,$accts,$total)=getboracctrecord('',\%bor);
	$request{'totaldue'}=$total;
#
	  push(@noconditionloop,\%request);}
	else { push(@conditionloop,\%request);}
		
                                                                                                                             
        }


my ($cant,@complete)= completeReport($branch);
my @completeloop;
foreach my $req  (@complete){
my %request;

        $request{'branchname'}=$req->{'branchname'};
        $request{'branchcode'}=$branch;

        $request{'emailaddress'}=$req->{'emailaddress'};  
        $request{'title'}=$req->{'title'};
        $request{'author'}=$req->{'author'};
        $request{'authorhtmlescaped'}=$req->{'author'};
        $request{'authorhtmlescaped'}=~s/ /%20/g;
        if ($req->{'requesttype'} eq 'copy'){$request{'copy'}=1}else{$request{'print'}=1}
        $request{'bib'}=$req->{'biblionumber'};
        $request{'date'} = format_date($req->{'date_request'});
        $request{'datecomplete'} = format_date($req->{'date_complete'}); 
	$request{'borrowernumber'}=$req->{'borrowernumber'};
        $request{'firstname'}=$req->{'firstname'};
        $request{'surname'}=$req->{'surname'};
        $request{'voldesc'}=$req->{'volumeddesc'};
        $request{'itemtype'}=$req->{'itemtype'};
        ($request{'itemtype'},$request{'description'}) = FindItemType($req->{'biblioitemnumber'});
        ($request{'volumeddesc'},$request{'volume'})   = FindVol($req->{'biblioitemnumber'});
        $request{'biblioitemnumber'}= $req->{'biblioitemnumber'};
        $request{'timestamp'}= $req->{'timestamp'};
       
	#Verifica la fecha de pedido
        my $err= "Error con la fecha";
        my $reqD=C4::Date::format_date_in_iso($req->{'date_request'});
	my $ultimoDiaR = DateCalc($reqD,"+ ".$DR." days",\$err);
	
        $ultimoDiaR = C4::Date::format_date_in_iso($ultimoDiaR);
        if (ParseDate($ultimoDiaR)  < ParseDate($today)){
         $request{'redR'}=1;
        }

	#Verifica la fecha de cumplido
        my $reqC=C4::Date::format_date_in_iso($req->{'date_complete'});
        my $ultimoDiaC = DateCalc($reqC,"+ ".$DC." days",\$err);
       $ultimoDiaC = C4::Date::format_date_in_iso($ultimoDiaC);

        if (ParseDate($ultimoDiaC)  < ParseDate($today)){
         $request{'redC'}=1;}
	##
                                                                                                                      
        push(@completeloop,\%request);

        }


$template->param( 
			CONDITIONLOOP      => \@conditionloop,
			NOCONDITIONLOOP => \@noconditionloop,
	   		completeloop 	=>\@completeloop,
			CGIbranch        => $CGIbranch
			);

if (C4::Context->boolean_preference('marc') eq '1') {
        $template->param(script => "MARCdetail.pl");
} else {
        $template->param(script => "detail.pl");
}


output_html_with_http_headers $input, $cookie, $template->output;
