#!/usr/bin/perl
#script para administrar las tablas de referencia
#escrito el 8/9/2006 por einar@info.unlp.edu.ar
#
#Copyright (C) 2003-2006  Linti, Facultad de Inform�tica, UNLP
#This file is part of Koha-UNLP
#
#This program is free software; you can redistribute it and/or
#modify it under the terms of the GNU General Public License
#as published by the Free Software Foundation; either version 2
#of the License, or (at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software
#Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Utilidades;
use C4::AR::Estadisticas;

my $input = new CGI;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "parameters/referencies.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });

my $tabla=$input->param('editandotabla');
my $valores=buscarTabladeReferencia($tabla);
my $env;
my @campos=obtenerCampos($tabla);
my $ind=$input->param('editandoind');
($ind||($ind=0)); 
my $search=$input->param('description');
($search||($search='')); 
my $cant=$input->param('editandocant');
($cant||($cant=20)); 
my $orden=$input->param('editandoorden');
($orden||($orden=$valores->{'orden'})); 
my $bloqueIni= $input->param('bloqueIni');
($bloqueIni||($bloqueIni = ''));
my $bloqueFin= $input->param('bloqueFin');
($bloqueFin||($bloqueFin = ''));

#agregado********************************************************
#Inicializo el inicio y fin de la instruccion LIMIT en la consulta
my $ini;
my $pageNumber;
my $cantR=cantidadRenglones();

if (($input->param('ini') eq "")){
        $ini=0;
	$pageNumber=1;
} else {
	$ini= ($input->param('ini')-1)* $cantR;
	$pageNumber= $input->param('ini');
};
#FIN inicializacion

# my ($total,@loop)= listadoTabla($tabla,$ind,$cant,$valores->{'camporeferencia'},$orden,$search,$bloqueIni,$bloqueFin);
my ($total,@loop)= listadoTabla($tabla,$ini,$cantR,$valores->{'camporeferencia'},$orden,$search,$bloqueIni,$bloqueFin);
#para agregar la clase y que se vea la zebra
my $num= 1;
foreach my $res (@loop) {
	((($num % 2) && ($res->{'clase'} = 'par' ))|| ($res->{'clase'}='impar'));
    	$num++;
}

my @numeros=armarPaginas($total);
my $paginas = scalar(@numeros)||1;
my $pagActual = $input->param('ini')||1;

$template->param( paginas   => $paginas,
		  actual    => $pagActual,
		);

if ( $total > $cantR ){#Para ver si tengo que poner la flecha de siguiente pagina o la de anterior
        my $sig = $pagActual+1;
        if ($sig <= $paginas){
                 $template->param(
                                ok    =>'1',
                                sig   => $sig);
        };
        if ($sig > 2 ){
                my $ant = $pagActual-1;
                $template->param(
                                ok2     => '1',
                                ant     => $ant)}
}



$template->param(
		camposloop => \@campos,
		loop=> \@loop,
		editandoind=> $ind,
		editandocant=> $cant,
		search=> $search,
		editandoorden=> $orden,
		editandotabla=> $tabla,
		editandoidentificador=> $valores->{'nomcamporeferencia'},
		editandototal=> $total,
		bloqueFin=> $bloqueFin,
		bloqueIni=> $bloqueIni,
		numeros=> \@numeros,
);


output_html_with_http_headers $input, $cookie, $template->output;

