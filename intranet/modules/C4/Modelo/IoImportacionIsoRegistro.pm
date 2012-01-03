package C4::Modelo::IoImportacionIsoRegistro;

use strict;

use C4::Modelo::IoImportacionIsoRegistro;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'io_importacion_iso_registro',

    columns => [
        id                             => { type => 'integer', overflow => 'truncate', not_null => 1 },
        id_importacion_iso             => { type => 'integer', overflow => 'truncate', not_null => 1},
        type                           => { type => 'varchar', overflow => 'truncate', length => 25},
        estado                         => { type => 'integer', overflow => 'truncate', length => 2},
        matching                       => { type => 'integer', overflow => 'truncate'},
        id_matching                    => { type => 'integer', overflow => 'truncate'},
        id1                            => { type => 'integer', overflow => 'truncate'},
        id2                            => { type => 'integer', overflow => 'truncate'},
        id3                            => { type => 'integer', overflow => 'truncate'},
        marc_record                    => { type => 'text', overflow => 'truncate' },
    ],


    relationships =>
    [
      ref_importacion =>
      {
         class       => 'C4::Modelo::IoImportacionIso',
         key_columns => {id_importacion_iso => 'id' },
         type        => 'one to one',
       },
    ],

    primary_key_columns => [ 'id' ],
    unique_key          => ['id'],

);

#----------------------------------- FUNCIONES DEL MODELO ------------------------------------------------


sub agregar{
    my ($self)   = shift;
    my ($params) = @_;

    $self->setIdImportacionIso($params->{'id_importacion_iso'});
    $self->setMarcRecord($params->{'marc_record'});
    $self->save();
}


sub eliminar{
    my ($self)      = shift;
    my ($params)    = @_;

    #HACER ALGO SI ES NECESARIO

    $self->delete();
}
#----------------------------------- FIN - FUNCIONES DEL MODELO -------------------------------------------



#----------------------------------- GETTERS y SETTERS------------------------------------------------

sub setIdImportacionIso{
    my ($self) = shift;
    my ($id_imporatcion) = @_;
    utf8::encode($id_imporatcion);
    $self->id_importacion_iso($id_imporatcion);
}

sub setMarcRecord{
    my ($self)  = shift;
    my ($marc_record) = @_;
    $self->marc_record($marc_record);
}

sub getId{
    my ($self) = shift;
    return ($self->id);
}

sub getIdImportacionIso{
    my ($self) = shift;
    return ($self->id_importacion_iso);
}

sub setMarcRecord{
    my ($self) = shift;
    return ($self->marc_record);
}
