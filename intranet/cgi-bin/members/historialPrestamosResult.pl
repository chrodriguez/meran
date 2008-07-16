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
use C4::Date;
use C4::Interface::CGI::Output;
use CGI;

my $input=new CGI;

my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "members/historialPrestamosResult.tmpl",
				query => $input,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {borrowers => 1},
				debug => 1,
				});

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $bornum=$obj->{'borrowernumber'};
my $orden=$obj->{'orden'}||'date_due';
my $ini=$obj->{'ini'}||'';
my $funcion=$obj->{'funcion'};

my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

my ($cant,$issues)=C4::AR::Issues::historialPrestamos($bornum,$ini,$cantR,$orden);

&C4::AR::Utilidades::crearPaginador($template, $cant,$cantR, $pageNumber,$funcion);

my @loop_reading;
for (my $i=0;$i< $cantR;$i++){
   if ($issues->[$i]->{'id1'}){
 	my %line;
	$line{titulo}=$issues->[$i]->{'titulo'};
	$line{unititle}=$issues->[$i]->{'unititle'};
	$line{autor}=$issues->[$i]->{'autor'};
	$line{idautor}=$issues->[$i]->{'id'};
	$line{id1}=$issues->[$i]->{'id1'};
	$line{id2}=$issues->[$i]->{'id2'};
	$line{id3}=$issues->[$i]->{'id3'};
	$line{signatura_topografica}=$issues->[$i]->{'signatura_topografica'};
	$line{barcode}=$issues->[$i]->{'barcode'};
 	$line{date_due}=$issues->[$i]->{'date_due'};
    	$line{date_fin} = $issues->[$i]->{'date_fin'};
	$line{date_renew}="-";
 	if ($issues->[$i]->{'renewals'}){$line{date_renew}=$issues->[$i]->{'lastreneweddate'};}
	$line{returndate}=$issues->[$i]->{'returndate'};
	$line{volumeddesc}=$issues->[$i]->{'volumeddesc'};
	($line{grupos})=C4::Search::Grupos($issues->[$i]->{'id1'},'intra');
	push(@loop_reading,\%line);
   }
}

$template->param(
		cant  => $cant,
		bornum => $bornum,
		showfulllink => ($cant > 50),
		loop_reading => \@loop_reading
		);
output_html_with_http_headers $input, $cookie, $template->output;
