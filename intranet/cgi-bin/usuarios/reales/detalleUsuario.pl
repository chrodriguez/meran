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

my ($template, $session, $t_params) =  C4::Auth::get_template_and_user ({
			                                                        template_name	=> 'usuarios/reales/detalleUsuario.tmpl',
			                                                        query		=> $input,
			                                                        type		=> "intranet",
			                                                        authnotrequired	=> 0,
			                                                        flagsrequired	=> { circulate => 1 },
    });

    my $obj=$input->param('obj');
    $obj=C4::AR::Utilidades::from_json_ISO($obj);
    my $msg_object= C4::AR::Mensajes::create();
    my $nro_socio= $obj->{'nro_socio'};
    
    C4::AR::Validator::validateParams('U389',$obj,['nro_socio'] );
	my $socio=C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);

	if($socio){
	
		#### Verifica si la foto ya esta cargada
		my $picturesDir= C4::Context->config("picturesdir");
		my $foto;
		if (opendir(DIR, $picturesDir)) {
			my $pattern= $socio->getNro_socio."[.].";
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
		$t_params->{'id_socio'}= $socio->getId_socio;
		$t_params->{'foto_name'}= $foto;
		$t_params->{'mensaje_error_foto'}= $msgFoto;
		$t_params->{'mensaje_error_borrar'}= $msgError;
		$t_params->{'error'}=0;
		$t_params->{'nroSocioLoggeado'} = $socio->getNro_socio;	
		$t_params->{'socio'}= $socio;
		$t_params->{'relativePicturesDir'}= C4::Context->config("relativePicturesDir");
	}

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);