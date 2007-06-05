#!/usr/bin/perl

# This module is a "Web Service"
# Module to find if a borrower is free debt 
# written 05/2005
# by Luciano Iglesias - li@info.unlp.edu.ar - LINTI, Facultad de Informática, UNLP Argentina
                                                                                                                             
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

#############################################################################
########### This is an example to invoke the web service in perl ############
#############################################################################
# use SOAP::Lite;
# print SOAP::Lite
#   -> uri('http://www.soaplite.com/Demo')
#   -> proxy('http://intranet-koha.linti.unlp.edu.ar/cgi-bin/koha/server.pl')
#   -> isRegularBorrower($ARGV[0])
#   -> result;
# print "\n\n";
#############################################################################
#############################################################################

#############################################################################
############################# Return values #################################
#  1  the borrower had books/issues in his possession
#  0  the borrower hadn't books/issues in his possession
# -1  the borrower doesn't exist
#############################################################################
#############################################################################

use SOAP::Transport::HTTP;
SOAP::Transport::HTTP::CGI
  -> dispatch_to('Demo')
  -> handle;

package Demo;
use strict;
use C4::Search;
sub isRegularBorrower {
  my ($name,$documentnumber)= @_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("select borrowernumber from borrowers where documentnumber=?");
  $sth->execute($documentnumber);
  my $count= $sth->rows;
  if ($count) { # if $count <> 0 then exist a borrower with this $documentnumber
    my $bornum= $sth->fetchrow;
    my ($count,$issue)=borrissues($bornum);
    if ($count) { # if $count > 0 then the borrower had books in his possession
      return("1");
    } else { # if $count = 0 then the borrower hadn't books in his possession
      return("0");
    }
    $sth->finish;
  } else  { # if $count = 0 then then the borrower doesn't exist
    $sth->finish;
    return("-1");
  }
}
