#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
# use C4::AR::Reservas;
use C4::AR::Mensajes;
use JSON;

my $input=new CGI;

my ($userid, $session, $flags) = checkauth($input, 0,{circulate=> 1},"intranet");

C4::AR::Debug::debug("CirculacionDB:: responsable -> ".$userid);

my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);
my $loggedinuser= $userid;

#tipoAccion = PRESTAMO, RESREVA, DEVOLUCION, CONFIRMAR_PRESTAMO
my $tipoAccion= $obj->{'tipoAccion'}||"";
my $nro_socio= $obj->{'nro_socio'};
C4::AR::Debug::debug("ACCION -> ".$tipoAccion);
C4::AR::Debug::debug("SOCIO -> ".$nro_socio);

#***************************************************DEVOLUCION**********************************************
if($tipoAccion eq "DEVOLUCION" || $tipoAccion eq "RENOVACION"){
#items a devolver o renovar
#aca se arma el div para mostrar los items que se van a devolver o renovar

	my $array_ids=$obj->{'datosArray'};
	my $loop=scalar(@$array_ids);

	my @infoDevRen=();
	$infoDevRen[0]->{'accion'}=$tipoAccion;
	for(my $i=0;$i<$loop;$i++){
 		my $id_prestamo=$array_ids->[$i];
        my $prestamo = C4::Modelo::CircPrestamo->new(id_prestamo => $id_prestamo);
        $prestamo->load();
		$infoDevRen[$i]->{'id_prestamo'}=$id_prestamo;
        $infoDevRen[$i]->{'id3'}=$prestamo->getId3;
 		$infoDevRen[$i]->{'barcode'}=$prestamo->nivel3->getBarcode;
  		$infoDevRen[$i]->{'autor'}=$prestamo->nivel3->nivel1->cat_autor->getCompleto;
 		$infoDevRen[$i]->{'titulo'}=$prestamo->nivel3->nivel1->getTitulo;
  		$infoDevRen[$i]->{'unititle'}="";
 		$infoDevRen[$i]->{'edicion'}=$prestamo->nivel3->nivel2->getEdicion;
	}
	my $infoDevRenJSON = to_json \@infoDevRen;
	print $input->header;
	print $infoDevRenJSON;
}
#*************************************************************************************************************

#************************************************CONFIRMAR PRESTAMO*******************************************
elsif($tipoAccion eq "CONFIRMAR_PRESTAMO"){
#SE CREAN LOS COMBO PARA SELECCIONAR EL ITEM Y EL TIPO DE PRESTAMO
	my $array_ids3_a_prestar=$obj->{'datosArray'};
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
		my ($nivel2)= C4::AR::Nivel2::getNivel2FromId2($nivel3aPrestar->nivel2->getId2);
 		$infoPrestamo[$i]->{'autor'}= C4::AR::Referencias::getNombreAutor($nivel2->nivel1->getAutor);
 		$infoPrestamo[$i]->{'titulo'}= $nivel3aPrestar->nivel2->nivel1->getTitulo;
		$infoPrestamo[$i]->{'unititle'}='';#C4::AR::Nivel1::getUnititle($iteminfo->{'id1'});
		$infoPrestamo[$i]->{'edicion'}= $nivel3aPrestar->nivel2->getEdicion;
		$infoPrestamo[$i]->{'items'}= $items_array_ref;
		$infoPrestamo[$i]->{'tipoPrestamo'}= $tipoPrestamos;
	}

	my $infoPrestamoJSON = to_json \@infoPrestamo;

	print $input->header;
	print $infoPrestamoJSON;
}
#*************************************************************************************************************

#***************************************************PRESTAMO*************************************************
elsif($tipoAccion eq "PRESTAMO"){
#se realizan los prestamos
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

C4::AR::Debug::debug("SE PRESTAN ".$loop." EJEMPLARES");
	
	for(my $i=0;$i<$loop;$i++){
		#obtengo el id3 de un item a prestar
 		$id3= $array_ids3->[$i]->{'id3'};
		$tipoPrestamo= $array_ids3->[$i]->{'tipoPrestamo'};
		$id3Old=$array_ids3->[$i]->{'id3Old'}; #Esto nunca viene

#Presta 1 o mas al mismo tiempo
		if($id3 ne ""){

C4::AR::Debug::debug("SE VA A PRESTAR ID3:".$id3." (ID3VIEJO: ".$id3Old.") CON EL TIPO :".$array_ids3->[$i]->{'descripcionTipoPrestamo'}." Y BARCODE ".$array_ids3->[$i]->{'barcode'});

			my $nivel3aPrestar= C4::AR::Nivel3::getNivel3FromId3($id3);
			my %params;
			$params{'id1'}= $nivel3aPrestar->nivel2->nivel1->getId1;
			$params{'id2'}= $nivel3aPrestar->nivel2->getId2;
			$params{'id3'}= $nivel3aPrestar->getId3;
			$params{'barcode'}= $nivel3aPrestar->getBarcode;
			$params{'id3Old'}=$id3Old;
			$params{'descripcionTipoPrestamo'}= $array_ids3->[$i]->{'descripcionTipoPrestamo'};
			$params{'nro_socio'}=$nro_socio;
			$params{'loggedinuser'}= $loggedinuser;
			$params{'id_ui'}=C4::AR::Preferencias->getValorPreferencia('defaultbranch');
			$params{'id_ui_prestamo'}=C4::AR::Preferencias->getValorPreferencia('defaultbranch');
			$params{'tipo'}="INTRA";
			$params{'tipo_prestamo'}= $tipoPrestamo;
		
			my ($msg_object)= &C4::AR::Prestamos::t_realizarPrestamo(\%params);
			my $ticketObj=0;

			if(!$msg_object->{'error'}){
			#Se crean los ticket para imprimir.
				C4::AR::Debug::debug("SE PRESTO SIN ERROR --> SE CREA EL TICKET");
				$ticketObj=C4::AR::Prestamos::crearTicket($id3,$nro_socio,$loggedinuser);
			}
			#guardo los errores
			push (@infoMessages, $msg_object);
			
			my %infoOperacion = (
						ticket  => $ticketObj,
			);
	
			push (@infoTickets, \%infoOperacion);

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

elsif($tipoAccion eq "DEVOLVER_RENOVAR"){
	my $array_ids3=$obj->{'datosArray'};
	my $loop=scalar(@$array_ids3);

	
	my $accion=$obj->{'accion'};
	my $id3;
	my $barcode;
    my $id_prestamo;
	my $ticketObj;
	my @infoTickets;
	my @infoMessages;
	my %params;
	my %messageObj;
	$params{'loggedinuser'}= $loggedinuser;
	$params{'nro_socio'}= $nro_socio;
	$params{'tipo'}= 'INTRA';

	my $print_renew= C4::AR::Preferencias->getValorPreferencia("print_renew");

    C4::AR::Debug::debug("LOOP --> $loop");
	for(my $i=0;$i<$loop;$i++){
		$id3= $array_ids3->[$i]->{'id3'};
		$barcode= $array_ids3->[$i]->{'barcode'};
        $id_prestamo= $array_ids3->[$i]->{'id_prestamo'};
		$ticketObj=0;
		$params{'id3'}= $id3;
		$params{'barcode'}= $barcode;
        $params{'id_prestamo'}= $id_prestamo;
		
		if ($accion eq 'DEVOLUCION') {
        C4::AR::Debug::debug("DEVOLUCION");
        C4::AR::Debug::debug("USUARIO $nro_socio");
        C4::AR::Debug::debug("ID3: $id3");
			my ($Message_arrayref) = C4::AR::Prestamos::t_devolver(\%params);

			#guardo los errores
			push (@infoMessages, $Message_arrayref);

		}elsif($accion eq 'RENOVACION') {
        C4::AR::Debug::debug("RENOVACION");
        C4::AR::Debug::debug("ID3: $id3");
			my ($Message_arrayref) = C4::AR::Prestamos::t_renovar(\%params);

			#guardo los errores
			push (@infoMessages, $Message_arrayref);


			if($print_renew && !$Message_arrayref->{'error'}){
			#IF PARA LA CONDICION SI SE QUIERE O NO IMPRIMIR EL TICKET
				$ticketObj=C4::AR::Prestamos::crearTicket($id3,$nro_socio,$loggedinuser);
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
elsif($tipoAccion eq "CANCELAR_RESERVA"){

	my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{superlibrarian => 1},"intranet");
		
	my %params;
	$params{'reservenumber'}= $obj->{'reserveNumber'};
	$params{'nro_socio'}= $obj->{'nro_socio'};
	$params{'loggedinuser'}= $loggedinuser;
	$params{'tipo'}="INTRA";
	
	my ($Message_arrayref)=C4::AR::Reservas::t_cancelar_reserva(\%params);
	
	my $infoOperacionJSON=to_json $Message_arrayref;
	
	print $input->header;
	print $infoOperacionJSON;
}
#******************************************FIN***CANCELAR RESERVA*********************************************

elsif($tipoAccion eq "CIRCULACION_RAPIDA"){

	my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{superlibrarian => 1},"intranet");
		
	my $Message_arrayref;
	my %params;
	$params{'barcode'}= $obj->{'barcode'};
	$params{'nro_socio'}= $obj->{'nro_socio'};
	$params{'operacion'}= $obj->{'operacion'};
	
	if($params{'operacion'} eq "renovar"){	
# 		my ($Message_arrayref) = C4::AR::Prestamos::t_renovarPorBarcode(\%params);
	C4::AR::Debug::debug("circulacionDB.pl => circulacion rapida => renovar barcode: ".$params{'barcode'});	
	}
	elsif($params{'operacion'} eq "devolver"){
	C4::AR::Debug::debug("circulacionDB.pl => circulacion rapida => devolver barcode: ".$params{'barcode'});
		($Message_arrayref) = C4::AR::Prestamos::t_devolverPorBarcode(\%params);	
	}
	elsif($params{'operacion'} eq "prestar"){
	C4::AR::Debug::debug("circulacionDB.pl => circulacion rapida => prestar barcode: ".$params{'barcode'});
# 		my ($Message_arrayref) = C4::AR::Prestamos::t_prestarPorBarcode(\%params);	
	}
	
	my $infoOperacionJSON=to_json $Message_arrayref;
	
	print $input->header;
	print $infoOperacionJSON;
}
elsif($tipoAccion eq "CIRCULACION_RAPIDA_TIENE_AUTORIZADO"){

	my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{superlibrarian => 1},"intranet");
		
	my $Message_arrayref;
	my %params;
	$params{'barcode'}= $obj->{'barcode'};
	$params{'nro_socio'}= $obj->{'nro_socio'};
	$params{'operacion'}= $obj->{'operacion'};
	
	my $socio= C4::AR::Usuarios::getSocioInfoPorNroSocio($params{'nro_socio'});
	my $flag=0;
	if($socio){
		$flag= $socio->tieneAutorizado;	
	}
	
	print $input->header;
	print $flag;
}
