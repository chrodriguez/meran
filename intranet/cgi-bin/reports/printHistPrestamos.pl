#!/usr/bin/perl
require Exporter;
use CGI;
use C4::Context;
use C4::Search;
use C4::AR::PdfGenerator;
use C4::Auth;
use C4::Interface::CGI::Output;
use HTML::Template;
use C4::AR::Utilidades;
use C4::AR::Estadisticas;
use C4::Koha;
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

my $fechaInicio =  format_date_in_iso($ini);
my $fechaFin    =  format_date_in_iso($fin);

my $orden= $input->param('orden') || 'firstname' ;

#Traigo los prestamos
my ($cantidad,@results)= historicoPrestamos($orden,$fechaInicio,$fechaFin,$tipoItem,$tipoPrestamo,$catUsuarios);


$msg='Prestamos ';
if (($ini) and ($fin)){$msg.=' entre las fechas: <b>'.format_date($ini).'</b> y <b>'.format_date($fin).'</b> .'; }

#Si se quiere crear el PDF
if ($input->param('type') eq 'pdf') {&hitoricoPrestamosPdfGenerator($msg,@results);}
else{ #Para imprimir los resultados
	my  ($template, $borrowernumber, $cookie)
                = get_template_and_user({template_name => "reports/printHistPrestamos.tmpl",
                             query => $input,
                             type => "intranet",
                             authnotrequired => 1,
                             flagsrequired => {borrow => 1}
                             });

my $resultsarray=\@results;
($resultsarray) || (@$resultsarray=());

$template->param(RESULTSLOOP => $resultsarray,
		 numrecords => $cantidad,
		 msg => $msg);


output_html_with_http_headers $input, $cookie, $template->output;
}
