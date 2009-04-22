#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::AR::Busquedas;
use Time::HiRes;

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
my $timeIni= time();
my $start = [ Time::HiRes::gettimeofday( ) ];

my $cantidad;
my $resultsarray;
$obj->{'type'} = 'OPAC';

my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

if($obj->{'tipoAccion'} eq 'BUSQUEDA_SIMPLE_POR_AUTOR'){

	$obj->{'autor'}= $obj->{'searchinc'};
	($cantidad, $resultsarray)= C4::AR::Busquedas::busquedaSimplePorAutor($ini,$cantR,$obj,$session);

}elsif($obj->{'tipoAccion'} eq 'BUSQUEDA_SIMPLE_POR_TITULO'){

	$obj->{'titulo'}= $obj->{'searchinc'};
	($cantidad, $resultsarray)= C4::AR::Busquedas::busquedaSimplePorTitulo($ini,$cantR,$obj,$session);

}elsif($obj->{'tipoAccion'} eq 'BUSQUEDA_SIMPLE_POR_TEMA'){

	$obj->{'tema'}= $obj->{'searchinc'};
# FIXME falta implementar

}elsif($obj->{'tipoAccion'} eq 'BUSQUEDA_COMBINABLE'){

	($cantidad, $resultsarray)= C4::AR::Busquedas::busquedaAvanzada_newTemp($ini,$cantR,$obj,$session);
}

=item
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

my ($cantidad, $resultsarray)= C4::AR::Busquedas::busquedaAvanzada_newTemp($ini,$cantR,$obj,$session);

=cut

$t_params->{'paginador'} = C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$obj->{'funcion'},$t_params);
#se arma el arreglo con la info para mostrar en el template
$obj->{'cantidad'}= $cantidad;
$obj->{'loggedinuser'}= $session->param('nro_socio');
$t_params->{'SEARCH_RESULTS'}= $resultsarray;
$t_params->{'buscoPor'}= C4::AR::Busquedas::armarBuscoPor($obj);
$t_params->{'cantidad'}= $cantidad;

my $timeFin= time();
my ($secFin,$minFin,$hourFin)= localtime($timeFin - $timeIni);
C4::AR::Debug::debug("Hora Ini Fin: ".$timeIni);
C4::AR::Debug::debug("Hora Fin: ".$timeFin);
C4::AR::Debug::debug("Hora Fin h: ".$hourFin.", ".$minFin." ,".$secFin. " seg");
$t_params->{'timeMin'}= $minFin;
$t_params->{'timeSeg'}= $secFin;




my $elapsed = Time::HiRes::tv_interval( $start );
print "Elapsed time: $elapsed seconds!\n";
$t_params->{'timeSeg'}= $elapsed;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
