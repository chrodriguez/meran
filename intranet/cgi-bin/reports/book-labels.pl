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
use C4::Koha;
use C4::Search;
use C4::Interface::CGI::Output;
use CGI;
use HTML::Template;
use C4::AR::PdfGenerator;
use C4::AR::Estadisticas;

my $input = new CGI;
my  $orden=$input->param('orden');
my  $op=$input->param('op');
my  $barcode1=$input->param('barcode1');
my  $barcode2=$input->param('barcode2');
my  $bulk1=$input->param('bulk1');
my  $bulk2=$input->param('bulk2');
my  $bulkbegin=$input->param('bulkbegin');

my  $branch=$input->param('branch');
my  $count=0;
my  $cantidad=0;
my  @results=();

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/book-labels.tmpl",

			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });



if ($op eq 'pdf') {
#HAY QUE GENERAR EL PDF CON LOS CARNETS

my $tmpFileName= "etiquetas.pdf";
($cantidad,@results)= listaDeEjemplares($barcode1,$barcode2,$bulk1,$bulk2,$bulkbegin,$branch,1,"todos",$orden);
my $pdf = batchBookLabelGenerator($cantidad,@results);

print "Content-type: application/pdf\n";
print "Content-Disposition: attachment; filename=\"$tmpFileName\"\n\n";
print $pdf->Finish();

}
else
{


if ($op ne ''){

#Inicializo el inicio y fin de la instruccion LIMIT en la consulta
my $ini;
my $pageNumber;
my $cantR=cantidadRenglones();
if ($input->param('renglones')){$cantR=$input->param('renglones');}

if (($input->param('ini') eq "")){
        $ini=0;
	$pageNumber=1;
} else {
	$ini= ($input->param('ini')-1)* $cantR;
	$pageNumber= $input->param('ini');
};
#FIN inicializacion


($cantidad,@results)= listaDeEjemplares($barcode1,$barcode2,$bulk1,$bulk2,$bulkbegin,$branch,$ini,$cantR,$orden);

if ($cantR ne 'todos') {
my @numeros= armarPaginasPorRenglones($cantidad,$pageNumber,$cantR);

my $paginas = scalar(@numeros)||1;
my $pagActual = $input->param('ini')||1;

$template->param( paginas   => $paginas,
		  actual    => $pagActual,
		);

if ( $cantidad > $cantR ){#Para ver si tengo que poner la flecha de siguiente pagina o la de anterior
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

$template->param( 	numeros		 => \@numeros,
			ini		 => $pagActual);
}

}



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
                                 );

#Fin: Por los branches

if ($op eq 'search'){
#Se realiza la busqueda si al algun campo no vacio
$template->param(
		RESULTSLOOP=>\@results,
	               );
	}

my $MINB=C4::Circulation::Circ2::getminbarcode($branch);
my $MAXB=C4::Circulation::Circ2::getmaxbarcode($branch);
my $MINS= signaturamax($branch);
my $MAXS= signaturamin($branch);

$template->param(
                cantidad=>$cantidad,
		unidades => $CGIbranch,
		branch => $branch,
		orden => $orden,
		barcode1 => $barcode1,
		barcode2 => $barcode2,
		MAXB => $MAXB,
		MINB => $MINB,
		bulk1 => $bulk1,
		bulk2 => $bulk2,
		MAXS => $MAXS,
		MINS => $MINS,
		bulkbegin => $bulkbegin
		);


output_html_with_http_headers $input, $cookie, $template->output;

}
