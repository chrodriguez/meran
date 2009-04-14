#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Utilidades;

use POSIX qw(ceil floor);


my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user ({
                                                        template_name	=> 'busquedas/busquedaResult.tmpl',
                                                        query		=> $input,
                                                        type		=> "intranet",
                                                        authnotrequired	=> 0,
                                                        flagsrequired	=> { circulate => 1 },
    					});

my $obj=$input->param('obj');

if($obj ne ""){
	$obj= C4::AR::Utilidades::from_json_ISO($obj);
}

my $outside= $input->param('outside');
my $keyword= $obj->{'keyword'};
my $tipo_documento= $obj->{'tipo_nivel3_name'};

my $search;
$search->{'keyword'}= $keyword;
$search->{'class'}= $tipo_documento;


my $ini= $obj->{'ini'};
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

$obj->{'type'} = 'INTRA';

=item

PARCHE PARA PAGINASSSSSSSSSSSSSSSSSSSSSSSSSSSSSS

=cut


# my $cantidadRenglones = C4::AR::Preferencias->getValorPreferencia("renglones") || 30;

my ($cantidad, $resultId1)= C4::AR::Busquedas::busquedaCombinada_newTemp($ini,$cantR,$search->{'keyword'},$session,$obj);



# FIXME  despues de una par de paginas, muestra todo NULL :(

# FIXME tambien hay que acotar el arreglo para que se mueva en no más de $cantidadRenglones X 3

# @$resultId1=@$resultId1[ (floor(($ini*($cantidadRenglones) / 3))..floor(($cantR+($ini*$cantidadRenglones)-1) / 3) ];

# C4::AR::Debug::debug("PAGINA: ".(floor($ini / 3)) ."     INI: ".$ini."   DESDE: ".(floor(($ini*$cantidadRenglones) / 3))." HASTA: ".floor(($cantR+($ini*$cantidadRenglones)-1) / 3));


$t_params->{'paginador'} = C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$obj->{'funcion'},$t_params);

#se arma el arreglo con la info para mostrar en el template
$obj->{'cantidad'}= $cantidad;

#se loguea la busqueda

$t_params->{'SEARCH_RESULTS'}= $resultId1;
$t_params->{'buscoPor'}= C4::AR::Busquedas::armarBuscoPor($obj);
$t_params->{'cantidad'}= $cantidad;

if($outside) {
    $t_params->{'HEADERS'}= 1;
}

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
