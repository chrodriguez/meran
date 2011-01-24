#!/usr/bin/perl
# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA
#
#

use strict;
use C4::AR::Auth;
use CGI;
use C4::AR::Utilidades;
use C4::AR::Reportes;
use C4::AR::PdfGenerator;

my $input  = new CGI;
my $to_pdf = $input->param('export') || 0;
my $obj    = $input->param('obj') || 0;

$obj = C4::AR::Utilidades::from_json_ISO($obj);

my ( $template, $session, $t_params, $data_url );

my $template_name = "reports/altas_registro_result.tmpl";

if ($to_pdf) {
	$template_name = "reports/altas_registro_result_export.tmpl";
}    

( $template, $session, $t_params ) = get_template_and_user(
	{
		template_name   => $template_name,
		query           => $input,
		type            => "intranet",
		authnotrequired => 0,
		flagsrequired   => {
			ui             => 'ANY',
			tipo_documento => 'ANY',
			accion         => 'CONSULTA',
			entorno        => 'undefined'
		},
		debug => 1,
	}
);

my $ini = 0;

if ( !$to_pdf ) {
	$obj->{'ini'} = $obj->{'ini'} || 1;
	$ini = $obj->{'ini'};
}
else {
	$obj = $input->Vars;
	$ini = 0;
}

my ( $ini, $pageNumber, $cantR ) = C4::AR::Utilidades::InitPaginador($ini);
my ( $cantidad, $data ) = C4::AR::Reportes::altasRegistro( $ini, $cantR, $obj, $to_pdf );

#my ($path,$filename) = C4::AR::Reportes::toXLS($data,0,'Altas','Altas de Registro');
#$t_params->{'filename'} = '/reports/'.$filename;

my $funcion = $obj->{'funcion'};
my $inicial = $obj->{'inicial'};

if ( !$to_pdf ) {
	$t_params->{'paginador'} =
	  C4::AR::Utilidades::crearPaginador( $cantidad, $cantR, $pageNumber,
		$funcion, $t_params );
}

$t_params->{'buscoPor'} =
  Encode::encode( 'utf8', C4::AR::Busquedas::armarBuscoPor($obj) );
$t_params->{'data'}       = $data;
$t_params->{'cantidad'}   = $cantidad;
$t_params->{'item_type'}  = $obj->{'item_type'};
$t_params->{'date_begin'} = $obj->{'date_begin'};
$t_params->{'date_end'}   = $obj->{'date_end'};

if ($to_pdf) {
	$t_params->{'exported'} = 1;
	my $out = C4::AR::Auth::get_html_content( $template, $t_params, $session );
	my $filename = C4::AR::PdfGenerator::pdfFromHTML($out);

	print C4::AR::PdfGenerator::pdfHeader();

	C4::AR::PdfGenerator::printPDF($filename);

}
else {
	C4::AR::Auth::output_html_with_http_headers( $template, $t_params, $session );
}

