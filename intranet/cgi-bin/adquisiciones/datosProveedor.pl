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


my $nombre = $input->param('nombre_proveedor');
my $direccion = $input->param('direccion');
my $tel = $input->param('telefono');
my $email = $input->param('email');
my $id_proveedor = $input->param('id_proveedor');

$t_params->{'nombre'} = $nombre;
$t_params->{'dir'} = $direccion;
$t_params->{'tel'} = $tel;
$t_params->{'email'} = $email;
$t_params->{'id_proveedor'} = $id_proveedor;

C4::Auth::output_html_with_http_headers($template, $t_params, $session);