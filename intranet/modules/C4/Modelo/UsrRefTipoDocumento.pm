package C4::Modelo::UsrRefTipoDocumento;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'usr_ref_tipo_documento',

    columns => [
        id_tipo_documento => { type => 'serial', not_null => 1 },
        nombre            => { type => 'varchar', length => 50, not_null => 1 },
        descripcion       => { type => 'varchar', length => 250, not_null => 1 },
    ],

    primary_key_columns => [ 'id_tipo_documento' ],
);

1;

