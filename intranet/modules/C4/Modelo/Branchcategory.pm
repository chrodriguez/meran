package C4::Modelo::Branchcategory;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

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

