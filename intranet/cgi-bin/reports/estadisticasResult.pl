#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Estadisticas;
use C4::Date;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
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
$template->param( 	
# 			Esta variables que se pasan son para poder imprimir los resultados
			chck             => $obj->{'chck'},
			chkfecha         => $chkfecha,
			chkuser		 => $chkuser,
			dateselected     => $obj->{'fechaIni'},
		        dateselectedEnd  => $obj->{'fechaFin'},
#			Variables que se muestran en el tmpl
			domiTotal        => $domiTotal,
			renovados        => $renovados,
			devueltos        => $devueltos,
			foto             => $foto,
			sala             => $sala,
			especial         => $especial,
			cantUsuPrest	 => $cantUsuPrest,
			cantUsuRenov	 => $cantUsuRenov,
			cantUsuReser	 => $cantUsuReser,
		);

output_html_with_http_headers $input, $cookie, $template->output;
