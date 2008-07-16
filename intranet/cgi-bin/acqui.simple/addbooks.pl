#!/usr/bin/perl

# $Id: addbooks.pl,v 1.19 2003/05/04 03:16:15 rangi Exp $

#
# Modified saas@users.sf.net 12:00 01 April 2001
# The biblioitemnumber was not correctly initialised
# The max(barcode) value was broken - koha 'barcode' is a string value!
# - If left blank, barcode value now defaults to max(biblionumber)

#
# TODO
#
# Add info on biblioitems and items already entered as you enter new ones
#
# Add info on biblioitems and items already entered as you enter new ones

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
use C4::Biblio;
use C4::Output;
use C4::Interface::CGI::Output;
use HTML::Template;

my $query = new CGI;

my $error   = $query->param('error');
my $success = $query->param('biblioitem');
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui.simple/addbooks.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { editcatalogue => 1 },
        debug           => 1,
    }
);
my $marc_p = C4::Context->boolean_preference("marc");
$template->param( NOTMARC => !$marc_p );

output_html_with_http_headers $query, $cookie, $template->output;
