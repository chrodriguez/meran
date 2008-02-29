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
use C4::Search;

my $cgi= new CGI;
my $bornum = $cgi->param('bornum');

#FALTA HACER EL LLENADO DE LOS CAMPOS PARA LOS LIBRO Y DEMAS DATOS; SE PROCESA EN LA MISMA PAGINA

my $borrewer= &borrdata("",$bornum);
&prestInterBiblio($bornum,$borrewer);



