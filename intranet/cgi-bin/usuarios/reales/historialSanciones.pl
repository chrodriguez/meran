#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use C4::Date;

use CGI;

my $input=new CGI;

my ($template, $session, $t_params) =  get_template_and_user ({
							template_name	=> 'usuarios/reales/historialSanciones.tmpl',
							query		=> $input,
							type		=> "intranet",
							authnotrequired	=> 0,
							flagsrequired	=> { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
    });


my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));

C4::AR::Validator::validateParams('U389',$obj,['nro_socio'] );

my $nro_socio= $obj->{'nro_socio'};
my $orden= $obj->{'orden'}||'fecha desc';
my $ini= $obj->{'ini'};
my $funcion= $obj->{'funcion'};

my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

my ($cant,$sanciones_array_ref)=C4::AR::Sanciones::getHistorialSanciones($nro_socio,$ini,$cantR,$orden);

$t_params->{'paginador'}=&C4::AR::Utilidades::crearPaginador($cant,$cantR, $pageNumber,$funcion,$t_params);
$t_params->{'cant'}= $cant;
$t_params->{'nro_socio'}= $nro_socio;
$t_params->{'HISTORIAL_SANCIONES'}= $sanciones_array_ref;

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
