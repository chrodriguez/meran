#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::UploadFile;
use CGI;
use JSON;

my $input = new CGI;

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

	my ($template, $loggedinuser, $cookie)= get_template_and_user({	template_name => "usuarios/reales/permisos-usuario.tmpl",
									query => $input,
									type => "intranet",
									authnotrequired => 0,
									flagsrequired => $flagsrequired,
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

	$template->param(	
  				surname => $bor->{'surname'},
  				firstname => $bor->{'firstname'},
				loop => \@loop
		);
	
	print $input->header;
	print  $template->output;

} #end if($tipoAccion eq "MOSTRAR_PERMISOS")


=item
Se elimina el usuario
=cut
elsif($tipoAccion eq "ELIMINAR_USUARIO"){

	my %params;
	my $usuario_hash_ref= C4::AR::Usuarios::getBorrower($obj->{'borrowernumber'});
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
	
#   	my ($error,$codMsg,$message)= C4::AR::Usuarios::t_addBorrower($obj);
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

	my ($template, $loggedinuser, $cookie) = get_templateexpr_and_user({
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

	$template->param(	

				document    	=> $comboDeTipoDeDoc,
				catcodepopup	=> $comboDeCategorias,
				CGIbranch 	=> $comboDeBranches,
		
				changepassword	=> $datosBorrower_hashref->{'changepassword'},
				type		=> $datosBorrower_hashref->{'type'},
				physstreet      => $datosBorrower_hashref->{'physstreet'},
				firstname       => $datosBorrower_hashref->{'firstname'},
				surname         => $datosBorrower_hashref->{'surname'},
				streetaddress   => $datosBorrower_hashref->{'streetaddress'},
				zipcode 	=> $datosBorrower_hashref->{'zipcode'},
				dstreetcity     => $datosBorrower_hashref->{'streetcity'},
				homezipcode 	=> $datosBorrower_hashref->{'homezipcode'},
				city		=> $datosBorrower_hashref->{'city'},
				dcity           => $datosBorrower_hashref->{'dcity'},
				phone           => $datosBorrower_hashref->{'phone'},
				phoneday        => $datosBorrower_hashref->{'phoneday'},
				emailaddress    => $datosBorrower_hashref->{'emailaddress'},
				borrowernotes	=> $datosBorrower_hashref->{'borrowernotes'},
				documentnumber  => $datosBorrower_hashref->{'documentnumber'},
				studentnumber 	=> $datosBorrower_hashref->{'studentnumber'},
				dateenrolled	=> $datosBorrower_hashref->{'dateenrolled'},
				expiry		=> $datosBorrower_hashref->{'expiry'},
				cardnumber	=> $datosBorrower_hashref->{'cardnumber'},
 				dateofbirth	=> C4::Date::format_date($datosBorrower_hashref->{'dateofbirth'},$dateformat),
				addBorrower	=> 0,
 				dateformat      => C4::Date::display_date_format($dateformat),
		);

 	print $input->header;
 	print  $template->output;

} #end if($tipoAccion eq "MODIFICAR_USUARIO")


elsif($tipoAccion eq "DATOS_USUARIO"){

	my ($template, $loggedinuser, $cookie)
	= get_template_and_user({template_name => "usuarios/reales/detalleUsuario.tmpl",
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
		$data->{'course'}=1;
		$data->{'usercourse'} = C4::Date::format_date($data->{'usercourse'},$dateformat);
	}
	#
	$data->{'dateenrolled'} = C4::Date::format_date($data->{'dateenrolled'},$dateformat);
	$data->{'expiry'} = C4::Date::format_date($data->{'expiry'},$dateformat);
	$data->{'dateofbirth'} = C4::Date::format_date($data->{'dateofbirth'},$dateformat);
	$data->{'IS_ADULT'} = ($data->{'categorycode'} ne 'I');
	
	$data->{'city'}=C4::AR::Busquedas::getNombreLocalidad($data->{'city'});
	$data->{'streetcity'}=C4::AR::Busquedas::getNombreLocalidad($data->{'streetcity'});
	
	# Converts the branchcode to the branch name
	$data->{'branchcode'} = C4::AR::Busquedas::getBranch($data->{'branchcode'})->{'branchname'};
	
	# Converts the categorycode to the description
	$data->{'categorycode'} = C4::AR::Busquedas::getborrowercategory($data->{'categorycode'});
	
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
	####
	
	#### Verifica si hay problemas para subir la foto
	my $msgFoto=$input->param('msg');
	($msgFoto) || ($msgFoto=0);
	####
	
	#### Verifica si hay problemas para borrar un usuario
	my $msgError=$input->param('error');
	($msgError) || ($msgError=0);
	####
	
	$template->param($data);
	$template->param(
			bornum          => $bornum,
# 			completo	=> $completo,
# # # # # # 			mensaje		=> $mensaje,
			foto_name 	=> $foto,
			mensaje_error_foto   => $msgFoto,
			mensaje_error_borrar => $msgError,
		);
	
	output_html_with_http_headers $input, $cookie, $template->output;
}


elsif($tipoAccion eq "SUBIR_FOTO"){
	my $bornum= $obj->{'borrowernumber'};
	my $filepath= $obj->{'picture'};
 	my $msg= &C4::AR::UploadFile::uploadPhoto($bornum,$filepath);
}	

elsif($tipoAccion eq "ELIMINAR_FOTO"){
	my $foto_name= $obj->{'foto_name'};
	my $msg= &C4::AR::UploadFile::deletePhoto($foto_name);
}	
