#!/usr/bin/perl

# $Id: actualizarPersonas.pl,v 1.0 2005/05/3 10:44:45 tipaul Exp $

#script para actualizar los datos de los posibles usuarios
#written 3/05/2005  by einar@info.unlp.edu.ar

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Persons_Members;

my $input = new CGI;
my $flagsrequired;
$flagsrequired->{borrowers}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 1, $flagsrequired,"intranet");

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $msg='';

my $data=$obj->{'personNumbers'};

($obj->{'accion'} eq "habilitar")?($msg=addmembers(@$data)):($msg=delmembers(@$data));

print $input->header;
print $msg;
