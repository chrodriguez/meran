#!/usr/bin/perl
use strict;
require Exporter;

use CGI;
use C4::AR::Auth;
use C4::Date;;
use Date::Manip;
use C4::AR::Busquedas;

my $input = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
                                    template_name => "includes/opac-favoritosResult.inc",
                                    query => $input,
                                    type => "opac",
                                    authnotrequired => 1,
                                    flagsrequired => {  ui => 'ANY', 
                                                        tipo_documento => 'ANY', 
                                                        accion => 'CONSULTA', 
                                                        entorno => 'undefined'},
});


my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);
my $action = $obj->{'action'};
my $id1 = $obj->{'id1'};
my $nro_socio = C4::AR::Auth::getSessionNroSocio();

$t_params->{'no_content_message'}= C4::AR::Filtros::i18n("UD. no ha marcado ningun ejemplar como favorito.");

if ($action eq "add_favorite"){
    print $session->header;
    print C4::AR::Nivel1::addToFavoritos($id1,$nro_socio);
}
elsif ($action eq "delete_favorite"){

    C4::AR::Nivel1::removeFromFavoritos($id1,$nro_socio);
    
    my ($cantidad,$resultsarray)= C4::AR::Nivel1::getFavoritos($nro_socio);

    $t_params->{'cantidad'}= $cantidad;
    $t_params->{'nro_socio'}= $session->param('nro_socio');
    $t_params->{'SEARCH_RESULTS'}= $resultsarray;
    $t_params->{'content_title'}= C4::AR::Filtros::i18n("Sus favoritos: ".$cantidad);
    
    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
}
elsif ($action eq "get_favoritos"){

    my $nro_socio = C4::AR::Auth::getSessionNroSocio();
    my ($socio, $flags) = C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);
    C4::AR::Validator::validateObjectInstance($socio);


    my ($cantidad,$resultsarray)= C4::AR::Nivel1::getFavoritos($nro_socio);
    $t_params->{'cantidad'}= $cantidad;
    $t_params->{'nro_socio'}= $session->param('nro_socio');
    $t_params->{'SEARCH_RESULTS'}= $resultsarray;
    $t_params->{'content_title'}= C4::AR::Filtros::i18n("Sus favoritos: ".$cantidad);

    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
}

1;