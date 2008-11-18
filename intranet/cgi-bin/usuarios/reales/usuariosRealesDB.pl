#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::UploadFile;
use JSON;


use Template;
use CGI;

my $input = new CGI;



# OBTENGO EL BORROWER LOGGEADO
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{circulate=> 1},"intranet");

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

$loggedinuser=getborrowernumber($loggedinuser);

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

	my ($template, $session, $params) = get_template_and_user({
									template_name => "usuarios/reales/permisos-usuario.tmpl",
									query => $input,
									type => "intranet",
									authnotrequired => 0,
									flagsrequired => {borrowers => 1},
									debug => 1,
			    });


	my ($bor,$flags,$accessflags)= C4::Circulation::Circ2::getpatroninformation( $obj->{'usuario'},'');
	
	my $dbh=C4::Context->dbh();
	my $sth=$dbh->prepare("SELECT bit,flag,flagdesc FROM userflags ORDER BY bit");
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

	$params->{'surname'}= $bor->{'surname'};
  	$params->{'firstname'}= $bor->{'firstname'};
	$params->{'loop'}= \@loop;

# 	print $session->header;
	C4::Auth::output_html_with_http_headers($input, $template, $params);

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
	
	my ($Message_arrayref)= C4::AR::Usuarios::t_addBorrower($obj);

	my $infoOperacionJSON=to_json $Message_arrayref;
	
	print $input->header;
	print $infoOperacionJSON;

} #end if($tipoAccion eq "AGREGAR_USUARIO")


=item
Se guarda la modificacion los datos del usuario
=cut
elsif($tipoAccion eq "GUARDAR_MODIFICACION_USUARIO"){
	
	my ($Message_arrayref)= C4::AR::Usuarios::t_updateBorrower($obj);
	
	my $infoOperacionJSON=to_json $Message_arrayref;
	
	print $input->header;
	print $infoOperacionJSON;

} #end if($tipoAccion eq "GUARDAR_MODIFICACION_USUARIO")


=item
Se genra la ventana para modificar los datos del usuario
=cut
elsif($tipoAccion eq "MODIFICAR_USUARIO"){

	my ($template, $session, $params) = get_template_and_user({
									template_name => "usuarios/reales/agregarUsuario.tmpl",
									query => $input,
									type => "intranet",
									authnotrequired => 0,
									flagsrequired => {borrowers => 1},
									debug => 1,
			    });

	my $borrowernumber =$obj->{'borrowernumber'};

	#Obtenemos los datos del borrower
	my $datosBorrower_hashref= &C4::AR::Usuarios::getBorrowerInfo($borrowernumber);

	#se genera el combo de categorias de usuario
	my $comboDeCategorias= &C4::AR::Utilidades::generarComboCategorias($datosBorrower_hashref->{'categorycode'});
	
	#se genera el combo de tipos de documento
	my $comboDeTipoDeDoc= &C4::AR::Utilidades::generarComboTipoDeDoc($datosBorrower_hashref->{'documenttype'});

	#se genera el combo de las bibliotecas
	my $comboDeBranches= &C4::AR::Utilidades::generarComboDeBranches($datosBorrower_hashref->{'branchcode'});

	$params->{'document'}= $comboDeTipoDeDoc;
	$params->{'catcodepopup'}= $comboDeCategorias;
	$params->{'CGIbranch'}= $comboDeBranches;
	$params->{'changepassword'}= $datosBorrower_hashref->{'changepassword'};
	$params->{'type'}= $datosBorrower_hashref->{'type'};
	$params->{'physstreet'}= $datosBorrower_hashref->{'physstreet'};
	$params->{'firstname'}= $datosBorrower_hashref->{'firstname'};
	$params->{'surname'}= $datosBorrower_hashref->{'surname'};
	$params->{'streetaddress'}= $datosBorrower_hashref->{'streetaddress'};
	$params->{'zipcode'}= $datosBorrower_hashref->{'zipcode'};
	$params->{'dstreetcity'}= $datosBorrower_hashref->{'streetcity'};
	$params->{'homezipcode'}= $datosBorrower_hashref->{'homezipcode'};
	$params->{'city'}= $datosBorrower_hashref->{'city'};
	$params->{'dcity'}= $datosBorrower_hashref->{'dcity'};
	$params->{'phone'}= $datosBorrower_hashref->{'phone'};
	$params->{'phoneday'}= $datosBorrower_hashref->{'phoneday'};
	$params->{'emailaddress'}= $datosBorrower_hashref->{'emailaddress'};
	$params->{'borrowernotes'}= $datosBorrower_hashref->{'borrowernotes'};
	$params->{'documentnumber'}= $datosBorrower_hashref->{'documentnumber'};
	$params->{'studentnumber'}= $datosBorrower_hashref->{'studentnumber'};
	$params->{'dateenrolled'}= $datosBorrower_hashref->{'dateenrolled'};
	$params->{'expiry'}= $datosBorrower_hashref->{'expiry'};
	$params->{'cardnumber'}= $datosBorrower_hashref->{'cardnumber'};
 	$params->{'dateofbirth'}= C4::Date::format_date($datosBorrower_hashref->{'dateofbirth'},$dateformat);
	$params->{'addBorrower'}= 0;
	$params->{'sex'}= $datosBorrower_hashref->{'sex'};
 	$params->{'dateformat'}= C4::Date::display_date_format($dateformat);
	$params->{'top'}= "intranet-top.inc";
	$params->{'menuInc'}= "menu.inc";
	$params->{'themelang'}= '/intranet-tmpl/blue/es2/';

C4::Auth::output_html_with_http_headers($input, $template, $params);
} #end if($tipoAccion eq "MODIFICAR_USUARIO")


elsif($tipoAccion eq "DATOS_USUARIO"){

	my ($template, $session, $params) = get_template_and_user({
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
		$params->{'course'}=1;
		$params->{'usercourse'} = C4::Date::format_date($data->{'usercourse'},$dateformat);
	}
	#
	$params->{'dateenrolled'} = C4::Date::format_date($data->{'dateenrolled'},$dateformat);
	$params->{'expiry'} = C4::Date::format_date($data->{'expiry'},$dateformat);
	$params->{'dateofbirth'} = C4::Date::format_date($data->{'dateofbirth'},$dateformat);
	$params->{'IS_ADULT'} = ($data->{'categorycode'} ne 'I');
	
	$params->{'city'}=C4::AR::Busquedas::getNombreLocalidad($data->{'city'});
	$params->{'streetcity'}=C4::AR::Busquedas::getNombreLocalidad($data->{'streetcity'});
	
	# Converts the branchcode to the branch name
	$params->{'branchcode'} = C4::AR::Busquedas::getBranch($data->{'branchcode'})->{'branchname'};
	
	# Converts the categorycode to the description
	$params->{'categorycode'} = C4::AR::Busquedas::getborrowercategory($data->{'categorycode'});
	
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
	
	$params->{'bornum'}= $bornum;
	$params->{'foto_name'}= $foto;

	C4::Auth::output_html_with_http_headers($input, $template, $params);
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
	
	my ($template, $session, $params) = get_template_and_user({
									template_name => "usuarios/reales/printPrestInterBiblio.tmpl",
									query => $input,
									type => "intranet",
									authnotrequired => 0,
									flagsrequired => {borrowers => 1},
									debug => 1,
			    });

	my $bibliotecas=C4::AR::Utilidades::generarComboDeBranches();

	$params->{'bibliotecas'}= $bibliotecas;
	$params->{'bornum'}= $bornum;

	C4::Auth::output_html_with_http_headers($input, $template, $params);


	

} #end if($tipoAccion eq "GUARDAR_PERMISOS")