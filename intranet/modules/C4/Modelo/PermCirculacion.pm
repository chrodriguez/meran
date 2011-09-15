package C4::Modelo::PermCirculacion;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'perm_circulacion',

    columns => [
        nro_socio => { type => 'varchar', overflow => 'truncate', length => 16, not_null => },
        ui  => { type => 'varchar', overflow => 'truncate', length => 4, not_null => 1 },
        tipo_documento => { type => 'varchar', overflow => 'truncate', length => 4, not_null => 1 }, 
        prestamos => { type => 'varchar', overflow => 'truncate', length => 8, not_null => 1 },
        circ_opac => { type => 'varchar', overflow => 'truncate', length => 8, not_null => 1 },

    ],

    primary_key_columns => [ 'nro_socio','ui','tipo_documento' ],

);

sub agregar{

    my ($self) = shift;
    my ($permisos_hash) = @_;

    $self->setNro_socio($permisos_hash->{'nro_socio'});
    $self->setUI($permisos_hash->{'id_ui'});
    $self->setTipo_documento($permisos_hash->{'tipo_documento'});
    $self->setPrestamos($permisos_hash->{'prestamos'});
    $self->setCirc_opac($permisos_hash->{'circ_opac'});
    $self->save();
}

sub setAll{

    my ($self) = shift;
    my ($permisosByte) = @_;
    
    $self->setPrestamos($permisosByte);
    $self->setCirc_opac($permisosByte);
}

sub modificar{

    my ($self) = shift;
    my ($permisos_hash) = @_;

    $self->save();
}

sub getNro_socio{

    my ($self) = shift;

    return ($self->nro_socio);
}

sub setNro_socio{

    my ($self) = shift;
    my ($nro_socio) = @_;
    
    $self->nro_socio($nro_socio);
}

sub getCirc_opac{
    my ($self) = shift;
    return ($self->circ_opac);
}

sub setCirc_opac{
    my ($self) = shift;
    my ($permisos) = @_;
    $self->circ_opac($permisos);
}

sub getUI{

    my ($self) = shift;
    
    return ($self->ui);
}

sub setUI{

    my ($self) = shift;
    my ($ui) = @_;
    
    $self->ui($ui);
}

sub getTipo_documento{

    my ($self) = shift;
    
    return ($self->tipo_documento);
}

sub setTipo_documento{

    my ($self) = shift;
    my ($tipo_documento) = @_;
    
    $self->tipo_documento($tipo_documento);
}

sub getPrestamos{

    my ($self) = shift;
    
    return ($self->prestamos);
}

sub setPrestamos{

    my ($self) = shift;
    my ($prestamos) = @_;
    
    $self->prestamos($prestamos);
}


sub convertirEnEstudiante{

    my ($self) = shift;
    my ($socio) = @_;
    $self->setAll(C4::AR::Permisos::getConsultaByte());
    $self->setNro_socio($socio->getNro_socio);
    $self->setUI($socio->getId_ui);
    $self->setTipo_documento('ALL');
    $self->save();

}

sub convertirEnLibrarian{

    my ($self) = shift;
    my ($socio) = @_;

    $self->setAll(C4::AR::Permisos::getConsultaByte() | C4::AR::Permisos::getAltaByte() | C4::AR::Permisos::getModificacionByte() );
    $self->setNro_socio($socio->getNro_socio);
    $self->setUI($socio->getId_ui);
    $self->setTipo_documento('ALL');

    $self->save();

}

sub convertirEnSuperLibrarian{

    my ($self) = shift;
    my ($socio) = @_;

    $self->setAll(C4::AR::Permisos::getTodosByte());
    $self->setNro_socio($socio->getNro_socio);
    $self->setUI($socio->getId_ui);
    $self->setTipo_documento('ALL');

    $self->save();

}

1;

