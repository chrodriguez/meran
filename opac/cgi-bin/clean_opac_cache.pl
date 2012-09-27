#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Utilidades;
use vars qw($CACHE_MERAN);

if (($ENV{'REMOTE_ADDR'} eq '127.0.0.1') || (!$ENV{'REMOTE_ADDR'})||($ENV{'REMOTE_ADDR'} eq $ENV{'SERVER_ADDR'})) {
    $CACHE_MERAN = undef;
    C4::AR::Debug::info("SE ACTUALIZO LA CACHE_OPAC DE MERAN");
}
