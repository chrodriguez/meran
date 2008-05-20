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
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 1, $flagsrequired,"intranet");

my $msg='';

my @data=split(",",$input->param('personNumbers'));;

if ($input->param('accion') eq "habilitar"){
	$msg=addmembers(@data);
}
else{
	$msg=delmembers (@data);
}


print $input->header;
print $msg;
