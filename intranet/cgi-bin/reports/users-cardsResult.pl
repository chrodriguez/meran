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
#

use strict;
use C4::Auth;
use C4::Output;
use C4::Koha;
use C4::Search;
use C4::Interface::CGI::Output;
use CGI;
use HTML::Template;
use PDF::Report;
use C4::AR::PdfGenerator;

my $input = new CGI;

my $orden=$input->param('orden');
my $op=$input->param('op');
my $surname1=$input->param('surname1');
my $surname2=$input->param('surname2');
my $legajo1=$input->param('legajo1');
my $legajo2=$input->param('legajo2');
my $category=$input->param('category');
my $regular=$input->param('regular');
my $branch=$input->param('branch');
my $count=0;
my @results=();


if ($op ne ''){
 ($count,@results)=BornameSearchForCard($surname1,$surname2,$category,$branch,$orden,$regular,$legajo1,$legajo2);
}


my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/users-cardsResult.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

#Se realiza la busqueda si al algun campo no vacio
$template->param(
		RESULTSLOOP=>\@results,
                cantidad=>$count
	               );

output_html_with_http_headers $input, $cookie, $template->output;

