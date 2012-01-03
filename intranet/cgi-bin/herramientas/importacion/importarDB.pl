#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use C4::AR::ImportacionIsoMARC;
use CGI;
use JSON;

my $input           = new CGI;
my $authnotrequired = 0;
my $obj             = $input->param('obj');
$obj                = C4::AR::Utilidades::from_json_ISO($obj);
my $tipoAccion      = $obj->{'tipoAccion'}||"";

=item
    Se elimina el Proveedor
=cut

if($tipoAccion eq "ELIMINAR"){

        my ($userid, $session, $flags) = checkauth( $input,
                                            $authnotrequired,
                                            {   ui              => 'ANY',
                                                tipo_documento  => 'ANY',
                                                accion          => 'BAJA',
                                                tipo_permiso => 'general',
                                                entorno => 'undefined'},
                                                "intranet"
                                    );

        my $id_importacion        = $obj->{'id_importacion'};

        my ($Message_arrayref)  = C4::AR::ImportacionIsoMARC::eliminarImportacion($id_importacion);
        my $infoOperacionJSON   = to_json $Message_arrayref;

        C4::AR::Auth::print_header($session);
        print $infoOperacionJSON;

    } #end if($tipoAccion eq "ELIMINAR_Importacion")

=item
Se guarda la modificacion los datos del Proveedor
=cut
elsif($tipoAccion eq "DETALLE"){

      my ($nro_socio, $session, $flags) = checkauth(
                                               $input,
                                               $authnotrequired,
                                               {   ui               => 'ANY',
                                                   tipo_documento   => 'ANY',
                                                   accion           => 'CONSULTA',
                                                   tipo_permiso => 'general',
                                                   entorno => 'undefined'},
                                                   "intranet"
                                );

        my ($Message_arrayref)  = C4::AR::ImportacionIsoMARC::editarImportacion($obj);
        my $infoOperacionJSON   = to_json $Message_arrayref;

        C4::AR::Auth::print_header($session);
        print $infoOperacionJSON;

 }

elsif($tipoAccion eq "BUSQUEDA"){
#Lista de Proveedores por defecto
    my ($template, $session, $t_params)= get_template_and_user({
                                    template_name => "/herramientas/importacion/lista_importaciones.tmpl",
                                    query => $input,
                                    type => "intranet",
                                    authnotrequired => 0,
                                    flagsrequired => {  ui => 'ANY',
                                                        tipo_documento => 'ANY',
                                                        accion => 'CONSULTA',
                                                        entorno => 'undefined'},
                                    debug => 1,
            });

  my $orden     = $obj->{'orden'}||'nombre';
  my $funcion   = $obj->{'funcion'};
  my $inicial   = $obj->{'inicial'};
  my $busqueda  = $obj->{'nombre_importacion'};
  my $ini       = $obj->{'ini'} || 1;

  my ($ini,$pageNumber,$cantR) = C4::AR::Utilidades::InitPaginador($ini);
  my ($cantidad,$importaciones) = C4::AR::ImportacionIsoMARC::getImportacionLike($busqueda,$orden,$ini,$cantR,1,$inicial);

      $t_params->{'paginador'} = C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);
      $t_params->{'resultsloop'}        = $importaciones;
      $t_params->{'cantidad'}           = $cantidad;
      $t_params->{'importacion_busqueda'} = $busqueda;


C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);


}
