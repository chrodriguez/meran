#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::UploadFile;
use JSON;


use Template;
use CGI;

my $input = new CGI;

my $authnotrequired= 0;
# OBTENGO EL BORROWER LOGGEADO
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, $authnotrequired,{circulate=> 0},"intranet");

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# $loggedinuser=getborrowernumber($loggedinuser);

my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $tipoAccion= $obj->{'tipoAccion'}||"";

my $dateformat = C4::Date::get_date_format();

=item
Aca se maneja el cambio de la password para el usuario
=cut
if($tipoAccion eq "CAMBIAR_PASSWORD"){

	my %params;
	$params{'usuario'}= $obj->{'usuario'};
	$params{'newpassword'}= $obj->{'newpassword'};
	$params{'newpassword1'}= $obj->{'newpassword1'};

	my ($Message_arrayref)= C4::AR::Usuarios::t_cambiarPassword(\%params);
	
	my $infoOperacionJSON=to_json $Message_arrayref;
	
	print $input->header;
	print $infoOperacionJSON;
	
} #end if($tipoAccion eq "CAMBIAR_PASSWORD")

=item
Aca se maneja el cambio de permisos para el usuario
=cut
elsif($tipoAccion eq "GUARDAR_PERMISOS"){

	my %params;
	$params{'usuario'}= $obj->{'usuario'};
	$params{'array_permisos'}= $obj->{'array_permisos'};
	
 	my ($Message_arrayref)= C4::AR::Usuarios::t_cambiarPermisos(\%params);
	
	my $infoOperacionJSON=to_json $Message_arrayref;
	
	print $input->header;
	print $infoOperacionJSON;

} #end if($tipoAccion eq "GUARDAR_PERMISOS")


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


	my ($bor,$flags,$accessflags)= C4::Circulation::Circ2::getpatroninformation( $obj->{'usuario'},'');
	
	my $dbh=C4::Context->dbh();
	my $sth=$dbh->prepare("SELECT bit,flag,flagdesc FROM usr_permiso ORDER BY bit");
	$sth->execute;
	my @loop;

	while (my ($bit, $flag, $flagdesc) = $sth->fetchrow) {
		my $checked='';
		if ( $accessflags->{$flag} ) {
			$checked='checked';
		}
		
		my %row = ( 	bit => $bit,
				flag => $flag,
				checked => $checked,
				flagdesc => $flagdesc );

		push @loop, \%row;
	}

	$t_params->{'surname'}= $bor->{'surname'};
  	$t_params->{'firstname'}= $bor->{'firstname'};
	$t_params->{'loop'}= \@loop;

# 	print $session->header;
	C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);

} #end if($tipoAccion eq "MOSTRAR_PERMISOS")


=item
Se elimina el usuario
=cut
elsif($tipoAccion eq "ELIMINAR_USUARIO"){

	my %params;
	my $usuario_hash_ref= C4::AR::Usuarios::getBorrower($obj->{'borrowernumber'});
	$params{'loggedInUser'} = $loggedinuser;
	$params{'usuario'}= $usuario_hash_ref->{'surname'}.', '.$usuario_hash_ref->{'firstname'};
   	$params{'borrowernumber'}= $usuario_hash_ref->{'borrowernumber'};

 	my ($Message_arrayref)= C4::AR::Usuarios::t_eliminarUsuario(\%params);
	my $infoOperacionJSON=to_json $Message_arrayref;
	
	print $input->header;
	print $infoOperacionJSON;

} #end if($tipoAccion eq "ELIMINAR_USUARIO")


=item
Se elimina el usuario
=cut
elsif($tipoAccion eq "AGREGAR_USUARIO"){
	
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

	my $numero_socio =$obj->{'numero_socio'};

	#Obtenemos los datos del borrower
	my $socio= &C4::AR::Usuarios::getSocioInfo($numero_socio);

	#se genera el combo de categorias de usuario
	my $comboDeCategorias= &C4::AR::Utilidades::generarComboCategorias($socio->cod_categoria);
	
	#se genera el combo de tipos de documento
	my $comboDeTipoDeDoc= &C4::AR::Utilidades::generarComboTipoDeDoc($socio->persona->tipo_documento);

	#se genera el combo de las bibliotecas
	my $comboDeUI= &C4::AR::Utilidades::generarComboUI($socio->id_ui);

	$t_params->{'combo_tipo_documento'}= $comboDeTipoDeDoc;
	$t_params->{'comboDeCategorias'}= $comboDeCategorias;
	$t_params->{'comboDeUI'}= $comboDeUI;
	$t_params->{'change_password'}= $socio->getChange_password;
	$t_params->{'nombre'}= $socio->persona->getNombre;
	$t_params->{'apellido'}= $socio->persona->getApellido;
	$t_params->{'calle'}= $socio->persona->getCalle;
	$t_params->{'barrio'}= $socio->persona->getBarrio;
	$t_params->{'ciudad'}= $socio->persona->ciudad_ref->NOMBRE;
    $t_params->{'id_ciudad'}= $socio->persona->ciudad_ref->LOCALIDAD;
#     $t_params->{'alt_ciudad'}= $socio->persona->ciudad_ref->NOMBRE;
#     $t_params->{'id_alt_ciudad'}= $socio->persona->ciudad_ref->LOCALIDAD;
	$t_params->{'telefono'}= $socio->persona->getTelefono;
	$t_params->{'alt_telefono'}= $socio->persona->getAlt_telefono;
	$t_params->{'email'}= $socio->persona->getEmail;
	$t_params->{'otros_nombres'}= $socio->persona->getOtros_nombres;
	$t_params->{'nro_documento'}= $socio->persona->getNro_documento;
# 	$t_params->{'studentnumber'}= $socio->studentnumber'};
	$t_params->{'fecha_alta'}= $socio->getFecha_alta;
	$t_params->{'expira'}= $socio->getExpira;
	$t_params->{'nro_socio'}= $socio->getNro_socio;
 	$t_params->{'nacimiento'}= C4::Date::format_date($socio->persona->getNacimiento,$dateformat);
	$t_params->{'addBorrower'}= 0;
	$t_params->{'sexo'}= $socio->persona->getSexo;
#  	$t_params->{'dateformat'}= C4::Date::display_date_format($dateformat);

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
} #end if($tipoAccion eq "MODIFICAR_USUARIO")


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
	my $foto_name= $obj->{'foto_name'};
	my ($Message_arrayref)= &C4::AR::UploadFile::deletePhoto($foto_name);
	
	my $infoOperacionJSON=to_json $Message_arrayref;
	
	print $input->header;
	print $infoOperacionJSON;
}	


elsif($tipoAccion eq "PRESTAMO_INTER_BIBLIO"){

# 	my %params;
	my $bornum = $obj->{'borrowernumber'};

#  	my ($Message_arrayref)= (\%params);
	
# 	my $infoOperacionJSON=to_json $Message_arrayref;
	
	my ($template, $session, $t_params) = get_template_and_user({
									template_name => "usuarios/reales/printPrestInterBiblio.tmpl",
									query => $input,
									type => "intranet",
									authnotrequired => 0,
									flagsrequired => {borrowers => 1},
									debug => 1,
			    });

	my $bibliotecas=C4::AR::Utilidades::generarComboDeBranches();

	$t_params->{'bibliotecas'}= $bibliotecas;
	$t_params->{'bornum'}= $bornum;

	C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);


	

} #end if($tipoAccion eq "GUARDAR_PERMISOS")