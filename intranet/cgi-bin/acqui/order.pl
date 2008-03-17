#!/usr/bin/perl

# $Id: order.pl,v 1.9.2.1 2004/02/06 14:13:59 tipaul Exp $

#script to show suppliers and orders
#written by chris@katipo.co.nz 23/2/2000


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
use C4::Catalogue;
use C4::Auth;
use C4::Biblio;
use C4::Output;
use CGI;
use C4::Interface::CGI::Output;
use C4::Database;
use HTML::Template;
use C4::Catalogue;
use C4::Date;

my $query=new CGI;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "acqui/order.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {editcatalogue => 1},
			     debug => 1,
			     });

my $supplier=$query->param('supplier');
my ($count,@suppliers)=bookseller($supplier);

my $colour='#EEEEEE';
my $toggle=0;
my @loop_suppliers;
for (my $i=0; $i<$count; $i++) {
	my ($ordcount,$orders)=getorders($suppliers[$i]->{'id'});
	my %line;
	if ($toggle==0){
		$line{color}='#EEEEEE';
		$toggle=1;
	} else {
		$line{color}='white';
		$toggle=0;
	}
	$line{id} =$suppliers[$i]->{'id'};
	$line{name} = $suppliers[$i]->{'name'};
	$line{active} = $suppliers[$i]->{'active'};
	$line{total} = $orders->[0]->{'count(*)'};
	$line{authorisedby} = $orders->[0]->{'authorisedby'};
	$line{entrydate} = $orders->[0]->{'entrydate'};
	my @loop_basket;
	for (my $i2=0;$i2<$ordcount;$i2++){
		my %inner_line;
		$inner_line{basketno} =$orders->[$i2]->{'basketno'};
		$inner_line{total} =$orders->[$i2]->{'count(*)'};
		$inner_line{authorisedby} = $orders->[$i2]->{'authorisedby'};
		$inner_line{entrydate} = format_date($orders->[$i2]->{'entrydate'});
		push @loop_basket, \%inner_line;
	}
	$line{loop_basket} = \@loop_basket;
	push @loop_suppliers, \%line;
}
$template->param(loop_suppliers => \@loop_suppliers,
						supplier => $supplier,
						count => $count);

output_html_with_http_headers $query, $cookie, $template->output;
