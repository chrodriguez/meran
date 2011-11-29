#!/usr/bin/perl

use strict;
use C4::Date;
use CGI;

if (C4::AR::Preferencias::getValorPreferencia('reminderMail') == 1){

    my $input       = new CGI;
    my $dateformat  = C4::Date::get_date_format();
    my $today       = C4::Date::format_date_in_iso(Date::Manip::ParseDate("today"),$dateformat);

    C4::AR::Debug::debug("CRON => recordatorio_prestamos_vto.pl => Se verifica via CRON si es necesario enviar los mails de recordacion!!! TODAY=".$today);

    if ( ($ENV{'REMOTE_ADDR'} eq '127.0.0.1')  || (!$ENV{'REMOTE_ADDR'}) ){
        C4::AR::Prestamos::enviarRecordacionDePrestamo($today);
    } else {
        C4::AR::Debug::debug("recordatorio_prestamos => se intento correr script de una dir. IP no local => ".$ENV{'REMOTE_ADDR'});
    }
   
 
    C4::AR::Debug::debug("REMOTE ADDRESS DE ENVIAR RECORDATORIO PRESTAMOS: ".$ENV{'REMOTE_ADDR'});
}

1;
