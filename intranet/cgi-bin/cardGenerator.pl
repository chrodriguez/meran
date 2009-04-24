#!/usr/bin/perl

# script to generate cards for the borrowers
# written 03/2005
# by Luciano Iglesias - li@info.unlp.edu.ar - LINTI, Facultad de Inform�tica, UNLP Argentina

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

require Exporter;

use strict;
use CGI;
use C4::Context;
use PDF::Report;
use C4::AR::PdfGenerator;

my $cgi= new CGI;
my $nro_socio = $cgi->param('nro_socio');
my $tmpFileName= $nro_socio.".pdf";
my $pdf = C4::AR::PdfGenerator::cardGenerator($nro_socio);
print "Content-type: application/pdf\n";
print "Content-Disposition: attachment; filename=\"$tmpFileName\"\n\n";
print $pdf->Finish();
