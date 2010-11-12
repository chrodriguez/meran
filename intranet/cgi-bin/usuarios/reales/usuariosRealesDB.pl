#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::UploadFile;
use JSON;
use CGI;

my $input = new CGI;
my $authnotrequired= 0;
my $editing = $input->param('edit');

if($editing){
    my ($template, $session, $t_params)  = get_template_and_user({  
                        template_name => "includes/partials/modificar_value.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'permisos', tipo_permiso => 'general'},
                        debug => 1,
                    });
    my %params = {};

    $params{'action'} = $input->param('action');
    $params{'edit'} = $input->param('edit');
    $params{'id'} = $input->param('id');
    $params{'nro_socio'} = $input->param('nro_socio');
    $params{'value'} = $input->param('value');
    C4::AR::Validator::validateParams('U389',\%params,['nro_socio'] );

    my ($value)= C4::AR::Usuarios::editarAutorizado(\%params);

    $t_params->{'value'} = $value;
    C4::Auth::output_html_with_http_headers($template, $t_params, $session);

}else{

    my $obj=$input->param('obj');
    $obj=C4::AR::Utilidades::from_json_ISO($obj);

    my $tipoAccion= $obj->{'tipoAccion'}||"";


=item
    Aca se maneja el resteo de password del usuario
=cut
    ## TODO tambien se podria hacer que el sistema genere la pass y se la envie por correo al socio, esto deberia ser una preferencia 
    # resetPassword = [0 | 1]
    # autoGeneratePassword = [0 | 1]
    if($tipoAccion eq "RESET_PASSWORD"){
        my ($userid, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'MODIFICACION', 
                                                entorno => 'usuarios'},
                                            "intranet"
                                );

        my %params;
        $params{'nro_socio'}= $obj->{'nro_socio'};

        C4::AR::Validator::validateParams('U389',$obj,['nro_socio'] );

        my ($Message_arrayref)= C4::AR::Usuarios::resetPassword(\%params);
        my $infoOperacionJSON=to_json $Message_arrayref;

        C4::Auth::print_header($session);
        print $infoOperacionJSON;

    } #end if($tipoAccion eq "RESET_PASSWORD")


    elsif($tipoAccion eq "AGREGAR_AUTORIZADO"){
        my ($userid, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'MODIFICACION', 
                                                entorno => 'usuarios'},
                                            "intranet"
                                );

        C4::AR::Validator::validateParams('U389',$obj,['nro_socio'] );

        my ($Message_arrayref)= C4::AR::Usuarios::agregarAutorizado($obj);
        my $infoOperacionJSON=to_json $Message_arrayref;

        C4::Auth::print_header($session);
        print $infoOperacionJSON;

    }

    elsif($tipoAccion eq "MOSTRAR_VENTANA_AGREGAR_AUTORIZADO"){
        my $flagsrequired;
        $flagsrequired->{permissions}=1;

        my ($template, $session, $t_params) = get_template_and_user({
                                        template_name => "includes/popups/agregarAutorizado.inc",
                                        query => $input,
                                        type => "intranet",
                                        authnotrequired => 0,
                                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
                                        debug => 1,
                    });

        C4::Auth::output_html_with_http_headers($template, $t_params, $session);

    } 

    elsif($tipoAccion eq "ELIMINAR_AUTORIZADO"){
        my ($userid, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'BAJA', 
                                                entorno => 'usuarios'},
                                            "intranet"
                                );

        my %params;
        $params{'nro_socio'}= $obj->{'nro_socio'};

        C4::AR::Validator::validateParams('U389',$obj,['nro_socio'] );

        my ($Message_arrayref)= C4::AR::Usuarios::desautorizarTercero(\%params);
        my $infoOperacionJSON=to_json $Message_arrayref;

        C4::Auth::print_header($session);
        print $infoOperacionJSON;

    } 

=item
Se elimina el usuario
=cut
    elsif($tipoAccion eq "ELIMINAR_USUARIO"){
        my ($userid, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'BAJA', 
                                                entorno => 'usuarios'},
                                                "intranet"
                                );

        my %params;
        my $nro_socio= $obj->{'nro_socio'};

        C4::AR::Validator::validateParams('U389',$obj,['nro_socio'] );

        my ($Message_arrayref)= C4::AR::Usuarios::eliminarUsuario($nro_socio);
        my $infoOperacionJSON=to_json $Message_arrayref;

        C4::Auth::print_header($session);
        print $infoOperacionJSON;

    } #end if($tipoAccion eq "ELIMINAR_USUARIO")


=item
Se agrega el usuario
=cut
    elsif($tipoAccion eq "AGREGAR_USUARIO"){
        my ($loggedinuser, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'ALTA', 
                                                entorno => 'usuarios'},
                                            "intranet"
                                );

        C4::AR::Validator::validateParams('U389',$obj,['nombre','nacimiento','ciudad','apellido','id_ui','sexo'] );
        my $Message_arrayref=C4::AR::Usuarios::agregarPersona($obj);
        my $infoOperacionJSON=to_json $Message_arrayref;

        C4::Auth::print_header($session);
        print $infoOperacionJSON;

    } #end if($tipoAccion eq "AGREGAR_USUARIO")


=item
Se guarda la modificacion los datos del usuario
=cut
    elsif($tipoAccion eq "GUARDAR_MODIFICACION_USUARIO"){
        my ($loggedinuser, $session, $flags) = checkauth( 
                                                                $input, 
                                                                $authnotrequired,
                                                                {   ui => 'ANY', 
                                                                    tipo_documento => 'ANY', 
                                                                    accion => 'MODIFICACION', 
                                                                    entorno => 'usuarios'},
                                                                "intranet"
                                );	

        C4::AR::Validator::validateParams('U389',$obj,['nro_socio','nombre','nacimiento','ciudad','apellido','id_ui','sexo'] );

        my ($Message_arrayref)= C4::AR::Usuarios::actualizarSocio($obj);
        my $infoOperacionJSON=to_json $Message_arrayref;

        C4::Auth::print_header($session);
        print $infoOperacionJSON;

    } #end if($tipoAccion eq "GUARDAR_MODIFICACION_USUARIO")


=item
Se genra la ventana para modificar los datos del usuario
=cut
    elsif($tipoAccion eq "MODIFICAR_USUARIO"){

        my ($template, $session, $t_params, $socio) = get_template_and_user({
                                        template_name   => "usuarios/reales/agregarUsuario.tmpl",
                                        query           => $input,
                                        type            => "intranet",
                                        authnotrequired => 0,
                                        flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'MODIFICACION', entorno => 'usuarios'},
                                        debug           => 1,
        });

        my $nro_socio                   = $obj->{'nro_socio'};
        $t_params->{'nro_socio'}        = $nro_socio;
        C4::AR::Validator::validateParams('U389',$obj,['nro_socio'] );
        #Obtenemos los datos del borrower
        my $socio                       = &C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);
        #SI NO EXISTE EL SOCIO IMPRIME 0, PARA INFORMAR AL CLIENTE QUE ACCION REALIZAR
        C4::AR::Validator::validateObjectInstance($socio);
        my %params;
        $params{'default'}              = $socio->getCod_categoria;
        #se genera el combo de categorias de usuario
        my $comboDeCategorias           = &C4::AR::Utilidades::generarComboCategoriasDeSocio(\%params);

        $params{'default'}              = $socio->persona->getTipo_documento;
        #se genera el combo de tipos de documento
        my $comboDeTipoDeDoc            = &C4::AR::Utilidades::generarComboTipoDeDoc(\%params);
        #se genera el combo de las bibliotecas
        my $comboDeUI                   = &C4::AR::Utilidades::generarComboUI(\%params);

        $t_params->{'socio_modificar'}  = $socio;
        my $comboDeCredentials          = &C4::AR::Utilidades::generarComboDeCredentials($t_params); #llama a getSocioInfoPorNroSocio
        $t_params->{'combo_temas'}      = C4::AR::Utilidades::generarComboTemasINTRA($nro_socio); #llama a getSocioInfoPorNroSocio
        $t_params->{'comboDeCredentials'}   = $comboDeCredentials;
        $t_params->{'combo_tipo_documento'} = $comboDeTipoDeDoc;
        $t_params->{'comboDeCategorias'}    = $comboDeCategorias;
        $t_params->{'comboDeUI'}            = $comboDeUI;
        $t_params->{'addBorrower'}          = 0;

        #paso el objeto socio al cliente
        C4::Auth::output_html_with_http_headers($template, $t_params, $session);
    } #end if($tipoAccion eq "MODIFICAR_USUARIO")

    elsif($tipoAccion eq "ELIMINAR_FOTO"){
        my ($loggedinuser, $session, $flags) = checkauth( 
                                                                $input, 
                                                                $authnotrequired,
                                                                {   ui => 'ANY', 
                                                                    tipo_documento => 'ANY', 
                                                                    accion => 'MODIFICACION', 
                                                                    entorno => 'usuarios'},
                                                                "intranet"
                                );  

        my $foto_name           = $obj->{'foto_name'};

        C4::AR::Validator::validateParams('U389',$obj,['foto_name'] );

        my ($Message_arrayref)  = &C4::AR::UploadFile::deletePhoto($foto_name);
        my $infoOperacionJSON   = to_json $Message_arrayref;

        C4::Auth::print_header($session);
        print $infoOperacionJSON;
    }


    elsif($tipoAccion eq "PRESTAMO_INTER_BIBLIO"){

        my ($template, $session, $t_params) = get_template_and_user({
                                        template_name => "usuarios/reales/printPrestInterBiblio.tmpl",
                                        query => $input,
                                        type => "intranet",
                                        authnotrequired => 0,
                                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                                        debug => 1,
        });
        C4::AR::Validator::validateParams('U389',$obj,['nro_socio'] );


        my $socio= C4::AR::Usuarios::getSocioInfoPorNroSocio($obj->{'nro_socio'});

        #SI NO EXISTE EL SOCIO IMPRIME 0, PARA INFORMAR AL CLIENTE QUE ACCION REALIZAR
        C4::AR::Validator::validateObjectInstance($socio);

        my $comboDeUI= &C4::AR::Utilidades::generarComboUI();

        $t_params->{'comboDeUI'}= $comboDeUI;
        $t_params->{'nro_socio'}= $socio->getNro_socio;
        $t_params->{'id_socio'}= $obj->{'id_socio'};

        C4::Auth::output_html_with_http_headers($template, $t_params, $session);

    }
}
