package C4::Modelo::AdqMoneda;

use strict;
use utf8;
use C4::AR::Permisos;
use C4::AR::Utilidades;
use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'adq_moneda',

    columns => [
        id   => { type => 'integer', length => 255, not_null => 1 },
        nombre  => { type => 'varchar', length => 255, not_null => 1},
    ],
    
    primary_key_columns => [ 'id' ],

);


1;