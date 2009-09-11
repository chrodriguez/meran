#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;
# use C4::Database;
# use C4::Auth;
# use C4::Context;
use CGI;
use C4::AR::Usuarios;
use C4::AR::Permisos;
use C4::AR::Permisos 'TODOS';
use C4::AR::Permisos 'BAJA';
use C4::AR::Permisos 'ALTA';
use C4::AR::Permisos 'CONSULTA';
use C4::AR::Permisos 'MODIFICACION';


my $session = CGI::Session->new();

=item
INSERT INTO `perm_catalogo` (`ui`, `tipo_documento`, `datos_nivel1`, `datos_nivel2`, `datos_nivel3`, `estantes_virtuales`, `estructura_catalogacion_n1`, `estructura_catalogacion_n2`, `estructura_catalogacion_n3`, `tablas_de_refencia`, `control_de_autoridades`, `nro_socio`) VALUES
('CD', 'LIB', '00000', '00000', '00010000', '00000', '00000', '00000', '00000', '00000', '00000', 'TEST');
=cut

my $data_hash;
my $nro_socio= 'TEST';
my $id_ui= 'DEO';
my $tipo_documento= 'LIB';

my $flagsrequired;
my $socio = &C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);

# $flagsrequired->{'ui'}= $self->getId_ui;
# $flagsrequired->{'nro_socio'}= $self->getNro_socio;

$flagsrequired->{'tipo_documento'}= 'LIB';
$flagsrequired->{'entorno'}= 'datos_nivel1';

$data_hash->{'nro_socio'}= $nro_socio;
$data_hash->{'id_ui'}= $id_ui;
$data_hash->{'tipo_documento'}= $tipo_documento;
$data_hash->{'datos_nivel1'}= TODOS;
$data_hash->{'datos_nivel2'}= TODOS;
$data_hash->{'datos_nivel3'}= TODOS;
$data_hash->{'estantes_virtuales'}= TODOS;
$data_hash->{'estructura_catalogacion_n1'}= TODOS;
$data_hash->{'estructura_catalogacion_n2'}= TODOS;
$data_hash->{'estructura_catalogacion_n3'}= TODOS;
$data_hash->{'tablas_de_refencia'}= TODOS;
$data_hash->{'control_de_autoridades'}= TODOS;


$data_hash->{'datos_nivel1'}= ALTA;
my $permisos = C4::Modelo::PermCatalogo->new(nro_socio => $nro_socio, ui => $id_ui, tipo_documento => $tipo_documento);
$permisos->load();
$permisos->modificar($data_hash);
C4::AR::Debug::debug("=============================================================================");
C4::AR::Debug::debug("test_permisos => test 1");
$flagsrequired->{'accion'}= 'ALTA';
$flagsrequired->{'entorno'}= 'datos_nivel1';
C4::AR::Debug::debug("test_permisos => permisos requeridos: ".$flagsrequired->{'accion'});
C4::AR::Debug::debug("test_permisos => entorno: ".$flagsrequired->{'entorno'});
# resultado esperado: el usuario tiene permisos
if($socio->tienePermisos($flagsrequired)){
    C4::AR::Debug::debug("test_permisos => test 1 - PASSED");
}else{
    C4::AR::Debug::debug("test_permisos => test 1 - FAILED");
}


$data_hash->{'datos_nivel1'}= ALTA;
$flagsrequired->{'tipo_documento'}= 'LIB';
$permisos->agregar($data_hash);
C4::AR::Debug::debug("=============================================================================");
C4::AR::Debug::debug("test_permisos => test 2");
$flagsrequired->{'accion'}= 'CONSULTA';
$flagsrequired->{'entorno'}= 'datos_nivel1';
C4::AR::Debug::debug("test_permisos => permisos requeridos: ".$flagsrequired->{'accion'});
C4::AR::Debug::debug("test_permisos => entorno: ".$flagsrequired->{'entorno'});
# resultado esperado: el usuario tiene permisos
if($socio->tienePermisos($flagsrequired)){
    C4::AR::Debug::debug("test_permisos => test 2 - PASSED");
}else{
    C4::AR::Debug::debug("test_permisos => test 2 - FAILED");
}

C4::AR::Debug::debug("=============================================================================");
C4::AR::Debug::debug("test_permisos => test 3");
$flagsrequired->{'accion'}= 'MODIFICACION';
$flagsrequired->{'entorno'}= 'datos_nivel1';
$flagsrequired->{'tipo_documento'}= 'LIB';
C4::AR::Debug::debug("test_permisos => permisos requeridos: ".$flagsrequired->{'accion'});
C4::AR::Debug::debug("test_permisos => entorno: ".$flagsrequired->{'entorno'});
# resultado esperado: el usuario tiene permisos
if($socio->tienePermisos($flagsrequired)){
    C4::AR::Debug::debug("test_permisos => test 3 - PASSED");
}else{
    C4::AR::Debug::debug("test_permisos => test 3 - FAILED");
}


C4::AR::Debug::debug("test_permisos => se modifica el permiso del usuario a BAJA");
$data_hash->{'datos_nivel1'}= BAJA;
$permisos = C4::Modelo::PermCatalogo->new(nro_socio => $nro_socio, ui => $id_ui, tipo_documento => $tipo_documento);
$permisos->load();
$permisos->modificar($data_hash);
C4::AR::Debug::debug("=============================================================================");
C4::AR::Debug::debug("test_permisos => test 4");
$flagsrequired->{'accion'}= 'BAJA';
$flagsrequired->{'entorno'}= 'datos_nivel1';
$flagsrequired->{'tipo_documento'}= 'LIB';
$flagsrequired->{'ui'}= 'DEO';
C4::AR::Debug::debug("test_permisos => permisos requeridos: ".$flagsrequired->{'accion'});
C4::AR::Debug::debug("test_permisos => entorno: ".$flagsrequired->{'entorno'});
# resultado esperado: el usuario tiene permisos
if($socio->tienePermisos($flagsrequired)){
    C4::AR::Debug::debug("test_permisos => test 4 - PASSED");
}else{
    C4::AR::Debug::debug("test_permisos => test 4 - FAILED");
}

C4::AR::Debug::debug("=============================================================================");
C4::AR::Debug::debug("test_permisos => test 5");
$flagsrequired->{'accion'}= 'ALTA';
$flagsrequired->{'entorno'}= 'datos_nivel1';
$flagsrequired->{'tipo_documento'}= 'LIB';
C4::AR::Debug::debug("test_permisos => permisos requeridos: ".$flagsrequired->{'accion'});
C4::AR::Debug::debug("test_permisos => entorno: ".$flagsrequired->{'entorno'});
# resultado esperado: el usuario tiene permisos
if($socio->tienePermisos($flagsrequired)){
    C4::AR::Debug::debug("test_permisos => test 5 - PASSED");
}else{
    C4::AR::Debug::debug("test_permisos => test 5 - FAILED");
}


C4::Auth::print_header($session);