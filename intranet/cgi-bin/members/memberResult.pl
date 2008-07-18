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
use C4::Interface::CGI::Output;
use CGI;
use C4::Date;
use Date::Manip;
use C4::AR::Usuarios;
use C4::AR::Utilidades;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/memberResult.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });
my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $orden=$obj->{'orden'}||'surname';
my $member=$obj->{'member'};
my $ini=$obj->{'ini'};
my $funcion=$obj->{'funcion'};
my $env;


my ($cantidad,$results);
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

if($member ne ""){
	if((length($member) == 1)&&(defined $member)) {
		($cantidad,$results)=&ListadoDeUsuarios($env,$member,"simple",$orden,$ini,$cantR);
	} else {
		($cantidad,$results)=&ListadoDeUsuarios($env,$member,"advanced",$orden,$ini,$cantR);
	}
}
&C4::AR::Utilidades::crearPaginador($template, $cantidad,$cantR, $pageNumber,$funcion);

my @resultsdata;
for (my $i=0; $i < $cantR; $i++){
  #find out stats
    if($results->[$i]{'borrowernumber'} ne ""){
	my $clase="";
 	my ($od,$issue)=C4::AR::Issues::cantidadDePrestamosPorUsuario($results->[$i]{'borrowernumber'});
 	my $regular= &C4::AR::Usuarios::esRegular($results->[$i]{'borrowernumber'});

 	if ($regular eq 1){$regular="Regular"; $clase="prestamo";}	
	else{
		if($regular eq 0){$regular="Irregular";$clase="fechaVencida";}
		else{
			$regular="---";
		}
	}

  	my %row = (
		clase=>$clase,
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
        	regular => $regular,
        	borrowernotes => $results->[$i]{'borrowernotes'}
	);
	push(@resultsdata, \%row);
     }
}

$template->param(
			member          => $member,
			resultsloop     => \@resultsdata,
			cantidad        => $cantidad,
);

output_html_with_http_headers $input, $cookie, $template->output;
