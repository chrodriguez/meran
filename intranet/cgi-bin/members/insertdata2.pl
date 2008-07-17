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
use Date::Manip;
use C4::Date;
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
my $dateformat = C4::Date::get_date_format();

my $queryb="Select * from borrowers where borrowernumber=?";
my $sthb=$dbh->prepare($queryb);
$sthb->execute($data->{'borrowernumber'});
if (my $data2=$sthb->fetchrow_hashref){
  $data->{'dateofbirth'}=format_date_in_iso($data->{'dateofbirth'},$dateformat);
  $data->{'joining'}=format_date_in_iso($data->{'joining'},$dateformat);
  $data->{'expiry'}=format_date_in_iso($data->{'expiry'},$dateformat);

##
 updateborrower($data); #Se actualiza en borrower
##
}

my $query="Select * from persons where personnumber=?";
my $sth=$dbh->prepare($query);
$sth->execute($data->{'personnumber'});
if (my $data2=$sth->fetchrow_hashref){
  $data->{'dateofbirth'}=format_date_in_iso($data->{'dateofbirth'},$dateformat);
  $data->{'joining'}=format_date_in_iso($data->{'joining'},$dateformat);
  $data->{'expiry'}=format_date_in_iso($data->{'expiry'},$dateformat);

  ##
  updateperson($data); #Se actualiza en person
  ##
  
}

#Esto iria si se permitiera agregar nuevos usuarios factibles 
=item
else{
  $data{'dateofbirth'}=format_date_in_iso($data{'dateofbirth'},$dateformat);
  $data{'joining'}=format_date_in_iso($data{'joining'},$dateformat);
  $data{'expiry'}=format_date_in_iso($data{'expiry'},$dateformat);
  $data{'borrowernumber'}=NewBorrowerNumber();
  $query="insert into borrowers (title,expiry,cardnumber,sex,ethnotes,streetaddress,faxnumber,
  firstname,altnotes,dateofbirth,contactname,emailaddress,textmessaging,dateenrolled,streetcity,
  altrelationship,othernames,phoneday,categorycode,city,area,phone,borrowernotes,altphone,surname,
  initials,ethnicity,physstreet,branchcode,zipcode,homezipcode,documenttype,documentnumber,studentnumber) values ('$data{'title'}','$data{'expiry'}','$data{'cardnumber'}',
  '$data{'sex'}','$data{'ethnotes'}','$data{'address'}','$data{'faxnumber'}',
  '$data{'firstname'}','$data{'altnotes'}','$data{'dateofbirth'}','$data{'contactname'}','$data{'emailaddress'}','$data{'textmessaging'}',
  '$data{'joining'}','$data{'streetcity'}','$data{'altrelationship'}','$data{'othernames'}',
  '$data{'phoneday'}','$data{'categorycode'}','$data{'city'}','$data{'area'}','$data{'phone'}',
  '$data{'borrowernotes'}','$data{'altphone'}','$data{'surname'}','$data{'initials'}',
  '$data{'ethnicity'}','$data{'streetaddress'}','$data{'branchcode'}','$data{'zipcode'}','$data{'homezipcode'}',
	'$data{'documenttype'}','$data{'documentnumber'}', '$data{'studentnumber'}')";
}
# ok if its an adult (type) it may have borrowers that depend on it as a guarantor
# so when we update information for an adult we should check for guarantees and update the relevant part
# of their records, ie addresses and phone numbers

if ($data{'categorycode'} eq 'A' || $data{'categorycode'} eq 'W'){
    # is adult check guarantees;
    my ($count,$guarantees)=findguarantees($data{'borrowernumber'});
    for (my $i=0;$i<$count;$i++){
	# FIXME
	# It looks like the $i is only being returned to handle walking through
	# the array, which is probably better done as a foreach loop.
	#
	my $guaquery="update borrowers set streetaddress='$data{'address'}',faxnumber='$data{'faxnumber'}',
        streetcity='$data{'streetcity'}',phoneday='$data{'phoneday'}',city='$data{'city'}',area='$data{'area'}',phone='$data{'phone'}'
        ,streetaddress='$data{'address'}'
        where borrowernumber='$guarantees->[$i]->{'borrowernumber'}'";
        my $sth3=$dbh->prepare($guaquery);
        $sth3->execute;
        $sth3->finish;
     }
}
=cut

$sth->finish;
$sthb->finish;
print $input->redirect("/cgi-bin/koha/moremember2.pl?pernum=$data{'personnumber'}");
