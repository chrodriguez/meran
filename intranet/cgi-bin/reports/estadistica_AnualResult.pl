#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Estadisticas;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                                                template_name => "reports/estadistica_AnualResult.tmpl",
                                                query => $input,
                                                type => "intranet",
                                                authnotrequired => 0,
                                                flagsrequired => {borrowers => 1},
                                                debug => 1,
			    });


# my $branch=(split("_",(split(";",$cookie))[0]))[1];


my $branch= $input->param('branch') || C4::AR::Preferencias->getValorPreferencia('defaultbranch');

my $obj= C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $year= $obj->{'year'};

my @resultsdata= C4::AR::Estadisticas::prestamosAnual($branch,$year);

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

$t_params->{'resultsloop'}= \@loop;
$t_params->{'branch'}= $branch;


C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
