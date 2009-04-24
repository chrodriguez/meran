#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use JSON;
use CGI;

my $input = new CGI;

my $authnotrequired= 0;

my $obj=$input->param('obj');

$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $tipoAccion= $obj->{'tipoAccion'}||"";

my $dateformat = C4::Date::get_date_format();


my ($template, $session, $t_params) = get_template_and_user ({
                                                        template_name   => 'busquedas/busquedaResult.tmpl',
                                                        query       => $input,
                                                        type        => "intranet",
                                                        authnotrequired => 0,
                                                        flagsrequired   => { circulate => 1 },
                        });
my $ini= $obj->{'ini'};

my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

=item
Aca se maneja el cambio de la password para el usuario
=cut
if($tipoAccion eq "POR_AUTOR"){

    my $session = CGI::Session->load();

	
	$t_params->{'idAutor'}= $obj->{'idAutor'};
    $t_params->{'session'}= $session;
    $t_params->{'ini'} = $ini;
    $t_params->{'cantR'} = $cantR;

    my ($cantidad, $resultId1)= C4::AR::Busquedas::filtrarPorAutor($t_params);

    $t_params->{'paginador'} = C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$obj->{'funcion'},$t_params);

C4::AR::Debug::debug("CANTIDAD AUTOR: ".scalar(@$resultId1));

C4::AR::Debug::debug("INI: ".$ini);

C4::AR::Debug::debug("PAGINA: ".$pageNumber);

    $t_params->{'SEARCH_RESULTS'}= $resultId1;
    $t_params->{'buscoPor'}= C4::AR::Busquedas::armarBuscoPor($obj);
    $t_params->{'cantidad'}= $cantidad;

    C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
	
} #end if($tipoAccion eq "POR_AUTOR")
=item

=cut
elsif($tipoAccion eq "GUARDAR_PERMISOS"){

}
