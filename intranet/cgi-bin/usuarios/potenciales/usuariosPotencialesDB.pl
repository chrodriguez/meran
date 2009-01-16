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
my $authnotrequired= 0;
$flagsrequired->{borrowers}=1;
my ($loggedinuser, $session, $flags) = checkauth($input, $authnotrequired, $flagsrequired, "intranet");

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));

my $id_personas_array_ref= $obj->{'id_personas'};
my $Messages_arrayref;


if($obj->{'tipoAccion'} eq "HABILITAR_PERSON"){

    my %hash_data;
    $hash_data{'categoria_socio_id'}=$obj->{'categoria_socio_id'};
	($Messages_arrayref)= &C4::AR::Usuarios::habilitarPersona($id_personas_array_ref);

	my $infoOperacionJSON=to_json $Messages_arrayref;

	print $input->header;
	print $infoOperacionJSON;

}elsif($obj->{'tipoAccion'} eq "DESHABILITAR_PERSON"){

	($Messages_arrayref)= &C4::AR::Usuarios::deshabilitarPersona($id_personas_array_ref);

	my $infoOperacionJSON=to_json $Messages_arrayref;
	
	print $input->header;
	print $infoOperacionJSON;

}

