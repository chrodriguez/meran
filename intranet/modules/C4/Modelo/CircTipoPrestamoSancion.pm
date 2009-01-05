package C4::Modelo::CircTipoPrestamoSancion;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'circ_tipo_prestamo_sancion',

    columns => [
        sanctiontypecode => { type => 'integer', not_null => 1 },
        issuecode        => { type => 'character', length => 2, not_null => 1 },
    ],

    primary_key_columns => [ 'sanctiontypecode', 'issuecode' ],
);

1;

