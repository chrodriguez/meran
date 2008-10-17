#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use Date::Manip;
use C4::Date;
use C4::AR::Reservas;
use C4::AR::Issues;
use C4::AR::Sanctions;
use C4::AR::Busquedas;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "usuarios/reales/datosUsuario.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $bornum=$input->param('bornum');
my $completo=$input->param('completo');
my $mensaje=$input->param('mensaje');#Mensaje que viene desde libreDeuda si es que no se puede imprimir

my $data=C4::AR::Usuarios::getBorrowerInfo($bornum);
$data->{'updatepassword'}= $data->{'changepassword'};

my $dateformat = C4::Date::get_date_format();
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
		completo	=> $completo,
		mensaje		=> $mensaje,
		foto_name 	=> $foto,
		mensaje_error_foto   => $msgFoto,
		mensaje_error_borrar => $msgError,
	);

output_html_with_http_headers $input, $cookie, $template->output;
