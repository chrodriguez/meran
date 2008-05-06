#!/usr/bin/perl
# NOTE: This file uses standard 8-space tabs
#       DO NOT SET TAB SIZE TO 4

# $Id: memberentry.pl,v 1.37.2.2 2004/01/26 10:44:45 tipaul Exp $

#script to set up screen for modification of borrower details
#written 20/12/99 by chris@katipo.co.nz


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
use CGI;
use C4::Search;
use C4::Members;
use C4::Koha;
use HTML::Template;
use Date::Manip;
use C4::Date;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/memberentry2.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $member=$input->param('pernum');
my $borrowernumber=$input->param('borrowernumber');
# if ($member eq ''){
#	$member=NewBorrowerNumber();
# }
my $type=$input->param('type') || '';
my $modify=$input->param('modify');
my $delete=$input->param('delete');
if ($delete){
	print $input->redirect("/cgi-bin/koha/members/deletemem.pl?member=$member");
} else {  # this else goes down the whole script
	if ($type eq 'Add'){
		$template->param( addAction => 1);
	} else {
		$template->param( addAction =>0);
	}

	my $data=persdata('',$member);
	if ($type eq 'Add'){
		$template->param( updtype => 'I');
	} else {
		$template->param( updtype => 'M');
	}
	my $cardnumber=C4::Members::fixup_cardnumber($data->{'cardnumber'});
	if ($data->{'sex'} eq 'F'){
		$template->param(female => 1);
	}
	my ($categories,$labels)=ethnicitycategories();
	my $ethnicitycategoriescount=$#{$categories};
	my $ethcatpopup;
	if ($ethnicitycategoriescount>=0) {
		$ethcatpopup = CGI::popup_menu(-name=>'ethnicity',
					-id => 'ethnicity',
					-values=>$categories,
					-default=>$data->{'ethnicity'},
					-labels=>$labels);
		$template->param(ethcatpopup => $ethcatpopup); # bad style, has to be fixed
	}


	($categories,$labels)=borrowercategories();
	my $catcodepopup = CGI::popup_menu(-name=>'categorycode',
					-id => 'categorycode',
					-values=>$categories,
					-default=>$data->{'categorycode'},
					-labels=>$labels);


	my @relationships = ('trabajo', 'pariente','amigo', 'vecino');

	my @relshipdata;
	while (@relationships) {
		my $relship = shift @relationships;
		my %row = ('relationship' => $relship);
		if ($data->{'altrelationship'} eq $relship) {
			$row{'selected'}=' selected';
		} else {
			$row{'selected'}='';
		}
		push(@relshipdata, \%row);
	}

        my @documents = ('DNI', 'LC','LE', 'CI', 'PAS');

        my @documentdata;
        while (@documents) {
                my $doc = shift @documents;
                my %row = ('document' => $doc);
                if ($data->{'documenttype'} eq $doc) {
                        $row{'selected'}=' selected';
                } else {
                        $row{'selected'}='';
                }
                push(@documentdata, \%row);
        }

	# %flags: keys=$data-keys, datas=[formname, HTML-explanation]
	my %flags = ('gonenoaddress' => ['gna', 'Sin direcci&oacute;n actualizada'],
				'lost'          => ['lost', 'Perdido'],
				'debarred'      => ['debarred', 'Inhabilitado']);
				
	my @flagdata;
	foreach (keys(%flags)) {
	my $key = $_;
	my %row =  ('key'   => $key,
			'name'  => $flags{$key}[0],
			'html'  => $flags{$key}[1]);
	if ($data->{$key}) {
		$row{'yes'}=' checked';
		$row{'no'}='';
	} else {
		$row{'yes'}='';
		$row{'no'}=' checked';
	}
	push(@flagdata, \%row);
	}

	if ($modify){
	$template->param( modify => 1 );
	}

	#Convert dateofbirth to correct format
	$data->{'dateofbirth'} = format_date($data->{'dateofbirth'});

	my @branches;
	my @select_branch;
	my %select_branches;
	my $branches=getbranches();
	foreach my $branch (keys %$branches) {
		push @select_branch, $branch;
		$select_branches{$branch} = $branches->{$branch}->{'branchname'};
	}
	#agregado por Einar para que quede el branch por defecto
        my $branchdefecto=$data->{'branchcode'};
	($branchdefecto ||($branchdefecto=(split("_",(split(";",$cookie))[0]))[1]));
	#hasta aca y la linea adentro del pasaje por parametros a la CGIbranch

	my $CGIbranch=CGI::scrolling_list( -name     => 'branchcode',
				-id => 'branchcode',
				-values   => \@select_branch,
				-defaults  => $branchdefecto, #tambien agregado para que funcione
				-labels   => \%select_branches,
				-size     => 1,
				-multiple => 0 );
	
	#agregado para los combos de las ciudades
	#my $dcity=getcity($data->{'city'});
	$data->{'dcity'}=getcity($data->{'city'});
	
	$data->{'dstreetcity'}=getcity($data->{'streetcity'});



	$template->param(	type 		=> $type,
				member          => $member,
				address         => $data->{'streetaddress'},
				firstname       => $data->{'firstname'},
				surname         => $data->{'surname'},
				othernames	=> $data->{'othernames'},
				initials	=> $data->{'initials'},
				ethcatpopup	=> $ethcatpopup,
				catcodepopup	=> $catcodepopup,
				streetaddress   => $data->{'physstreet'},
				zipcode         => $data->{'zipcode'},
				streetcity      => $data->{'streetcity'},
				dstreetcity      => $data->{'dstreetcity'},
				homezipcode     => $data->{'homezipcode'},
				city		=> $data->{'city'},
				dcity		=> $data->{'dcity'},
				phone           => $data->{'phone'},
				phoneday        => $data->{'phoneday'},
				faxnumber       => $data->{'faxnumber'},
				emailaddress    => $data->{'emailaddress'},
				textmessaging   => $data->{'textmessaging'},
				contactname     => $data->{'contactname'},
				altphone        => $data->{'altphone'},
				altnotes	=> $data->{'altnotes'},
				borrowernotes	=> $data->{'borrowernotes'},
				borrowernumber	=> $data->{'borrowernumber'},
				studentnumber  => $data->{'studentnumber'},


                                documentnumber  => $data->{'documentnumber'},
				documentloop    => \@documentdata,


				flagloop	=> \@flagdata,
				relshiploop	=> \@relshipdata,
				"title_".$data->{'title'} => " SELECTED ",
				dateenrolled	=> $data->{'dateenrolled'},
				expiry		=> $data->{'expiry'},
# cardnumber	=> $cardnumber, Esto es lo que estaba, ahora lo cambie porque no se mostraba el cardnumber cunado editas el usuario 
				cardnumber	=> $data->{'cardnumber'}, #esto es lo que agregue yo
				dateofbirth	=> $data->{'dateofbirth'},
				dateformat      => display_date_format(),
			        modify          => $modify,
				CGIbranch       => $CGIbranch,
				regular         => $data->{'regular'},
);
	output_html_with_http_headers $input, $cookie, $template->output;


}

# Local Variables:
# tab-width: 8
# End:
