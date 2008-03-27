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
    = get_template_and_user({template_name => "reports/estadistica_Anual.tmpl",

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
					-onChange  =>'hacerSubmit()'
                                 );

#Fin: Por los branches

my @date=localtime;
my $year_Default=$date[5]+1900;
my @years;
for (my $i =2005 ; $i < 2036; $i++){
	push (@years,$i);
}
my $year=CGI::scrolling_list(   -name      => 'year',
                                -values    => \@years,
                                -defaults  => $year_Default,
                                -size      => 1,
                                -onChange  =>'hacerSubmit()'
                                 );

my $year_selected = $input->param('year')||$year_Default;
my @resultsdata= prestamosAnual($branch,$year_selected);

#******** 18/05/2007 - Damian - Se agrego para que se vea la cantidad de prestamos por tipo, antes
#                               no se veia. Se cambio la consulta prestamosAnual en Estadisticas.pm
my $row=0;
my @result;
my @loop;
my $mes="";
my $cantTotal=0;
my $devoluciones=0;

my $i=0;
foreach $row (@resultsdata){
	if ($mes eq ""){$mes=$row->{'mes'};}
	
	if ($mes eq $row->{'mes'}){
		$result[$i]{'mes'} = $mes;
		$cantTotal=$cantTotal + $row->{'cantidad'};
		$devoluciones=$devoluciones + $row->{'devoluciones'};
		if ($row->{'issuecode'} eq 'DO'){
			$result[$i]{'DO'}= $row->{'cantidad'};
			$result[$i]{'renovaciones'} = $row->{'renovaciones'};
		}
		elsif($row->{'issuecode'} eq 'ES'){$result[$i]{'ES'}=$row->{'cantidad'};}
		elsif($row->{'issuecode'} eq 'FO'){$result[$i]{'FO'}=$row->{'cantidad'};}
		else{$result[$i]{'SA'}= $row->{'cantidad'};}
		
	}
	else{
		$result[$i]{'cantTotal'}=$cantTotal;
		$result[$i]{'devoluciones'}=$devoluciones;
		$cantTotal=0;
		$devoluciones=0;
		$mes=$row->{'mes'};

		$i++;

		$result[$i]{'mes'} = $mes;
		$cantTotal=$cantTotal + $row->{'cantidad'};
		$devoluciones=$devoluciones + $row->{'devoluciones'};
		if ($row->{'issuecode'} eq 'DO'){
			$result[$i]{'DO'}= $row->{'cantidad'};
			$result[$i]{'renovaciones'} = $row->{'renovaciones'};
		}
		elsif($row->{'issuecode'} eq 'ES'){$result[$i]{'ES'}=$row->{'cantidad'};}
		elsif($row->{'issuecode'} eq 'FO'){$result[$i]{'FO'}=$row->{'cantidad'};}
		else{$result[$i]{'SA'}= $row->{'cantidad'};}
	}
}

$result[$i]{'cantTotal'}=$cantTotal;
$result[$i]{'devoluciones'}=$devoluciones;
push(@loop,@result);


#********

$template->param( 
			resultsloop      => \@loop,
			unidades         => $CGIbranch,
			year	  	 => $year,
			branch           => $branch,
		);

output_html_with_http_headers $input, $cookie, $template->output;
