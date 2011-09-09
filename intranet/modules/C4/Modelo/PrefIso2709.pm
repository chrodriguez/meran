package C4::Modelo::PrefIso2709;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'pref_iso2709',

    columns => [
        id               => { type => 'serial', not_null => 1 },
        campoIso         => { type => 'integer', default => '0', not_null => 1 },
        subCampoIso      => { type => 'character', length => 1 },
        descripcion      => { type => 'text', length => 65535 },
        kohaTabla        => { type => 'varchar', overflow => 'truncate', length => 100 },
        kohaCampo        => { type => 'varchar', overflow => 'truncate', length => 100 },
        ui               => { type => 'text', length => 65535, not_null => 1 },
        marc_koha_field  => { type => 'text', length => 65535, not_null => 1 },
        marc_table_field => { type => 'text', length => 65535, not_null => 1 },
        orden            => { type => 'integer' },
        separador        => { type => 'varchar', overflow => 'truncate', length => 5 },
        interfazWeb      => { type => 'varchar', overflow => 'truncate', length => 5 },
        tipo             => { type => 'varchar', overflow => 'truncate', default => '', length => 10, not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],
);

1;

