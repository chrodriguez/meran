package UsrRefEstado;

use strict;

use base qw(Rose::DB::Object::LoaderGenerated::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'usr_ref_estados',

    columns => [
        id_estado   => { type => 'integer', not_null => 1 },
        descripcion => { type => 'varchar', default => '', length => 255, not_null => 1 },
    ],

    primary_key_columns => [ 'id_estado' ],
);

1;

