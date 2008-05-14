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

my $msg='';

my $branches=getbranches();
my $branch = getbranch($input, $branches);

my $orden;
if ($input->param('orden') eq ""){$orden='date'}
				else {$orden=$input->param('orden')};
#Inicializo avail
my $avail;
if ($input->param('avail') eq ""){$avail=1}
else {$avail=$input->param('avail')};
#fin

#Fechas
my $ini='';
my $fin='';
if($input->param('ini')){$ini=$input->param('ini');}
if($input->param('fin')){$fin=$input->param('fin');}
#

my ($cantidad, @results)= disponibilidad($branch,$orden,$avail,$ini,$fin);

	$msg='Ejemplares con disponibilidad: <b>'.getAvail($avail)->{'description'}.'</b> ';
	my $dateformat = C4::Date::get_date_format();
	if (($ini) and ($fin)){$msg.='entre las fechas: <b>'.format_date($ini,$dateformat).'</b> y <b>'.format_date($fin).'</b> .'; }

if ($input->param('type') eq 'pdf') {#Para PDF
					my  $msg2='Ejemplares con disponibilidad: '.getAvail($avail)->{'description'}.' ';
					my $dateformat = C4::Date::get_date_format();
				        if (($ini) and ($fin)){$msg2.='entre las fechas: '.format_date($ini,$dateformat).' y '.format_date($fin).' .'; }
					availPdfGenerator($msg2,@results);
				    }
else{ #Para imprimir
	my  ($template, $borrowernumber, $cookie)
                = get_template_and_user({template_name => "print.tmpl",
                             query => $input,
                             type => "intranet",
                             authnotrequired => 1,
                             flagsrequired => {borrow => 1}
                             });

my $resultsarray=\@results;
($resultsarray) || (@$resultsarray=());

$template->param(SEARCH_RESULTS => $resultsarray,
		 numrecords => $cantidad,
		 msg => $msg);


output_html_with_http_headers $input, $cookie, $template->output;
}
