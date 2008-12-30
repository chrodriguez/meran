package C4::Modelo::EstructuraCatalogacion;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'estructura_catalogacion',

    columns => [
        id                  => { type => 'serial', not_null => 1 },
        campo               => { type => 'character', length => 3, not_null => 1 },
        subcampo            => { type => 'character', length => 1, not_null => 1 },
        itemtype            => { type => 'varchar', length => 4, not_null => 1 },
        liblibrarian        => { type => 'varchar', length => 255, not_null => 1 },
        tipo                => { type => 'character', length => 5, not_null => 1 },
        referencia          => { type => 'integer', default => '0', not_null => 1 },
        nivel               => { type => 'integer', not_null => 1 },
        obligatorio         => { type => 'integer', default => '0', not_null => 1 },
        intranet_habilitado => { type => 'integer', default => '0' },
        visible             => { type => 'integer', default => 1, not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],
);

1;

