#!/usr/bin/perl

#written 27/01/2000
#script to display borrowers reading record



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
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::VirtualLibrary;
use C4::Search;
use HTML::Template;
use C4::Date;

my $input=new CGI;


my $bornum=$input->param('bornum');
#get borrower details
my $data=borrdata('',$bornum);
my $order=$input->param('order');
my $order2=$order;
  if ($order2 eq ''){
  $order2="virtual_request.date_request DESC";
  }elsif ($order2 eq 'aquiredate'){
  $order2="virtual_request.date_aquire DESC";
  }elsif ($order2 eq 'completedate'){
  $order2="virtual_request.date_complete DESC";
  }elsif($order2 eq 'branch'){
  $order2="branches.branchname ASC";
  }elsif ($order2 eq 'title'){
  $order2="biblio.title ASC";
  }elsif($order2 eq 'author'){
  $order2="biblio.author ASC";
  }

 

my $limit=$input->param('limit');
if ($limit eq 'full'){
  $limit='';
} else {
  $limit='Limit 0,50';
}
my ($count,@report)=aquireReport ($bornum,$order2,$limit);

my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "virtual/virtualrec.tmpl",
				query => $input,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {borrowers => 1},
				debug => 1,
				});

my @loop_reading;


foreach my $req  (@report){
my %request;

	$request{'title'}=$req->{'title'};
        $request{'author'}=$req->{'author'};
        $request{'branchname'}=$req->{'branchname'};
        $request{'daterequest'} = format_date($req->{'date_request'});
        $request{'dateaquire'} = format_date($req->{'date_aquire'});
        $request{'datecomplete'} = format_date($req->{'date_complete'});
        $request{'borrowernumber'}=$req->{'borrowernumber'};
        $request{'firstname'}=$req->{'firstname'};
        $request{'surname'}=$req->{'surname'};
        $request{'voldesc'}=$req->{'volumeddesc'};
        ($request{'itemtype'},$request{'description'}) = FindItemType($req->{'biblioitemnumber'});
        ($request{'volumeddesc'},$request{'volume'})   = FindVol($req->{'biblioitemnumber'});
        $request{'biblioitemnumber'}= $req->{'biblioitemnumber'};
        $request{'timestamp'}= $req->{'timestamp'};

         if ($req->{'requesttype'} eq 'copy'){$request{'copy'}=1}else{$request{'print'}=1}

        push(@loop_reading,\%request);

        }

$template->param(title => $data->{'title'},
						initials => $data->{'initials'},
						surname => $data->{'surname'},
						bornum => $bornum,
						limit => $limit,
						firstname => $data->{'firstname'},
						cardnumber => $data->{'cardnumber'},
						showfulllink => ($count > 50),					
						loop_reading => \@loop_reading);
output_html_with_http_headers $input, $cookie, $template->output;



