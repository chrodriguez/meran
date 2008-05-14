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
use C4::AR::Utilidades;
use C4::Koha;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/usersResult.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $orden;
if ($input->param('orden') eq ""){
	 $orden='cardnumber'
}
else {
	$orden=$input->param('orden')
};

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

my $year = $input->param('year');
my $categ= $input->param('categoria');
my @chck=split('#',$input->param('chck'));
my $usos=$input->param('usos');
my $branch=$input->param('branch');

my (@resultsdata)= usuarios($branch,$orden,$ini,$cantR,$year,$usos,$categ,@chck);#Obtengo los usuarios de una pagina dada

my $cantidad =cantidadUsuarios($branch,$year,$usos,$categ,@chck);#Obtengo la cantidad total de usuarios para poder paginar


my @numeros=C4::AR::Estadisticas::armarPaginas($cantidad);
#Miguel 30-03-07 
my $paginas = scalar(@numeros)||1;
my $pagActual = $input->param('ini')||1;
$template->param( paginas   => $paginas,
		  actual    => $pagActual,
		);

if ( $cantidad > $cantR ){#Para ver si tengo que poner la flecha de siguiente pagina o la de anterior
        my $sig = $pageNumber+1;
        if ($sig <= $paginas){
                 $template->param(
                                ok    =>'1',
                                sig   => $sig);
        };
        if ($sig > 2 ){
                my $ant = $pageNumber-1;
                $template->param(
                                ok2     => '1',
                                ant     => $ant)}
}

$template->param( 	orden		 => $orden,
			resultsloop      => \@resultsdata,
 			ini		 => $pagActual,
			numeros		 => \@numeros,
			cantidad  	 => $cantidad
		);

output_html_with_http_headers $input, $cookie, $template->output;
