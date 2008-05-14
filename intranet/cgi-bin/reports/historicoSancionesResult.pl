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

use strict;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use C4::Search;
use HTML::Template;
use C4::AR::Estadisticas;
use C4::Koha;
use C4::Date;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/historicoSancionesResult.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {circulate => 1},
			     debug => 1,
			     });


my $orden= "date";  # $input->param('orden')||'operacion';

###Marca la Fecha de Hoy
                                                                                
my @datearr = localtime(time);
my $today =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
$template->param( todaydate => format_date($today));
                                                                                
###

#Inicializo el inicio y fin de la instruccion LIMIT en la consulta
my $ini;
my $pageNumber;
my $cantR=cantidadRenglones();

if (($input->param('ini') eq "")){
        $ini=0;
	$pageNumber=1;
}
else {
	$ini= ($input->param('ini')-1)* $cantR;
	$pageNumber= $input->param('ini');
};

#FIN inicializacion
#Tomo las fechas que setea el usuario y las paso a formato ISO
my $fechaIni =  format_date_in_iso($input->param('fechaIni'));
my $fechaFin    =  format_date_in_iso($input->param('fechaFin'));
my @resultsdata;
my $cant;
my $user= $input->param('user');
my $tipoPrestamo= $input->param('tiposPrestamos');
my $tipoOperacion= $input->param('tipoOperacion');

($cant,@resultsdata)=
 &historicoSanciones($fechaIni,$fechaFin,$user,"",$ini,$cantR,$orden,$tipoPrestamo, $tipoOperacion);

my @numeros=armarPaginas($cant,$pageNumber);
my $paginas = scalar(@numeros)||1;
my $pagActual = $input->param('ini')||1;
$template->param( paginas   => $paginas,
		  actual    => $pagActual);

if ( $cant > $cantR ){#Seteo las flechas de siguiente y anterior
       	my $sig = $pageNumber+1;;
        if ($sig <= $paginas){
       	         $template->param(
               	                ok    =>'1',
                       	        sig   => $sig);
        };
	if ($sig > 2 ){
               my $ant = $pageNumber-1;
               $template->param(
                               ok2     => '1',
                               ant     => $ant)
	}
}


$template->param( 
			resultsloop      => \@resultsdata,
                        cant             => $cant,
			user             => $user,
			tiposPrestamos	 => $tipoPrestamo,
			tipoOperacion	 => $tipoOperacion,
			numeros 	 => \@numeros

		);

output_html_with_http_headers $input, $cookie, $template->output;
