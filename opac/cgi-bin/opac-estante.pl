#!/usr/bin/perl

use strict;
use CGI;
use C4::Output;
use C4::AR::Auth;

use HTML::Template;
use C4::AR::Estantes;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user ({
                                        template_name   => 'opac-main.tmpl',
                                        query       => $input,
                                        type => "opac",
                                        authnotrequired => 1,
                                        flagsrequired => {  ui => 'ANY', 
                                                            tipo_documento => 'ANY', 
                                                            accion => 'CONSULTA', 
                                                            entorno => 'undefined'},
                                        debug => 1,
                 });

my $id_estante=$input->param('id_estante');

if(!$id_estante){
  #Si no viene estante se ven los Estantes Principales (Padre = 0)
  my $estantes_publicos = C4::AR::Estantes::getListaEstantesPublicos();
  $t_params->{'cant_estantes'}= @$estantes_publicos;
  $t_params->{'SUBESTANTES'}= $estantes_publicos;
}
else{
  #Se ve un estante en particular con su contenido
    my $estante= C4::AR::Estantes::getEstante($id_estante);
    my $subEstantes= C4::AR::Estantes::getSubEstantes($id_estante);

    $t_params->{'estante'}= $estante;
    $t_params->{'SUBESTANTES'}= $subEstantes;
    $t_params->{'cant_estantes'}= @$subEstantes;
}

$t_params->{'content_title'}        = C4::AR::Filtros::i18n("Estantes Virtuales");
$t_params->{'partial_template'}     = "opac-estante.inc";

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);