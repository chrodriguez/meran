package C4::Modelo::CircTipoSancion;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'circ_tipo_sancion',

    columns => [
        sanctiontypecode => { type => 'serial', not_null => 1 },
        categorycode     => { type => 'character', default => '', length => 2, not_null => 1 },
        issuecode        => { type => 'character', default => '', length => 2, not_null => 1 },
    ],

    primary_key_columns => [ 'sanctiontypecode' ],

    unique_key => [ 'categorycode', 'issuecode' ],
);

1;

