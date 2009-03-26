#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
# use C4::AR::Reservas;
use C4::AR::Mensajes;
use JSON;
use C4::Circulation::Circ2;


my $input=new CGI;

my ($userid, $session, $flags) = checkauth($input, 0,{circulate=> 1},"intranet");

C4::AR::Debug::debug("CirculacionDB:: responsable -> ".$userid);

my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);

#tipoAccion = PRESTAMO, RESREVA, DEVOLUCION, CONFIRMAR_PRESTAMO
my $tipoAccion= $obj->{'tipoAccion'}||"";
my $nro_socio= $obj->{'nro_socio'};
C4::AR::Debug::debug("ACCION -> ".$tipoAccion);
C4::AR::Debug::debug("SOCIO -> ".$nro_socio);

#***************************************************DEVOLUCION**********************************************
if($tipoAccion eq "DEVOLUCION" || $tipoAccion eq "RENOVACION"){
#items a devolver o renovar
#aca se arma el div para mostrar los items que se van a devolver o renovar

	my $array_ids3=$obj->{'datosArray'};
	my $loop=scalar(@$array_ids3);


	my @infoDevRen=();
	$infoDevRen[0]->{'accion'}=$tipoAccion;
	for(my $i=0;$i<$loop;$i++){
		my $id3=$array_ids3->[$i];
		my $iteminfo= C4::Circulation::Circ2::getiteminformation($id3,"");
		$infoDevRen[$i]->{'id3'}=$id3;
		$infoDevRen[$i]->{'barcode'}=$iteminfo->{'barcode'};
		$infoDevRen[$i]->{'autor'}=$iteminfo->{'autor'};
		$infoDevRen[$i]->{'titulo'}=$iteminfo->{'titulo'};
		$infoDevRen[$i]->{'unititle'}=C4::AR::Nivel1::getUnititle($iteminfo->{'id1'});
		$infoDevRen[$i]->{'edicion'}=C4::AR::Nivel2::getEdicion($iteminfo->{'id2'});
	}
	my $infoDevRenJSON = to_json \@infoDevRen;
	print $input->header;
	print $infoDevRenJSON;
}
#*************************************************************************************************************

#************************************************CONFIRMAR PRESTAMO*******************************************
if($tipoAccion eq "CONFIRMAR_PRESTAMO"){
#SE CREAN LOS COMBO PARA SELECCIONAR EL ITEM Y EL TIPO DE PRESTAMO
	my $array_ids3=$obj->{'datosArray'};
	my $cant= scalar(@$array_ids3_a_prestar);


	my @infoPrestamo;
	for(my $i=0;$i<$cant;$i++){
		my $id3_a_prestar= $array_ids3_a_prestar->[$i];
		my $nivel3aPrestar= C4::AR::Nivel3::getNivel3FromId3($id3_a_prestar);
		#Busco ejemplares no prestados con estado disponible e igual disponibilidad que el que se quiere prestar
		my $items_array_ref= C4::AR::Nivel3::buscarNivel3PorDisponibilidad($nivel3aPrestar);
		#Busco los tipos de prestamo habilitados y con la misma disponibilidad del nivel 3 a prestar
		my ($tipoPrestamos)=&C4::AR::Prestamos::prestamosHabilitadosPorTipo($nivel3aPrestar->getId_disponibilidad,$nro_socio);
			
		$infoPrestamo[$i]->{'id3Old'}= $id3_a_prestar;
		$infoPrestamo[$i]->{'autor'}=$nivel3aPrestar->nivel2->nivel1->cat_autor->getCompleto;
		$infoPrestamo[$i]->{'titulo'}=$nivel3aPrestar->nivel2->nivel1->getTitulo;
		#$infoPrestamo[$i]->{'unititle'}=C4::AR::Nivel1::getUnititle($iteminfo->{'id1'});
		$infoPrestamo[$i]->{'edicion'}=$nivel3aPrestar->nivel2->getEdicion;
		$infoPrestamo[$i]->{'items'}= $items_array_ref;
		$infoPrestamo[$i]->{'tipoPrestamo'}=$tipoPrestamos;
	}

	my $infoPrestamoJSON = to_json \@infoPrestamo;

	print $input->header;
	print $infoPrestamoJSON;
}
#*************************************************************************************************************

#***************************************************PRESTAMO*************************************************
if($tipoAccion eq "PRESTAMO"){
#se realizan los prestamos
print A "desde PRESTAMO \n";
	my $array_ids3=$obj->{'datosArray'};
	my $loop=scalar(@$array_ids3);

	my $id3='';
	my $id3Old;
	my $id2;
	my $tipoPrestamo;
	my %infoOperacion;
	my @infoOperacionArray;
	my @infoMessages;
	my @infoTickets;
	my @errores;

print A "long: $loop \n";
	for(my $i=0;$i<$loop;$i++){
		#obtengo el id3 de un item a prestar
 		$id3= $array_ids3->[$i]->{'id3'};
		$tipoPrestamo= $array_ids3->[$i]->{'tipoPrestamo'};
		$id3Old=$array_ids3->[$i]->{'id3Old'};

print A "id3 antes de setear: $id3\n";
#Presta 1 o mas al mismo tiempo
		if($id3 ne ""){
			my $data= C4::AR::Nivel3::getDataNivel3($id3);
			my %params;
			$params{'id1'}= $data->{'id1'};
			$params{'id2'}= $data->{'id2'};
			$params{'id3'}= $id3;
			$params{'id3Old'}=$id3Old;
			$params{'barcode'}= $array_ids3->[$i]->{'barcode'};
			$params{'descripcionTipoPrestamo'}= $array_ids3->[$i]->{'descripcionTipoPrestamo'};
			$params{'borrowernumber'}=$borrnumber;
			$params{'loggedinuser'}=$loggedinuser;
			$params{'defaultbranch'}=C4::AR::Preferencias->getValorPreferencia('defaultbranch');
			$params{'tipo'}="INTRA";
			$params{'issuesType'}= $tipoPrestamo;
		
			my ($msg_object)= &C4::AR::Reservas::t_realizarPrestamo(\%params);
			my $ticketObj=0;

			if(!$msg_object->{'error'}){
			#Se crean los ticket para imprimir.
				$ticketObj=C4::AR::Prestamos::crearTicket($id3,$borrnumber,$loggedinuser);
			}
			#guardo los errores
			push (@infoMessages, $msg_object);
			
			my %infoOperacion = (
						ticket  => $ticketObj,
			);
	
			push (@infoTickets, \%infoOperacion);

print A "id3: $id3\n";		
print A "id2: $id2\n";	
# print A "id1: $id1\n";	
		}
	} #end for

	#se arma la info para enviar al cliente
	my %infoOperaciones;
	$infoOperaciones{'tickets'}= \@infoTickets;
	$infoOperaciones{'messages'}= \@infoMessages;
	
	my $infoOperacionJSON = to_json \%infoOperaciones;

	print $input->header;
	print $infoOperacionJSON;

}
#**********************************************FIN*****PRESTAMO**********************************************

#*********************************************DEVOLVER_RENOVAR***********************************************

if($tipoAccion eq "DEVOLVER_RENOVAR"){
	my $array_ids3=$obj->{'datosArray'};
	my $loop=scalar(@$array_ids3);

	
	my $accion=$obj->{'accion'};
	my $id3;
	my $barcode;
	my $ticketObj;
	my @infoTickets;
	my @infoMessages;
	my %params;
	my %messageObj;
	$params{'loggedinuser'}= $loggedinuser;
	$params{'borrowernumber'}= $borrnumber;
	$params{'tipo'}= 'INTRA';

	my $print_renew= C4::AR::Preferencias->getValorPreferencia("print_renew");

print A "LOOP: $loop\n";
	for(my $i=0;$i<$loop;$i++){
		$id3= $array_ids3->[$i]->{'id3'};
		$barcode= $array_ids3->[$i]->{'barcode'};
		$ticketObj=0;
		$params{'id3'}= $id3;
		$params{'barcode'}= $barcode;
		
		if ($accion eq 'DEVOLUCION') {
print A "Entra al if de dev\n";
			my ($Message_arrayref) = C4::AR::Prestamos::t_devolver(\%params);

			#guardo los errores
			push (@infoMessages, $Message_arrayref);

		}elsif($accion eq 'RENOVACION') {
print A "Entra al if de ren\n";
print A "ID3: $id3\n";
			my ($Message_arrayref) = C4::AR::Prestamos::t_renovar(\%params);

			#guardo los errores
			push (@infoMessages, $Message_arrayref);


			if($print_renew && !$Message_arrayref->{'error'}){
			#IF PARA LA CONDICION SI SE QUIERE O NO IMPRIMIR EL TICKET
				$ticketObj=C4::AR::Prestamos::crearTicket($id3,$borrnumber,$loggedinuser);
			}
		}# end elsif($accion eq 'RENOVACION')

		#se genera info para enviar al cliente	
		my %infoOperacion = (
				  	ticket  => $ticketObj,
		);

		push (@infoTickets, \%infoOperacion);
	}

	my %infoOperaciones;
	$infoOperaciones{'tickets'}= \@infoTickets;
	$infoOperaciones{'messages'}= \@infoMessages;
	
	my $infoOperacionJSON = to_json \%infoOperaciones;

	print $input->header;
	print $infoOperacionJSON;
}
#******************************************FIN***DEVOLVER_RENOVAR*********************************************


#******************************************CANCELAR RESERVA***************************************************
if($tipoAccion eq "CANCELAR_RESERVA"){

	my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{superlibrarian => 1},"intranet");
	
	$loggedinuser = getborrowernumber($loggedinuser);
		
	my %params;
	$params{'reservenumber'}=$obj->{'reserveNumber'};
	$params{'borrowernumber'}=$obj->{'borrowernumber'};
	$params{'loggedinuser'}=$loggedinuser;
	$params{'tipo'}="INTRA";
	
	my ($Message_arrayref)=C4::AR::Reservas::t_cancelar_reserva(\%params);
	
	my $infoOperacionJSON=to_json $Message_arrayref;
	
	print $input->header;
	print $infoOperacionJSON;
}
#******************************************FIN***CANCELAR RESERVA*********************************************


close(A);
