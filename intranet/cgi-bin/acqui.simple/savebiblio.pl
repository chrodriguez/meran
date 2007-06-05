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

use CGI;
use strict;
use C4::Catalogue;
use C4::Biblio;
use C4::Auth;

my $input = new CGI;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{ editcatalogue => 1});
my $responsable=$input->param('userloggedname');
my $biblio = {
    title       => $input->param('title'),
    subtitle    => $input->param('subtitle')?$input->param('subtitle'):"",
    author      => $input->param('author')?$input->param('author'):"",
    unititle   => $input->param('unititle')?$input->param('unititle'):"",
    abstract    => $input->param('abstract')?$input->param('abstract'):"",
    notes       => $input->param('notes')?$input->param('notes'):"",
    #Campos agregados seriestitle es CDU
    seriestitle => $input->param('seriestitle')?$input->param('seriestitle'):"",
    responsability => $input->param('responsability')?$input->param('responsability'):"",
    additionalauthors => $input->param('additionalauthors')?$input->param('additionalauthors'):"",
    colaboradores => $input->param('colaboradores')?$input->param('colaboradores'):"",
    subjectheadings   => $input->param('subjectheadings')?$input->param('subjectheadings'):""
}; # my $biblio
my $biblionumber;
my $cdunumber;

if (! $biblio->{'title'}) {
    print $input->redirect('addbiblio-nomarc.pl?error=notitle');
} else {

    $biblionumber = &newbiblio($biblio,$responsable);
    $cdunumber = $biblio->{'seriestitle'};
    #&newsubtitle($biblionumber, $biblio->{'subtitle'});

    #print $input->redirect("additem-nomarc.pl?biblionumber=$biblionumber");
    print $input->redirect("additem-nomarc.pl?biblionumber=$biblionumber&bulk=$cdunumber");
} # else
