#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Estadisticas;
use C4::Date;

my $input = new CGI;

my ($template, $session, $t_params)
    = get_template_and_user({template_name => "reports/estadisticasResult.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $chkfecha= $obj->{'chkfecha'};
my @chck= split(",",$obj->{'chck'});
my $chkuser= $obj->{'chkuser'};

my $dateformat = C4::Date::get_date_format();
#Tomo las fechas que setea el usuario y las paso a formato ISO
my $fechaInicio =  format_date_in_iso($obj->{'fechaIni'},$dateformat);
my $fechaFin    =  format_date_in_iso($obj->{'fechaFin'},$dateformat);

my $domiTotal;
my $renovados;
my $devueltos;
my $foto;
my $sala;
my $especial;
my $cantUsuPrest;
my $cantUsuRenov;
my $cantUsuReser;
my $checkbox=scalar(@chck);

if( $checkbox>0 || ($checkbox==0 && $chkuser eq "false")){
	($domiTotal,$renovados,$devueltos,$sala,$foto,$especial)=estadisticasGenerales($fechaInicio, $fechaFin, $chkfecha, @chck);
}

if(($chkuser eq "false" && $checkbox==0)||$chkuser ne "false"){
	$cantUsuPrest=cantidadUsuariosPrestamos($fechaInicio, $fechaFin, $chkfecha);
	$cantUsuRenov=cantidadUsuariosRenovados($fechaInicio, $fechaFin, $chkfecha);
	$cantUsuReser=cantidadUsuariosReservas($fechaInicio, $fechaFin, $chkfecha);
};
$t_params->{'chck'}=$obj->{'chck'};
$t_params->{'chkfecha'}=$chkfecha;
$t_params->{'chkuser'}=$chkuser;
$t_params->{'dateselect'}=$obj->{'fechaIni'};
$t_params->{'dateselectEnd'}=$obj->{'fechaFin'};
$t_params->{'domiTotal'}=$domiTotal;
$t_params->{'renovados'}=$renovados;
$t_params->{'devueltos'}=$devueltos;
$t_params->{'foto'}=$foto;
$t_params->{'sala'}=$sala;
$t_params->{'especial'}=$especial;
$t_params->{'cantUsuPrest'}=$cantUsuPrest;
$t_params->{'cantUsuRenov'}=$cantUsuRenov;
$t_params->{'cantUsuReser'}=$cantUsuReser;
C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
