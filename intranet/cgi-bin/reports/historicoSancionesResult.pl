#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Estadisticas;
use C4::Date;

my $input = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
								template_name => "reports/historicoSancionesResult.tmpl",
								query => $input,
								type => "intranet",
								authnotrequired => 0,
								flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
								debug => 1,
			     });


#Inicializo el inicio y fin de la instruccion LIMIT en la consulta
my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $ini= $obj->{'ini'};
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);
#FIN inicializacion

$obj->{'orden'}= $obj->{'orden'} ||'date';
my $socio= $obj->{'user'};
my $tipoPrestamo= $obj->{'tiposPrestamo'};
my $tipoOperacion= $obj->{'tipoOperacion'};
my $funcion=$obj->{'funcion'};
$obj->{'cantR'} = $cantR;
$obj->{'ini'} = $ini;

my ($cant,$resultsdata)=C4::AR::Estadisticas::historicoSanciones($obj);


$t_params->{'paginador'}= C4::AR::Utilidades::crearPaginador($cant,$cantR, $pageNumber,$funcion,$t_params);


$t_params->{'resultsloop'}= $resultsdata;
$t_params->{'cant'}= $cant;
$t_params->{'socio'}= $socio;
$t_params->{'tiposPrestamos'}= $tipoPrestamo;
$t_params->{'tipoOperacion'}= $tipoOperacion;

C4::Auth::output_html_with_http_headers($template, $t_params, $session);
