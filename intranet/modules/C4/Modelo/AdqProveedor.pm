package C4::Modelo::Proveedor;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'proveedor',

    columns => [
        id   => { type => 'integer', not_null => 1 },
        nombre  => { type => 'varchar', length => 255},
        direccion    => { type => 'varchar', length =>  255 },
        telefono => { type => 'varchar', length => 255 },
        email  => { type => 'varchar', length => 255},
        activo => { type => 'integer', default => 0, not_null => 1},
        item        => { type => 'integer', not_null => 1 },
    ],
    
    relationships =>
    [
      item_ref => 
      {
        class       => 'C4::Modelo::RefItem',
        key_columns => { item => 'id' },
        type        => 'many to many',
      },
    
    primary_key_columns => [ 'id' ],

);

sub desactivar{
    my ($self) = shift;
    $self->setActivo(0);
    $self->save();
}

1;



