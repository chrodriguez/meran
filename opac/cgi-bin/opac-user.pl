#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::Auth;
use C4::Circulation::Circ2;
use C4::Date;
use C4::AR::Sanctions;
use Date::Manip;

# Agregado por Einar.
#para soportar el tema de las que pueden o no modificar a los socios
use C4::AR::UpdateData;

my $query = new CGI;

my ($template, $session, $params)= get_template_and_user({
									template_name => "opac-user.tmpl",
									query => $query,
									type => "opac",
									authnotrequired => 0,
									flagsrequired => {borrow => 1},
									debug => 1,
			     });


my $dateformat = C4::Date::get_date_format();
# get borrower information ....
my ($borr, $flags) = getpatroninformation($session->param('borrowernumber'),"");

$borr->{'city'}=C4::AR::Busquedas::getNombreLocalidad($borr->{'city'});
$borr->{'streetcity'}=C4::AR::Busquedas::getNombreLocalidad($borr->{'streetcity'});
$borr->{'dateenrolled'} = C4::Date::format_date($borr->{'dateenrolled'},$dateformat);
$borr->{'expiry'}       = C4::Date::format_date($borr->{'expiry'},$dateformat);
$borr->{'dateofbirth'}  = C4::Date::format_date($borr->{'dateofbirth'},$dateformat);
if ($borr->{'amountoutstanding'} > 5) {
    $borr->{'amountoverfive'} = 1;
}
if (5 >= $borr->{'amountoutstanding'} && $borr->{'amountoutstanding'} > 0 ) {
    $borr->{'amountoverzero'} = 1;
}
if ($borr->{'amountoutstanding'} < 0) {
    $borr->{'amountlessthanzero'} = 1;
    $borr->{'amountoutstanding'} = -1*($borr->{'amountoutstanding'});
}

$borr->{'amountoutstanding'} = sprintf "%.02f", $borr->{'amountoutstanding'};

#### Verifica si la foto ya esta cargada
my $picturesDir= C4::Context->config("picturesdir");
my $foto;
if (opendir(DIR, $picturesDir)) {
        my $pattern= $session->param('borrowernumber')."[.].";
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

$borr->{'foto_name'} = $foto;
$borr->{'mensaje_error_foto'} = $msgFoto;
$borr->{'bornum'} = $session->param('borrowernumber');
if (C4::Context->preference("UploadPictureFromOPAC") eq 'yes') {
	$borr->{'UploadPictureFromOPAC'}=1;
} else {
	$borr->{'UploadPictureFromOPAC'}=0;
}

my @bordat;
$bordat[0] = $borr;
foreach my $aux (keys (%$borr)) {
# 		$template->param($aux => ($borr->{$aux}))
		$params->{$aux}= ($borr->{$aux});

}

$params->{'borrowernumber'}= $session->param('borrowernumber');

my $sanc= hasSanctions($session->param('borrowernumber'));

foreach my $san (@$sanc) {
if ($san->{'id3'}) {
	my $aux=C4::AR::Nivel1::buscarNivel1PorId3($san->{'id3'}); 
	$san->{'description'}.=": ".$aux->{'titulo'}." (".$aux->{'completo'}.") "; }
	$san->{'enddate'}=format_date($san->{'enddate'},$dateformat);
	$san->{'startdate'}=format_date($san->{'startdate'},$dateformat);
}

$params->{'sanciones_loop'}= $sanc;
$params->{'updatedata'}= checkUpdateData();
$params->{'LibraryName'}= C4::Context->preference("LibraryName");
$params->{'pagetitle'}= "Usuarios";


# #No se pudo renovar por no tener el curso?
# $template->param(no_user_course => $query->param('no_user_course'));
# $template->param(CirculationEnabled => C4::Context->preference("circulation"));

#se verifica la preferencia showHistoricReserves, para mostrar o no el historico de las Reservas
my $showHistoricReserves= C4::Context->preference("showHistoricReserves");
$params->{'showHistoricReserves'}= $showHistoricReserves;

C4::Auth::output_html_with_http_headers($query, $template, $params);
