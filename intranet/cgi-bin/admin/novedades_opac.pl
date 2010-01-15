#!/usr/bin/perl

use strict;
use C4::Auth;
use CGI;
use C4::AR::Novedades;
my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
									template_name => "admin/novedades_opac.tmpl",
									query => $input,
									type => "intranet",
									authnotrequired => 0,
									flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
									debug => 1,
			    });



my %hash_temp = {};
my $obj = \%hash_temp;
my $accion = $obj->{'tipoAccion'} = $input->param('tipoAccion');
my $ini = $obj->{'ini'} = $input->param('page') || 0;
my $id_mensaje = $input->param('id') || 0;
my $url = "/cgi-bin/koha/admin/novedades_opac.pl?token=".$input->param('token')."&tipoAccion=".$obj->{'tipoAccion'};

if ($accion eq 'eliminar'){
    C4::AR::Novedades::eliminar($id_mensaje);
}

my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

my ($cant_novedades,$novedades) = C4::AR::Novedades::listar($ini,$cantR);

$t_params->{'paginador'} = C4::AR::Utilidades::crearPaginadorOPAC($cant_novedades,$cantR, $pageNumber,$url,$t_params);

$t_params->{'novedades'} = $novedades;
$t_params->{'cant_novedades'} = $cant_novedades;

C4::Auth::output_html_with_http_headers($template, $t_params, $session);