#!/usr/bin/perl
  use SOAP::Lite;
  print SOAP::Lite
    -> uri('http://www.soaplite.com/Demo')
    -> proxy('http://intranet-koha.linti.unlp.edu.ar/cgi-bin/koha/server.pl')
    -> isRegularBorrower($ARGV[0])
    -> result;
  print "\n\n";
