package C4::Modelo::RefSoporte;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'ref_soporte',

    columns => [
        idSupport   => { type => 'varchar',length => 10 ,not_null => 1 },
        description  => { type => 'varchar', length => 30, not_null => 1 },
    ],

    primary_key_columns => [ 'idSupport' ],
);

sub nextMember{
    use C4::Modelo::RefNivelBibliografico;
    return(C4::Modelo::RefNivelBibliografico->new());
}

1;

