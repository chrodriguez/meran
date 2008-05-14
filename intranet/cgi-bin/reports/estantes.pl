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
use C4::Interface::CGI::Output;
use CGI;
use C4::Search;
use HTML::Template;
use C4::AR::Estadisticas;
use C4::AR::Utilidades;
use C4::Koha;
use C4::BookShelves;
use ooolib;

my $input = new CGI;

my  $shelf=$input->param('shelf');

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/estantes.tmpl",

			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

#Por los shelfs
my @select_shelfs;
my %select_shelfs;
my ($count)=      &getshelfListCount('public');
my  %shelflist = &GetShelfList('public',0, $count);
 
foreach my $she (keys %shelflist) {
        push @select_shelfs, $she;
        $select_shelfs{$she} = %shelflist->{$she}->{'shelfname'};
	if ($shelf eq ''){$shelf=$she; }
}


push @select_shelfs, 'SIN SELECCIONAR';
my $CGIshelf=CGI::scrolling_list(      -name      => 'shelf',
                                        -id        => 'shelf',
                                        -values    => \@select_shelfs,
                                        -defaults  => $shelf,
                                        -labels    => \%select_shelfs,
                                        -size      => 1,
                                        -onChange  =>'consultar()',
					default    =>'SIN SELECCIONAR'
                                 );
#Fin: 

$template->param( 
			estantes         => $CGIshelf,
		);

output_html_with_http_headers $input, $cookie, $template->output;
