#!/usr/bin/perl

# $Id: member.pl,v 1.13 2003/08/07 12:37:21 wolfpac444 Exp $

#script to do a borrower enquiery/brin up borrower details etc
#written 20/12/99 by chris@katipo.co.nz


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
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use C4::Search;
use HTML::Template;
use C4::AR::Persons_Members;
use C4::AR::Estadisticas;

my $input = new CGI;

my $theme = $input->param('theme') || "default";

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/member2.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $member=$input->param('member');

#Para el orden
my $orden;
if ($input->param('orden')){$orden=$input->param('orden');} else {$orden='surname,firstname';}
#

my $env;

my ($count,$results);

### Added by Luciano  ###
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
                                                                                                                             
if(length($member) == 1) {
	$count=PersonNameSearch($env,$member,"simple",1,$orden);
} else {
	$count=PersonNameSearch($env,$member,"advanced",1,$orden);
}

my @numeros=armarPaginas($count,$pageNumber);
                                                                                                                             
if ( $count > $cantR ){#Para ver si tengo que poner la flecha de siguiente pagina o la de anterior
        my $sig = $pageNumber+1;
        if ($sig <= scalar(@numeros)){
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
### ###

if(length($member) == 1) {
	($count,$results)=PersonNameSearch($env,$member,"simple",0,$orden,$ini,$cantR);
} else {
	($count,$results)=PersonNameSearch($env,$member,"advanced",0,$orden,$ini,$cantR);
}

#	open L, ">/tmp/pepe";
#				foreach my $pp (@aux){
#				printf L $pp; 
#				}	
#		 	        printf L $row{'borrowernumber'}."\n"; 
#				close L;

my @resultsdata;
my $background = 'par';
for (my $i=0; $i < $count; $i++){

my $regular=$results->[$i]{'regular'};
if ($regular eq 1){$regular="<font color='green'>Regular</font>";}elsif($regular eq 0){$regular="<font color='red'>Irregular</font>";}else{$regular="---";};
if($results->[$i]{'categorycode'} eq 'EG'){$regular="<font color='blue'>Egresado</font>";}
#  my ($od,$issue,$fines)=boordata2($env,$results->[$i]{'borrowernumber'}); esta funcion averigua sobre prestamos del borrowernumber
  my %row = (
        documentnumber=> $results->[$i]{'documentnumber'},
        documenttype=> $results->[$i]{'documenttype'},
	emailaddress=> $results->[$i]{'emailaddress'},
	phone=> $results->[$i]{'phone'},
	borrowernumber => $results->[$i]{'borrowernumber'},
        personnumber => $results->[$i]{'personnumber'},
        cardnumber => $results->[$i]{'cardnumber'},
        surname => $results->[$i]{'surname'},
	studentnumber => $results->[$i]{'studentnumber'},
        firstname => $results->[$i]{'firstname'},
        categorycode => $results->[$i]{'categorycode'},
        streetaddress => $results->[$i]{'streetaddress'},
        city => $results->[$i]{'city'},
        borrowernotes => $results->[$i]{'borrowernotes'},
	regular=> $regular,
        clase=> $background,
	);
  if ($background eq 'par') {$background='impar'} else {$background='par'};
  if ($row{'borrowernumber'}){my @aux=sepuedeeliminar($row{'borrowernumber'});
				$row{'modificable'}=$aux[3]; }
				else{$row{'nomodificable'}="0";} 
			
  push(@resultsdata, \%row);
}

if(my $msg=$input->param('msg')){$template->param(msg => $msg)};

$template->param(   orden     => $orden,
		        count	=> $count, 
			member          => $member,
			numeros          => \@numeros,
			resultsloop     => \@resultsdata );

output_html_with_http_headers $input, $cookie, $template->output;
