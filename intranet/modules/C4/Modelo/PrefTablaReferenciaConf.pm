package C4::Modelo::PrefTablaReferenciaConf;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'pref_tabla_referencia_conf',

    columns => [
        id                  => { type => 'serial', overflow => 'truncate'},
        tabla               => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
        campo               => { type => 'varchar', overflow => 'truncate', length => 20, not_null => 1 },
        campo_alias         => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
        visible             => { type => 'varchar', overflow => 'truncate', length => 255},
    ],

    primary_key_columns => [ 'id' ],
);

use C4::Modelo::PrefTablaReferenciaConf::Manager;



1;

