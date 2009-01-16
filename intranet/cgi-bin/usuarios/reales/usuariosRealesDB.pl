#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::UploadFile;
use JSON;
use CGI;

my $input = new CGI;

my $authnotrequired= 0;
open(A, ">>/tmp/debug.txt");
print A "desde usuariosRealesDB=>\n";

my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $tipoAccion= $obj->{'tipoAccion'}||"";

my $dateformat = C4::Date::get_date_format();

=item
Aca se maneja el cambio de la password para el usuario
=cut
if($tipoAccion eq "CAMBIAR_PASSWORD"){

    my $session = CGI::Session->load();

	my %params;
	$params{'id_socio'}= $obj->{'usuario'};
    $params{'actualPassword'}= $obj->{'actualPassword'};

#     if($params{'changePassword'} ){
#         $params{'actualPassword'}= '';
#     }

	$params{'newpassword'}= $obj->{'newpassword'};
	$params{'newpassword1'}= $obj->{'newpassword1'};
    $params{'session'}= $session;

	my ($Message_arrayref)= C4::AR::Usuarios::cambiarPassword(\%params);
	
	my $infoOperacionJSON=to_json $Message_arrayref;
	
	print $input->header;
	print $infoOperacionJSON;
	
} #end if($tipoAccion eq "CAMBIAR_PASSWORD")
=item
Aca se maneja el cambio de permisos para el usuario
=cut
elsif($tipoAccion eq "GUARDAR_PERMISOS"){
my ($loggedinuser, $cookie, $session, $flags) = checkauth($input, $authnotrequired,{borrowers=> 1},"intranet");
	my %params;
	$params{'id_socio'}= $obj->{'usuario'};
	$params{'array_permisos'}= $obj->{'array_permisos'};
	
 	my ($Message_arrayref)= C4::AR::Usuarios::t_cambiarPermisos(\%params);
	
	my $infoOperacionJSON=to_json $Message_arrayref;
	
	print $input->header;
	print $infoOperacionJSON;

} #end if($tipoAccion eq "GUARDAR_PERMISOS")


=item
Aca se maneja el resteo de password del usuario
=cut
elsif($tipoAccion eq "RESET_PASSWORD"){
my ($loggedinuser, $cookie, $session, $flags) = checkauth($input, $authnotrequired,{borrowers=> 1},"intranet");
    my %params;
    $params{'id_socio'}= $obj->{'usuario'};
    
    my ($Message_arrayref)= C4::AR::Usuarios::resetPassword(\%params);
    
    my $infoOperacionJSON=to_json $Message_arrayref;
    
    print $input->header;
    print $infoOperacionJSON;

} #end if($tipoAccion eq "RESET_PASSWORD")

=item
Se buscan los permisos del usuario y se muestran por pantalla
=cut
elsif($tipoAccion eq "MOSTRAR_PERMISOS"){
	my $flagsrequired;
	$flagsrequired->{permissions}=1;

	my ($template, $session, $t_params) = get_template_and_user({
									template_name => "usuarios/reales/permisos-usuario.tmpl",
									query => $input,
									type => "intranet",
									authnotrequired => 0,
									flagsrequired => {borrowers => 1},
									debug => 1,
			    });

    my ($socio)= C4::AR::Usuarios::getSocioInfo($obj->{'usuario'});
    
    #Obtengo los permisos del socio
    my $flags_hashref= $socio->getPermisos;

    #Obtengo todos los permisos
    my $permisos_array_ref = C4::Modelo::UsrPermiso::Manager->get_usr_permiso();

    my @loop;

    foreach my $permiso (@$permisos_array_ref){
        my $checked='';

        if ( $flags_hashref->{ $permiso->{'flag'} } ) {
            $checked='checked';
        }
        
        my %row = (     bit => $permiso->{'bit'},
                        flag =>  $permiso->{'flag'},
                        checked => $checked,
                        flagdesc => $permiso->{'flagdesc'} );

        push @loop, \%row;
    }

	$t_params->{'loop'}= \@loop;
    $t_params->{'tiene'}=$socio->tienePermisos($flagsrequired);

	C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);

} #end if($tipoAccion eq "MOSTRAR_PERMISOS")


=item
Se elimina el usuario
=cut
elsif($tipoAccion eq "ELIMINAR_USUARIO"){
my ($loggedinuser, $cookie, $session, $flags) = checkauth($input, $authnotrequired,{borrowers=> 1},"intranet");
	my %params;
	my $id_socio= $obj->{'id_socio'};
 	my ($Message_arrayref)= C4::AR::Usuarios::eliminarUsuario($id_socio);
	my $infoOperacionJSON=to_json $Message_arrayref;
	
	print $input->header;
	print $infoOperacionJSON;

} #end if($tipoAccion eq "ELIMINAR_USUARIO")


=item
Se elimina el usuario
=cut
elsif($tipoAccion eq "AGREGAR_USUARIO"){
my ($loggedinuser, $cookie, $session, $flags) = checkauth($input, $authnotrequired,{borrowers=> 1},"intranet");	
    print $obj->{'nombre'};
	my $Message_arrayref=C4::AR::Usuarios::agregarPersona($obj); #C4::AR::Usuarios::t_addBorrower($obj);
    
	my $infoOperacionJSON=to_json $Message_arrayref;
	
	print $input->header;
	print $infoOperacionJSON;

} #end if($tipoAccion eq "AGREGAR_USUARIO")


=item
Se guarda la modificacion los datos del usuario
=cut
elsif($tipoAccion eq "GUARDAR_MODIFICACION_USUARIO"){
my ($loggedinuser, $cookie, $session, $flags) = checkauth($input, $authnotrequired,{borrowers=> 1},"intranet");	
# 	my ($Message_arrayref)= C4::AR::Usuarios::t_updateBorrower($obj);
# 	
# 	my $infoOperacionJSON=to_json $Message_arrayref;
# 	
# 	print $input->header;
# 	print $infoOperacionJSON;

    my ($Message_arrayref)= C4::AR::Usuarios::actualizarSocio($obj);
    
    my $infoOperacionJSON=to_json $Message_arrayref;
    
    print $input->header;
    print $infoOperacionJSON;

} #end if($tipoAccion eq "GUARDAR_MODIFICACION_USUARIO")


=item
Se genra la ventana para modificar los datos del usuario
=cut
elsif($tipoAccion eq "MODIFICAR_USUARIO"){

	my ($template, $session, $t_params) = get_template_and_user({
									template_name => "usuarios/reales/agregarUsuario.tmpl",
									query => $input,
									type => "intranet",
									authnotrequired => 0,
									flagsrequired => {borrowers => 1},
									debug => 1,
			    });

	my $id_socio =$obj->{'id_socio'};

	#Obtenemos los datos del borrower
	my $socio= &C4::AR::Usuarios::getSocioInfo($id_socio);

    my %params;
    $params{'default'}= $socio->cod_categoria;
	#se genera el combo de categorias de usuario
	my $comboDeCategorias= &C4::AR::Utilidades::generarComboCategoriasDeSocio(\%params);
	
    $params{'default'}= $socio->persona->tipo_documento;
	#se genera el combo de tipos de documento
	my $comboDeTipoDeDoc= &C4::AR::Utilidades::generarComboTipoDeDoc(\%params);

    $params{'default'}= $socio->persona->tipo_documento;
	#se genera el combo de las bibliotecas
	my $comboDeUI= &C4::AR::Utilidades::generarComboUI(\%params);

	$t_params->{'combo_tipo_documento'}= $comboDeTipoDeDoc;
	$t_params->{'comboDeCategorias'}= $comboDeCategorias;
	$t_params->{'comboDeUI'}= $comboDeUI;
	$t_params->{'addBorrower'}= 0;

    #paso el objeto socio al cliente
    $t_params->{'socio'}= $socio;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
} #end if($tipoAccion eq "MODIFICAR_USUARIO")

## FIXME parece q no se usa!!!!!!!!!!!!!!!!!!!!!!!!!!
elsif($tipoAccion eq "DATOS_USUARIO"){

	my ($template, $session, $t_params) = get_template_and_user({
									template_name => "usuarios/reales/detalleUsuario.tmpl",
									query => $input,
									type => "intranet",
									authnotrequired => 0,
									flagsrequired => {borrowers => 1},
									debug => 1,
			    });
	
	my $bornum= $obj->{'borrowernumber'};
	
	my $data=C4::AR::Usuarios::getBorrowerInfo($bornum);
	$data->{'changepassword'}= $data->{'changepassword'};#creo q no es necesario
	
	# Curso de usuarios#
	if (C4::Context->preference("usercourse")){
		$t_params->{'course'}=1;
		$t_params->{'usercourse'} = C4::Date::format_date($data->{'usercourse'},$dateformat);
	}
	#
## FIXME pasar el objeto compelto al cliente
	$t_params->{'dateenrolled'} = C4::Date::format_date($data->{'dateenrolled'},$dateformat);
	$t_params->{'expiry'} = C4::Date::format_date($data->{'expiry'},$dateformat);
	$t_params->{'dateofbirth'} = C4::Date::format_date($data->{'dateofbirth'},$dateformat);
	$t_params->{'IS_ADULT'} = ($data->{'categorycode'} ne 'I');
	
	$t_params->{'city'}=C4::AR::Busquedas::getNombreLocalidad($data->{'city'});
	$t_params->{'streetcity'}=C4::AR::Busquedas::getNombreLocalidad($data->{'streetcity'});
	
	# Converts the branchcode to the branch name
	$t_params->{'branchcode'} = C4::AR::Busquedas::getBranch($data->{'branchcode'})->{'branchname'};
	
	# Converts the categorycode to the description
	$t_params->{'categorycode'} = C4::AR::Busquedas::getborrowercategory($data->{'categorycode'});
	
	#### Verifica si la foto ya esta cargada
	my $picturesDir= C4::Context->config("picturesdir");
	my $foto;
	if (opendir(DIR, $picturesDir)) {
		my $pattern= $bornum."[.].";
		my @file = grep { /$pattern/ } readdir(DIR);
		$foto= join("",@file);
		closedir DIR;
	} else {
		$foto= 0;
	}
	
	$t_params->{'bornum'}= $bornum;
	$t_params->{'foto_name'}= $foto;

	C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}
	

elsif($tipoAccion eq "ELIMINAR_FOTO"){
my ($loggedinuser, $cookie, $session, $flags) = checkauth($input, $authnotrequired,{borrowers=> 1},"intranet");
	my $foto_name= $obj->{'foto_name'};
	my ($Message_arrayref)= &C4::AR::UploadFile::deletePhoto($foto_name);
	
	my $infoOperacionJSON=to_json $Message_arrayref;
	
	print $input->header;
	print $infoOperacionJSON;
}	


elsif($tipoAccion eq "PRESTAMO_INTER_BIBLIO"){
	
	my ($template, $session, $t_params) = get_template_and_user({
									template_name => "usuarios/reales/printPrestInterBiblio.tmpl",
									query => $input,
									type => "intranet",
									authnotrequired => 0,
									flagsrequired => {borrowers => 1},
									debug => 1,
			    });

    my $socio= C4::AR::Usuarios::getSocioInfo($obj->{'id_socio'});

    my $comboDeUI= &C4::AR::Utilidades::generarComboUI();

    $t_params->{'comboDeUI'}= $comboDeUI;
    $t_params->{'nro_socio'}= $socio->getNro_socio;
    $t_params->{'id_socio'}= $obj->{'id_socio'};

	C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);

} #end if($tipoAccion eq "GUARDAR_PERMISOS")