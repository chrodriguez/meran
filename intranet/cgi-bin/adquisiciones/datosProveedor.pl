#!/usr/bin/perl

# use strict;
use C4::Auth;
use CGI;
use C4::AR::Proveedores;

my $input = new CGI;

my $id_proveedor    = $input->param('id_proveedor');
my $tipoAccion      = $input->param('action');
my ($template, $session, $t_params);

# C4::AR::Debug::debug("entro".$tipoAccion);

if ($tipoAccion eq "EDITAR") {

# C4::AR::Debug::debug("entro");
    
    ($template, $session, $t_params) =  C4::Auth::get_template_and_user ({
            template_name   => '/adquisiciones/datosProveedor.tmpl',
            query       => $input,
            type        => "intranet",
            authnotrequired => 0,
            flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
    });
    my $comboDeTipoDeDoc = &C4::AR::Utilidades::generarComboTipoDeDoc();
    $t_params->{'combo_tipo_documento'} = $comboDeTipoDeDoc;

} else {
          ($template, $session, $t_params) =  C4::Auth::get_template_and_user ({
                      template_name   => '/adquisiciones/detalleProveedor.tmpl',
                      query       => $input,
                      type        => "intranet",
                      authnotrequired => 0,
                      flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
          });
}

# recibimos solo el id del proveedor y creamos el objeto aca
my $proveedor = C4::AR::Proveedores::getProveedorInfoPorId($id_proveedor);

$t_params->{'proveedor'} = $proveedor;

C4::Auth::output_html_with_http_headers($template, $t_params, $session);