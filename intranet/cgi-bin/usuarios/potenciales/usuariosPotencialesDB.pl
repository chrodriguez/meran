#!/usr/bin/perl

# $Id: actualizarPersonas.pl,v 1.0 2005/05/3 10:44:45 tipaul Exp $

#script para actualizar los datos de los posibles usuarios
#written 3/05/2005  by einar@info.unlp.edu.ar

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Persons_Members;
use JSON;

my $input = new CGI;
my $flagsrequired;
$flagsrequired->{borrowers}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 1, $flagsrequired,"intranet");

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));

my $personNumbers= $obj->{'personNumbers'};
# my ($error, $codMsg, $message);
my $Messages_arrayref;


if($obj->{'tipoAccion'} eq "HABILITAR_PERSON"){

	($Messages_arrayref)= &C4::AR::Usuarios::t_addPersons($personNumbers);

	my $infoOperacionJSON=to_json $Messages_arrayref;

	print $input->header;
	print $infoOperacionJSON;

}elsif($obj->{'tipoAccion'} eq "DESHABILITAR_PERSON"){

	($Messages_arrayref)= &C4::AR::Usuarios::t_delPersons($personNumbers);

	my $infoOperacionJSON=to_json $Messages_arrayref;
	
	print $input->header;
	print $infoOperacionJSON;

}

