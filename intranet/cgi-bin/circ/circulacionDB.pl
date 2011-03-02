#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;
# use C4::AR::Mensajes;
use JSON;

my $input           = new CGI;
my $obj             = $input->param('obj');
$obj                = C4::AR::Utilidades::from_json_ISO($obj);
my $authnotrequired = 0;
#tipoAccion = PRESTAMO, RESREVA, DEVOLUCION, CONFIRMAR_PRESTAMO
my $tipoAccion      = C4::AR::Utilidades::trim($obj->{'tipoAccion'})||"";
my $nro_socio       = C4::AR::Utilidades::trim($obj->{'nro_socio'});
C4::AR::Debug::debug("ACCION -> ".$tipoAccion);
C4::AR::Debug::debug("SOCIO -> ".$nro_socio);

#***************************************************DEVOLUCION**********************************************
if($tipoAccion eq "DEVOLUCION" || $tipoAccion eq "RENOVACION"){

    my ($user, $session, $flags, $usuario_logueado) = checkauth(    $input, 
                                                                    $authnotrequired, 
                                                                    {   ui => 'ANY', 
                                                                        tipo_documento => 'ANY', 
                                                                        accion => 'CONSULTA', 
                                                                        entorno => 'undefined'}, 
                                                                        'intranet'
                                        );
#items a devolver o renovar
#aca se arma el div para mostrar los items que se van a devolver o renovar

    my $id_prestamo;
    my $prestamo;
	my $array_ids   = $obj->{'datosArray'};
	my $loop        = scalar(@$array_ids);

	my @infoDevRen                  = ();
	$infoDevRen[0]->{'nro_socio'}   = $user;
	$infoDevRen[0]->{'accion'}      = $tipoAccion;

	for(my $i=0;$i<$loop;$i++){
 		$id_prestamo = $array_ids->[$i];
        $prestamo = C4::AR::Prestamos::getInfoPrestamo($id_prestamo);

        if ($prestamo){
            $infoDevRen[$i]->{'id_prestamo'}    = $id_prestamo;
            $infoDevRen[$i]->{'id3'}            = $prestamo->getId3;
            $infoDevRen[$i]->{'barcode'}        = $prestamo->nivel3->getBarcode;
            $infoDevRen[$i]->{'autor'}          = $prestamo->nivel3->nivel1->getAutor;
            $infoDevRen[$i]->{'titulo'}         = $prestamo->nivel3->nivel1->getTitulo;
            $infoDevRen[$i]->{'unititle'}       = "";
            $infoDevRen[$i]->{'edicion'}        = $prestamo->nivel3->nivel2->getEdicion;
        }
	}

	my $infoDevRenJSON = to_json \@infoDevRen;
    C4::AR::Auth::print_header($session);
	print $infoDevRenJSON;
}
#*************************************************************************************************************

#************************************************CONFIRMAR PRESTAMO*******************************************
elsif($tipoAccion eq "CONFIRMAR_PRESTAMO"){
	
    my ($user, $session, $flags, $usuario_logueado) = checkauth(    $input, 
                                                                    $authnotrequired, 
                                                                    {   ui => 'ANY', 
                                                                        tipo_documento => 'ANY', 
                                                                        accion => 'CONSULTA', 
                                                                        entorno => 'undefined'}, 
                                                                    'intranet'
                                    );
#SE CREAN LOS COMBO PARA SELECCIONAR EL ITEM Y EL TIPO DE PRESTAMO
	my $array_ids3_a_prestar    = $obj->{'datosArray'};
	my $cant                    = scalar(@$array_ids3_a_prestar);
	my @infoPrestamo;

	for(my $i=0;$i<$cant;$i++){
		my $id3_a_prestar                       = $array_ids3_a_prestar->[$i];
		my $nivel3aPrestar                      = C4::AR::Nivel3::getNivel3FromId3($id3_a_prestar);
		#Busco ejemplares no prestados con estado disponible e igual disponibilidad que el que se quiere prestar
		my $items_array_ref                     = C4::AR::Nivel3::buscarNivel3PorDisponibilidad($nivel3aPrestar);
		#Busco los tipos de prestamo habilitados y con la misma disponibilidad del nivel 3 a prestar
		my ($tipoPrestamos)                     = &C4::AR::Prestamos::prestamosHabilitadosPorTipo($nivel3aPrestar->getIdDisponibilidad,$nro_socio);

		$infoPrestamo[$i]->{'id3Old'}           = $id3_a_prestar;
		my ($nivel2)                            = C4::AR::Nivel2::getNivel2FromId2($nivel3aPrestar->nivel2->getId2);
        $infoPrestamo[$i]->{'autor'}            = $nivel2->nivel1->getAutor;
 		$infoPrestamo[$i]->{'titulo'}           = $nivel3aPrestar->nivel2->nivel1->getTitulo;
		$infoPrestamo[$i]->{'unititle'}         = '';
		$infoPrestamo[$i]->{'edicion'}          = $nivel3aPrestar->nivel2->getEdicion;
		$infoPrestamo[$i]->{'items'}            = $items_array_ref;
		$infoPrestamo[$i]->{'tipoPrestamo'}     = $tipoPrestamos;
	}

	my $infoPrestamoJSON                        = to_json \@infoPrestamo;

    C4::AR::Auth::print_header($session);
	print $infoPrestamoJSON;
}
#*************************************************************************************************************

#***************************************************PRESTAMO*************************************************
elsif($tipoAccion eq "PRESTAMO"){
    my ($user, $session, $flags, $usuario_logueado)= checkauth(     $input, 
                                                                    $authnotrequired, 
                                                                    {   ui => 'ANY', 
                                                                        tipo_documento => 'ANY', 
                                                                        accion => 'CONSULTA', 
                                                                        entorno => 'undefined'}, 
                                                                    'intranet'
                                );	
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
 		$id3            = $array_ids3->[$i]->{'id3'};
		$tipoPrestamo   = $array_ids3->[$i]->{'tipoPrestamo'};
		$id3Old         = $array_ids3->[$i]->{'id3Old'}; #Esto nunca viene

#Presta 1 o mas al mismo tiempo
		if($id3 ne ""){

C4::AR::Debug::debug("SE VA A PRESTAR ID3:".$id3." (ID3VIEJO: ".$id3Old.") CON EL TIPO :".$array_ids3->[$i]->{'descripcionTipoPrestamo'}." Y BARCODE ".$array_ids3->[$i]->{'barcode'});

			my $nivel3aPrestar                  = C4::AR::Nivel3::getNivel3FromId3($id3);
			my %params;
			$params{'id1'}                      = $nivel3aPrestar->nivel2->nivel1->getId1;
			$params{'id2'}                      = $nivel3aPrestar->nivel2->getId2;
			$params{'id3'}                      = $nivel3aPrestar->getId3;
			$params{'barcode'}                  = $nivel3aPrestar->getBarcode;
			$params{'id3Old'}                   = $id3Old;
			$params{'descripcionTipoPrestamo'}  = $array_ids3->[$i]->{'descripcionTipoPrestamo'};
			$params{'nro_socio'}                = $nro_socio;
			$params{'loggedinuser'}             = $user;
			$params{'responsable'}              = $user;
			$params{'id_ui'}                    = C4::AR::Preferencias::getValorPreferencia('defaultUI');
			$params{'id_ui_prestamo'}           = C4::AR::Preferencias::getValorPreferencia('defaultUI');
			$params{'tipo'}                     = "INTRA";
			$params{'tipo_prestamo'}            = $tipoPrestamo;
		
			my ($msg_object)                    = &C4::AR::Prestamos::t_realizarPrestamo(\%params);
			my $ticketObj                       = 0;

			if(!$msg_object->{'error'}){
			#Se crean los ticket para imprimir.
				C4::AR::Debug::debug("SE PRESTO SIN ERROR --> SE CREA EL TICKET");
				$ticketObj = C4::AR::Prestamos::crearTicket($id3,$nro_socio,$user);
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
	$infoOperaciones{'tickets'}     = \@infoTickets;
	$infoOperaciones{'messages'}    = \@infoMessages;
	my $infoOperacionJSON           = to_json \%infoOperaciones;

    C4::AR::Auth::print_header($session);
	print $infoOperacionJSON;

}
#**********************************************FIN*****PRESTAMO**********************************************
elsif($tipoAccion eq "REALIZAR_DEVOLUCION"){
    my ($user, $session, $flags, $usuario_logueado) = checkauth(    $input, 
                                                                    $authnotrequired, 
                                                                    {   ui => 'ANY', 
                                                                        tipo_documento => 'ANY', 
                                                                        accion => 'CONSULTA', 
                                                                        entorno => 'undefined'}, 
                                                                    'intranet'
                                );

	$obj->{'loggedinuser'}= $user;
	my ($Message_arrayref) = C4::AR::Prestamos::t_devolver($obj);
    
   	my %info;
     $info{'Messages_arrayref'}= $Message_arrayref;

    C4::AR::Auth::print_header($session);
    print to_json \%info;
}


elsif($tipoAccion eq "REALIZAR_RENOVACION"){
    my ($user, $session, $flags, $usuario_logueado) = checkauth(    $input, 
                                                                    $authnotrequired, 
                                                                    {   ui => 'ANY', 
                                                                        tipo_documento => 'ANY', 
                                                                        accion => 'CONSULTA', 
                                                                        entorno => 'undefined'}, 
                                                                    'intranet'
                                );

    my $infoOperaciones = C4::AR::Prestamos::t_renovar($obj);

    my $infoOperacionJSON = to_json $infoOperaciones;
    C4::AR::Auth::print_header($session);
	print $infoOperacionJSON;
}
#******************************************FIN***DEVOLVER_RENOVAR*********************************************


#******************************************CANCELAR RESERVA***************************************************
elsif($tipoAccion eq "CANCELAR_RESERVA"){

    my ($user, $session, $flags, $usuario_logueado) = checkauth(    $input, 
                                                                    $authnotrequired, 
                                                                    {   ui => 'ANY', 
                                                                        tipo_documento => 'ANY', 
                                                                        accion => 'CONSULTA', 
                                                                        entorno => 'undefined'}, 
                                                                    'intranet'
                                );
		
	my %params;
	$params{'id_reserva'}= $obj->{'id_reserva'};
	$params{'nro_socio'}= $obj->{'nro_socio'};
	$params{'loggedinuser'}= $user;
	$params{'tipo'}="INTRA";
	
	my ($Message_arrayref)=C4::AR::Reservas::t_cancelar_reserva(\%params);
	
	my $infoOperacionJSON=to_json $Message_arrayref;
	
    C4::AR::Auth::print_header($session);
	print $infoOperacionJSON;
}
#******************************************FIN***CANCELAR RESERVA*********************************************

elsif($tipoAccion eq "CIRCULACION_RAPIDA"){

    my ($user, $session, $flags, $usuario_logueado) = checkauth(    $input, 
                                                                    $authnotrequired, 
                                                                    {   ui => 'ANY', 
                                                                        tipo_documento => 'ANY', 
                                                                        accion => 'CONSULTA', 
                                                                        entorno => 'undefined'}, 
                                                                    'intranet'
                                );
		
	my $Message_arrayref;
	my %params;
	$params{'barcode'}= $obj->{'barcode'};
	$params{'nro_socio'}= $obj->{'nro_socio'};
	$params{'operacion'}= $obj->{'operacion'};
	$params{'loggedinuser'}= $user;
	$params{'responsable'}= $user;
	$params{'tipo_prestamo'}= $obj->{'tipoPrestamo'};
	$params{'datosArray'}= $obj->{'datosArray'};
	
	if($params{'operacion'} eq "renovar"){	
# 		my ($Message_arrayref) = C4::AR::Prestamos::t_renovarPorBarcode(\%params);
	C4::AR::Debug::debug("circulacionDB.pl => circulacion rapida => renovar barcode: ".$params{'barcode'});	
	}
	elsif($params{'operacion'} eq "devolver"){

		($Message_arrayref) = C4::AR::Prestamos::t_devolver(\%params);	
	}
	elsif($params{'operacion'} eq "prestar"){
		($Message_arrayref)= C4::AR::Prestamos::prestarYGenerarTicket(\%params)		
	}
	
	my $infoOperacionJSON=to_json $Message_arrayref;

    C4::AR::Auth::print_header($session);
	print $infoOperacionJSON;
}
elsif($tipoAccion eq "CIRCULACION_RAPIDA_OBTENER_TIPOS_DE_PRESTAMO"){

    my ($user, $session, $flags, $usuario_logueado) = checkauth(    $input, 
                                                                    $authnotrequired, 
                                                                    {   ui => 'ANY', 
                                                                        tipo_documento => 'ANY', 
                                                                        accion => 'CONSULTA', 
                                                                        entorno => 'undefined'}, 
                                                                    'intranet'
                                );

	#obtengo el objeto de nivel3 segun el barcode que se quiere prestar
	my ($nivel3aPrestar) = C4::AR::Nivel3::getNivel3FromBarcode($obj->{'barcode'});

    if($nivel3aPrestar){

        C4::AR::Debug::debug("nivel3aPrestar disponibilidad=> ".$nivel3aPrestar->getIdDisponibilidad());
	    #obtengo los tipos de prestmos segun disponibilidad del ejemplar y el usuario
	    my ($tipoPrestamos_array_hash_ref)  = &C4::AR::Prestamos::prestamosHabilitadosPorTipo(   $nivel3aPrestar->getIdDisponibilidad(),
                                                                                                 $obj->{'nro_socio'}
                                                                                        );
    
	    my %tiposPrestamos;
	    $tiposPrestamos{'tipoPrestamo'}     = $tipoPrestamos_array_hash_ref;
	    my $infoOperacionJSON               = to_json \%tiposPrestamos;
    
        C4::AR::Auth::print_header($session);
	    print $infoOperacionJSON;
    }
}
elsif($tipoAccion eq "CIRCULACION_RAPIDA_OBTENER_SOCIO"){

    my ($user, $session, $flags, $usuario_logueado) = checkauth(    $input, 
                                                                    $authnotrequired, 
                                                                    {   ui => 'ANY', 
                                                                        tipo_documento => 'ANY', 
                                                                        accion => 'CONSULTA', 
                                                                        entorno => 'undefined'}, 
                                                                    'intranet'
                                );

	#obtengo el objeto de nivel3 segun el barcode que se quiere prestar
	my ($socio)= C4::AR::Prestamos::getSocioFromID_Prestamo($obj->{'prestamo'});
	
	my %infoSocio;
	if($socio){
		$infoSocio{'apeYNom'}= $socio->persona->getApeYNom;
		$infoSocio{'nro_socio'}= $socio->getNro_socio;
	}

	my $infoOperacionJSON=to_json \%infoSocio;

    C4::AR::Auth::print_header($session);
	print $infoOperacionJSON;
}
elsif($tipoAccion eq "CIRCULACION_RAPIDA_TIENE_AUTORIZADO"){

#     my ($user, $session, $flags, $usuario_logueado) = checkauth(    $input, 
#                                                                     $authnotrequired, 
#                                                                     {   ui => 'ANY', 
#                                                                         tipo_documento => 'ANY', 
#                                                                         accion => 'CONSULTA', 
#                                                                         entorno => 'undefined'}, 
#                                                                     'intranet'
#                                 );

    my ($template, $session, $t_params) = get_template_and_user({
                                    template_name => "circ/mostrarAdicional.tmpl",
                                    query => $input,
                                    type => "intranet",
                                    authnotrequired => 0,
                                    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
                                    debug => 1,
                });
		
	my $Message_arrayref;
	my %params;
	$params{'barcode'}      = $obj->{'barcode'};
	$params{'nro_socio'}    = $obj->{'nro_socio'};
	$params{'operacion'}    = $obj->{'operacion'};
	
	my $socio               = C4::AR::Usuarios::getSocioInfoPorNroSocio($params{'nro_socio'});
# 	my $flag                = 0;

# 	if($socio){
# 		$flag = $socio->tieneAutorizado;
# 	}

    $t_params->{'socio'} = $socio;

    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);

#     C4::AR::Auth::print_header($session);
# 	print $flag;
}
elsif($tipoAccion eq "CIRCULACION_RAPIDA_ES_REGULAR"){

    my ($user, $session, $flags, $usuario_logueado) = checkauth(    $input, 
                                                                    $authnotrequired, 
                                                                    {   ui => 'ANY', 
                                                                        tipo_documento => 'ANY', 
                                                                        accion => 'CONSULTA', 
                                                                        entorno => 'undefined'},
                                                                    'intranet'
                                );

	my $socio= C4::AR::Usuarios::getSocioInfoPorNroSocio($obj->{'nro_socio'});

	my $regular= 1;
    if ($socio){
		$regular= $socio->esRegular;
	}
	
    C4::AR::Auth::print_header($session);
	print $regular;
}
