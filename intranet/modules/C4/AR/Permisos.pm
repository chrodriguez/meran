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
use constant {
        TODOS           => '00010000',
        ALTA            => '00001000',
        BAJA            => '00000100',
        MODIFICACION    => '00000010',
        CONSULTA        => '00000001'
};

use vars qw(@EXPORT @ISA @EXPORT_OK);
@ISA=qw(Exporter);
@EXPORT=qw(
    &obtenerPermisos
);

our @EXPORT_OK= ('TODOS', 'ALTA', 'BAJA', 'MODIFICACION', 'CONSULTA');

sub checkTipoPermiso{

    my ($entorno_byte,$tipo_permiso)= @_;
    my $flag;
    my $result;
    if($tipo_permiso eq 'TODOS'){
        $flag= TODOS;
        $result = substr($entorno_byte,3,1);
    }elsif($tipo_permiso eq 'ALTA'){
        $flag= ALTA;
        $result = substr($entorno_byte,4,1);
    }elsif($tipo_permiso eq 'BAJA'){
        $flag= BAJA;
        $result = substr($entorno_byte,5,1);
    }elsif($tipo_permiso eq 'MODIFICACION'){
        $flag= MODIFICACION;
        $result = substr($entorno_byte,6,1);
    }elsif($tipo_permiso eq 'CONSULTA'){
        $flag= CONSULTA;
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
        }
    }
    return (\%hash_permisos);

}

sub obtenerPermisos{

    my ($nro_socio,$id_ui,$tipo_documento)= @_;

    my @filtros;

    push (@filtros, (nro_socio => {eq => $nro_socio}));
    $id_ui = $id_ui || 'ANY';
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

    $id_ui = $id_ui || 'ANY';
    $hash_permisos->{'id_ui'} = $id_ui;

    $permisos->agregar($hash_permisos);

    $permisos = C4::AR::Permisos::parsearPermisos($permisos);

    return ($permisos);

}

sub nuevoPermiso{

    my ($nro_socio,$id_ui,$tipo_documento,$permisos_array)= @_;

    my @filtros;

    my $hash_permisos = C4::AR::Permisos::procesarPermisos($permisos_array); #DEBE HACER UNA HASH TENIENDO COMO CLAVE EL NOMBRE

    my $permisos = C4::Modelo::PermCatalogo->new();
    $hash_permisos->{'tipo_documento'} = $tipo_documento;
    $hash_permisos->{'nro_socio'} = $nro_socio;
    $hash_permisos->{'id_ui'} = $id_ui || 'ANY';

    $permisos->agregar($hash_permisos);

    $permisos = C4::AR::Permisos::parsearPermisos($permisos);

    return ($permisos);
}

sub permisos_str_to_bin {

    my ($permisos) = @_;
    my $flag;

    $flag= '00000000';

    if($permisos eq 'TODOS'){
        $flag= TODOS;
    }elsif($permisos eq 'ALTA'){
        $flag= ALTA;
    }elsif($permisos eq 'BAJA'){
        $flag= BAJA;
    }elsif($permisos eq 'MODIFICACION'){
        $flag= MODIFICACION;
    }elsif($permisos eq 'CONSULTA'){
        $flag= CONSULTA;
    }

    return $flag;
}


sub get_permisos_catalogo {
    my ($params) = @_;

    my @filtros;

    if($params->{'ui'} ne 'ANY'){
        #interesa la UI
        push (@filtros, ( 'ui' => { eq => $params->{'ui'} }) );
    }

    if($params->{'tipo_documento'} ne 'ANY'){
        #interesa el tipo_documento
        push (@filtros, ( 'tipo_documento' => { eq => $params->{'tipo_documento'} }) );
    }
    
    push (@filtros, ( 'nro_socio' => { eq => $params->{'nro_socio'} }) );


    my $permisos_catalogo_array_ref = C4::Modelo::PermCatalogo::Manager::get_perm_catalogo( 
                                                                                            query => \@filtros,
                                                                     );
    if(scalar(@$permisos_catalogo_array_ref) > 0){
        return $permisos_catalogo_array_ref->[0];
    }else{
        return 0;
    }
}

1;
