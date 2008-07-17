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
use C4::Circulation::Circ2;
use Mail::Sendmail;
use C4::Date;
use Date::Manip;

my $input = new CGI;

my $orden=$input->param('orden');
my $ini=$input->param('ini');
my $estado=$input->param('estado');
my $renglones=$input->param('renglones');
my $branch=$input->param('branch');
my $return_url ="prestamos.pl?ini=$ini&branch=$branch&estado=$estado&orden=$orden&renglones=$renglones";


my $mensaje =C4::Context->preference("mailMessage");
my $mailSubject=C4::Context->preference("mailSubject");

my $branchname=C4::AR::Busquedas::getbranchname($branch);
$mailSubject=~ s/BRANCH/$branchname/;
$mensaje=~ s/BRANCH/$branchname/;

my $mailFrom=C4::Context->preference("mailFrom");
   $mailFrom =~ s/BRANCH/$branchname/;

my $count;
my $result;

#Matias - Para seleccionar a quienes se envia el mail
my @chkbox=$input->param('chkbox1');
my $cant=scalar(@chkbox);
##Hay que quitar los duplicados ya que un usuario puede llegar a tener muchos ejemplares vencidos!!!!
my @borrowers=C4::AR::Utilidades::quitarduplicados(@chkbox);

for(my $i=0;$i<scalar(@borrowers);$i++){
	my $bornum=$borrowers[$i];
	my $env;
	my ($borrower, $flags)=C4::Circulation::Circ2::getpatroninformation($env,$bornum);
	if ( $borrower->{'emailaddress'} ne ''){# Si tiene mail se envia la info de sus prestamos vencidos
		my $mailMessage = $mensaje;
	##Reemplazo por los valores correctos
		my $firstname=$borrower->{'firstname'};
		$mailMessage =~ s/FIRSTNAME/$firstname/;
		my $surname=$borrower->{'surname'};
		$mailMessage =~ s/SURNAME/$surname/;

	#Se buscan y procesan los prestamos vencidos
		($count,$result)=C4::AR::Usuarios::mailIssuesForBorrower($branch,$bornum);
		my $mensajeVencidos="";

		my $dateformat = C4::Date::get_date_format();
		for (my $i=0;$i<$count;$i++){
			my $mensajeActual=C4::Context->preference("mailMensajeVencido");

			my $title=$result->[$i]{'title'};
			$mensajeActual =~ s/TITLE/$title/;

			my $unititle=$result->[$i]{'unititle'};
			$mensajeActual =~ s/UNITITLE/$unititle/;

			my $date=$result->[$i]{'vencimiento'};
			$date=C4::Date::format_date($date,$dateformat);
        		$mensajeActual =~ s/DATE/$date/;
		#Concateno
			$mensajeVencidos.=$mensajeActual;
		}
		#Pongo los vencidos en el mensaje del mail
		$mailMessage =~ s/MENSAJEVENCIDO/$mensajeVencidos/;

		my %mail = ( To => $borrower->{'emailaddress'},
				From => $mailFrom,
				Subject => $mailSubject,
				Message => $mailMessage);

		if (sendmail(%mail)) {
		#mail enviado correctamente
			$return_url.="&msg=mail_sended";
		} 
		else {die $Mail::Sendmail::error;}
	}
}

print $input->redirect($return_url);

