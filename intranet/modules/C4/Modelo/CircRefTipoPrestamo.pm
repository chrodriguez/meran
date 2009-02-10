package C4::Modelo::CircRefTipoPrestamo;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'circ_ref_tipo_prestamo',

    columns => [
        issuecode    => { type => 'character', length => 2, not_null => 1 },
        description  => { type => 'text', length => 65535 },
        notforloan   => { type => 'integer', default => '0', not_null => 1 },
        maxissues    => { type => 'integer', default => '0', not_null => 1 },
        daysissues   => { type => 'integer', default => '0', not_null => 1 },
        renew        => { type => 'integer', default => '0', not_null => 1 },
        renewdays    => { type => 'integer', default => '0', not_null => 1 },
        dayscanrenew => { type => 'integer', default => '0', not_null => 1 },
        enabled      => { type => 'integer', default => 1 },
    ],

    primary_key_columns => [ 'issuecode' ],
);

sub nextMember{
    use C4::Modelo::RefSoporte;
    return(C4::Modelo::RefSoporte->new());
}

1;

