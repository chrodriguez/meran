#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;
use C4::AR::Catalogacion;
use JSON;
my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user ({
                            template_name	=> 'catalogacion/estructura/datosDocumento.tmpl',
                            query		=> $input,
                            type		=> "intranet",
                            authnotrequired	=> 0,
                            flagsrequired	=> {    ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'CONSULTA', 
                                                    entorno => 'datos_nivel1', 
                                                    tipo_permiso => 'catalogo'},
    					});


my $post_params                 = $input->Vars;
#estos parametros se usan cuando se viene desde otra pagina y se intenta modificar algun nivel
my $id1                         = $input->param('id1')||0;
my $id2                         = $input->param('id2')||0;
my $id3                         = $input->param('id3')||0;
my $tipoAccion                  = $input->param('tipoAccion');
$t_params->{'id1'}              = $id1;
$t_params->{'id2'}              = $id2;
$t_params->{'id3'}              = $id3;
$t_params->{'tipoAccion'}       = $tipoAccion;
$t_params->{'tiene_nivel_2'}    = 0;
my $nivel                       = 1;
my %params_combo;


if(($tipoAccion eq "MODIFICAR_NIVEL_1")||($tipoAccion eq "MODIFICAR_NIVEL_3_ALL")){
# se verifica si tiene nivel 2, sino hay q mostrar el comboTiposNivel3 para q selecione el tipo de documento (esquema)
    $t_params->{'tiene_nivel_2'}        = C4::AR::Catalogacion::cantNivel2($t_params->{'id1'});
    my @n3_array;
    my @split_array;

    while ( my ($key, $value) = each(%$post_params) ) {

          my $result = rindex($key, "n3_");

          if( $result != -1){
              push (@n3_array, $value);
          }
    }

    $t_params->{'cant'}                             = $input->param('cant');
    $t_params->{'n3_array'}                         = \@n3_array;


}

$params_combo{'onChange'}                       = 'seleccionar_esquema()';
$params_combo{'default'}                        = 'SIN SELECCIONAR';
$t_params->{'comboTipoDocumento'}               = &C4::AR::Utilidades::generarComboTipoNivel3(\%params_combo);
$t_params->{'nivel'}                            = $nivel;
$params_combo{'onChange'}                       = '';
$params_combo{'default'}                        = 'SIN SELECCIONAR';
$t_params->{'comboTipoNivelBibliografico'}      = &C4::AR::Utilidades::generarComboNivelBibliografico(\%params_combo);
$t_params->{'page_sub_title'}                   = C4::AR::Filtros::i18n("Catalogaci&oacute;n - Datos del documento");

if($id1){
    $t_params->{'ocultarDivLateral'}            = 0;
}else{
    $t_params->{'ocultarDivLateral'}            = 1;
}

# ????????????????
$t_params->{'ocultarDivLateral'}            = 0;

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
