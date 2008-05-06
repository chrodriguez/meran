#!/usr/bin/perl

# $Id: moremember.pl,v 1.33.2.1 2003/12/22 10:40:55 tipaul Exp $

# script to do a borrower enquiry/bring up borrower details etc
# Displays all the details about a borrower
# written 20/12/99 by chris@katipo.co.nz
# last modified 21/1/2000 by chris@katipo.co.nz
# modified 31/1/2001 by chris@katipo.co.nz
#   to not allow items on request to be renewed
#
# needs html removed and to use the C4::Output more, but its tricky
#


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
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Interface::CGI::Template;
use CGI;
use C4::Search;
use Date::Manip;
use C4::Date;
# use C4::Reserves2;
# use C4::Circulation::Renewals2;
use C4::Circulation::Circ2;
use C4::Koha;
use HTML::Template;

my $dbh = C4::Context->dbh;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/moremember2.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $pernum=$input->param('pernum');

#start the page and read in includes

my $data=persdata('',$pernum);
$data->{'dateenrolled'} = format_date($data->{'dateenrolled'});
$data->{'expiry'} = format_date($data->{'expiry'});
$data->{'dateofbirth'} = format_date($data->{'dateofbirth'});
$data->{'ethnicity'} = fixEthnicity($data->{'ethnicity'});
$data->{&expand_sex_into_predicate($data->{'sex'})} = 1;

if ($data->{'ethnicity'} || $data->{'ethnotes'}) {
	$template->param(printethnicityline => 1);
}


my %bor;
$bor{'personnumber'}=$pernum;

# Converts the branchcode to the branch name
$data->{'branchcode'} = &getbranchname($data->{'branchcode'});

# Converts the categorycode to the description
$data->{'categorycode'} = &getborrowercategory($data->{'categorycode'});

# Converts the citycodes to the description
$data->{'city'} = &getcitycategory($data->{'city'});
$data->{'streetcity'} = &getcitycategory($data->{'streetcity'});

my $today=ParseDate('today');

#### Verifica si la foto ya esta cargada
my $picturesDir= C4::Context->config("picturesdir");
my $foto;
if (opendir(DIR, $picturesDir)) {
	my $pattern= $pernum.".*";
	my @file = grep { /$pattern/ } readdir(DIR);
	$foto= join("",@file);
	closedir DIR;
} else {
	$foto= 0;
}
####

#### Verifica si hay problemas para subir la foto
my $msgFoto=$input->param('msg');
($msgFoto) || ($msgFoto=0);
####

$template->param($data);
$template->param(
		pernum          => $pernum,
		foto_name => $foto,
		mensaje_error_foto => $msgFoto,
	);
output_html_with_http_headers $input, $cookie, $template->output;
