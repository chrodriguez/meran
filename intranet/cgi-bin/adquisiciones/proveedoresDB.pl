#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::AR::Proveedores;
use CGI;

my $input = new CGI;
my $authnotrequired= 0;

my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $tipoAccion= $obj->{'tipoAccion'}||"";


=item
    Se elimina el Proveedor
=cut
    ## TODO tambien se podria hacer que el sistema genere la pass y se la envie por correo al socio, esto deberia ser una preferencia 
    # resetPassword = [0 | 1]
    # autoGeneratePassword = [0 | 1]
    if($tipoAccion eq "ELIMINAR"){
    	
#     	C4::AR::Debug::debug($infoOperacionJSON);
#     	C4::AR::Debug::debug("Estoy eliminando");
        my ($userid, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'BAJA', 
                                                entorno => 'usuarios'},
                                                "intranet"
                                );

        my %params;
        my $id_proveedor= $obj->{'id_proveedor'};

        C4::AR::Validator::validateParams('U389',$obj,['id_proveedor'] );

        my ($Message_arrayref)= C4::AR::Proveedores::eliminarProveedor($id_proveedor);
        my $infoOperacionJSON=to_json $Message_arrayref;

        C4::Auth::print_header($session);
        print $infoOperacionJSON;

    } #end if($tipoAccion eq "ELIMINAR_USUARIO")


=item
Se guarda la modificacion los datos del Proveedor
=cut
    elsif($tipoAccion eq "GUARDAR_MODIFICION_PROVEEDOR"){

      my $obj=$input->param('obj');
      $obj=C4::AR::Utilidades::from_json_ISO($obj);

        my ($loggedinuser, $session, $flags) = checkauth( 
                                                                $input, 
                                                                $authnotrequired,
                                                                {   ui => 'ANY', 
                                                                    tipo_documento => 'ANY', 
                                                                    accion => 'MODIFICACION', 
# TODO generar el entorno proveedores
                                                                    entorno => 'usuarios'},
#                                                                 entorno => 'proveedores'},    
                                                                "intranet"
                                );  

        my ($Message_arrayref)= C4::AR::Proveedores::editarProveedor($obj);


        my $infoOperacionJSON=to_json $Message_arrayref;
        C4::Auth::print_header($session);
        print $infoOperacionJSON;

    } #end if($tipoAccion eq "GUARDAR_MODIFICACION_USUARIO")
