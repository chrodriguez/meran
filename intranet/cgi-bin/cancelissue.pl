#!/usr/bin/perl

#script to cancel issues
#written 31/10/05
#by einar@info.unlp.edu.ar



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

use C4::Search;
use CGI;
use C4::Output;
use C4::AR::Issues;
use C4::Auth;

my $input = new CGI;

my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{borrow => 1});
$loggedinuser = getborrowernumber($loggedinuser);

my $itemnumber=$input->param('item');
my $barcode=$input->param('barcode');
my $borrowernumber=$input->param('borrnumber');

devolver($itemnumber , $borrowernumber,$loggedinuser);

my $borname=$input->param('borrnumber');
print $input->redirect("circ/circulation.pl?borrnumber=".$borname."&devolver=1&msgbar=".$barcode);
#Matias


