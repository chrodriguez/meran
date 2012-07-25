#!/usr/bin/perl
use strict;
use warnings;
use CGI;

#http://perlmeme.org/tutorials/cgi_script.html

my $q = new CGI;

print $q->header;

print $q->header;
print $q->start_html;
print $q->h1("Hello World!");
print $q->end_html;

1;