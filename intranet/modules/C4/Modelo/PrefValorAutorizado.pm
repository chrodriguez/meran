package C4::Modelo::PrefValorAutorizado;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'pref_valor_autorizado',

    columns => [
        id               => { type => 'serial', not_null => 1 },
        category         => { type => 'character', default => '', length => 10, not_null => 1 },
        authorised_value => { type => 'character', default => '', length => 80, not_null => 1 },
        lib              => { type => 'character', length => 80 },
    ],

    primary_key_columns => [ 'id' ],
);

1;

