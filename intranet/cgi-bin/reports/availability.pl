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
    = get_template_and_user({template_name => "reports/availability.tmpl",

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


my $branch= C4::Context->preference('defaultbranch');

my $CGIbranch=CGI::scrolling_list(      -name      => 'branch',
                                        -id        => 'branch',
                                        -values    => \@select_branch,
					-defaults  => $branch,
                                        -labels    => \%select_branches,
                                        -size      => 1,
# 					-onChange  =>'hacerSubmit()',

                                 );

#Fin: Por los branches

my $orden;
if ($input->param('orden') eq ""){
	 $orden='date'}
else {$orden=$input->param('orden')};

#Inicializo avail
my $avail;
if ($input->param('avail') eq ""){
         $avail=1}
else {$avail=$input->param('avail')};
#fin

#Fechas
my $ini='';
my $fin='';
if($input->param('ini')){$ini=$input->param('ini');}
if($input->param('fin')){$fin=$input->param('fin');}

#Inicializo el inicio y fin de la instruccion LIMIT en la consulta
my $iniPag;
my $pageNumber;
my $cantR=cantidadRenglones();

if (($input->param('iniPag') eq "")){
        $iniPag=0;
	$pageNumber=1;
} else {
	$iniPag= ($input->param('iniPag')-1)* $cantR;
	$pageNumber= $input->param('iniPag');
};
#FIN inicializacion

my ($cantidad, @resultsdata)= disponibilidad($branch,$orden,$avail,$ini,$fin);

my @numeros=armarPaginas($cantidad,$pageNumber);
my $paginas = scalar(@numeros)||1;
my $pagActual = $input->param('iniPag')||1;
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




my $availD;
if ($avail eq 0){$availD='Disponible';}else{	my $av=getAvail($avail);
						if ($av){$availD=$av->{'description'};}
						}

$template->param( 
			resultsloop      => \@resultsdata,
			unidades         => $CGIbranch,
			cantidad	 => $cantidad,
			branch           => $branch,
			orden 		 => $orden, 
			avail		 => $avail,
			availD		 => $availD,
			ini 		 => $ini,
			fin		 => $fin		
		);



## Scroll de disponibilidades
my %availlabels;
my @availtypes;

 ( %availlabels) = &getavails;
        foreach my $aux ( sort { $availlabels{$a} cmp $availlabels{$b} } keys(%availlabels)){
        push(@availtypes,$aux);}
        my $Cavails=CGI::scrolling_list(-name      => 'avail',
                                        -id        => 'avail',
                                        -values    => \@availtypes,
                                        -defaults => $avail,
                                        -labels    => \%availlabels,
                                        -size      => 1,
                                        -multiple  => 0,
# 					-onChange  =>'hacerSubmit()'
                                 );


$template->param(Cavails => $Cavails);

output_html_with_http_headers $input, $cookie, $template->output;
