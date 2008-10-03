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

my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{circulate=> 1},"intranet");

$loggedinuser=getborrowernumber($loggedinuser);

my $obj=$input->param('obj');
open(A, ">>/tmp/debug.txt");
print A "obj: $obj \n";
$obj=C4::AR::Utilidades::from_json_ISO($obj);

#tipoAccion = PRESTAMO, RESREVA, DEVOLUCION, CONFIRMAR_PRESTAMO
my $tipoAccion= $obj->{'tipoAccion'}||"";
my $borrnumber= $obj->{'borrowernumber'};


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
	my $loop=scalar(@$array_ids3);


	my @infoPrestamo;
	for(my $i=0;$i<$loop;$i++){
		my $id3=$array_ids3->[$i];
		my $iteminfo= C4::Circulation::Circ2::getiteminformation($id3,"");
		my ($infoN3,@results)=C4::AR::Busquedas::buscarNivel3PorId2YDisponibilidad($iteminfo->{'id2'});
#Los disponibles son los prestados + los reservados + los que se pueden prestar + los de sala
		my @items;
		my $j=0;
		foreach (@results){
			if (!$_->{'prestado'} && (($iteminfo->{'notforloan'} eq 'SA' && 
			$_->{'notforloan'} eq 'SA') || ($iteminfo->{'notforloan'} eq 'DO' && $_->{'forloan'}))){ 
#solo pone los items que no estan prestados
				$items[$j]->{'label'}="$_->{'barcode'}";
				$items[$j]->{'value'}=$_->{'id3'};
				$j++;
			}
		}

		my ($tipoPrestamos)=&C4::AR::Issues::IssuesTypeEnabled($iteminfo->{'notforloan'}, $borrnumber);
			
		$infoPrestamo[$i]->{'id3Old'}=$id3;
		$infoPrestamo[$i]->{'autor'}=$iteminfo->{'autor'};
		$infoPrestamo[$i]->{'titulo'}=$iteminfo->{'titulo'};
		$infoPrestamo[$i]->{'unititle'}=C4::AR::Nivel1::getUnititle($iteminfo->{'id1'});
		$infoPrestamo[$i]->{'edicion'}=C4::AR::Nivel2::getEdicion($iteminfo->{'id2'});
		$infoPrestamo[$i]->{'items'}=\@items;
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
	my ($error, $codMsg, $message);
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
			$params{'defaultbranch'}=C4::Context->preference('defaultbranch');
			$params{'tipo'}="INTRA";
			$params{'issuesType'}= $tipoPrestamo;
		
			($error, $codMsg, $message)= &C4::AR::Reservas::t_realizarPrestamo(\%params);
			my $ticketObj=0;
			if(!$error){
			#Se crean los ticket para imprimir.
				$ticketObj=C4::AR::Issues::crearTicket($id3,$borrnumber,$loggedinuser);
			}
			#guardo los errores
 			my %messageObj;
			$messageObj{'error'}= $error;
			$messageObj{'codMsg'}= $codMsg;
			$messageObj{'message'}= $message;

			push (@infoMessages, \%messageObj);
			
			my %infoOperacion = (
						ticket  => $ticketObj,
			);
	
			push (@infoTickets, \%infoOperacion);

print A "id3: $id3\n";		
print A "id2: $id2\n";	
# print A "id1: $id1\n";	
print A "error: $error\n";
print A "message: $message \n";
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
	my ($error,$codMsg,$message,$paraMens);
	my %params;
	my %messageObj;
	$params{'loggedinuser'}= $loggedinuser;
	$params{'borrowernumber'}= $borrnumber;
	$params{'tipo'}= 'INTRA';

	my $print_renew= C4::Context->preference("print_renew");

print A "LOOP: $loop\n";
	for(my $i=0;$i<$loop;$i++){
		$id3= $array_ids3->[$i]->{'id3'};
		$barcode= $array_ids3->[$i]->{'barcode'};
		$ticketObj=0;
		$params{'id3'}= $id3;
		$params{'barcode'}= $barcode;
		
		if ($accion eq 'DEVOLUCION') {
print A "Entra al if de dev\n";
			my ($error,$codMsg, $message) = C4::AR::Issues::t_devolver(\%params);

			#guardo los errores
  			my %messageObj;
 			$messageObj{'error'}= $error;
 			$messageObj{'codMsg'}= $codMsg;
 			$messageObj{'message'}= $message;
 
 			push (@infoMessages, \%messageObj);

		}elsif($accion eq 'RENOVACION') {
print A "Entra al if de ren\n";
print A "ID3: $id3\n";
			($error,$codMsg, $message) = C4::AR::Issues::t_renovar(\%params);

			#guardo los errores
  			my %messageObj;
 			$messageObj{'error'}= $error;
 			$messageObj{'codMsg'}= $codMsg;
 			$messageObj{'message'}= $message;

 			push (@infoMessages, \%messageObj);


print A "error: $error --- cod: $codMsg\n";
			if($print_renew && !$error){
			#IF PARA LA CONDICION SI SE QUIERE O NO IMPRIMIR EL TICKET
				$ticketObj=C4::AR::Issues::crearTicket($id3,$borrnumber,$loggedinuser);
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
	
	my ($error,$codMsg,$message)=C4::AR::Reservas::t_cancelar_reserva(\%params);
	
	my %infoOperacion = (
				codMsg	=> $codMsg,
				error 	=> $error,
				message => $message,
	);
	
	my $infoOperacionJSON=to_json \%infoOperacion;
	
	print $input->header;
	print $infoOperacionJSON;
}
#******************************************FIN***CANCELAR RESERVA*********************************************


close(A);
