#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::AR::Auth;
use C4::Date;
use C4::AR::Sanciones;
use Date::Manip;
use C4::AR::Usuarios;

my $query = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
									template_name => "opac-user.tmpl",
									query => $query,
									type => "opac",
									authnotrequired => 0,
									flagsrequired => {  ui => 'ANY', 
                                                        tipo_documento => 'ANY', 
                                                        accion => 'CONSULTA', 
                                                        entorno => 'undefined'},
									debug => 1,
			     });


my $dateformat = C4::Date::get_date_format();

my $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($session->param('userid'));
my $persona=$socio->getPersona;


$t_params->{'socio'}=$socio;
$t_params->{'persona'}=$persona;

#### Verifica si la foto ya esta cargada
my $picturesDir= C4::Context->config("picturesdir");
my $foto;
if (opendir(DIR, $picturesDir)) {
        my $pattern= $session->param('userid')."[.].";
        my @file = grep { /$pattern/ } readdir(DIR);
        $foto= join("",@file);
        closedir DIR;
} else {
        $foto= 0;
}

#### Verifica si hay problemas para subir la foto
my $msgFoto=$query->param('msg');
($msgFoto) || ($msgFoto=0);
####

$t_params->{'foto_name'} = $foto;
$t_params->{'mensaje_error_foto'} = $msgFoto;

$t_params->{'UploadPictureFromOPAC'}= C4::AR::Preferencias::getValorPreferencia("UploadPictureFromOPAC");

# FIXME falta 
=item
my $sanc= C4::AR::Sanciones::hasSanctions($session->param('userid'));

foreach my $san (@$sanc) {
if ($san->{'id3'}) {
	my $aux=C4::AR::Nivel1::buscarNivel1PorId3($san->{'id3'}); 
	$san->{'description'}.=": ".$aux->{'titulo'}." (".$aux->{'completo'}.") "; }
	$san->{'fecha_final'}=format_date($san->{'fecha_final'},$dateformat);
	$san->{'fecha_comienzo'}=format_date($san->{'fecha_comienzo'},$dateformat);
}
if (scalar(@$sanc) > 0){$t_params->{'sanciones_loop'}= $sanc;}
=cut
#$t_params->{'LibraryName'}= C4::AR::Preferencias::getValorPreferencia("LibraryName");
$t_params->{'pagetitle'}= "Usuarios";


C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
