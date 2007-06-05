package C4::Interface::AccountsCDK; #asummes C4/Interface/AccountsCDK

#uses Newt

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

use C4::InterfaceCDK;
use C4::Accounts2;
use strict;

require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;
@ISA = qw(Exporter);
@EXPORT = qw(&accountsdialog);

sub accountsdialog {
  my ($env,$title,$borrower,$accountlines,$amountowing)=@_;
  my $titlepanel = titlepanel($env,$env->{'sysarea'},"Money Owing");
  my @borinfo;
  my $reason;
  #$borinfo[0]  = "$borrower->{'cardnumber'}";
  #$borinfo[1] = "$borrower->{'surname'}, $borrower->{'title'} $borrower->{'firstname'} ";
  #$borinfo[2] = "$borrower->{'streetaddress'}, $borrower->{'city'}";
  #$borinfo[3] = "<R>Total Due:  </B>".fmtdec($env,$amountowing,"52");
  #my $borpanel =
  #  new Cdk::Label ('Message' =>\@borinfo, 'Ypos'=>4, 'Xpos'=>"RIGHT");
  my $borpanel = borrowerbox($env,$borrower,$amountowing);
  $borpanel->draw();
  my @sel = ("N ","Y ");
  my $acctlist = new Cdk::Selection ('Title'=>"Outstanding Items",
      'List'=>\@$accountlines,'Choices'=>\@sel,'Height'=>12,'Width'=>80,
      'Xpos'=>1,'Ypos'=>10);
  my @amounts=$acctlist->activate();
  my $accountno;
  my $amount2;
  my $count=@amounts;
  my $amount;
  my $check=0;
  for (my $i=0;$i<$count;$i++){
    if ($amounts[$i] == 1){
      $check=1;
      if ($accountlines->[$i]=~ /(^[0-9]+)/){
        $accountno=$1;
      }
      if ($accountlines->[$i]=~/([0-9]+\.[0-9]+)/){
        $amount2=$1;
      }
      my $borrowerno=$borrower->{'borrowernumber'};
      makepayment($borrowerno,$accountno,$amount2);
      $amount+=$amount2;
    }
  }
  my $amountentry = new Cdk::Entry('Label'=>"Amount:  ",
     'Max'=>"10",'Width'=>"10",
     'Xpos'=>"1",'Ypos'=>"3",
     'Type'=>"INT");
  $amountentry->preProcess ('Function' => sub{preamt(@_,$env,$acctlist);});
  #

  if ($amount eq ''){
    $amount =$amountentry->activate();
  } else {
    $amountentry->set('Value'=>$amount);
    $amount=$amountentry->activate();
  }
#  debug_msg($env,"accounts $amount barcode=$accountno");
  if (!defined $amount) {
     #debug_msg($env,"escaped");
     #$reason="Finished user";
  }
  $borpanel->erase();
  $acctlist->erase();
  $amountentry->erase();
  undef $acctlist;
  undef $borpanel;
  undef $borpanel;
  undef $titlepanel;
  if ($check == 1){
    $amount=0;
  }
  return($amount,$reason);
}

sub preamt {
  my ($input,$env,$acctlist)= @_;
  my $key_tab  = chr(9);
  if ($input eq $key_tab) {
    actlist ($env,$acctlist);
    return 0;
  }
  return 1;
}

sub actlist {
  my ($env,$acctlist) = @_;
  $acctlist->activate();
}


END { }       # module clean-up code here (global destructor)
