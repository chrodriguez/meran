#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use Mail::Sendmail;
use C4::Auth;         # checkauth, getnro_socio.
use C4::Circulation::Circ2;
use C4::Interface::CGI::Output;
use C4::Date;

my $query = new CGI;

my $input = $query;

my ($template, $session, $t_params)= get_template_and_user({
                                    template_name => "opac-main.tmpl",
                                    query => $query,
                                    type => "opac",
                                    authnotrequired => 1,
                                    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
             });


my $nro_socio = C4::Auth::getSessionNroSocio();

my ($socio, $flags) = C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);

my $review = $input->param('review') || 0;
my $id2 = $input->param('id2');

if ($review){
    C4::AR::Nivel2::reviewNivel2($id2,$review,$nro_socio);
}
$t_params->{'portada_registro_medium'}=  C4::AR::PortadasRegistros::getImageForId2($id2,'M');
$t_params->{'portada_registro_big'}=  C4::AR::PortadasRegistros::getImageForId2($id2,'L');
my $nivel2 = C4::AR::Nivel2::getNivel2FromId2($id2);
$t_params->{'nivel2'}= $nivel2->toMARC_Opac;
$t_params->{'titulo'}=  $nivel2->nivel1->getTitulo;
$t_params->{'reviews'}= C4::AR::Nivel2::getReviews($id2);
$t_params->{'partial_template'}= "reviews.inc";
$t_params->{'id2'}= $id2;

C4::Auth::output_html_with_http_headers($template, $t_params, $session);
