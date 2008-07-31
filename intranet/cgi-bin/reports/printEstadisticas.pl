#!/usr/bin/perl
require Exporter;
use CGI;
use C4::AR::PdfGenerator;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Utilidades;
use C4::AR::Estadisticas;
use C4::Date;
use C4::AR::Busquedas;

my $input=new CGI;

my $msg="";

my $chkfecha= $input->param('chkfecha');
my @chck= $input->param('chck');
my $chkuser= $input->param('chkuser');

#Fechas


my $ini='';
my $fin='';
$ini=$input->param('dateselected'); # Fecha para mostrar en la impresion
$fin=$input->param('dateselectedEnd');
my $dateformat = C4::Date::get_date_format();
my $fechaInicio =  C4::Date::format_date_in_iso($ini,$dateformat);# Fecha para poder hacer la busqueda
my $fechaFin    =  C4::Date::format_date_in_iso($fin,$dateformat);
#

my $domiTotal;
my $renovados;
my $devueltos;
my $foto;
my $sala;
my $especial;
my $cantUsuPrest;
my $cantUsuRenov;
my $cantUsuReser;

my @estadisicas;

($domiTotal,$renovados,$devueltos,$sala,$foto,$especial)=estadisticasGenerales($fechaInicio, $fechaFin, $chkfecha, @chck);

$estadisticas[0]=$domiTotal;
$estadisticas[1]=$renovados;
$estadisticas[2]=$devueltos;
$estadisticas[3]=$sala;
$estadisticas[4]=$foto;
$estadisticas[5]=$especial;

if(($chkuser eq "" && scalar(@chck)==0)||$chkuser ne ""){
	$cantUsuPrest=cantidadUsuariosPrestamos($fechaInicio, $fechaFin, $chkfecha);
	$cantUsuRenov=cantidadUsuariosRenovados($fechaInicio, $fechaFin, $chkfecha);
	$cantUsuReser=cantidadUsuariosReservas($fechaInicio, $fechaFin, $chkfecha);
}

$estadisticas[6]=$cantUsuPrest;
$estadisticas[7]=$cantUsuRenov;
$estadisticas[8]=$cantUsuReser;





$msg="Prestamos: ";
my $dateformat = C4::Date::get_date_format();
if (($ini) and ($fin)){$msg.='entre las fechas: '.format_date($ini,$dateformat).' y '.format_date($fin,$dateformat).'.'; }

if ($input->param('type') eq 'pdf'){#Para PDF

	&estadisticasPdfGenerator($msg,@estadisticas);

}
else{ #Para imprimir
	my  ($template, $borrowernumber, $cookie)
                = get_template_and_user({template_name => "reports/printEstadisticas.tmpl",
                             query => $input,
                             type => "intranet",
                             authnotrequired => 1,
                             flagsrequired => {borrow => 1}
                             });

my $resultsarray=\@estadisticas;
($estadisticas) || (@$estadisticas=());

$template->param(
		 domiTotal        => $domiTotal,
		 renovados        => $renovados,
		 devueltos        => $devueltos,
		 foto             => $foto,
		 sala             => $sala,
		 especial         => $especial,
		 cantUsuPrest	  => $cantUsuPrest,
		 cantUsuRenov	  => $cantUsuRenov,
		 cantUsuReser	  => $cantUsuReser,
		 msg              => $msg
		);


output_html_with_http_headers $input, $cookie, $template->output;
}
