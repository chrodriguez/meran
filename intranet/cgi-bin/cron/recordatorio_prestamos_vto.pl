#!/usr/bin/perl

use strict;
require Exporter;
use C4::Context;
use CGI;

my $input   = new CGI;
my $dbh     = C4::Context->dbh;
my $dateformat = C4::Date::get_date_format();
my $today   = C4::Date::format_date_in_iso(Date::Manip::ParseDate("today"),$dateformat);

C4::AR::Debug::debug("CRON => recordatorio_prestamos.pl => Se verifica via CRON si es necesario enviar los mails de recordacion!!! TODAY=".$today);

# C4::AR::Debug::debug("recordatorio_prestamos => se intento correr script de una dir. IP no local => ".$ENV{'REMOTE_ADDR'});

if ($ENV{'REMOTE_ADDR'} eq '127.0.0.1') {
    C4::AR::Prestamos::enviarCorreosDeRecordacion($today);
} else {
    C4::AR::Debug::debug("recordatorio_prestamos => se intento correr script de una dir. IP no local => ".$ENV{'REMOTE_ADDR'});
}
  
# print $input->header();
# exit;
