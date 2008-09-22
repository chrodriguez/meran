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
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Estadisticas;
use Mail::Sendmail;
use C4::Date;
use Date::Manip;

my $input = new CGI;
my $branch = $input->param('branch');

my ($count,$result)=C4::AR::Reservas::mailReservas($branch);
# mensaje que depende del tipo de consulta.
my $mensaje =C4::Context->preference("reserveMessage");
# mensaje para el asunto.
my $mailSubject=C4::Context->preference("reserveSubject")


my $branchname=C4::AR::Busquedas::getBranch($branch);
$branchname=$branchname->{'branchname'};
$mailSubject=~ s/BRANCH/$branchname/;

my $mailFrom=C4::Context->preference("mailFrom");
   $mailFrom =~ s/BRANCH/$branchname/;

my $horaInicio = C4::Context->preference("open");
my $horaFin = C4::Context->preference("close");
my $dateformat = C4::Date::get_date_format();

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
		my $unititle=C4::AR::Nivel1::getUnititle($result->[$i]{'id1'});
		$mailMessage =~ s/UNITITLE/$unititle/;
		my $dateInicio=format_date($result->[$i]{'notificationdate'},$dateformat);
		$mailMessage =~ s/a1/$dateInicio/;
		my $dateFin= format_date($result->[$i]{'reminderdate'},$dateformat);
		$mailMessage =~ s/a4/$dateFin/;
		$mailMessage =~ s/a2/$horaInicio/;
		$mailMessage =~ s/a3/$horaFin/;
		my $author= $result->[$i]{'autor'};
		$mailMessage =~ s/AUTHOR/$author/;
		$mailMessage =~ s/BRANCH/$branchname/;


		my %mail = ( To => $result->[$i]{'emailaddress'},
			From => $mailFrom,
			Subject => $mailSubject,
			Message => $mailMessage);
	

	 	sendmail(%mail) or die $Mail::Sendmail::error;
	}
}


print $input->redirect("reservas.pl?branch=$branch");

