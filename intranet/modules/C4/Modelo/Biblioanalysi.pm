package Biblioanalysi;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'biblioanalysis',

    columns => [
        analyticaltitle    => { type => 'text', length => 65535 },
        biblionumber       => { type => 'integer', default => '0', not_null => 1 },
        analyticalunititle => { type => 'text', length => 65535 },
        biblioitemnumber   => { type => 'integer', default => '0', not_null => 1 },
        parts              => { type => 'text', default => '', length => 65535, not_null => 1 },
        timestamp          => { type => 'timestamp', not_null => 1 },
        analyticalnumber   => { type => 'integer', not_null => 1 },
        classification     => { type => 'varchar', length => 25 },
        resumen            => { type => 'text', length => 65535 },
        url                => { type => 'varchar', length => 100 },
    ],

    primary_key_columns => [ 'analyticalnumber' ],
);

1;

