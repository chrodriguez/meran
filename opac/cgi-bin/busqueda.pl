#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::AR::Busquedas;
use C4::AR::Utilidades;
use C4::AR::Catalogacion;

my $input = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
								template_name => "busquedaResult.tmpl",
								query => $input,
								type => "opac",
								authnotrequired => 1,
								flagsrequired => {borrow => 1},
			     });


my $obj=$input->param('obj');

if($obj ne ""){
	$obj= C4::AR::Utilidades::from_json_ISO($obj);
}

my $ini= $obj->{'ini'};

$obj->{'type'} = 'OPAC';

my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

my ($cantidad, $resultsarray)= C4::AR::Busquedas::busquedaAvanzada_newTemp($ini,$cantR,$obj,$session);

$t_params->{'paginador'} = C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$obj->{'funcion'},$t_params);

#se arma el arreglo con la info para mostrar en el template
$obj->{'cantidad'}= $cantidad;
$obj->{'loggedinuser'}= $session->param('nro_socio');

$t_params->{'SEARCH_RESULTS'}= $resultsarray;
$t_params->{'buscoPor'}= C4::AR::Busquedas::armarBuscoPor($obj);
$t_params->{'cantidad'}= $cantidad;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
