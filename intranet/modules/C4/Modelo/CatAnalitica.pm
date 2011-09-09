package C4::Modelo::CatAnalitica;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_analitica',

    columns => [
        id1                => { type => 'integer', not_null => 1 },
        id2                => { type => 'integer', not_null => 1 },
        analyticaltitle    => { type => 'text', length => 65535 },
        analyticalunititle => { type => 'text', length => 65535 },
        parts              => { type => 'text', length => 65535, not_null => 1 },
        timestamp          => { type => 'timestamp', not_null => 1 },
        analyticalnumber   => { type => 'integer', not_null => 1 },
        classification     => { type => 'varchar', overflow => 'truncate', length => 25 },
    ],

    primary_key_columns => [ 'analyticalnumber' ],
);

1;

