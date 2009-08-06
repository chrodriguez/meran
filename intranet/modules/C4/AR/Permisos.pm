package C4::AR::Permisos;

use strict;
require Exporter;
use C4::Context;
use CGI::Session;
use C4::Modelo::PermCatalogo;
use C4::Modelo::PermCatalogo::Manager;
use C4::Modelo::PermGeneral;
use C4::Modelo::PermGeneral::Manager;
use C4::Modelo::PermCirculacion;
use C4::Modelo::PermCirculacion::Manager;
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


# FUNCIONES COMUNES A TODOS LOS PERMISOS

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


# FUNCIONES DE PERMISOS PARA CATALOGO

sub actualizarPermisosCatalogo{

    my ($nro_socio,$id_ui,$tipo_documento,$permisos_array)= @_;

    my @filtros;

    my $hash_permisos = C4::AR::Permisos::procesarPermisosCatalogo($permisos_array); #DEBE HACER UNA HASH TENIENDO COMO CLAVE EL NOMBRE

    my $permisos = C4::Modelo::PermCatalogo->new(nro_socio => $nro_socio, ui => $id_ui, tipo_documento => $tipo_documento);
    eval{
        $permisos->load();
        $hash_permisos->{'tipo_documento'} = $tipo_documento;
        $hash_permisos->{'nro_socio'} = $nro_socio;
        $id_ui = $id_ui || 'ALL';
        $hash_permisos->{'id_ui'} = $id_ui;

        $permisos->agregar($hash_permisos);

        $permisos = C4::AR::Permisos::parsearPermisos($permisos);

        return ($permisos);
    };
    return (0);

}

sub obtenerPermisosCatalogo{

    my ($nro_socio,$id_ui,$tipo_documento,$perfil)= @_;
    my $permisos;
    my @filtros;
    my $newUpdate;
    push (@filtros, (nro_socio => {eq => $nro_socio}));
    $id_ui = $id_ui || 'ANY';
    push (@filtros, (ui => {eq => $id_ui}));
    push (@filtros, (tipo_documento => {eq => $tipo_documento}));

    $permisos = C4::Modelo::PermCatalogo::Manager::get_perm_catalogo( query => \@filtros,
                                                                        );
    if ($permisos->[0]){
        $permisos = C4::AR::Permisos::parsearPermisos($permisos->[0]);
        $newUpdate = 0;
    }else{
        if ($perfil){
            $permisos = C4::AR::Permisos::armarPerfilCatalogo($perfil);
            $permisos = C4::AR::Permisos::parsearPermisos($permisos);
        }else{
            $permisos = 0;
        }
        $newUpdate = 1;
    }
    return ($permisos,$newUpdate);
}

sub nuevoPermisoCatalogo{

    my ($nro_socio,$id_ui,$tipo_documento,$permisos_array)= @_;

    my @filtros;

    my $hash_permisos = C4::AR::Permisos::procesarPermisos($permisos_array); #DEBE HACER UNA HASH TENIENDO COMO CLAVE EL NOMBRE

    my $permisos = C4::Modelo::PermCatalogo->new();
    $hash_permisos->{'tipo_documento'} = $tipo_documento;
    $hash_permisos->{'nro_socio'} = $nro_socio;
    $hash_permisos->{'id_ui'} = $id_ui || 'ALL';

    $permisos->agregar($hash_permisos);

    $permisos = C4::AR::Permisos::parsearPermisos($permisos);

    return ($permisos);
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
        return $permisos_catalogo_array_ref;
    }else{
        return 0;
    }
}

sub armarPerfilCatalogo{

    my ($perfil) = @_;

    use C4::Modelo::PermCatalogo;
    my $permisoTemp = C4::Modelo::PermCatalogo->new();

    if ($perfil eq 'SL'){
        $permisoTemp->setAll(TODOS);
    }
    elsif ($perfil eq 'L'){
        $permisoTemp->setAll(ALTA | MODIFICACION | CONSULTA);

    }
    return $permisoTemp;

}


# FUNCIONES DE PERMISOS GENERALES

sub actualizarPermisosGeneral{

    my ($nro_socio,$id_ui,$tipo_documento,$permisos_array)= @_;

    my @filtros;

    my $hash_permisos = C4::AR::Permisos::procesarPermisos($permisos_array); #DEBE HACER UNA HASH TENIENDO COMO CLAVE EL NOMBRE

    my $permisos = C4::Modelo::PermGeneral->new(nro_socio => $nro_socio, ui => $id_ui, tipo_documento => $tipo_documento);
    eval{
        $permisos->load();
        $hash_permisos->{'tipo_documento'} = $tipo_documento;
        $hash_permisos->{'nro_socio'} = $nro_socio;
        $id_ui = $id_ui || 'ALL';
        $hash_permisos->{'id_ui'} = $id_ui;

        $permisos->agregar($hash_permisos);

        $permisos = C4::AR::Permisos::parsearPermisos($permisos);

        return ($permisos);
    };
    return (0);

}

sub obtenerPermisosGenerales{

    my ($nro_socio,$id_ui,$tipo_documento,$perfil)= @_;
    my $permisos;
    my @filtros;
    my $newUpdate;
    push (@filtros, (nro_socio => {eq => $nro_socio}));
    $id_ui = $id_ui || 'ANY';
    push (@filtros, (ui => {eq => $id_ui}));
    push (@filtros, (tipo_documento => {eq => $tipo_documento}));

    $permisos = C4::Modelo::PermGeneral::Manager::get_perm_general( query => \@filtros,
                                                                        );
    if ($permisos->[0]){
        $permisos = C4::AR::Permisos::parsearPermisos($permisos->[0]);
        $newUpdate = 0;
    }else{
        if ($perfil){
            $permisos = C4::AR::Permisos::armarPerfilGeneral($perfil);
            $permisos = C4::AR::Permisos::parsearPermisos($permisos);
        }else{
            $permisos = 0;
        }
        $newUpdate = 1;
    }
    return ($permisos,$newUpdate);
}

sub nuevoPermisoGeneral{

    my ($nro_socio,$id_ui,$tipo_documento,$permisos_array)= @_;

    my @filtros;

    my $hash_permisos = C4::AR::Permisos::procesarPermisos($permisos_array); #DEBE HACER UNA HASH TENIENDO COMO CLAVE EL NOMBRE

    my $permisos = C4::Modelo::PermGeneral->new();
    $hash_permisos->{'tipo_documento'} = $tipo_documento;
    $hash_permisos->{'nro_socio'} = $nro_socio;
    $hash_permisos->{'id_ui'} = $id_ui || 'ALL';

    $permisos->agregar($hash_permisos);

    $permisos = C4::AR::Permisos::parsearPermisos($permisos);

    return ($permisos);
}


sub get_permisos_general {
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


    my $permisos_general_array_ref = C4::Modelo::PermGeneral::Manager::get_perm_general( 
                                                                                            query => \@filtros,
                                                                                          );
    if(scalar(@$permisos_general_array_ref) > 0){
        return $permisos_general_array_ref;
    }else{
        return 0;
    }
}

sub armarPerfilGeneral{

    my ($perfil) = @_;

    use C4::Modelo::PermGeneral;
    my $permisoTemp = C4::Modelo::PermGeneral->new();

    if ($perfil eq 'SL'){
        $permisoTemp->setAll(TODOS);
    }
    elsif ($perfil eq 'L'){
        $permisoTemp->setAll(ALTA | MODIFICACION | CONSULTA);

    }
    return $permisoTemp;

}




# FUNCIONES DE PERMISOS PARA CIRCULACION

sub actualizarPermisosCirculacion{

    my ($nro_socio,$id_ui,$tipo_documento,$permisos_array)= @_;

    my @filtros;

    my $hash_permisos = C4::AR::Permisos::procesarPermisos($permisos_array); #DEBE HACER UNA HASH TENIENDO COMO CLAVE EL NOMBRE

    my $permisos = C4::Modelo::PermCirculacion->new(nro_socio => $nro_socio, ui => $id_ui, tipo_documento => $tipo_documento);
    eval{
        $permisos->load();
        $hash_permisos->{'tipo_documento'} = $tipo_documento;
        $hash_permisos->{'nro_socio'} = $nro_socio;
        $id_ui = $id_ui || 'ALL';
        $hash_permisos->{'id_ui'} = $id_ui;

        $permisos->agregar($hash_permisos);

        $permisos = C4::AR::Permisos::parsearPermisos($permisos);

        return ($permisos);
    };
    return (0);

}

sub obtenerPermisosCirculacion{

    my ($nro_socio,$id_ui,$tipo_documento,$perfil)= @_;
    my $permisos;
    my @filtros;
    my $newUpdate;
    push (@filtros, (nro_socio => {eq => $nro_socio}));
    $id_ui = $id_ui || 'ANY';
    push (@filtros, (ui => {eq => $id_ui}));
    push (@filtros, (tipo_documento => {eq => $tipo_documento}));

    $permisos = C4::Modelo::PermCirculacion::Manager::get_perm_circulacion( query => \@filtros,
                                                                        );
    if ($permisos->[0]){
        $permisos = C4::AR::Permisos::parsearPermisos($permisos->[0]);
        $newUpdate = 0;
    }else{
        if ($perfil){
            $permisos = C4::AR::Permisos::armarPerfilCirculacion($perfil);
            $permisos = C4::AR::Permisos::parsearPermisos($permisos);
        }else{
            $permisos = 0;
        }
        $newUpdate = 1;
    }
    return ($permisos,$newUpdate);
}

sub nuevoPermisoCirculacion{

    my ($nro_socio,$id_ui,$tipo_documento,$permisos_array)= @_;

    my @filtros;

    my $hash_permisos = C4::AR::Permisos::procesarPermisos($permisos_array); #DEBE HACER UNA HASH TENIENDO COMO CLAVE EL NOMBRE

    my $permisos = C4::Modelo::PermCirculacion->new();
    $hash_permisos->{'tipo_documento'} = $tipo_documento;
    $hash_permisos->{'nro_socio'} = $nro_socio;
    $hash_permisos->{'id_ui'} = $id_ui || 'ALL';

    $permisos->agregar($hash_permisos);

    $permisos = C4::AR::Permisos::parsearPermisos($permisos);

    return ($permisos);
}


sub get_permisos_circulacion {
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


    my $permisos_circulacion_array_ref = C4::Modelo::PermCirculacion::Manager::get_perm_circulacion( 
                                                                                            query => \@filtros,
                                                                                          );
    if(scalar(@$permisos_circulacion_array_ref) > 0){
        return $permisos_circulacion_array_ref;
    }else{
        return 0;
    }
}

sub armarPerfilCirculacion{

    my ($perfil) = @_;

    use C4::Modelo::PermCirculacion;
    my $permisoTemp = C4::Modelo::PermCirculacion->new();

    if ($perfil eq 'SL'){
        $permisoTemp->setAll(TODOS);
    }
    elsif ($perfil eq 'L'){
        $permisoTemp->setAll(ALTA | MODIFICACION | CONSULTA);

    }
    return $permisoTemp;

}

1;
