#!/usr/bin/perl

# script to generate cards for the borrowers
# written 03/2005
# by Luciano Iglesias - li@info.unlp.edu.ar - LINTI, Facultad de Inform�tica, UNLP Argentina

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

require Exporter;

use strict;
use CGI;
use C4::Context;
use PDF::Report;
use C4::AR::PdfGenerator;
use C4::Search;

my $input= new CGI;
my $bornum = $input->param('bornum');
my $borrewer= &borrdata("",$bornum);

my $libreD=C4::Context->preference("libreDeuda");
my @array=split(//, $libreD);
my $ok=1;
my $msj="";
# RESERVAS ADJUDICADAS 0--------> flag 1; function C4::AR::Reservas::cant_reservas($borum);
# RESERVAS EN ESPERA   1--------> flag 2; function C4::AR::Reserves::cant_waiting($borum);
# PRESTAMOS VENCIDOS   2--------> flag 3; fucntion C4::AR::Sanctions::hasDebts("",$borum); 1 tiene vencidos. 0 no.
# PRESTAMOS EN CURSO   3--------> flag 4; fucntion C4::AR::Issues::DatosPrestamos($borum);
# SANSIONADO           4--------> flag 5; function C4::AR::Sanctions::hasSanctions($borum);

if($array[0] eq "1"){
	if(C4::AR::Reservas::cant_reservas($bornum)){
		$ok=0;
		$msj="por tener reservas asignadas";
	}
}
if($array[1] eq "1" && $ok){
	if(C4::AR::Reserves::cant_waiting($bornum)->{'cant'}){
		$ok=0;
		$msj="por tener reservas en espera";
	}
}
if($array[2] eq "1" && $ok){
	if(C4::AR::Sanctions::tieneLibroVencido("",$bornum)){
		$ok=0;
		$msj="por tener pr�stamos vencidos";
	}
}
if($array[3] eq "1" && $ok){
	my($cant,$result)=C4::AR::Issues::DatosPrestamos($bornum);
	if($cant){
		$ok=0;
		$msj="por tener pr�stamos en curso";
	}
}
if($array[4] eq "1" && $ok){
	my $result=C4::AR::Sanctions::hasSanctions($bornum);
	if(scalar(@$result) > 0){
		$ok=0;
		$msj="por estar sancionado";
	}
}
if($ok){
	&libreDeuda($bornum,$borrewer);
}
else{
	my $mensaje="<b>No se puede imprimir el certificado de libre deuda ".$msj." </b>";
	print $input->redirect("/cgi-bin/koha/moremember.pl?bornum=$bornum&mensaje=$mensaje");
}

