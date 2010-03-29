#!/usr/bin/perl

require Exporter;

use strict;
use CGI;
use PDF::Report;
use C4::AR::PdfGenerator;
use C4::AR::Usuarios;
use C4::AR::Sanciones;
use C4::AR::Prestamos;


my $input= new CGI;
my $authnotrequired= 0;

my ($userid, $session, $flags) = C4::Auth::checkauth(   $input, 
                                                        $authnotrequired,
                                                        {   ui => 'ANY', 
                                                            tipo_documento => 'ANY', 
                                                            accion => 'CONSULTA', 
                                                            entorno => 'usuarios'
                                                        },
                                                        "intranet"
                            );

my $nro_socio = $input->param('nro_socio');

my $authnotrequired = 0;
my $socio= C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);

my ($userid, $session, $flags) = C4::Auth::checkauth(   $input, 
                                                        $authnotrequired,
                                                        {   ui => 'ANY', 
                                                            tipo_documento => 'ANY', 
                                                            accion => 'CONSULTA', 
                                                            entorno => 'usuarios'
                                                        },
                                                        "intranet"
                            );

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
	if(C4::AR::Reservas::_getReservasAsignadas($nro_socio)){
		$ok=0;
		$msj="por tener reservas asignadas";
	}
}
if($array[1] eq "1" && $ok){
	if(C4::AR::Reservas::getReservasDeSocioEnEspera($nro_socio)->{'cant'}){
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

