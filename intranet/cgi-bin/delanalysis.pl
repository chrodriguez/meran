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
use strict;
require Exporter;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Date;
use C4::AR::AnalysisBiblio;

my $input = new CGI;

my $analyticalnumber=$input->param('analyticalnumber');

my $bibnum=$input->param('biblionumber');
my $bibnumitems=$input->param('biblioitemnumber');
&BiblioSingleAnalysisDelete($analyticalnumber);

print $input->redirect("addanalysis.pl?bibnum=$bibnum&bibnumitems=$bibnumitems");


