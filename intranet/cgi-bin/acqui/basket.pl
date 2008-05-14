#!/usr/bin/perl

# $Id: basket.pl,v 1.16.2.1 2004/01/13 17:29:30 tipaul Exp $

#script to show display basket of orders
#written by chris@katipo.co.nz 24/2/2000


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

use C4::Auth;
use C4::Catalogue;
use C4::Biblio;
use C4::Output;
use CGI;
use C4::Interface::CGI::Output;
# use C4::Database;
use HTML::Template;
use C4::Date;
use strict;

my $query =new CGI;
my $basket=$query ->param('basket');
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "acqui/basket.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {editcatalogue => 1},
			     debug => 1,
			     });
my ($count,@results);
if ($basket eq ''){
	$basket=newbasket();
	$results[0]->{'booksellerid'}=$query->param('id');
	$results[0]->{'authorisedby'} = $loggedinuser;
} else {
	($count,@results)=basket($basket);
}

my ($count2,@booksellers)=bookseller($results[0]->{'booksellerid'});

my $line_total; # total of each line
my $sub_total; # total of line totals
my $gist;      # GST
my $grand_total; # $subttotal + $gist
my $toggle=0;

my @books_loop;
for (my $i=0;$i<$count;$i++){
	my $rrp=$results[$i]->{'listprice'};
	$rrp=curconvert($results[$i]->{'currency'},$rrp);

	$line_total=$results[$i]->{'quantity'}*$results[$i]->{'ecost'};
	$sub_total+=$line_total;
	my %line;
	if ($toggle==0){
		$line{color}='#EEEEEE';
		$toggle=1;
	} else {
		$line{color}='white';
		$toggle=0;
	}
	$line{ordernumber} = $results[$i]->{'ordernumber'};
	$line{publishercode} = $results[$i]->{'publishercode'};
	$line{isbn} = $results[$i]->{'isbn'};
	$line{booksellerid} = $results[$i]->{'booksellerid'};
	$line{basket}=$basket;
	$line{title} = $results[$i]->{'title'};
	$line{author} = $results[$i]->{'author'};
	$line{i} = $i;
	$line{rrp} = $results[$i]->{'rrp'};
	$line{ecost} = $results[$i]->{'ecost'};
	$line{quantity} = $results[$i]->{'quantity'};
	$line{quantityrecieved} = $results[$i]->{'quantityreceived'};
	$line{line_total} = $line_total;
	$line{biblionumber} = $results[$i]->{'biblionumber'};
	push @books_loop, \%line;
}
my $prefgist =C4::Context->preference("gist");
$gist=sprintf("%.2f",$sub_total*$prefgist);
$grand_total=$sub_total+$gist;

my $dateformat = C4::Date::get_date_format();
$template->param(basket => $basket,
						authorisedby => $results[0]->{'authorisedby'},
						entrydate => format_date($results[0]->{'entrydate'},$dateformat),
						id=> $results[0]->{'booksellerid'},
						name => $booksellers[0]->{'name'},
						books_loop => \@books_loop,
						count =>$count,
						sub_total => $sub_total,
						gist => $gist,
						grand_total =>$grand_total,
						currency => $booksellers[0]->{'listprice'},
						);
output_html_with_http_headers $query, $cookie, $template->output;
