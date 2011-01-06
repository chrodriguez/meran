#!/usr/bin/perl

use strict;
use C4::Auth;
use CGI;
use C4::AR::Nivel3 qw(getNivel3FromId3);
my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                                        template_name => "catalogacion/estructura/detalleEjemplar.tmpl",
                                        query => $input,
                                        type => "intranet",
                                        authnotrequired => 0,
                                        flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'datos_nivel1'},
                                        debug => 1,
    });



my %hash_temp = {};
my $obj = \%hash_temp;
my $id3 = $input->param('id3');
my $ini = $obj->{'ini'} = $input->param('page') || 0;
my $url = "/cgi-bin/koha/admin/detalleEjemplar.pl?token=".$input->param('token')."&id3=".$input->param('id3');

my $nivel3 = C4::AR::Nivel3::getNivel3FromId3($id3);

if ($nivel3) {
    my ($ini,$pageNumber,$cantR)    =   C4::AR::Utilidades::InitPaginador($ini);
    my ($cant_historico,$historico_disponibilidad) = C4::AR::Nivel3::getHistoricoDisponibilidad($id3,$ini,$cantR);

    $t_params->{'paginador'} = C4::AR::Utilidades::crearPaginadorOPAC($cant_historico,$cantR, $pageNumber,$url,$t_params);
    $t_params->{'nivel3'} = $nivel3;
    $t_params->{'historico_disponibilidad'} = $historico_disponibilidad;
    $t_params->{'cant_historico'} = $cant_historico;
}

C4::Auth::output_html_with_http_headers($template, $t_params, $session);