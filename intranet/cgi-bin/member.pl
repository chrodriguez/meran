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
use C4::AR::Estadisticas;

my $input = new CGI;

my $theme = $input->param('theme') || "default";


#Para el orden
my $orden;
if ($input->param('orden')){$orden=$input->param('orden');} else {$orden='surname,firstname';}
#


# only used if allowthemeoverride is set
#my %tmpldata = pathtotemplate ( template => 'member.tmpl', theme => $theme, language => 'fi' );
# FIXME - Error-checking
#my $template = HTML::Template->new( filename => $tmpldata{'path'},
#				    die_on_bad_params => 0,
#				    loop_context_vars => 1 );

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/member.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $member=$input->param('member');

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
	$count=BornameSearch($env,$member,"simple",1,$orden);
} else {
	$count=BornameSearch($env,$member,"advanced",1,$orden);
}

my @numeros=armarPaginas($count,$pageNumber);
my $paginas = scalar(@numeros)||1;
my $pagActual = $input->param('ini')||1;
$template->param( paginas   => $paginas,
		  actual    => $pagActual,
		  cantidad  => $count);


if ( $count > $cantR ){#Para ver si tengo que poner la flecha de siguiente pagina o la de anterior
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
### ###

if(length($member) == 1) {
	($count,$results)=BornameSearch($env,$member,"simple",0,$orden,$ini,$cantR);
} else {
	($count,$results)=BornameSearch($env,$member,"advanced",0,$orden,$ini,$cantR);
}


my @resultsdata;
my $background = 'par';
for (my $i=0; $i < $count; $i++){
  #find out stats

 my ($od,$issue,$fines)=borrdata2($env,$results->[$i]{'borrowernumber'});
  my $regular= isRegular($results->[$i]{'borrowernumber'});
 
  if ($regular eq 1){$regular="<font color='green'>Regular</font>";}	
	else{
	if($regular eq 0){$regular="<font color='red'>Irregular</font>";}
	else{$regular="---";};}
  
  if($results->[$i]{'categorycode'} eq 'EG'){$regular="<font color='blue'>Egresado</font>";}

  my %row = (
        clase => $background,
        borrowernumber => $results->[$i]{'borrowernumber'},
        cardnumber => $results->[$i]{'cardnumber'},
        surname => $results->[$i]{'surname'},
        firstname => $results->[$i]{'firstname'},
        categorycode => $results->[$i]{'categorycode'},
        streetaddress => $results->[$i]{'streetaddress'},
        documenttype => $results->[$i]{'documenttype'},
        documentnumber => $results->[$i]{'documentnumber'},
        studentnumber => $results->[$i]{'studentnumber'},
        city => $results->[$i]{'city'},
        odissue => "$od/$issue",
        issue => "$issue",
        od => "$od",
        fines => $fines,
        regular => $regular,
        borrowernotes => $results->[$i]{'borrowernotes'});
 if ( $background eq 'par' ) { $background = 'impar'; } else {$background = 'par'; }
  push(@resultsdata, \%row);
}

$template->param(     orden 	=> $orden,
			member          => $member,
			numeros          => \@numeros,
			resultsloop     => \@resultsdata );

output_html_with_http_headers $input, $cookie, $template->output;
