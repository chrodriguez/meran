#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use Template;
use C4::AR::Prestamos;
use JSON;

my $input = new CGI;
my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $op = $obj->{'op'};
my $id_tipo_prestamo = $obj->{'tipo_prestamo'};

my ($userid, $session, $flags) = checkauth($input, 0,{ parameters => 1});

if ($op eq 'MODIFICAR_TIPO_PRESTAMO') {

my ($template, $session, $t_params) = get_template_and_user({
                template_name => "admin/agregarTipoPrestamo.tmpl",
                query => $input,
                type => "intranet",
                authnotrequired => 0,
                flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                debug => 1,
          });

	if ($id_tipo_prestamo) {
        my $tipo_prestamo=C4::AR::Prestamos::getTipoPrestamo($id_tipo_prestamo);
        $t_params->{'tipo_prestamo'}= $tipo_prestamo;
        }

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);

} 
elsif ($op eq 'NUEVO_TIPO_PRESTAMO') {

my ($template, $session, $t_params) = get_template_and_user({
                template_name => "admin/agregarTipoPrestamo.tmpl",
                query => $input,
                type => "intranet",
                authnotrequired => 0,
                flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                debug => 1,
            });

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);

} 
elsif (($op eq 'MODIFICAR') or ($op eq 'AGREGAR')){
    my $tipo_prestamo=C4::AR::Prestamos::getTipoPrestamo($id_tipo_prestamo);
    
    $tipo_prestamo->setId_tipo_prestamo($input->param('id_tipo_prestamo'));
    $tipo_prestamo->setDescripcion($input->param('descripcion'));
    $tipo_prestamo->setId_disponibilidad($input->param('descripcion'));
    $tipo_prestamo->setPrestamos($input->param('prestamos'));
    $tipo_prestamo->setDias_prestamo($input->param('dias_prestamo'));
    $tipo_prestamo->setRenovaciones($input->param('renovaciones'));
    $tipo_prestamo->setDias_renovacion($input->param('dias_renovacion'));
    $tipo_prestamo->setDias_antes_renovacion($input->param('dias_antes_renovacion'));
    $tipo_prestamo->setHabilitado($input->param('habilitado'));
    $tipo_prestamo->save();
} 
elsif ($op eq 'CONFIRMAR_BORRADO') {

my ($template, $session, $t_params) = get_template_and_user({
                template_name => "admin/confirmarBorradoTipoPrestamo.tmpl",
                query => $input,
                type => "intranet",
                authnotrequired => 0,
                flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                debug => 1,
         });
    my $tipo_prestamo=C4::AR::Prestamos::getTipoPrestamo($id_tipo_prestamo);
    $t_params->{'tipo_prestamo'}= $tipo_prestamo;
} 
elsif ($op eq 'BORRAR') {
    my $tipo_prestamo=C4::AR::Prestamos::getTipoPrestamo($id_tipo_prestamo);
    $tipo_prestamo->delete();
}
elsif ($op eq 'TIPOS_PRESTAMOS') {
my ($template, $session, $t_params) = get_template_and_user({
                            template_name => "admin/tipos_de_prestamos.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                            debug => 1,
                });

my $tipos_de_prestamos=C4::AR::Prestamos::getTiposDePrestamos();
$t_params->{'TIPOS_PRESTAMOS_LOOP'}= $tipos_de_prestamos;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);

}
