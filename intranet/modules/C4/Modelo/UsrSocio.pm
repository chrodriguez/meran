package UsrSocio;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'usr_socios',

    columns => [
        id_persona         => { type => 'integer', default => '', not_null => 1 },
        id_socio           => { type => 'integer', not_null => 1 },
        nro_socio          => { type => 'varchar', default => '', length => 16, not_null => 1 },
        id_ui              => { type => 'varchar', default => '', length => 4, not_null => 1 },
        cod_categoria      => { type => 'character', default => '', length => 2, not_null => 1 },
        fecha_alta         => { type => 'date' },
        expira             => { type => 'date' },
        flags              => { type => 'integer' },
        password           => { type => 'varchar', length => 30 },
        lastlogin          => { type => 'datetime' },
        lastchangepassword => { type => 'date' },
        changepassword     => { type => 'integer', default => '0', not_null => 1 },
        cumple_requisito   => { type => 'date' },
        id_estado          => { type => 'integer', default => '', not_null => 1 },
    ],

    primary_key_columns => [ 'id_socio' ],

    unique_key => [ 'nro_socio' ],
);

1;

