#!/usr/bin/perl
require Exporter;
use CGI;
use C4::AR::PdfGenerator;
use C4::AR::Auth;

use C4::AR::Utilidades;
use C4::AR::Estadisticas;
use C4::Date;

my $input=new CGI;
my $msg="";

#Fechas
my $ini='';
my $fin='';
#recupero los parametros
my $tipoItem = $input->param('tiposItems');
my $tipoPrestamo = $input->param('tipoPrestamos');
my $catUsuarios = $input->param('catUsuarios');

if($input->param('ini')){$ini=$input->param('ini');}
if($input->param('fin')){$fin=$input->param('fin');}

my $dateformat = C4::Date::get_date_format();
my $fechaInicio =  C4::Date::format_date_in_iso($ini,$dateformat);
my $fechaFin    =  C4::Date::format_date_in_iso($fin,$dateformat);

my $orden= $input->param('orden') || 'firstname' ;

#Traigo los prestamos
my ($cantidad, $historico_prestamos_array_ref)= C4::AR::Estadisticas::historicoPrestamos($obj);


$msg='Prestamos ';
my $dateformat = C4::Date::get_date_format();
if (($ini) and ($fin)){$msg.=' entre las fechas: <b>'.C4::Date::format_date($ini,$dateformat).'</b> y <b>'.format_date($fin,$dateformat).'</b> .'; }

#Si se quiere crear el PDF
if ($input->param('type') eq 'pdf') {
    &hitoricoPrestamosPdfGenerator($msg,@results);
}else{ #Para imprimir los resultados
	my  ($template, $session, $t_params)= get_template_and_user({
                                template_name => "reports/printHistPrestamos.tmpl",
                                query => $input,
                                type => "intranet",
                                authnotrequired => 1,
                                flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                             });

# my $resultsarray=\@results;
# ($resultsarray) || (@$resultsarray=());

    $t_params->{'RESULTSLOOP'}= $historico_prestamos_array_ref;
    $t_params->{'numrecords'}=	$cantidad;
    $t_params->{'UI'}=  C4::AR::Preferencias->getValorPreferencia("defaultUI");
    $t_params->{'msg'}=	$msg;
    
    
    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
}
