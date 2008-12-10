package EstructuraCatalogacion;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'estructura_catalogacion',

    columns => [
        id                  => { type => 'integer', not_null => 1 },
        campo               => { type => 'character', default => '', length => 3, not_null => 1 },
        subcampo            => { type => 'character', default => '', length => 1, not_null => 1 },
        itemtype            => { type => 'varchar', default => '', length => 4, not_null => 1 },
        liblibrarian        => { type => 'varchar', default => '', length => 255, not_null => 1 },
        tipo                => { type => 'character', default => '', length => 5, not_null => 1 },
        referencia          => { type => 'integer', default => '0', not_null => 1 },
        nivel               => { type => 'integer', default => '', not_null => 1 },
        obligatorio         => { type => 'integer', default => '0', not_null => 1 },
        intranet_habilitado => { type => 'integer', default => '0' },
        visible             => { type => 'integer', default => 1, not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],
);

1;

