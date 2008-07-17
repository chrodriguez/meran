#!/usr/bin/perl
# Please use 8-character tabs for this file (indents are every 4 characters)

#written 8/5/2002 by Finlay
#script to execute issuing of books

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

use strict;
use CGI;
use C4::Output;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Koha;
use HTML::Template;

my $input=new CGI;

my ($template, $loggedinuser, $cookie) = get_template_and_user ({
	template_name	=> 'circ/detalleUsuario.tmpl',
	query		=> $input,
	type		=> "intranet",
	authnotrequired	=> 0,
	flagsrequired	=> { circulate => 1 },
    });

my $obj=$input->param('obj');

$obj=C4::AR::Utilidades::from_json_ISO($obj);
my $borrnumber= $obj->{'borrowernumber'};


my $sanctions = C4::AR::Sanctions::hasSanctions($borrnumber);
	
my $dateformat = C4::Date::get_date_format();
foreach my $san (@$sanctions) {
	if ($san->{'id3'}) {
		my $aux=C4::AR::Nivel1::buscarNivel1PorId3($san->{'id3'}); 
		$san->{'description'}.=": ".$aux->{'titulo'}." (".$aux->{'completo'}.") "; 
	}

	if ($san->{'reservaNoRetiradaVencida'}){
		#Miguel - Tiene reserva no retirada vencida, no se le muestra el combo para prestar
		$template->param(reservaNoRetiradaVencida =>$san->{'reservaNoRetiradaVencida'});
	}
# 	$san->{'enddate'}=format_date($san->{'enddate'},$dateformat);
# 	$san->{'startdate'}=format_date($san->{'startdate'},$dateformat);
}

my $debts= C4::AR::Sanctions::tieneLibroVencido($borrnumber); # indica si el usuario tiene libros vencidos
$template->param(sanctions =>$sanctions,
		 debts =>$debts
		);

my @resultBorrower;
$resultBorrower[0]=C4::AR::Usuarios::getBorrowerInfo($borrnumber);

$template->param(
	borrower => \@resultBorrower,
);

output_html_with_http_headers $input, $cookie, $template->output;

