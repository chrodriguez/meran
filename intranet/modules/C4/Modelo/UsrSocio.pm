package C4::Modelo::UsrSocio;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'usr_socio',

    columns => [
        id_persona         => { type => 'integer', not_null => 1 },
        id_socio           => { type => 'serial', not_null => 1 },
        nro_socio          => { type => 'varchar', length => 16, not_null => 1 },
        id_ui              => { type => 'varchar', length => 4, not_null => 1 },
        cod_categoria      => { type => 'character', length => 2, not_null => 1 },
        fecha_alta         => { type => 'date' },
        expira             => { type => 'date' },
        flags              => { type => 'integer' },
        password           => { type => 'varchar', length => 30 },
        lastlogin          => { type => 'datetime' },
        lastchangepassword => { type => 'date' },
        changepassword     => { type => 'integer', default => '0', not_null => 1 },
        cumple_requisito   => { type => 'date' },
        id_estado          => { type => 'integer', not_null => 1 },
    ],

    primary_key_columns => [ 'id_socio' ],

    unique_key => [ 'nro_socio' ],
);

1;

