#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use HTML::Template;

my $input=new CGI;

my ($template, $session, $t_params) =  get_template_and_user ({
                                template_name   => 'circ/detalleUsuario.tmpl',
                                query       => $input,
                                type        => "intranet",
                                authnotrequired => 0,
                                flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
                                });

my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);
my $msg_object= C4::AR::Mensajes::create();
my $nro_socio= $obj->{'nro_socio'};

my $socio=C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);

$t_params->{'socio'}= $socio;

C4::Auth::output_html_with_http_headers($template, $t_params, $session);
