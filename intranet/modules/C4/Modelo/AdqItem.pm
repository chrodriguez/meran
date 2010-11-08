package C4::Modelo::AdqItem;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'item',

    columns => [
        id_item   => { type => 'integer', not_null => 1 },
        descripcion => { type => 'varchar', length =>255 },
        precio  => { type => 'float'},
    ],
    
    primary_key_columns => [ 'id_item' ],

);

1;



