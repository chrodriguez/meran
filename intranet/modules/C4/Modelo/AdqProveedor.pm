package C4::Modelo::AdqProveedor;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'proveedor',

    columns => [
        id_proveedor   => { type => 'integer', not_null => 1 },
        nombre  => { type => 'varchar', length => 255, not_null => 1},
        direccion    => { type => 'varchar', length =>  255 },
        telefono => { type => 'varchar', length => 255 },
        email  => { type => 'varchar', length => 255},
        activo => { type => 'integer', default => 0, not_null => 1},
    ],
    
    primary_key_columns => [ 'id_proveedor' ],

);

sub desactivar{
    my ($self) = shift;
    $self->setActivo(0);
    $self->save();
}

1;



