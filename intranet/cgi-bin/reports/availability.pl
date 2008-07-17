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
use C4::Interface::CGI::Output;
use CGI;
use C4::Koha;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/availability.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

#Por los braches
my @branches;
my @select_branch;
my %select_branches;
my $branches=getbranches();

foreach my $branch (keys %$branches) {
        push @select_branch, $branch;
        $select_branches{$branch} = $branches->{$branch}->{'branchname'};
}

my $branch = $input->param('branch');
($branch ||($branch=(split("_",(split(";",$cookie))[0]))[1]));

my $CGIbranch=CGI::scrolling_list(      -name      => 'branch',
                                        -id        => 'branch',
                                        -values    => \@select_branch,
					-defaults  => $branch,
                                        -labels    => \%select_branches,
                                        -size      => 1,
                                 );

$template->param( 
			unidades         => $CGIbranch,
			branch           => $branch,	
		);

## Scroll de disponibilidades
my %availlabels;
my @availtypes;
my $avail;

 ( %availlabels) = C4::AR::Busquedas::getAvails();
        foreach my $aux ( sort { $availlabels{$a} cmp $availlabels{$b} } keys(%availlabels)){
        push(@availtypes,$aux);}
        my $Cavails=CGI::scrolling_list(-name      => 'avail',
                                        -id        => 'avail',
                                        -values    => \@availtypes,
                                        -defaults => $avail,
                                        -labels    => \%availlabels,
                                        -size      => 1,
                                        -multiple  => 0,
                                 );


$template->param(Cavails => $Cavails);

output_html_with_http_headers $input, $cookie, $template->output;
