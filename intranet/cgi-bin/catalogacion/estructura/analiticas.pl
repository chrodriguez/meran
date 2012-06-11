#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::AR::Auth;
use C4::AR::Nivel3 qw(detalleCompletoINTRA);

my $input=new CGI;
my $ajax = $input->param('ajax') || 0;
my ($template, $session, $t_params) = get_template_and_user({
                            template_name   => ('catalogacion/estructura/analiticas.tmpl'),
                            query           => $input,
                            type            => "intranet",
                            authnotrequired => 0,
                            flagsrequired   => {    ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'CONSULTA', 
                                                    entorno => 'datos_nivel1'},
                        });

my $id1                         = $input->param('id1');
$t_params->{'id2'}              = $input->param('id2') || 0;

# TODO validar id1 y id2, q llegen y que existan


$t_params->{'ajax'}                                 = $ajax;
$t_params->{'page_sub_title'}                       = C4::AR::Filtros::i18n("Catalogaci&oacute;n - Detalle del &iacute;tem");
$t_params->{'mensaje'}                              = $input->url_param('msg_file');
my $nivel1											= C4::AR::Nivel1::getNivel1FromId2($t_params->{'id2'});

if($nivel1) {
	$t_params->{'nivel1'}			= $nivel1->toMARC_Intra();
    $t_params->{'id1'}              = $nivel1->getId1();
    $t_params->{'titulo'}           = $nivel1->getTitulo();    
    $t_params->{'autor'}            = $nivel1->getAutor();

    my $nivel2						= C4::AR::Nivel2::getNivel2FromId2($t_params->{'id2'});

    if($nivel2){
    	$t_params->{'nivel2'}			= $nivel2->toMARC_Intra();
    }

} else {
	# mostrar algun cartel indicando q no existe el nivel 2
}

$t_params->{'analiticas_array'}     = C4::AR::Nivel2::getAnaliticasFromNivel2($t_params->{'id2'});

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
