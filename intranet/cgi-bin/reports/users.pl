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

my $input = new CGI;

my $theme = $input->param('theme') || "default";
my $campoIso = $input->param('code') || ""; 
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/users.tmpl",

			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

#Por los braches
my @branches;
my @select_branch;
my %select_branches;
my $branches=getbranches();
foreach my $branch (keys %$branches) {
        push @select_branch, $branch;
        $select_branches{$branch} = $branches->{$branch}->{'branchname'};
}

#Miguel - 30-03-07 - Le agrego una opcion para que le indique al usuario que no se ha seleccionado nada a�n, ver si queda
push @select_branch, 'SIN SELECCIONAR';

my $branch= C4::Context->preference('defaultbranch');

my $CGIbranch=CGI::scrolling_list(      -name      => 'branch',
                                        -id        => 'branch',
                                        -values    => \@select_branch,
					-defaults  => $branch,
                                        -labels    => \%select_branches,
                                        -size      => 1,
                                 );

#Fin: Por los branches

#CATEGORIAS
my ($valuesCateg,$labelsCateg)=&borrowercategories();
my $CGIcateg=CGI::scrolling_list(    -name      => 'categoria',
                                     -id        => 'categoria',
                                     -values    => $valuesCateg,
				     -defaults  => $branch,
                                     -labels    => $labelsCateg,
                                     -size      => 1,
                                 );



#Para los a�os
my @date=localtime;
my $year_Default= $date[5]+1900;
my @years;
for (my $i =2005 ; $i < 2036; $i++){
	push (@years,$i);
}
my $years=CGI::scrolling_list(  -name      => 'year',
				-id	   => 'year',
                                -values    => \@years,
                                -defaults  => $year_Default,
                                -size      => 1,
                                 );
#fin a�os

my $year = $input->param('year');
my $categ= $input->param('categoria');

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

my @chck=$input->param('chck');
my $usos=$input->param('usos');


my $chck2=$input->param('chck2'); #Variable que viene por el metodo GET desde la pagina, 
				  #cuando se toca en siguiente o anterior (numeros).
if($chck2 ne ""){
	@chck=split/,/, $chck2; #Convierte chck2 que es un string a un arreglo 
}                               #se hace para poder volver hacer las consultas


my (@resultsdata)= usuarios($branch,$orden,$ini,$cantR,$year,$usos,$categ,@chck);#Obtengo los usuarios de una pagina dada

my $cantidad =cantidadUsuarios($branch,$year,$usos,$categ,@chck);#Obtengo la cantidad total de usuarios para poder paginar


my @numeros=armarPaginas($cantidad);
#Miguel 30-03-07 
my $paginas = scalar(@numeros)||1;
my $pagActual = $input->param('ini')||1;
$template->param( paginas   => $paginas,
		  actual    => $pagActual,
		  cantidad  => $cantidad);

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
			unidades         => $CGIbranch,
			categorias	 => $CGIcateg,
			numeros		 => \@numeros,
			branch           => $branch,
			years		 => $years,
			chck             => join(",",@chck),#Trasfoma el arreglo checkbox en string
			usos		 => $usos,
			categ		 => $categ,
			year		 => $year
		);

output_html_with_http_headers $input, $cookie, $template->output;
