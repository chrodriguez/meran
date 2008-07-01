#!/usr/bin/perl

#script to cancel reserves
#written 1/8/05
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
use C4::Auth;
use C4::AR::Utilidades;
use JSON;

my $input = new CGI;

my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{borrow => 1});



my $objJSON=$input->param('obj');

my $obj=from_json_ISO($objJSON);

my $borrowernumber=getborrowernumber($loggedinuser);
my %params;
$params{'reservenumber'}=$obj->{'reserveNumber'};
$params{'borrowernumber'}=$borrowernumber;
$params{'loggedinuser'}=$borrowernumber;
$params{'tipo'}="OPAC";

my ($error,$codMsg,$message)=C4::AR::Reservas::t_cancelar_reserva(\%params);

my %infoOperacion = (	error => $error,
        		message => $message,
		);

my $infoOperacionJSON = to_json \%infoOperacion;

print $input->header;
print $infoOperacionJSON;



