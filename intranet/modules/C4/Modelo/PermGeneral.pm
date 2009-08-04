package C4::Modelo::PermGeneral;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'perm_general',

    columns => [
        nro_socio       => { type => 'varchar', length => 16, not_null => },
        ui              => { type => 'varchar', length => 4, not_null => 1 },
        tipo_documento  => { type => 'varchar', length => 4, not_null => 1 }, 
        preferencias    => { type => 'varbinary', length => 8, not_null => 1 },
    ],

    primary_key_columns => [ 'nro_socio','ui','tipo_documento' ],

);

sub agregar{

    my ($self) = shift;
    my ($permisos_hash) = @_;

    $self->setNro_socio($permisos_hash->{'nro_socio'});
    $self->setUI($permisos_hash->{'id_ui'});
    $self->setTipo_documento($permisos_hash->{'tipo_documento'});

    $self->save();
}

sub setAll{

    my ($self) = shift;
    my ($permisosByte) = @_;

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


1;

