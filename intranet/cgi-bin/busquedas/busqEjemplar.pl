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
# use C4::Output;
use C4::Interface::CGI::Output;
# use HTML::Template;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user ({
                                        template_name	=> 'busquedas/busqEjemplar.tmpl',
                                        query		=> $input,
                                        type		=> "intranet",
                                        authnotrequired	=> 0,
                                        flagsrequired	=> { circulate => 1 },
    			 });

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $isbn = $obj->{'isbn'};
my $titulo = $obj->{'titulo'};
my $ini = $obj->{'ini'};
my $funcion=$obj->{'funcion'};

#combo itemtype
my ($cant,@itemtypes)= C4::AR::Busquedas::getItemTypes();
my @valuesItemtypes;
my %labelsItemtypes;
my $i=0;
push(@valuesItemtypes,-1);
$labelsItemtypes{-1}="Elegir tipo Item";
for ($i; $i<scalar(@itemtypes); $i++){
	push(@valuesItemtypes,$itemtypes[$i]->{'itemtype'});
	$labelsItemtypes{$itemtypes[$i]->{'itemtype'}}=$itemtypes[$i]->{'description'};
}
#fin combo
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

my ($cantidad,$result)=&C4::AR::Busquedas::buscarGrupos($isbn,$titulo,$ini,$cantR);

C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber, $funcion, $t_params);


for (my $i=0; $i<scalar(@$result); $i++ ){
	my $id1=$result->[$i]{'id1'};
	if($id1 ne ""){
		$result->[$i]{'combo'}=&C4::AR::Utilidades::crearComponentes('combo',$id1,\@valuesItemtypes,\%labelsItemtypes,'');
	}
}

$t_params->{'isbn'}= $isbn;
$t_params->{'titulo'}= $titulo;
$t_params->{'cantidad'}= $cantidad;
$t_params->{'result'}= $result;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
