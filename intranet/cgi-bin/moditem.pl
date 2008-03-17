#!/usr/bin/perl

# $Id: moditem.pl,v 1.7 2003/03/18 09:52:30 tipaul Exp $


#script to modify/delete biblios
#written 8/11/99
# modified 11/11/99 by chris@katipo.co.nz
# modified 12/16/02 by hdl@ifrance.com : Templating

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
require Exporter;

use C4::Search;
use CGI;
use C4::Output;
#use C4::Acquisitions;
use C4::Biblio;
use HTML::Template;
use C4::Koha;
use C4::Catalogue;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Date;

my $input = new CGI;
my $submit=$input->param('delete.x');
my $itemnum=$input->param('itemnum');
my $bibitemnum=$input->param('bibitemnum');
if ($submit ne ''){
  print $input->redirect("/cgi-bin/koha/delitem.pl?itemnum=$itemnum&bibitemnum=$bibitemnum");
}

my $data=bibitemdata($bibitemnum);
my @autorPPAL= &getautor($data->{'author'});



#my ($analytictitle)=analytic($biblionumber,'t');
#my ($analyticauthor)=analytic($biblionumber,'a');


my ($template, $loggedinuser, $cookie) = get_template_and_user({
	template_name   => 'moditem.tmpl',
	query           => $input,
	type            => "intranet",
	authnotrequired => 0,
	flagsrequired   => {editcatalogue => 1},
    });

my %inputs;
my $homebranch;

my $wthdrawn=0;
######Edicion Grupal
if ($input->param('type') eq 'ALL') {
        
$template->param(ALL => 1);

my (@items)=itemissues($input->param('bibitemnum'));
#print @items;
my @itemloop;
my $count=@items;
my $bulk;
for (my $i=0;$i<$count;$i++){
	if ($i eq 0){$bulk=$items[$i]->{'bulk'}; 
	             $homebranch= $items[$i]->{'homebranch'};}
        my %line;
        $items[$i]->{'datelastseen'} = format_date($items[$i]->{'datelastseen'});
        $line{barcode}=$items[$i]->{'barcode'};
        $line{itemnumber}=$items[$i]->{'itemnumber'};
        $line{biblionumber}=$input->param('biblio');
        $line{biblioitemnumber}=$input->param('bibitem');
        $line{holdingbranch}=$items[$i]->{'holdingbranch'};
        $line{datelastseen}=$items[$i]->{'datelastseen'};

	if (($items[$i]->{'wthdrawn'}) eq 0) {$line{wthdrawn}=''; }
	else{
	$line{wthdrawn}=" - <font size=2 color='red'>NO DISPONIBLE</font>(<font color='red' size=1>".getAvail($items[$i]->{'wthdrawn'})->{'description'}."</font>)";
	 }

	if ($items[$i]->{'notforloan'} eq 1){$line{notforloan}="<font size=2 color='blue'>PARA SALA</font>";}else {$line{notforloan}="<font size=2 color='green'>PRESTAMO</font>";}

        push(@itemloop,\%line);
}
$template->param(itemloop => \@itemloop,
		title => $data->{'title'},
	        author => $data->{'author'},
		biblionumber => $data->{'biblionumber'},
        	biblioitemnumber => $data->{'biblioitemnumber'},
		itemnumber => $itemnum,
		bulk => $bulk
		);

}   else {
###########
my $item=itemnodata('blah','',$itemnum);

$wthdrawn=$item->{'wthdrawn'};


#hash is set up with input name being the key then
#the value is a tab separated list, the first item being the input type
#$inputs{'Author'}="text\t$data->{'author'}\t0";
#$inputs{'Title'}="text\t$data->{'title'}\t1";
# FIXME - The Dewey code is a string, not a number. And "000" is a
# perfectly acceptable value.
my $dewey = $data->{'dewey'};
$dewey =~ s/0+$//;
if ($dewey eq "000.") { $dewey = "";};
if ($dewey < 10){$dewey='00'.$dewey;}
if ($dewey < 100 && $dewey > 10){$dewey='0'.$dewey;}
if ($dewey <= 0){
  $dewey='';
}
$dewey=~ s/\.$//;

if ($item->{'wthdrawn'} gt 0) {
$template->param(itemwithdrawn =>1)}

$template->param(
        title => $data->{'title'},
        author => $data->{'author'},
        barcode => $item->{'barcode'},
        publisher => $data->{'publisher'},
        publicationyear => $data->{'publicationyear'},
        pages => $data->{'pages'},
        illustration => $data->{'illustration'},
        itemnotes => $item->{'itemnotes'},
        volumeiddesc => $data->{'volumeddesc'},
        homebranch => $item->{'homebranch'},
        itemlost => ($item->{'itemlost'} ==1),
        biblionumber => $data->{'biblionumber'},
        biblioitemnumber => $data->{'biblioitemnumber'},
        notforloan => ($item->{'notforloan'}==1),
        bulk => $item->{'bulk'},
        itemnumber => $itemnum,
        classification =>"$data->{'classification'}$dewey$data->{'subclass'}",
	oldnotforloan => $item->{'notforloan'},
	oldwithdrawn => $item->{'wthdrawn'}
);


# 12/16/2002 hdl@ifrance.com : all these inputs seem unused !!!
my %inputs;

$inputs{'barcode'}="text\t$item->{'barcode'}\t0";
$inputs{'class'}="hidden\t$data->{'classification'}$dewey$data->{'subclass'}\t2";
$inputs{'itemtype'}="text\t$data->{'itemtype'}\t3";
#$inputs{'subject'}="textarea\t$sub\t4";
$inputs{'publisher'}="hidden\t$data->{'publishercode'}\t5";
$inputs{'copyrightdate'}="text\t$data->{'copyrightdate'}\t6";
$inputs{'ISBN'}="hidden\t$data->{'isbncode'}\t7";
$inputs{'publicationyear'}="hidden\t$data->{'publicationyear'}\t8";
$inputs{'pages'}="hidden\t$data->{'pages'}\t9";
$inputs{'illustrations'}="hidden\t$data->{'illustration'}\t10";
$inputs{'seriestitle'}="text\t$data->{'seriestitle'}\t11";
#$inputs{'additionalauthor'}="text\t$additional\t12";
#$inputs{'subtitle'}="text\t$subtitle->[0]->{'subtitle'}\t13";
$inputs{'unititle'}="text\t$data->{'unititle'}\t14";
$inputs{'itemnotes'}="textarea\t$item->{'itemnotes'}\t15";
$inputs{'serial'}="text\t$data->{'serial'}\t16";
$inputs{'volume'}="hidden\t$data->{'volumeddesc'}\t17";
$inputs{'homebranch'}="text\t$item->{'homebranch'}\t18";
$inputs{'Lost'}="radio\t$item->{'itemlost'}\t19";
$inputs{'Analytic author'}="text\t\t18";
$inputs{'Analytic title'}="text\t\t19";
$inputs{'bibnum'}="hidden\t$data->{'biblionumber'}\t20";
$inputs{'bibitemnum'}="hidden\t$data->{'biblioitemnumber'}\t21";
$inputs{'itemnumber'}="hidden\t$itemnum\t22";
$inputs{'bulk'}="text\t$item->{'bulk'}\t23";
$inputs{'notforloan'}="text\t$item->{'notforloan'}\t23";

$homebranch=$item->{'homebranch'};
}#fin else de edicion grupal

#12/16/2002 hdl@ifrance.com : end of comment

my @branches;
my @select_branch;
my %select_branches;
my ($count2,@branches)=branches();
for (my $i=0;$i<$count2;$i++){
        push @select_branch, $branches[$i]->{'branchcode'};#
        $select_branches{$branches[$i]->{'branchcode'}} = $branches[$i]->{'branchname'};
}


my $CGIbranch=CGI::scrolling_list( -name     => 'homebranch',
                        -values   => \@select_branch,
                        -defaults => $homebranch, 
                        -labels   => \%select_branches,
                        -size     => 1,
                        -multiple => 0 );


$template->param(CGIbranch => $CGIbranch);

## Scroll de disponibilidades
my %availlabels;
my @availtypes;

if ($wthdrawn gt 0) {
	$template->param(itemwithdrawn =>1);}
    else{$template->param(disableDisp => 1);}

 ( %availlabels) = &getavails;
        foreach my $aux ( sort { $availlabels{$a} cmp $availlabels{$b} } keys(%availlabels)){
        push(@availtypes,$aux);}
        my $Cavails=CGI::scrolling_list(-name      => 'unavailable',
                                        -id        => 'unavailable',
                                        -values    => \@availtypes,
                                        -defaults => $wthdrawn, 
                                        -labels    => \%availlabels,
                                        -size      => 1,
                                        -multiple  => 0,
                                 );


$template->param(Cavails => $Cavails);



print $input->header(
        -type => C4::Interface::CGI::Output::guesstype($template->output),
        -expires=>'now'
), $template->output;

#print "Content-Type: text/html\n\n", $template->output;
#12/16/2002 hdl@ifrance.com : templating
