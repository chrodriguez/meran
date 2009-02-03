package C4::Modelo::CatEstructuraCatalogacion;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_estructura_catalogacion',

    columns => [
        id                  => { type => 'serial', not_null => 1 },
        campo               => { type => 'character', length => 3, not_null => 1 },
        subcampo            => { type => 'character', length => 1, not_null => 1 },
        itemtype            => { type => 'varchar', length => 4, not_null => 1 },
        liblibrarian        => { type => 'varchar', length => 255, not_null => 1 },
        tipo                => { type => 'character', length => 5, not_null => 1 },
        referencia          => { type => 'integer', default => '0', not_null => 1 },
        nivel               => { type => 'integer', not_null => 1 },
        obligatorio         => { type => 'integer', default => '0', not_null => 1 },
        intranet_habilitado => { type => 'integer', default => '0' },
        visible             => { type => 'integer', default => 1, not_null => 1 },
    ],

    
    primary_key_columns => [ 'id' ],

    tipoItem => 
      {
        class       => 'C4::Modelo::CatRefTipoNivel3',
        key_columns => { itemtype => 'id_tipo_doc' },
        type        => 'one to one',
      },

     refCampo => 
      {
        class       => 'C4::Modelo::PrefEstructuraSubcampoMarc',
        key_columns => { campo => 'tagfield',
                         subcampo => 'tagsubfield' },
        type        => 'one to one',
      },

);

sub agregar{

    my ($self)=shift;
    my ($data_hash)=@_;

    $self->setCampo($data_hash->{'campo'});
    $self->setSubcampo($data_hash->{'subcampo'});
    $self->setItemtype($data_hash->{'itemtype'});
    $self->setLiblibrarian($data_hash->{'liblibrarian'});
    $self->setTipo($data_hash->{'tipo'});
    $self->setReferencia($data_hash->{'referencia'});
    $self->setNivel($data_hash->{'nivel'});
    $self->setObligatorio($data_hash->{'obligatorio'});
    $self->setIntranet_habilitado($data_hash->{'intranet_habilitado'});
    $self->setVisible($data_hash->{'visible'});

    $self->save();

}

sub modificar{

    my ($self)=shift;
    my ($data_hash)=@_;

    $self->setCampo($data_hash->{'campo'});
    $self->setSubcampo($data_hash->{'subcampo'});
    $self->setItemtype($data_hash->{'itemtype'});
    $self->setLiblibrarian($data_hash->{'liblibrarian'});
    $self->setTipo($data_hash->{'tipo'});
    $self->setReferencia($data_hash->{'referencia'});
    $self->setNivel($data_hash->{'nivel'});
    $self->setObligatorio($data_hash->{'obligatorio'});
    $self->setIntranet_habilitado($data_hash->{'intranet_habilitado'});
    $self->setVisible($data_hash->{'visible'});

    $self->save();

}

sub defaultSort{

    return ("liblibrarian");
}


1;

