#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Date;
use C4::AR::Usuarios;
use Date::Manip;
use Cwd;
my $input=new CGI;

my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);
my $msg_object= C4::AR::Mensajes::create();
my $dateformat = C4::Date::get_date_format();


my ($template, $session, $t_params) =  C4::Auth::get_template_and_user ({
			template_name	=> 'usuarios/reales/detalleUsuario.tmpl',
			query		=> $input,
			type		=> "intranet",
			authnotrequired	=> 0,
			flagsrequired	=> { circulate => 1 },
    });

my $bornum= $obj->{'borrowernumber'};
	
if ( (&C4::AR::Usuarios::existeUsuario($bornum)) && (&C4::AR::Utilidades::validateString($bornum)) ) {
		
	my $data=C4::AR::Usuarios::getBorrowerInfo($bornum);
	$t_params->{'changepassword'}= $data->{'changepassword'};#creo q no es necesario
	
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
	
	####
		
	#### Verifica si hay problemas para subir la foto
	my $msgFoto=$input->param('msg');
	($msgFoto) || ($msgFoto=0);
	####
	
	#### Verifica si hay problemas para borrar un usuario
	my $msgError=$input->param('error');
	($msgError) || ($msgError=0);
	####error  => 0,
	$t_params->{'bornum'}= $bornum;
	$t_params->{'foto_name'}= $foto;
	$t_params->{'mensaje_error_foto'}= $msgFoto;
	$t_params->{'mensaje_error_borrar'}= $msgError;
	$t_params->{'error'}=0;
	

	
	
}else{

		$t_params->{'error'}= 1;
		$t_params->{'error_msg'}= &C4::AR::Mensajes::getMensaje('U353');

     }


C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);





