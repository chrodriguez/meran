#!/usr/bin/perl

# $Id: modbib.pl,v 1.14 2003/07/15 11:34:52 slef Exp $

#script to modify/delete biblios
#written 8/11/99
# modified 11/11/99 by chris@katipo.co.nz
# modified 12/16/2002 by hdl@ifrance.com : templating


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
use HTML::Template;
use strict;
require Exporter;
use C4::Context;
use C4::Output;  # contains gettemplate
use CGI;
use C4::Search;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Date;

use C4::AR::AnalysisBiblio;

my $input = new CGI;
my $bibnum=$input->param('biblionumber');
my $bibnumitems=$input->param('biblioitemnumber');
my $analyticalnumber=$input->param('analyticalnumber');

my @result2;
my (@result2)=&BiblioAnalysisSingularData($analyticalnumber);

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "editanalysis.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {acquisition => 1},
			     debug => 1,
			     });
 
$template->param ( biblionumber => $bibnum,
	           biblioitemnumber => $bibnumitems,
		   ANALYSIS => \@result2
		   );

output_html_with_http_headers $input, $cookie, $template->output;

