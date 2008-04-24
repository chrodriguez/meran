#!/usr/bin/perl

#script to enter borrower data into the data base
#needs to be moved into a perl module
# written 9/11/99 by chris@katipo.co.nz


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

use CGI;
use Digest::MD5 qw(md5_base64);
use C4::AR::Authldap;
use C4::Membersldap;
use C4::Context;
# use C4::Input;
use C4::Search;
use Date::Manip;
use C4::Date;
use C4::AR::Persons_Members;

use strict;

my $input= new CGI;

#get all the data into a hash
my @names=$input->param;
my $data;
my $keyfld;
my $keyval;
my $problems;
my $env;
foreach my $key (@names){
  $data->{$key}=$input->param($key);
  $data->{$key}=~ s/\'/\\\'/g;
  $data->{$key}=~ s/\"/\\\"/g;
}
my $dbh = C4::Context->dbh;
my $query="Select * from borrowers where borrowernumber=?";
my $sth=$dbh->prepare($query);
$sth->execute($data->{'borrowernumber'});
if (my $data2=$sth->fetchrow_hashref){
  $data->{'dateofbirth'}=format_date_in_iso($data->{'dateofbirth'});
  $data->{'joining'}=format_date_in_iso($data->{'joining'});
  $data->{'expiry'}=format_date_in_iso($data->{'expiry'});
  if ($data->{'updatepassword'} && ($data->{'updatepassword'} eq 'on')) {
	$data->{'updatepassword'}=1;
  } else {
	$data->{'updatepassword'}=0;
  }

	# Curso de usuarios#
  	if (C4::Context->preference("usercourse") && $data->{'usercourse'} && ($data->{'usercourse'} eq 'on')) {
	$data->{'usercourse'}=1;
  	} else {
	$data->{'usercourse'}=0;
  	}
	####################
##
 updateborrower($data); #Se actualiza en borrower
##

 $query="Select * from persons where borrowernumber=?";
my $sth=$dbh->prepare($query);
$sth->execute($data->{'borrowernumber'});
if (my $data2=$sth->fetchrow_hashref){
  $data->{'dateofbirth'}=format_date_in_iso($data->{'dateofbirth'});
  $data->{'joining'}=format_date_in_iso($data->{'joining'});
  $data->{'expiry'}=format_date_in_iso($data->{'expiry'});

##
$data->{'personnumber'}=$data2->{'personnumber'};
updateperson($data); #Se actualiza en person
##

}


}else{
  $data->{'dateofbirth'}=format_date_in_iso($data->{'dateofbirth'});
  $data->{'joining'}=format_date_in_iso($data->{'joining'});
  $data->{'expiry'}=format_date_in_iso($data->{'expiry'});
  if ($data->{'updatepassword'} && ($data->{'updatepassword'} eq 'on')) {
	$data->{'updatepassword'}=1;
  } else {
	$data->{'updatepassword'}=0;
  }

	# Curso de usuarios#
  	if (C4::Context->preference("usercourse") && $data->{'usercourse'} && ($data->{'usercourse'} eq 'on')) {
	$data->{'usercourse'}=1;
  	} else {
	$data->{'usercourse'}=0;
  	}
	####################
 

  $data->{'borrowernumber'}=addborrower($data); #Se agregar en borrower

### Added by Luciano, when a new borrower is inserted the documentnumber is set as password
  my $digest= md5_base64($data->{'documentnumber'});
  if (C4::Context->preference("ldapenabled") eq "yes") { # update the ldap password
    addupdateldapuser($dbh,$data->{'cardnumber'},$digest);
  } else { # update the database password
    $sth=$dbh->prepare("update borrowers set password=? where cardnumber=?");
    $sth->execute($digest,$data->{'cardnumber'});
  }
### Added by Luciano

}
# ok if its an adult (type) it may have borrowers that depend on it as a guarantor
# so when we update information for an adult we should check for guarantees and update the relevant part
# of their records, ie addresses and phone numbers

if ($data->{'categorycode'} eq 'A' || $data->{'categorycode'} eq 'W'){
    # is adult check guarantees;
    my ($count,$guarantees)=findguarantees($data->{'borrowernumber'});
    for (my $i=0;$i<$count;$i++){
	# FIXME
	# It looks like the $i is only being returned to handle walking through
	# the array, which is probably better done as a foreach loop.
	#
	my $guaquery="update borrowers set streetaddress='$data->{'address'}',faxnumber='$data->{'faxnumber'}',
        streetcity='$data->{'streetcity'}',phoneday='$data->{'phoneday'}',city='$data->{'city'}',area='$data->{'area'}',phone='$data->{'phone'}'
        ,streetaddress='$data->{'address'}'
        where borrowernumber='$guarantees->[$i]->{'borrowernumber'}'";
        my $sth3=$dbh->prepare($guaquery);
        $sth3->execute;
        $sth3->finish;
     }
}

 $sth->finish;

print $input->redirect("/cgi-bin/koha/moremember.pl?bornum=$data->{'borrowernumber'}");
