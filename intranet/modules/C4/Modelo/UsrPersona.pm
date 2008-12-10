package UsrPersona;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'usr_persona',

    columns => [
        id_persona        => { type => 'integer', not_null => 1 },
        id_socio          => { type => 'integer' },
        version_documento => { type => 'character', default => 'P', length => 1, not_null => 1 },
        nro_documento     => { type => 'varchar', default => '', length => 16, not_null => 1 },
        tipo_documento    => { type => 'character', default => '', length => 3, not_null => 1 },
        apellido          => { type => 'varchar', default => '', length => 255, not_null => 1 },
        nombre            => { type => 'varchar', default => '', length => 255, not_null => 1 },
        titulo            => { type => 'varchar', length => 255 },
        otros_nombres     => { type => 'varchar', length => 255 },
        iniciales         => { type => 'varchar', default => '', length => 255, not_null => 1 },
        calle             => { type => 'varchar', default => '', length => 255, not_null => 1 },
        barrio            => { type => 'varchar', length => 255 },
        ciudad            => { type => 'varchar', length => 255 },
        telefono          => { type => 'varchar', length => 255 },
        email             => { type => 'varchar', length => 255 },
        fax               => { type => 'varchar', length => 255 },
        msg_texto         => { type => 'varchar', length => 255 },
        alt_calle         => { type => 'varchar', length => 255 },
        alt_barrio        => { type => 'varchar', length => 255 },
        alt_ciudad        => { type => 'varchar', length => 255 },
        alt_telefono      => { type => 'varchar', length => 255 },
        nacimiento        => { type => 'date' },
        fecha_alta        => { type => 'date' },
        sexo              => { type => 'character', length => 1 },
        telefono_laboral  => { type => 'varchar', length => 50 },
        cumple_condicion  => { type => 'integer', default => '0', not_null => 1 },
    ],

    primary_key_columns => [ 'id_persona' ],
);

1;

