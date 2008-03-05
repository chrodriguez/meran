#!/usr/bin/perl
use strict;

# written 04-09-2005 by Luciano Iglesias (li@info.unlp.edu.ar)
# script to renew items from the web

use C4::AR::Issues;
use CGI;

my $query = new CGI;
my $itemnumber = $query->param('item');
my $borrowernumber = $query->param("bornum");
my $status = renovar($borrowernumber,$itemnumber,$borrowernumber);
print $query->redirect("/cgi-bin/koha/opac-user.pl");
