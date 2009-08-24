#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Catalogacion;
use JSON;
my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user ({
                            template_name	=> 'catalogacion/estructura/datosDocumento.tmpl',
                            query		=> $input,
                            type		=> "intranet",
                            authnotrequired	=> 0,
                            flagsrequired	=> { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'datos_nivel1'},
    					});

#estos parametros se usan cuando se viene desde otra pagina y se intenta modificar algun nivel
my $id1= $input->param('id1')||0;
my $id2= $input->param('id2')||0;
my $id3= $input->param('id3')||0;
my $tipoAccion= $input->param('tipoAccion');
$t_params->{'id1'}= $id1;
$t_params->{'id2'}= $id2;
$t_params->{'id3'}= $id3;
$t_params->{'tipoAccion'}= $tipoAccion;


my $nivel=1;
my %params_combo;
$params_combo{'onChange'}= 'mostrarEstructuraDelNivel1()';
$params_combo{'default'}= 'SIN SELECCIONAR';
my $comboTiposNivel3= &C4::AR::Utilidades::generarComboTipoNivel3(\%params_combo);
$t_params->{'comboTipoDocumento'}= $comboTiposNivel3;

$t_params->{'nivel'}= $nivel;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
