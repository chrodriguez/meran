package Branchcategory;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'branchcategories',

    columns => [
        categorycode    => { type => 'varchar', length => 4, not_null => 1 },
        categoryname    => { type => 'text', length => 65535 },
        codedescription => { type => 'text', length => 65535 },
    ],

    primary_key_columns => [ 'categorycode' ],
);

1;

