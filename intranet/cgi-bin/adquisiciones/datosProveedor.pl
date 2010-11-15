#!/usr/bin/perl

# use strict;
use C4::Auth;
use CGI;

my $input=new CGI;


my ($template, $session, $t_params) =  C4::Auth::get_template_and_user ({
            template_name   => '/adquisiciones/datosProveedor.tmpl',
            query       => $input,
            type        => "intranet",
            authnotrequired => 0,
            flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
});

C4::AR::Debug::debug("hola");

my $nombre = $input->param('nombre_proveedor');
my $direccion = $input->param('direccion');
my $tel = $input->param('telefono');
my $email = $input->param('email');
my $id_proveedor = $input->param('id_proveedor');
#my $mensaje                     = $input->param('mensaje');#Mensaje que viene desde libreDeuda si es que no se puede imprimir
#my $mensaje_desde_pdf           = $input->param('mensaje');

# $t_params->{'nro_socio'}        = $nombre;
# $t_params->{'socio_modificar'}  = C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio) || C4::AR::Utilidades::redirectAndAdvice('U353');
# $t_params->{'page_sub_title'}   = C4::AR::Filtros::i18n("Datos del Usuario");
# 
# 
# if ($mensaje_desde_pdf){
#     $t_params->{'mensaje'} = $mensaje_desde_pdf;
# }

$t_params->{'nombre'} = $nombre;
$t_params->{'dir'} = $direccion;
$t_params->{'tel'} = $tel;
$t_params->{'email'} = $email;
$t_params->{'id_proveedor'} = $id_proveedor;

C4::Auth::output_html_with_http_headers($template, $t_params, $session);