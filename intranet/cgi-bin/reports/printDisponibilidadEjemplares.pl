#!/usr/bin/perl
require Exporter;
use CGI;
use C4::AR::PdfGenerator;
use C4::AR::Auth;

use C4::AR::Utilidades;
use C4::Date;

## Usado por availability (Disponibilidad de Ejemplares)

my $input=new CGI;
my $msg='';

my $branch = $input->param('branch');

my $orden=$input->param('orden')||'date';
#Inicializo avail
my $avail=$input->param('avail')||1;
#fin
# FIXME esto esta malisimo, pasar todo y generar mensajes de error no concatenar
#Fechas
my $fini=$input->param('fechaIni');
my $ffin=$input->param('fechaFin');
#

my ($cantidad, @results)= C4::AR::Estadisticas::disponibilidad($branch,$orden,$avail,$fini,$ffin,'','');

$msg='Ejemplares con disponibilidad: <b>'.C4::AR::Busquedas::getAvail($avail)->{'description'}.'</b> ';
my $dateformat = C4::Date::get_date_format();
if (($fini) and ($ffin)){
	$msg.='entre las fechas: <b>'.C4::Date::format_date($fini,$dateformat).'</b> y <b>'.format_date($ffin,$dateformat).'</b> .'; 
}

if ($input->param('type') eq 'pdf') {
C4::AR::Debug::debug("PDF");
    #Para PDF
	my  $msg2='Ejemplares con disponibilidad: '.C4::AR::Busquedas::getAvail($avail)->{'description'}.' ';
	if (($fini) and ($ffin)){
		$msg2.='entre las fechas: '.format_date($fini,$dateformat).' y '.format_date($ffin,$dateformat).' .';
	}
 	availPdfGenerator($msg2,@results);
}
else{ #Para imprimir
my  ($template, $session, $t_params)= get_template_and_user({
									template_name => "reports/printDisponibilidadEjemplares.tmpl",
									query => $input,
									type => "intranet",
									authnotrequired => 0,
									flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                             });

my $resultsarray=\@results;
($resultsarray) || (@$resultsarray=());

$t_params->{'SEARCH_RESULTS'}= $resultsarray;
$t_params->{'numrecords'}= $cantidad;
$t_params->{'msg'}= $msg;

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
}

