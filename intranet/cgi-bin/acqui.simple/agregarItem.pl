#!/usr/bin/perl

# $Id: addbiblio.pl,v 1.32.2.7 2004/03/19 08:21:01 tipaul Exp $

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
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use C4::Koha; 
use HTML::Template;
use C4::AR::Catalogacion;
use CGI::Ajax;
use JSON;
my $input = new CGI;


my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "acqui.simple/agregarItem.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {editcatalogue => 1},
			     debug => 1,
			     });

my $nivel=1;

#item type
my ($cant,@results)= C4::Biblio::getitemtypes();
my @valuesItemtypes;
my %labelsItemtypes;
my $i=0;
push(@valuesItemtypes,-1);
$labelsItemtypes{-1}="Elegir tipo Item";
for ($i; $i<scalar(@results); $i++){
	push(@valuesItemtypes,$results[$i]->{'itemtype'});
	$labelsItemtypes{$results[$i]->{'itemtype'}}=$results[$i]->{'description'};
}

my $selectItemType=CGI::scrolling_list(  -name      => 'itemtype',
				-id	   => 'itemtype',
                                -values    => \@valuesItemtypes,
				-labels    => \%labelsItemtypes,
                                -defaults  => 'Elegir tipo Item',
                                -size      => 1,
				-onChange  => 'seleccionTipoItem()',
                                 );
#fin item type



$template->param(
			selectItemType  => $selectItemType,
			nivel		=> $nivel,
		);

output_html_with_http_headers $input, $cookie, $template->output;
