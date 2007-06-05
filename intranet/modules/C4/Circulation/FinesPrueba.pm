package C4::Circulation::FinesPrueba;

# $Id: Borrower.pm,v 1.6 2003/12/03 12:09:44 slef Exp $

#package to deal with Issues
#written 3/11/99 by chris@katipo.co.nz


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

# FIXME - This module is never used. Obsolete?

use strict;
require Exporter;
use C4::Context;
use DBI;
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&Getoverdues &CalcFine &BorType &UpdateFine
&ReplacementCost);

sub Getoverdues  {
  }

sub CalcFine {
}


sub BorType {
}

sub UpdateFine {
}

sub ReplacementCost {
}
