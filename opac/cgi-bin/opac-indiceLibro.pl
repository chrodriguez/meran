#!/usr/bin/perl

# $Id: moditem.pl,v 1.7 2003/03/18 09:52:30 tipaul Exp $


#script to modify/delete biblios
#written 8/11/99
# modified 11/11/99 by chris@katipo.co.nz
# modified 12/16/02 by hdl@ifrance.com : Templating

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

use C4::Search;
use CGI;
use C4::Output;
use HTML::Template;
use C4::Koha;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Date;
use C4::Biblio;

my $input = new CGI;
my $biblioitemnumber=$input->param('biblioitemnumber');
my $biblionumber=$input->param('biblionumber');
my $infoIndice=$input->param('indice');


my ($template, $borrowernumber, $cookie) 
    = get_template_and_user({template_name => "opac-indiceLibro.tmpl",
			     query => $input,
			     type => "opac",
			     authnotrequired => 1,
			     flagsrequired => {borrow => 1},
			     });

my ($resultsdata)=&getIndice($biblioitemnumber, $biblionumber);

my $allsubtitles;
my ($subtitlecount,$subtitles) =&subtitle($biblionumber);
if ($subtitlecount) {
	$allsubtitles=" " . $subtitles->[0]->{'subtitle'};
        for (my $i = 1; $i < $subtitlecount; $i++) {
                $allsubtitles.= ", " . $subtitles->[$i]->{'subtitle'};
        } # for
} # if

# getbiblio se elimino
# my ( $bibliocount, @biblios ) = &getbiblio($biblionumber);
my @autorPPAL= &getautor($biblios[0]->{'author'});
my @autoresAdicionales=&getautoresAdicionales($biblionumber);
my @colaboradores=&getColaboradores($biblionumber);

$template->param(
		infoIndice => $resultsdata->{'indice'},
 		biblionumber => $biblionumber,
         	biblioitemnumber => $biblioitemnumber,
		TITLE     => $biblios[0]->{'title'},
		UNITITLE    => $biblios[0]->{'unititle'},
            	SUBTITLE    => $allsubtitles,
		AUTHOR    => \@autorPPAL,
		ADDITIONAL => \@autoresAdicionales,
	    	COLABS => \@colaboradores,
);

output_html_with_http_headers $input, $cookie, $template->output;
