#!/usr/bin/perl


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
use C4::Context;
use C4::Output;  # contains gettemplate
use C4::Search;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::Biblio;
use C4::Output;
use HTML::Template;

my $input       = new CGI;
my $bibnum      = checkinp($input->param('biblionumber'));

my $flagsrequired;
$flagsrequired->{editcatalogue}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0, $flagsrequired,"intranet");

my $biblio = {
	biblionumber => $bibnum,
	title        => $input->param('title')?$input->param('title'):"",
	author       => $input->param('author')?$input->param('author'):"",
	abstract     => $input->param('abstract')?$input->param('abstract'):"",
	subtitle    => $input->param('subtitle')?$input->param('subtitle'):"",
	seriestitle  => $input->param('seriestitle')?$input->param('seriestitle'):"",
	serial       => $input->param('serial')?$input->param('serial'):"",
	unititle     => $input->param('unititle')?$input->param('unititle'):"",
	responsability     => $input->param('responsability')?$input->param('responsability'):"",
	notes        => $input->param('notes')?$input->param('notes'):"",
	additionalauthors => $input->param('additionalauthors')?$input->param('additionalauthors'):"",
	colaboradores => $input->param('colaboradores')?$input->param('colaboradores'):"",
	subjectheadings   => $input->param('subjectheadings')?$input->param('subjectheadings'):""
  
}; # my $biblio

&modbiblio($biblio, $loggedinuser);

     if ( $input->param('from') eq 'additem') {print $input->redirect("acqui.simple/additem-nomarc.pl?type=intra&biblionumber=$bibnum"); }
             else { print $input->redirect("detail.pl?type=intra&bib=$bibnum");}
	     

sub checkinp{
  my ($inp)=@_;
  $inp=~ s/\'/\\\'/g;
  $inp=~ s/\"/\\\"/g;
  return($inp);
}
