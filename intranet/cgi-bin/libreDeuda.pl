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
use PDF::Report;
use C4::AR::PdfGenerator;
use C4::AR::Usuarios;
use C4::AR::Sanciones;
use C4::AR::Prestamos;


my $input= new CGI;
my $nro_socio = $input->param('nro_socio');
my $socio= C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);

my ($userid, $session, $flags) = C4::Auth::checkauth($input, 0 ,{circulate=> 0},"intranet");

my $libreD=C4::AR::Preferencias->getValorPreferencia("libreDeuda");
my @array=split(//, $libreD);
my $ok=1;
my $msj="";
# RESERVAS ADJUDICADAS 0--------> flag 1; function C4::AR::Reservas::cant_reservas($borum);
# RESERVAS EN ESPERA   1--------> flag 2; function C4::AR::Reserves::cant_waiting($borum);
# PRESTAMOS VENCIDOS   2--------> flag 3; fucntion C4::AR::Sanciones::hasDebts("",$borum); 1 tiene vencidos. 0 no.
# PRESTAMOS EN CURSO   3--------> flag 4; fucntion C4::AR::Prestamos::DatosPrestamos($borum);
# SANSIONADO           4--------> flag 5; function C4::AR::Sanciones::hasSanctions($borum);

if($array[0] eq "1"){
	if(C4::AR::Reservas::cant_reservas($nro_socio)){
		$ok=0;
		$msj="por tener reservas asignadas";
	}
}
if($array[1] eq "1" && $ok){
	if(C4::AR::Reservas::cant_waiting($nro_socio)->{'cant'}){
		$ok=0;
		$msj="por tener reservas en espera";
	}
}
if($array[2] eq "1" && $ok){
	if(&C4::AR::Sanciones::tieneLibroVencido($nro_socio)){
		$ok=0;
		$msj="por tener pr&eacute;stamos vencidos";
	}
}
if($array[3] eq "1" && $ok){
	my($cant,$result)=C4::AR::Prestamos::DatosPrestamos($nro_socio);
	if($cant){
		$ok=0;
		$msj="por tener pr&eacute;stamos en curso";
	}
}
if($array[4] eq "1" && $ok){
	my $result=C4::AR::Sanciones::hasSanctions($nro_socio);
	if(scalar(@$result) > 0){
		$ok=0;
		$msj="por estar sancionado";
	}
}
if($ok){
	&C4::AR::PdfGenerator::libreDeuda($socio);
}
else{
	my $mensaje="<b>No se puede imprimir el certificado de libre deuda ".$msj." </b>";
	print $input->redirect("/cgi-bin/koha/usuarios/reales/datosUsuario.pl?nro_socio=$nro_socio&mensaje=$mensaje");
}

