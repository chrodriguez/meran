#!/usr/bin/perl

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
#use DBI;
use C4::Search;
use CGI;
use C4::Output;
use C4::AR::VirtualLibrary;
use C4::Auth;
use C4::Interface::CGI::Output;
use HTML::Template;

my $input = new CGI;
#print $input->header;

my $bibitems=$input->param('reqbib');
my $biblio=$input->param('biblio');
my $borrower=$input->param('member');
my $branch=$input->param('pickup');

my $already=0;
my $tomuchp=0;
my $tomuchc=0;

my $type=$input->param('type');
my $title=$input->param('title');
my $bornum=borrdata($borrower,'');

if ($bibitems ne '') {
 ##Matias - para que sea un pedido de un grupo por persona
                                                                                                                             
       my ($reqnum, @request) = virtualRequests($bibitems);
        for (my $i=0;$i<$reqnum;$i++){
            if ($request[$i]->{'borrowernumber'} eq $bornum->{'borrowernumber'}) {
                $already = 1;
		}}

##No se puede pasar de la maxima cantidad de Pedidos
my $type = requestType($bibitems);

 if ($type eq 'copy') { if(canCopy($bornum->{'borrowernumber'}) eq 0 ){$tomuchc=1;}}
	elsif (canPrint($bornum->{'borrowernumber'}) eq 0 ){$tomuchp=1;}
								

if (($already eq 0) && ($tomuchp eq 0) &&($tomuchc eq 0)&& ($bornum->{'borrowernumber'} ne '')) {

  my @datearr = localtime(time);
  my $today =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];

  CreateRequest($branch,$bornum->{'borrowernumber'},$bibitems,$today);


print $input->redirect("virtualrequest.pl?bib=$biblio");

							}
}


my ($template, $loggedinuser, $cookie) = get_template_and_user(
			{template_name => "virtual/virtualplacerequest.tmpl",
                             query => $input,
                             type => "intranet",
                             authnotrequired => 0,
                            flagsrequired => {parameters => 1}
                            });

if ($bibitems eq '') { $template->param(nosel => 1 );}
else {
if ($bornum->{'borrowernumber'} eq '')
	{ 	
	if ($borrower eq ''){ $template->param(nobornum => 1 ); }	
	else { $template->param(bornum => $borrower );}}

}
$template->param(biblio => $biblio,
		title => $title,
		borrower => $borrower,
		pickup => $branch,
		type => $type,
		already=> $already,
		tomuchp=>$tomuchp,
		tomuchc=>$tomuchc); 

if ($tomuchp eq 1) {
	$template->param(
			 maxPrint=> C4::Context->preference("maxvirtualprint"),
        		printRenew=> C4::Context->preference("virtualprintrenew")
			);	
		  }

if ($tomuchc eq 1) {
        $template->param(
                         maxCopy => C4::Context->preference("maxvirtualcopy"),
                        copyRenew => C4::Context->preference("virtualcopyrenew")
                        );
                  }


output_html_with_http_headers $input, $cookie, $template->output;

