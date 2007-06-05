#!/usr/bin/perl

# $Id: actualizarPersonas.pl,v 1.0 2005/05/3 10:44:45 tipaul Exp $

#script para actualizar los datos de los posibles usuarios
#written 3/05/2005  by einar@info.unlp.edu.ar



use strict;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use C4::Koha;
use HTML::Template;
use C4::AR::Persons_Members;

my $input = new CGI;
my $flagsrequired;
$flagsrequired->{borrowers}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 1, $flagsrequired);
my @names=$input->param;
my @data;
for (my $i=0;$i<$input->param('cantidad');$i++){
  		push(@data,$names[$i]);#Aca se recuperan los valores de los parametros que voy a modificar, pero como no se cuales van a venir los tengo que recuperar asi.
		}
if ($input->param('accion') eq "habilitar"){
		addmembers(@data);}
else{
	delmembers (@data);}

my $referer = $input->referer();
print $input->redirect("/cgi-bin/koha/members-home2.pl");


