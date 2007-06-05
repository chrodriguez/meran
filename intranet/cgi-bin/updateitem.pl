#!/usr/bin/perl

# $Id: updateitem.pl,v 1.8.2.1 2004/01/08 16:34:36 slef Exp $

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
use CGI;
use C4::Context;
use C4::Biblio;
use C4::Output;
use C4::Circulation::Circ2;
use C4::Accounts2;
use C4::Search;
#my $env;
my $input= new CGI;

my $bibnum=checkinp($input->param('bibnum'));
my $bibitemnum=checkinp($input->param('bibitemnum'));
my $bulk=$input->param('bulk');


my $notforloan=$input->param('notforloan');

my $wthdrawn=0;
if ($input->param('withdrawn') eq 1) {$wthdrawn=$input->param('unavailable');}

my $homebranch=checkinp($input->param('homebranch'));
my $responsable=$input->param('userloggedname');

 my $cantunavail=0;
 my $msg='';

###Edicion Grupal
if ($input->param('type') eq 'ALL'){

 my (@items) = itemsfrombiblioitem($bibitemnum);
 my $count   = @items;
 my $cant=0;
#go thru items assing selected ones to group
  for (my $i=0;$i<$count;$i++){
    my $temp="check_group_".$items[$i]->{'barcode'};
    my $barcode=$input->param($temp);

    if ($barcode ne ''){
	my $itemnumber= $items[$i]->{'itemnumber'};
	my $notes=$items[$i]->{'notes'};
	if($input->param('act') eq 'delete'){ #la operacion es de borrado
	if (canDeleteItem($itemnumber) eq 1) {$cant=1;} 
		else {delitem($itemnumber,$input->param('userloggedname'));}
		}
	else{#la operacion es actualizar
	if(($wthdrawn ne 0)&&(canDeleteItem($itemnumber) eq 1)){$cantunavail=1;}
	else{
#	updateItemAvail($itemnumber,$bibnum,$bibitemnum,$wthdrawn,$notforloan,$homebranch,$bulk);
	
	moditem( { biblionumber => $bibnum,
             itemnumber      => $itemnumber,
             bibitemnum   => $bibitemnum,
             homebranch   => $homebranch,
             wthdrawn     => $wthdrawn,
             notforloan => $notforloan,
	     barcode      => $items[$i]->{'barcode'},
             notes        => $notes,
             bulk =>$bulk},$responsable);

	changeAvailability($itemnumber,$wthdrawn,$notforloan,$homebranch);
	
	}	
	}

    }#if
  }#for
			
 if($input->param('act') eq 'delete'){
	if ($cant eq 1){$msg="&msg=noitemsdelete";}
	if ($cantunavail eq 1){$msg="&msg=noitemunavail";}
	print $input->redirect("/cgi-bin/koha/detail.pl?type=intra&bib=$bibnum".$msg); 
	}



}else{
###

my $itemnumber=checkinp($input->param('itemnumber'));
my $notes=checkinp($input->param('itemnotes'));

#need to do barcode check
my $barcode=$input->param('barcode');

my $oldwthdrawn   =$input->param('oldwithdrawn');
my $oldnotforloan =$input->param('oldnotforloan');
if(($wthdrawn ne 0)&&(canDeleteItem($itemnumber) eq 1)){$cantunavail=1;
							$msg="&msg=noitemunavail";}

if($cantunavail eq 0){

if (($oldwthdrawn ne $wthdrawn)or ($oldnotforloan ne $notforloan)) {changeAvailability($itemnumber,$wthdrawn,$notforloan,$homebranch)};
my $responsable=$input->param('userloggedname');


if ((checkitems(1,$barcode))&&($wthdrawn ne 2)){#Se chequea el barcode  salvo que este compartido
	$msg="&msg=barcodeinuse";
	}
else {
moditem( { biblionumber => $bibnum,
	     itemnumber      => $itemnumber,
	     bibitemnum   => $bibitemnum,
	     barcode      => $barcode,
	     notes        => $notes,
	     homebranch   => $homebranch,
	     wthdrawn     => $wthdrawn,
	     notforloan => $notforloan,	
	     bulk =>$bulk},$responsable);
}
}

## fin else de Edicion grupal
}
##
#print $input->redirect("moredetail.pl?type=intra&bib=$bibnum&bi=$bibitemnum");
print $input->redirect("detail.pl?type=intra&bib=$bibnum".$msg);

sub checkinp{
  my ($inp)=@_;
  $inp=~ s/\'/\\\'/g;
  $inp=~ s/\"/\\\"/g;
  return($inp);
}
