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
use C4::Reserves2;

use C4::Auth;
use C4::Interface::CGI::Output;
use HTML::Template;

my $MAXIMUM_NUMBER_OF_RESERVES = C4::Context->preference("maxreserves");


my $input = new CGI;
#print $input->header;

my @bibitems=$input->param('biblioitem');
my @reqbib=$input->param('reqbib');
my $biblio=$input->param('biblio');
my $borrower=$input->param('member');
my $notes=$input->param('notes');
my $branch=$input->param('pickup');
my @rank=$input->param('rank-request-'.$input->param('reqbib'));
#
my $already=0;
my $tomuch=0;
#
my $type=$input->param('type');
my $title=$input->param('title');
my $bornum=borrdata($borrower,'');
#if ($type eq 'str8' && $bornum ne ''){
#    my $count=@bibitems;
#    @bibitems=sort @bibitems;
#    my $i2=1;
#    my @realbi;
#    $realbi[0]=$bibitems[0];
#for (my $i=1;$i<$count;$i++){
#    my $i3=$i2-1;
#    if ($realbi[$i3] ne $bibitems[$i]){
#	$realbi[$i2]=$bibitems[$i];
#	$i2++;
#    }
#}
#}

if ($reqbib[0] ne '') {
 ##Matias - para que sea una reserva de un grupo por persona
                                                                                                                             
       my ($resnum, @reserves) = Findgroupreserve($reqbib[0],$biblio);
        for (my $i=0;$i<$resnum;$i++){
            if ($reserves[$i]->{'borrowernumber'} eq $bornum->{'borrowernumber'}) {
                $already = 1;
		}}

##No se puede pasar de la maxima cantidad de reservas
my ($ren, $res) = FindReserves('', $bornum->{'borrowernumber'});
 if ($ren >= $MAXIMUM_NUMBER_OF_RESERVES) 
	{$tomuch=1;}

if (($already eq 0) && ($tomuch eq 0) && ($bornum->{'borrowernumber'} ne '')) {
#

my $env;
my $const;
if ($input->param('request') eq 'any'){
  $const='a';
 # CreateReserve(\$env,$branch,$bornum->{'borrowernumber'},$biblio,$const,\@realbi,$rank[0],$notes,$title);
} elsif ($reqbib[0] ne ''){
  $const='o';
#Matias faltaba la fecha
  my @datearr = localtime(time);
  my $today =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
#                                                                                                    
  CreateReserve(\$env,$branch,$bornum->{'borrowernumber'},$biblio,$const,\@reqbib,$rank[0],$notes,$title,'',$today);
} else {
#  CreateReserve(\$env,$branch,$bornum->{'borrowernumber'},$biblio,'a',\@realbi,$rank[0],$notes,$title);
}
#print @realbi;
}


print $input->redirect("request.pl?bib=$biblio");

							}



my ($template, $loggedinuser, $cookie) = get_template_and_user(
			{template_name => "placerequest.tmpl",
                             query => $input,
                             type => "intranet",
                             authnotrequired => 0,
                            flagsrequired => {parameters => 1}
                            });

if ($reqbib[0] eq '') { $template->param(nosel => 1 );}
else {
if ($bornum->{'borrowernumber'} eq '')
	{ 	
	if ($borrower eq ''){ $template->param(nobornum => 1 ); }	
	else { $template->param(bornum => $borrower );}}

}
$template->param(biblio => $biblio,
		bibitem=> $rank[0],
		title => $title,
		borrower => $borrower,
		notes => $notes,
		pickup => $branch,
		type => $type,
		already=> $already,
		tomucho=>$tomuch); 


output_html_with_http_headers $input, $cookie, $template->output;

