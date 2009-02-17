package C4::Modelo::CatNivel2;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_nivel2',

    columns => [
        id2                 => { type => 'serial', not_null => 1 },
        id1                 => { type => 'integer', not_null => 1 },
        tipo_documento      => { type => 'varchar', length => 4, not_null => 1 },
        nivel_bibliografico => { type => 'varchar', length => 2, not_null => 1 },
        soporte             => { type => 'varchar', length => 3, not_null => 1 },
        pais_publicacion    => { type => 'character', length => 2, not_null => 1 },
        lenguaje            => { type => 'character', length => 2, not_null => 1 },
        ciudad_publicacion  => { type => 'varchar', length => 20, not_null => 1 },
        anio_publicacion    => { type => 'varchar', length => 15 },
        timestamp           => { type => 'timestamp' },
    ],

    primary_key_columns => [ 'id2' ],

    relationships => [
        cat_nivel2_repetible => {
            class      => 'C4::Modelo::CatNivel2Repetible',
            column_map => { id2 => 'id2' },
            type       => 'one to many',
        },
    ],
);

sub getId2{
    my ($self) = shift;
    return ($self->id2);
}

sub setId2{
    my ($self) = shift;
    my ($id2) = @_;
    $self->id2($id2);
}

sub getId1{
    my ($self) = shift;
    return ($self->id1);
}

sub setId1{
    my ($self) = shift;
    my ($id1) = @_;
    $self->id1($id1);
}

sub setTipo_documento{
    my ($self) = shift;
    my ($tipo_documento) = @_;
    $self->tipo_documento($tipo_documento);
}

sub getTipo_documento{
    my ($self) = shift;
    return ($self->tipo_documento);
}

sub getTimestamp{
    my ($self) = shift;
    return ($self->timestamp);
}

sub setTimestamp{
    my ($self) = shift;
    my ($timestamp) = @_;
    $self->timestamp($timestamp);
}


1;

