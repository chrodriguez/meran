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
use C4::Auth;
use CGI;
use C4::AR::Utilidades;
use C4::AR::Reportes;
use C4::AR::PdfGenerator;

my $input  = new CGI;
my $to_pdf = $input->param('export') || 0;
my $obj    = $input->param('obj') || 0;

$obj = C4::AR::Utilidades::from_json_ISO($obj);

my ( $template, $session, $t_params, $data_url );

my $template_name = "reports/estantes_virtuales_result.tmpl";

if ($to_pdf) {
	$template_name = "reports/estantes_virtuales_result_export.tmpl";
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

my $id_estante= $obj->{'estante'};

my ($subEstantes)= C4::AR::Reportes::estantesVirtuales( $id_estante);


use C4::AR::Estantes;

if($id_estante){
    my $estante= C4::AR::Estantes::getEstante($id_estante);
    $t_params->{'estante'}= $estante;
}

$t_params->{'SUBESTANTES'}= $subEstantes;
$t_params->{'id_estante'}= $id_estante;

if ($to_pdf) {
	$t_params->{'exported'} = 1;
	my $out = C4::Auth::get_html_content( $template, $t_params, $session );
	my $filename = C4::AR::PdfGenerator::pdfFromHTML($out);

	print C4::AR::PdfGenerator::pdfHeader();

	C4::AR::PdfGenerator::printPDF($filename);

}
else {
	C4::Auth::output_html_with_http_headers( $template, $t_params, $session );
}

