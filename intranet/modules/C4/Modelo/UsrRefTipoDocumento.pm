package UsrRefTipoDocumento;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'usr_ref_tipo_documento',

    columns => [
        id_tipo_documento => { type => 'integer', not_null => 1 },
        nombre            => { type => 'varchar', default => '', length => 50, not_null => 1 },
        descripcion       => { type => 'varchar', default => '', length => 250, not_null => 1 },
    ],

    primary_key_columns => [ 'id_tipo_documento' ],
);

1;

