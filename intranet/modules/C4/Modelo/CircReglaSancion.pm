package C4::Modelo::CircReglaSancion;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'circ_regla_sancion',

    columns => [
        sanctionrulecode => { type => 'serial', not_null => 1 },
        sanctiondays     => { type => 'integer', default => '0', not_null => 1 },
        delaydays        => { type => 'integer', default => '0', not_null => 1 },
    ],

    primary_key_columns => [ 'sanctionrulecode' ],
);

1;

