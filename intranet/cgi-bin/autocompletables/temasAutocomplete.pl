#!/usr/bin/perl

use strict;
require Exporter;# contains gettemplate
use CGI;
use C4::AR::Utilidades;

my $input = new CGI;
my $temaStr=$input->param('q');
my $campos=$input->param('campos');
my $separador=$input->param('separador');
my $textout="";


my @result=&obtenerTemas2($temaStr);
my @arrayCampos=split(",",$campos);
my $texto="";
foreach my $tema (@result){
	foreach my $valor(@arrayCampos){
		if($texto eq ""){
			$texto.=$tema->{$valor};
		}
		else{
			$texto.=$separador.$tema->{$valor};
		}
	}
# 	$textout.=$tema->{'nombre'}."|".$tema->{'id'}."\n";
	$textout.=$texto."|".$tema->{'id'}."\n";
	$texto="";
}

print "Content-type: text/html\n\n";
print $textout;
