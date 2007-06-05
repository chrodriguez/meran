package C4::Interface::FlagsCDK; #asummes C4/Interface/FlagsCDK


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

# FIXME - I'm pretty sure that this, along with the rest of the
# CDK-based stuff, is obsolete.

use C4::Format;
use C4::InterfaceCDK;
use strict;

require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&trapscreen &trapsnotes &reservesdisplay);

sub trapscreen {
  my ($env,$bornum,$borrower,$amount,$traps_set)=@_;
  my $titlepanel = C4::InterfaceCDK::titlepanel($env,$env->{'sysarea'},"Borrower Flags");
  my @borinfo;
  #debug_msg($env,"owwing = $amount");
  my $borpanel = C4::InterfaceCDK::borrowerbox($env,$borrower,$amount);
  $borpanel->draw();
  my $hght = @$traps_set+4;
  my $flagsset = new Cdk::Scroll ('Title'=>"Act On Flag",
      'List'=>\@$traps_set,'Height'=>$hght,'Width'=>15,
      'Xpos'=>4,'Ypos'=>3);
  my $act =$flagsset->activate();
  my $action;
  if (!defined $act) {
    $action = "NONE";
  } else {
    $action = @$traps_set[$act];
  }
  undef $titlepanel;
  undef $flagsset;
  undef $borpanel;
  return($action);
}

sub trapsnotes {
  my ($env,$bornum,$borrower,$amount) = @_;
  my $titlepanel = C4::InterfaceCDK::titlepanel($env,$env->{'sysarea'},"Borrower Notes");
  my $borpanel = C4::InterfaceCDK::borrowerbox($env,$borrower,$amount);
  $borpanel->draw();
  my $notesbox = new Cdk::Mentry ('Label'=>"Notes:  ",
    'Width'=>40,'Prows'=>10,'Lrows'=>30,
    'Lpos'=>"Top",'Xpos'=>"RIGHT",'Ypos'=>10);
  my $ln = length($borrower->{'borrowernotes'});
  my $x = 0;
  while ($x < $ln) {
    my $y = substr($borrower->{'borrowernotes'},$x,1);
    $notesbox->inject('Input'=>$y);
    $x++;
  }
  my $notes =  $notesbox->activate();
  if (!defined $notes) {
    $notes = $borrower->{'borrowernotes'};
  } else {
    while (substr($notes,0,1) eq " ") {
      my $temp;
      if (length($notes) == 1) {
        $temp = "";
      } else {
        $temp = substr($notes,1,length($notes)-1);
      }
      $notes = $temp;
    }
  }
  undef $notesbox;
  undef $borpanel;
  undef $titlepanel;
  return $notes;
}

sub reservesdisplay {
  my ($env,$borrower,$amount,$odues,$items) = @_;
  my $titlepanel = C4::InterfaceCDK::titlepanel($env,$env->{'sysarea'},"Reserves Waiting");
  my $borpanel = C4::InterfaceCDK::borrowerbox($env,$borrower,$amount);
  $borpanel->draw();
  my $x = 0;
  my @itemslist;
  while (@$items[$x] ne "") {
    my $itemdata = @$items[$x];
    my $itemrow = fmtstr($env,$itemdata->{'holdingbranch'},"L6");
    $itemrow = $itemrow.$itemdata->{'title'}.": ".$itemdata->{'author'};
    $itemrow = fmtstr($env,$itemrow,"L68").$itemdata->{'itemtype'};
    @itemslist[$x] = $itemrow;
    $x++;
  }
  my $reslist = new Cdk::Scroll('Title'=>"",'List'=>\@itemslist,
    'Height'=>10,'Width'=>76,'Xpos'=>1,'Ypos'=>10);
  $reslist->activate();
  undef $reslist;
  undef $borpanel;
  undef $titlepanel;
}

END { }       # module clean-up code here (global destructor)
