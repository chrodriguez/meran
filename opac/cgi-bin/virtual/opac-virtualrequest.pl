#!/usr/bin/perl
# NOTE: This file uses standard 8-character tabs

use strict;
require Exporter;
use CGI;

use C4::Search;
use C4::Auth;         # checkauth, getborrowernumber.
use C4::Koha;
use C4::Circulation::Circ2;
use C4::AR::VirtualLibrary;
use C4::AR::Reserves;
# use C4::Reserves2;
use C4::Interface::CGI::Output;
use HTML::Template;
use C4::Date;
use C4::Context;

my $query = new CGI;
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "virtual/opac-virtualrequest.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 0,
			     flagsrequired => {borrow => 1},
			     debug => 1,
			     });

# get borrower information ....
my ($borr, $flags) = getpatroninformation(undef, $borrowernumber);
my @bordat;
$bordat[0] = $borr;
my $dateformat = C4::Date::get_date_format();

# get biblionumber.....
my $biblionumber = $query->param('bib');

my $bibdata = bibdata($biblionumber);
 $template->param($bibdata);
 $template->param(BORROWER_INFO => \@bordat, biblionumber => $biblionumber);

# pass the pickup branch along....
my $branch = $query->param('branch');
$template->param(branch => $branch);

my $branches = getbranches();
$template->param(branchname => $branches->{$branch}->{'branchname'});


# make branch selection options...
#my $branchoptions = '';
my @branches;
my @select_branch;
my %select_branches;

foreach my $branch (keys %$branches) {
	if ($branch) {
		push @select_branch, $branch;
		$select_branches{$branch} = $branches->{$branch}->{'branchname'};
	}
}
$branch=getbranch($query,$branches);
my $CGIbranch=CGI::scrolling_list( -name     => 'branch',
			-values   => \@select_branch,
			-labels   => \%select_branches,
			-size     => 1,
			-multiple => 0 );
$template->param( CGIbranch => $CGIbranch);

#### THIS IS A BIT OF A HACK BECAUSE THE BIBLIOITEMS DATA IS A LITTLE MESSED UP!
# get the itemtype data....

 my @items = ItemInfo(undef, $biblionumber, 'opac');


##MATIAS
my ($count,@bibliotypes)= virtualBibitems($biblionumber);
my @bitypes;

for (my $i=0;$i<$count;$i++){

        $bitypes[$i]->{'bibitem'}=$bibliotypes[$i]->{'biblioitemnumber'};
 	$bitypes[$i]->{'bibitemtype'}=$bibliotypes[$i]->{'biblioitemnumber'}." GRUPO - ". $bibliotypes[$i]->{'description'};

	 if ($bibliotypes[$i]->{'requesttype'} eq 'copy'){$bitypes[$i]->{'copy'}=1}else{$bitypes[$i]->{'print'}=1}


	$bitypes[$i]->{'volume'} = $bibliotypes[$i]->{'volume'};
        $bitypes[$i]->{'volumeddesc'} = $bibliotypes[$i]->{'volumeddesc'};
	my ($available,$lost,$notloan,$cancel,$late,$isu,$dates,$reserve,@branches)=groupinfo(undef, $bibliotypes[$i]->{'biblioitemnumber'},$biblionumber);
	my $copies = "";

	for (my $j=0;$j<@branches;$j++) {
		  $copies .= $branches[$j]->{'branchname'}."(".$branches[$j]->{'count'}.")<br> ";
					}

	  $bitypes[$i]->{'branchinfo'} = $copies;
  	  $bitypes[$i]->{'available'} = $available;
	  $bitypes[$i]->{'issue'} = $isu;
	  $bitypes[$i]->{'issuelist'} = $dates;
          $bitypes[$i]->{'reserve'} = $reserve;

	}

  $template->param(BITYPES => \@bitypes);


# end old version
################################

my @temp;
foreach my $itm (@items) {
    push @temp, $itm if $itm->{'itemtype'};
}
@items = @temp;
my $itemcount = @items;
$template->param(itemcount => $itemcount);

my %bitypes;
my %bibitemtypes;

##Matias
foreach my $itm (@items) {
	$bibitemtypes{$itm->{'biblioitemnumber'}} = $itm;
}

###Marca la Fecha de Hoy

my @datearr = localtime(time);
my $today =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
$template->param( todaydate => format_date($today,$dateformat));

###

if ($query->param('item_types_selected')) {
	# this is what happens after the itemtypes have been selected. Stage 2
	my @bibitemtypes = $query->param('bibitemtype');
	my $fee = 0;
	my $proceed = 0;
	my $cant=0; #Matias

	$template->param(required_date => format_date($today,$dateformat));

	if (@bibitemtypes) {
		my @newbitypes;
		my $i=0;
		foreach my $bitmtype (@bibitemtypes) {


#NO se puede pasar de la maxima cantidad de pedidos virtuales

my $type = requestType($bitmtype);
                                                                                                                             
 if ($type eq 'copy') { if(canCopy($borrowernumber) eq 0 )
                        {
                          $template->param(message => 1);
                          $template->param(item_types_selected=> 0);
		          $template->param(select_item_types=>1);
		   	  $cant = 1;
                          $template->param(tomuchc => 1);
		        $template->param(
        	                maxCopy => C4::Context->preference("maxvirtualcopy"),
				CirculationEnabled => C4::Context->preference("circulation"),
	                        copyRenew => C4::Context->preference("virtualcopyrenew")
                		        );

                        }}
        elsif (canPrint($borrowernumber) eq 0 )
                        {
                          $template->param(message => 1);
			  $template->param(item_types_selected=> 0);
		          $template->param(select_item_types=>1);
                          $cant = 1;
                          $template->param(tomuchp => 1);
	  		  $template->param(
                           maxPrint=> C4::Context->preference("maxvirtualprint"),
                       	   printRenew=> C4::Context->preference("virtualprintrenew")
                        		);
                        }
	

##Matias - para que no se reserve un grupo del cual ya se posee un pedido
       my ($reqnum, @request) = virtualRequests($bitmtype);
        for (my $i=0;$i<$reqnum;$i++){
            if ($request[$i]->{'borrowernumber'} eq $borrowernumber) {
               $template->param(message => 1);
                $template->param(already => 1);
                $template->param(item_types_selected=> 0);
                $template->param(select_item_types=>1);
                $cant=1;

                }}

		for (my $i=0;$i<$count;$i++){
        		if ($bibliotypes[$i]->{'biblioitemnumber'} eq $bitmtype){
		$newbitypes[$i]->{'bibitem'}=$bibliotypes[$i]->{'biblioitemnumber'};
		$newbitypes[$i]->{'volume'}=$bibliotypes[$i]->{'volume'};
		$newbitypes[$i]->{'volumeddesc'}=$bibliotypes[$i]->{'volumeddesc'};
		$newbitypes[$i]->{'bibitemtype'}=$bibliotypes[$i]->{'biblioitemnumber'}." GRUPO - ". $bibliotypes[$i]->{'description'};
	
	#Tipo de pedido Virtual
	     if ($bibliotypes[$i]->{'requesttype'} eq 'copy'){$newbitypes[$i]->{'copy'}=1}else{$newbitypes[$i]->{'print'}=1};

							  	               }
					  }

		$i++;
		}
	if($cant eq 0){ #Para que no sobreescriba los datos cuando vuelva a la pagina anterior si ya hay una reserva para ese grupo
		$template->param(BITYPES => \@newbitypes);
			} #

		foreach my $bitype (@bibitemtypes) {
		my @reqbibs;
		foreach my $item (@items) {
			if ($item->{'biblioitemnumber'} eq $bitype) {
			push @reqbibs, $item->{'biblioitemnumber'};
			}
		}
		$fee += CalcReserveFee(undef,$borrowernumber,$biblionumber,'o',\@reqbibs);
		}
		$proceed = 1;
	} elsif ($query->param('all')) {
		$template->param(all => 1);
		$fee = 1;
		$proceed = 1;
	}
	warn "branch :$branch:";
	if ($cant ne 1) {	
	if ($proceed && $branch ) {

	if($fee ne 0){  $fee = sprintf "%.02f", $fee;
			$template->param(fee => $fee);}
	$template->param(item_types_selected => 1);
	} else {
		$template->param(message => 1);
		$template->param(no_items_selected => 1) unless ($proceed);
		$template->param(no_branch_selected =>1) unless ($branch);
	
		#Matias Muestra la tabla cuando no se selecciono nada
	        $template->param(select_item_types=>1);
		##
	}}
} elsif ($query->param('place_reserve')) {
	# here we actually do the request. Stage 3.
	my $title = $bibdata->{'title'};
	my @bibitemtypes = $query->param('bibitemtype');
	my @reqbibs;

	#Matias: Fecha
    	my $required_date = $query->param('required_date');
   $required_date = format_date_in_iso($required_date,$dateformat);
	# my $expires_date = $query->param('expires_date');
   	# if ($expires_date eq 0) {$expires_date ='NULL';};

	foreach my $bitype (@bibitemtypes) {if ($bitype ne '') {push @reqbibs, $bitype}}
	my $env;

#Se realiza el pedido
  CreateRequest($branch,$borrowernumber,@reqbibs[0],$required_date);


	print $query->redirect("/cgi-bin/koha/opac-search.pl");
} else {
	# Here we check that the borrower can actually make reserves Stage 1.
	my $noreserves = 0;
	my $maxoutstanding = C4::Context->preference("maxoustanding");
	if ($borr->{'amountoutstanding'} > $maxoutstanding) {
		my $amount = sprintf "\$%.02f", $borr->{'amountoutstanding'};
		$template->param(message => 1);
		$noreserves = 1;
		$template->param(too_much_oweing => $amount);
	}


	unless ($noreserves) {
		$template->param(BITYPES => \@bitypes) ;# MAtias
		$template->param(select_item_types => 1);
	}
}

$template->param (pagetitle => "Pedidos a la Biblioteca Virtual");

# check that you can actually make the reserve.

output_html_with_http_headers $query, $cookie, $template->output;

# Local Variables:
# tab-width: 8
# End:
