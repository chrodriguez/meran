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
    = get_template_and_user({template_name => "reports/browserItem.tmpl",

			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });


#Por los branches
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
                                        -onChange  =>'hacerSubmit()'
                                 );
#Fin: Por los branches
my $orden;
if ( $input->param('orden') eq ""){
	$orden='barcode'}  #Miguel 16-03-07 - el campo ISBN no exite en la tabla items
else {$orden=$input->param('orden')};

#Inicializo el inicio y fin de la instruccion LIMIT en la consulta
my $ini;
my $cantR = cantidadRenglones();

if (($input->param('ini') eq "") and ($input->param('fin') eq "")){
          $ini=0;}
else {$ini= ($input->param('ini')-1)*$cantR };
#FIN inicializacion

my @resultsdata= items($orden,$ini,$cantR);#Items

my $cantidad=cantidadItem($branch);#Cantidad total de items  para calcular la cantidad de paginas

my @numeros=armarPaginas($cantidad);
#Miguel 03-04-07 
my $paginas = scalar(@numeros)||1;
my $pagActual = $input->param('ini')||1;
$template->param( paginas   => $paginas,
		  actual    => $pagActual);

if ( $cantidad > $cantR ){#Para ver si tengo que poner la flecha de siguiente pagina o la de anterior
        my $sig = ($input->param('ini'))+1;
        if ($sig <= scalar(@numeros)){
                 $template->param(
                                ok    =>'1',
                                sig   => $sig);
        };
        if ($sig > 2 ){
                my $ant = ($input->param('ini'))-1;
                $template->param(
                                ok2     => '1',
                                ant     => $ant)}
}



$template->param( 
			resultsloop      => \@resultsdata,
			unidades         => $CGIbranch,
			cantidad         => $cantidad,
			numeros		 => \@numeros,
			branch           => $branch,
			orden		 => $orden,
			renglones	 => $cantR
		);

output_html_with_http_headers $input, $cookie, $template->output;
