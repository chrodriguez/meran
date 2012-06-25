#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;
use C4::AR::Utilidades;
use JSON;
use C4::AR::TipoDocumento;

my $input           = new CGI;
my $obj             = $input->param('obj');

$obj                = C4::AR::Utilidades::from_json_ISO($obj);

my $tipoAccion      = $obj->{'tipoAccion'} || "";

my $authnotrequired = 0;

if($tipoAccion eq "LISTAR"){

    my ($template, $session, $t_params) = get_template_and_user({
                  template_name       => "catalogacion/tipoDocumentoAjax.tmpl",
                  query               => $input,
                  type                => "intranet",
                  authnotrequired     => 0,
                  flagsrequired       => {    ui              => 'ANY', 
                                              tipo_documento  => 'ANY', 
                                              accion          => 'CONSULTA', 
                                              entorno         => 'usuarios'},
                  debug               => 1,
          });

    my ($tiposDocumento,$cant)     = C4::AR::TipoDocumento::getTipoDocumento();

    $t_params->{'cant'}             = $cant;    
    $t_params->{'tiposDocumento'}   = $tiposDocumento;

    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);

}elsif($tipoAccion eq "MOD_TIPO_DOC"){

    my ($template, $session, $t_params) = get_template_and_user({
                  template_name       => "catalogacion/modTipoDocumento.tmpl",
                  query               => $input,
                  type                => "intranet",
                  authnotrequired     => 0,
                  flagsrequired       => {    ui              => 'ANY', 
                                              tipo_documento  => 'ANY', 
                                              accion          => 'CONSULTA', 
                                              entorno         => 'usuarios'},
                  debug               => 1,
          });

    my ($tipoDocumento)             = C4::AR::TipoDocumento::getTipoDocumentoByTipo($obj->{'idTipoDoc'});

    $t_params->{'tipoDocumento'}    = $tipoDocumento;

    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);

}