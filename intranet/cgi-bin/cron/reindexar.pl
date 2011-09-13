#!/usr/bin/perl

use strict;
require Exporter;
use C4::Context;
use CGI;
use C4::AR::Sphinx qw(reindexar);

C4::AR::Debug::debug("CRON => reindexar.pl!!!!!");

if ($ENV{'REMOTE_ADDR'} eq '127.0.0.1') {
    C4::AR::Sphinx::reindexar();
} else {
    C4::AR::Debug::debug("reindexar => se intento correr script de una dir. IP no local => ".$ENV{'REMOTE_ADDR'});
} 
