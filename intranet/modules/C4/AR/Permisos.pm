package C4::AR::Permisos;

use strict;
require Exporter;
use C4::Context;
use CGI::Session;
use C4::Modelo::PermCatalogo;
use C4::Modelo::PermCatalogo::Manager;
use CGI;
use Encode;
use JSON;
use POSIX qw(ceil floor); #para redondear cuando divido un numero

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(
    &obtenerPermisos
    

);

sub checkTipoPermiso{

    my ($entorno_byte,$tipo_permiso)= @_;
    my $flag;
    my $result;
    if($tipo_permiso eq 'TODOS'){
        $flag= '00010000';
        $result = substr($entorno_byte,3,1);
    }elsif($tipo_permiso eq 'ALTA'){
        $flag= '00001000';
        $result = substr($entorno_byte,4,1);
    }elsif($tipo_permiso eq 'BAJA'){
        $flag= '00000100';
        $result = substr($entorno_byte,5,1);
    }elsif($tipo_permiso eq 'MODIFICACION'){
        $flag= '00000010';
        $result = substr($entorno_byte,6,1);
    }elsif($tipo_permiso eq 'CONSULTA'){
        $flag= '00000001';
        $result = substr($entorno_byte,7,1);
    }
    return ($result);
}

sub parsearPermisos{

    my ($permiso)= @_;

    my @tipo_permiso = ('ALTA','CONSULTA','MODIFICACION','BAJA','TODOS'); 
    my $entornos = $permiso->meta->columns;
    my %hash_permisos = {};
    foreach my $entorno (@$entornos){
        foreach my $flag (@tipo_permiso){
            $hash_permisos{$entorno}{$flag} = C4::AR::Permisos::checkTipoPermiso($permiso->{$entorno},$flag);
#             $permiso->{$entorno}->{$flag} = C4::AR::Permisos::checkTipoPermiso($permiso->{$entorno},$flag);
        }
    }
    return (\%hash_permisos);

}

sub obtenerPermisos{

    my ($nro_socio,$id_ui,$tipo_documento)= @_;

    my @filtros;

    push (@filtros, (nro_socio => {eq => $nro_socio}));
    push (@filtros, (ui => {eq => $id_ui}));
    push (@filtros, (tipo_documento => {eq => $tipo_documento}));

    my $permisos = C4::Modelo::PermCatalogo::Manager::get_perm_catalogo( query => \@filtros,
                                                                        );
    if ($permisos->[0]){
        $permisos = C4::AR::Permisos::parsearPermisos($permisos->[0]);
    }else{
        $permisos = 0;
    }

    return ($permisos);

}


sub armarByte{

    my ($permiso)= @_;

    my $byte = '000';

    $byte.= $permiso->{'todos'}.$permiso->{'alta'}.$permiso->{'baja'}.$permiso->{'modif'}.$permiso->{'consulta'};

    return ($byte);
}

sub procesarPermisos{

    my ($permisos_array)= @_;

    my %hash_permisos;

    foreach my $permiso (@$permisos_array){

        $hash_permisos{$permiso->{'nombre'}} = C4::AR::Permisos::armarByte($permiso);
    }

    return (\%hash_permisos);
}

sub actualizarPermisos{

    my ($nro_socio,$id_ui,$tipo_documento,$permisos_array)= @_;

    my @filtros;

    my $hash_permisos = C4::AR::Permisos::procesarPermisos($permisos_array); #DEBE HACER UNA HASH TENIENDO COMO CLAVE EL NOMBRE

    my $permisos = C4::Modelo::PermCatalogo->new(nro_socio => $nro_socio, ui => $id_ui, tipo_documento => $tipo_documento);
       $permisos->load();
    $hash_permisos->{'tipo_documento'} = $tipo_documento;
    $hash_permisos->{'nro_socio'} = $nro_socio;
    $hash_permisos->{'id_ui'} = $id_ui;

    $permisos->agregar($hash_permisos);

    $permisos = C4::AR::Permisos::parsearPermisos($permisos);

    return ($permisos);

}


sub permisos_str_to_bin {

    my ($permisos) = @_;
    my $flag;

    $flag= '00000000';

    if($permisos eq 'TODOS'){
        $flag= '00010000';
    }elsif($permisos eq 'ALTA'){
        $flag= '00001000';
    }elsif($permisos eq 'BAJA'){
        $flag= '00000100';
    }elsif($permisos eq 'MODIFICACION'){
        $flag= '00000010';
    }elsif($permisos eq 'CONSULTA'){
        $flag= '00000001';
    }

    return $flag;
}

1;
