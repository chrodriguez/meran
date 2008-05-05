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

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use HTML::Template;
use C4::AR::Utilidades;

my $input      = new CGI;
my $isbn       = $input->param('isbn');
my $titulo      = $input->param('titulo');
#FALTA EL PAGINADOR NO VA CAMBIAR POR AJAX

my $total;
my $count;
my @results;

if ( !$isbn && !$titulo ) {
    print $input->redirect('adminEjemplares.pl');
}
else {
    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "busquedas/busqEjemplar.tmpl",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { catalogue => 1 },
            debug           => 1,
        }
    );


#combo itemtype
	my ($cant,@results)= C4::Biblio::getitemtypes();
	my @valuesItemtypes;
	my %labelsItemtypes;
	my $i=0;
	push(@valuesItemtypes,-1);
	$labelsItemtypes{-1}="Elegir tipo Item";
	for ($i; $i<scalar(@results); $i++){
		push(@valuesItemtypes,$results[$i]->{'itemtype'});
		$labelsItemtypes{$results[$i]->{'itemtype'}}=$results[$i]->{'description'};
	}
#fin combo

	my @result=&C4::AR::Busquedas::buscarGrupos($isbn,$titulo);
	$cant=scalar(@result);
	for (my $i=0; $i<$cant; $i++ ){
		my $id1=$result[$i]{'id1'};
		$result[$i]{'combo'}=&crearComponentes('combo',$id1,\@valuesItemtypes,\%labelsItemtypes,'');
	}

$template->param(
		isbn          	=> $isbn,
		titulo         	=> $titulo,
		total        	=> $total,
		count	      	=> $cant,
		result          => \@result,
);

output_html_with_http_headers $input, $cookie, $template->output;
}# else
