#!/usr/bin/perl


use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Utilidades;

my $input = new CGI;

my ($template, $session, $t_params, $cookie) = get_template_and_user({
								template_name => "reports/availabilityResult.tmpl",
								query => $input,
								type => "intranet",
								authnotrequired => 0,
								flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
								debug => 1,
			    });

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));

$obj->{'orden'} = $obj->{'orden'}||'date';
my $ini =$obj->{'ini'};
my $funcion=$obj->{'funcion'};
my $ui = $obj->{'ui'};
# $obj->{'disponibilidad'}= C4::Modelo::RefDisponibilidad->new(codigo => $obj->{'disponibilidad'} );
#    $obj->{'disponibilidad'}->load();
my $ref_disponibilidad= C4::Modelo::RefDisponibilidad->new(codigo => $obj->{'disponibilidad'} );
$ref_disponibilidad->load();
$obj->{'disponibilidad'} = $ref_disponibilidad->getNombre;
my $fechaIni=$obj->{'fechaIni'};
my $fechaFin=$obj->{'fechaFin'};

#Inicializo el inicio y fin de la instruccion LIMIT en la consulta
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);
#FIN inicializacion
$obj->{'ini'} = $ini;
$obj->{'cantR'} = $cantR;

my ($cantidad, $resultsdata)= C4::AR::Estadisticas::disponibilidad($obj);

$t_params->{'paginador'}= C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);

my $availD;
if ($obj->{'disponibilidad'} eq 0){
    $availD='Disponible';
}else{
    my $av=C4::AR::Busquedas::getAvail($obj->{'disponibilidad'});
    if ($av){
        $availD=$av->{'description'};
    }
}

$t_params->{'resultsloop'}= $resultsdata;
$t_params->{'cantidad'}= $cantidad;
$t_params->{'ui'}= $ui;
$t_params->{'orden'}= $obj->{'orden'};
$t_params->{'disponibilidad'}= $obj->{'disponibilidad'};
$t_params->{'availD'}= $availD;
$t_params->{'fechaIni'}= $fechaIni;
$t_params->{'fechaFin'}= $fechaFin;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
