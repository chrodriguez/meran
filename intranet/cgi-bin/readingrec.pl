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
use C4::Date;
use C4::Interface::CGI::Output;
use CGI;
use C4::Search;
use C4::AR::Issues;
use HTML::Template;
use C4::AR::Estadisticas;
my $input=new CGI;


my $bornum=$input->param('bornum');
my $orden=$input->param('order')||'date_due';

#get borrower details
my $data=borrdata('',$bornum);

my $ini;
my $pageNumber;
my $cantR=cantidadRenglones();

if (($input->param('ini') eq "")){
        $ini=0;
	$pageNumber=1;
}
else {
	$ini= ($input->param('ini')-1)* $cantR;
	$pageNumber= $input->param('ini');
};

my ($cant,$issues)=allissues($bornum,$ini,$cantR,$orden);

my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "members/readingrec.tmpl",
				query => $input,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {borrowers => 1},
				debug => 1,
				});

my @loop_reading;
my $classe='par';
for (my $i=0;$i< $cantR;$i++){
if ($issues->[$i]->{'biblionumber'}){
 	my %line;
	$line{title}=$issues->[$i]->{'title'};
	$line{unititle}=$issues->[$i]->{'unititle'};
	$line{author}=$issues->[$i]->{'author'};
	$line{idauthor}=$issues->[$i]->{'id'};
	$line{biblionumber}=$issues->[$i]->{'biblionumber'};
	$line{biblioitemnumber}=$issues->[$i]->{'biblioitemnumber'};
	$line{itemnumber}=$issues->[$i]->{'itemnumber'};
	$line{bulk}=$issues->[$i]->{'bulk'};
	$line{barcode}=$issues->[$i]->{'barcode'};
 	$line{date_due}=$issues->[$i]->{'date_due'};
    	$line{date_fin} = $issues->[$i]->{'date_fin'};
	$line{date_renew}="-";
 	if ($issues->[$i]->{'renewals'}){$line{date_renew}=$issues->[$i]->{'lastreneweddate'};}
	$line{returndate}=$issues->[$i]->{'returndate'};
	$line{volumeddesc}=$issues->[$i]->{'volumeddesc'};
	($line{grupos})=Grupos($issues->[$i]->{'biblionumber'},'intra');
	if ( $classe eq 'par' ) { $classe = 'impar'; } else {$classe = 'par'; }
        $line{clase}=$classe;
	push(@loop_reading,\%line);
	}
}

my @numeros=armarPaginas($cant,$pageNumber);
my $paginas = scalar(@numeros)||1;
my $pagActual = $input->param('ini')||1;
$template->param( paginas   => $paginas,
		  actual    => $pagActual);

if ( $cant > $cantR ){
#Seteo las flechas de siguiente y anterior
       	my $sig = $pageNumber+1;;
        if ($sig <= $paginas){
       	         $template->param(
               	                ok    =>'1',
                       	        sig   => $sig);
        };

	if ($sig > 2 ){
               my $ant = $pageNumber-1;
               $template->param(
                               ok2     => '1',
                               ant     => $ant)
	}
}

$template->param(
		cant  => $cant,
		numeros => \@numeros,
		title => $data->{'title'},
		initials => $data->{'initials'},
		surname => $data->{'surname'},
		bornum => $bornum,
		firstname => $data->{'firstname'},
		cardnumber => $data->{'cardnumber'},
		showfulllink => ($cant > 50),
		orden =>$orden,
		loop_reading => \@loop_reading
		);
output_html_with_http_headers $input, $cookie, $template->output;



