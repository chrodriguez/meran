package C4::Modelo::RepRegistroModificacion;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'rep_registro_modificacion',

    columns => [
        idModificacion => { type => 'serial', not_null => 1 },
        operacion      => { type => 'varchar', length => 15 },
        fecha          => { type => 'date' },
        responsable    => { type => 'varchar', length => 16, not_null => 1 },
        nota           => { type => 'varchar', length => 50 },
        numero         => { type => 'integer', length => 5 },
        tipo           => { type => 'varchar', length => 15 },
        timestamp      => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'idModificacion' ],


   relationships => [
    socio_responsable => {
            class       => 'C4::Modelo::UsrSocio',
            key_columns => { responsable => 'nro_socio' },
            type        => 'one to one',
    },
   ]
);


sub getIdModificacion{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->idModificacion));
}

sub getNumero{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->numero));
}

sub getNota{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->nota));
}


sub getTipo{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->tipo));
}

sub getOperacion{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->operacion));
}


sub getFecha{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->fecha));
}


1;

