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
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use HTML::Template;
use C4::Koha;

my $input = new CGI;


my $theme = $input->param('theme') || "default";
my $campoIso = $input->param('code') || ""; 
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/estadistica_Anual.tmpl",

			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my  $branch=$input->param('branch');
($branch ||($branch=(split("_",(split(";",$cookie))[0]))[1]));


my $year_Default=2005;
my @years;
for (my $i =2005 ; $i < 2036; $i++){
	push (@years,$i);
}
my $year=CGI::scrolling_list(   -name      => 'year',
				-id	   => 'year',
                                -values    => \@years,
                                -defaults  => $year_Default,
                                -size      => 1,
                                -onChange  =>'consultar()'
                                 );

my $year_selected = $input->param('year')||$year_Default;

$template->param( 
			year	  	 => $year,
			branch           => $branch,
		);

output_html_with_http_headers $input, $cookie, $template->output;
