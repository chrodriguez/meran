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
# use C4::Circulation::Circ2;
# use C4::Search;
use C4::Output;
use DBI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Koha;
use HTML::Template;
# use C4::Date;
# use CGI::Util;
# use C4::AR::Reserves;
use C4::AR::Reservas;
# use C4::AR::Issues;
# use Date::Manip;
# use C4::AR::Sanctions;
use C4::AR::Mensajes;
use JSON;

my $input=new CGI;

my ($template, $loggedinuser, $cookie) = get_template_and_user ({
	template_name	=> 'circ/detalleReservas.tmpl',
	query		=> $input,
	type		=> "intranet",
	authnotrequired	=> 0,
	flagsrequired	=> { circulate => 1 },
    });

my $obj=$input->param('obj');
open(A, ">>/tmp/debug.txt");
print A "obj: $obj \n";
$obj=C4::AR::Utilidades::from_json_ISO($obj);

#tipoAccion = PRESTAMO, RESREVA, DEVOLUCION
my $tipoAccion= $obj->{'tipoAccion'}||"";



#***************************************************PRESTAMO*************************************************
if($tipoAccion eq "PRESTAMO"){

print A "desde PRESTAMO \n";
	my $array_ids3=$obj->{'ids3'};
	my $id2=$obj->{'id2'};
	my $borrnumber=$obj->{'borrowernumber'};

	my $i;
	my $id3='';
	my ($error, $codMsg, $message);
	my $long= scalar(@$array_ids3);
	my %infoOperacion;
	my @infoOperacionArray;
	my @errores;

print A "long: $long \n";
	for($i=0;$i<$long;$i++){

		#obtengo el id3 de un item a prestar
 		$id3= $array_ids3->[$i];

print A "id3 antes de setear: $id3\n";	

# FIXME ########################################################################################
#si se tiene la preferencia de intranetGroupReserve = 0, te dice q se presta, y esto no es asi
#deberia decir q no se permite prestar (sin reserva ) desde la INTRA
=item
HACER funcion o ver si existe, es para probar
=cut
#Presta 1 o mas al mismo tiempo

my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare("	SELECT id2, id1
			FROM nivel3
			WHERE id3 = ? ");
$sth->execute($id3);
my $data= $sth->fetchrow_hashref;
$id2= $data->{'id2'};
my $id1= $data->{'id1'};
# FIXME ########################################################################################


		if($id3 ne ""){
			my %params;
			$params{'id2'}=$id2;
			$params{'id3'}=$id3;
			$params{'borrowernumber'}=$borrnumber;
			$params{'loggedinuser'}=$loggedinuser;
			$params{'tipo'}="INTRA";
			$params{'issuesType'}="DO";  #?????
		
			($error, $codMsg, $message)= &C4::AR::Reservas::prestar(\%params);
			@errores;
			$errores[0]->{'barcode'}=$id3;
			$errores[0]->{'string'}= $message;

			#guardo los errores
			%infoOperacion = (
        			error => $error,
        			message => $message,
    			);

			push (@infoOperacionArray, \%infoOperacion);

print A "id3: $id3\n";		
print A "id2: $id2\n";	
# print A "id1: $id1\n";	
print A "error: $error\n";
print A "message: $message \n";

		}

	}

	my $infoOperacionJSON = to_json \@infoOperacionArray;

close(A);

	print $input->header;
	print $infoOperacionJSON;
}
#*************************************************************************************************************

#***************************************************RESERVA*************************************************
if($tipoAccion eq "RESERVA"){



	print $input->header;
}
#*************************************************************************************************************

#***************************************************DEVOLUCION**********************************************
if($tipoAccion eq "DEVOLCION"){

	print $input->header;
}
#*************************************************************************************************************

#************************************************CONFIRMAR PRESTAMO*******************************************
if($tipoAccion eq "CONFIRMAR_PRESTAMO"){
#SE CREA EL COMBO PARA SELECCIONAR EL ITEM Y EL TIPO DE PRESTAMO

	print $input->header;
}
#*************************************************************************************************************




