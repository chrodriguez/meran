#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
#
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
#
#

use strict;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use C4::Search;
use HTML::Template;
use C4::AR::Estadisticas;
use C4::Koha;
use Mail::Sendmail;
use C4::Date;
use Date::Manip;

my $input = new CGI;
my $branch = $input->param('branch');

# my $today=ParseDate('today');
my $tipo= $input->param('tipo'); # $tipo=0 prestamos vencidos/$tipo=1 reservas para ejemplar.
my $mensaje; # mensaje que depende del tipo de consulta.
my $mailSubject; # mensaje para el asunto.
my $count;
my $result;
if($tipo){
	($count,$result)=mailreservas($branch);
	$mensaje =C4::Context->preference("reserveMessage");
	$mailSubject=C4::Context->preference("reserveSubject")
}
else{
	($count,$result)=mailissues($branch);
	$mensaje =C4::Context->preference("mailMessage");
	$mailSubject=C4::Context->preference("mailSubject");
}

my $branchname=getbranchname($branch);
$mailSubject=~ s/BRANCH/$branchname/;
                                                                                                                             
my $mailFrom=C4::Context->preference("mailFrom");
   $mailFrom =~ s/BRANCH/$branchname/;


for (my $i=0;$i<$count;$i++){
	if ( $result->[$i]{'emailaddress'} ne ''){
		my $mailMessage = $mensaje;
		##Reemplazo por los valores correctos
		my $firstname=$result->[$i]{'firstname'};
		$mailMessage =~ s/FIRSTNAME/$firstname/;
                                                                                                                             
		my $surname=$result->[$i]{'surname'};
		$mailMessage =~ s/SURNAME/$surname/;
                                                                                                                             
		my $title=$result->[$i]{'title'};
		$mailMessage =~ s/TITLE/$title/;
                                                                                                                             
		my $unititle=$result->[$i]{'unititle'};
		$mailMessage =~ s/UNITITLE/$unititle/;
        	if ($tipo){
			my $dateInicio=format_date($result->[$i]{'notificationdate'});
        		$mailMessage =~ s/a1/$dateInicio/;
			my $dateFin= format_date($result->[$i]{'reminderdate'});
			$mailMessage =~ s/a4/$dateFin/;
			my $horaInicio = C4::Context->preference("open");
			$mailMessage =~ s/a2/$horaInicio/;
			my $horaFin = C4::Context->preference("close");
			$mailMessage =~ s/a3/$horaFin/;
			my $author= $result->[$i]{'author'};
			$mailMessage =~ s/AUTHOR/$author/;
		}
		else{
			my $date=$result->[$i]{'vencimiento'};
			$date=format_date($date);
        		$mailMessage =~ s/DATE/$date/;
		}
	                                                                                                                     
		$mailMessage =~ s/BRANCH/$branchname/;


		my %mail = ( To => $result->[$i]{'emailaddress'},
			From => $mailFrom,
			Subject => $mailSubject,
			Message => $mailMessage);
	

	 	sendmail(%mail) or die $Mail::Sendmail::error;
	}
}

my $input = new CGI;

if($tipo){
	print $input->redirect("reservas.pl?branch=$branch");
}
else{
	print $input->redirect("prestamos.pl?branch=$branch");
}
