package C4::Modelo::RefTipoOperacion;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'ref_tipo_operacion',

    columns => [
        id => { type => 'serial', not_null => 1 },
        descripcion => { type => 'varchar', length => 40, not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],
);


1;

