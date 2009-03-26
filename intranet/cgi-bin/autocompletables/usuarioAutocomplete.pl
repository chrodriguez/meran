#!/usr/bin/perl

use strict;
require Exporter;# contains gettemplate
use CGI;
use C4::AR::Usuarios;

my $input = new CGI;
my $usuarioStr= $input->param('q');
my $textout="";

my ($cant, $usuarios_array_ref)= C4::AR::Usuarios::getSocioLike($usuarioStr);

foreach my $usuario (@$usuarios_array_ref){
	$textout.= $usuario->persona->getApellido.", ".$usuario->persona->getNombre."|".$usuario->getNro_socio."\n";
}

print $input->header;
print $textout;
