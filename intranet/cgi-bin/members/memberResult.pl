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
use C4::Date;
use Date::Manip;
use C4::AR::Usuarios;
use HTML::Template;
use C4::AR::Estadisticas;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/memberResult.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $member=$input->param('member');

my $env;

my ($count,$results);

if($member ne ""){
	if(length($member) == 1) {
		$count=&ListadoDeUsuarios($env,$member,"simple",1);
	} else {
		$count=&ListadoDeUsuarios($env,$member,"advanced",1);
	}
}

$template->param( cantidad  => $count);

if($member ne ""){

	if((length($member) == 1)&&(defined $member)) {
		($count,$results)=&ListadoDeUsuarios($env,$member,"simple",0);
	} else {
		($count,$results)=&ListadoDeUsuarios($env,$member,"advanced",0);
	}
}


my @resultsdata;

my $err= "Error con la fecha";
my $hoy=C4::Date::format_date_in_iso(ParseDate("today"));
my  $close = ParseDate(C4::Context->preference("close"));
if (Date::Manip::Date_Cmp($close,ParseDate("today")) < 0){
	#Se paso la hora de cierre
	$hoy=C4::Date::format_date_in_iso(DateCalc($hoy,"+ 1 day",\$err));
}

for (my $i=0; $i < $count; $i++){
  #find out stats
 my ($od,$issue)=borrdata2($env,$results->[$i]{'borrowernumber'},$hoy,$close);
 my $regular= esRegular($results->[$i]{'borrowernumber'});

 if ($regular eq 1){$regular="<font color='green'>Regular</font>";}	
	else{
		if($regular eq 0){$regular="<font color='red'>Irregular</font>";}
		else{
			$regular="---";
		}
	}

  my %row = (
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
        borrowernotes => $results->[$i]{'borrowernotes'});
 
  	push(@resultsdata, \%row);
}

$template->param(
			member          => $member,
			resultsloop     => \@resultsdata 
);

output_html_with_http_headers $input, $cookie, $template->output;
