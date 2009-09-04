#!/usr/bin/perl


use strict;
require Exporter;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Date;
use C4::AR::Nivel3;

my $input = new CGI;

my ($template, $loggedinuser, $cookie) = get_template_and_user({
			template_name   => 'busquedas/detalleItem.tmpl',
			query           => $input,
			type            => "intranet",
			authnotrequired => 0,
			flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
        });

my $dateformat = C4::Date::get_date_format();
my $id3=$input->param('id3');
my $id2=$input->param('id2');
my $id1=$input->param('id1');
my $signatura_topografica=$input->param('signatura_topografica');
my $barcode=$input->param('barcode');

my $data=C4::AR::Catalogacion::buscarNivel1($id1);
my $autor=C4::AR::Busquedas::getautor($data->{'autor'});
$data->{'autor'}=$autor->{'completo'};
my %inputs;
my ($count, $detail)=C4::AR::Nivel3::detalleDisponibilidad($id3);
my @results;

for (my $i=0; $i < $count; $i++){
	my $avail='';
	my $clase="";
	my $clase2="";
	if ($detail->[$i]{'avail'} eq 'Disponible'){
		$avail='Disponible';
		$clase="prestamo";
	}
	else {
		$avail=$detail->[$i]{'avail'};
		$clase="fechaVencida";
	}	

	my $loan='';
	if ($detail->[$i]{'loan'} eq 'PRESTAMO'){
		$loan='PRESTAMO'; $clase2="prestamo";
	}
	else {
		$loan=$detail->[$i]{'loan'};
		$clase2="salaLectura";
	}
 	 my %row = (
		claseAvail=>$clase,
		claseLoan=>$clase2,
        	avail=> $avail,
		loan=>$loan,
        	date=> format_date($detail->[$i]{'date'},$dateformat)
        	);
  	push(@results, \%row);
}

my @datearr = localtime(time);
my $today =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
my $today= format_date($today,$dateformat);

$template->param(DETAIL => \@results,
		titulo => $data->{'titulo'},
	        autor => $data->{'autor'},
# 		itemnotes => FALTA LAS NOTAS DEL ITEM ES UN CAMPO MARC
		id1 => $id1,
        	id2 => $id2,
		id3 => $id3,
		barcode => $barcode,
		signatura_topografica => $signatura_topografica,
		today => $today,
		);

output_html_with_http_headers $cookie, $template->output;