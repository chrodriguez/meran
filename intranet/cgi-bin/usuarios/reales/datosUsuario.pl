#!/usr/bin/perl

# use strict;
use C4::Auth;
use CGI;

my $input=new CGI;

my ($template, $session, $t_params) =  C4::Auth::get_template_and_user ({
			template_name	=> 'usuarios/reales/datosUsuario.tmpl',
			query		=> $input,
			type		=> "intranet",
			authnotrequired	=> 0,
			flagsrequired	=> { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
    });


my $nro_socio= $input->param('nro_socio');
$t_params->{'nro_socio'}= $nro_socio;

my $mensaje=$input->param('mensaje');#Mensaje que viene desde libreDeuda si es que no se puede imprimir

$t_params->{'socio'}= C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio) || C4::AR::Utilidades::redirectAndAdvice('U353');

$t_params->{'page_sub_title'}=C4::AR::Filtros::i18n("Datos del Usuario");

C4::Auth::output_html_with_http_headers($template, $t_params, $session);