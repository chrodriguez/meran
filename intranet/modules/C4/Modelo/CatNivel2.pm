package C4::Modelo::CatNivel2;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_nivel2',

    columns => [
        id2                 => { type => 'serial', not_null => 1 },
        id1                 => { type => 'integer', not_null => 1 },
        tipo_documento      => { type => 'varchar', length => 4, not_null => 1 },
        nivel_bibliografico => { type => 'varchar', length => 2, not_null => 1 },
        soporte             => { type => 'varchar', length => 3, not_null => 1 },
        pais_publicacion    => { type => 'character', length => 2, not_null => 1 },
        lenguaje            => { type => 'character', length => 2, not_null => 1 },
        ciudad_publicacion  => { type => 'varchar', length => 20, not_null => 1 },
        anio_publicacion    => { type => 'varchar', length => 15 },
        timestamp           => { type => 'timestamp' },
    ],

    primary_key_columns => [ 'id2' ],

    relationships => [
        cat_nivel2_repetible => {
            class      => 'C4::Modelo::CatNivel2Repetible',
            column_map => { id2 => 'id2' },
            type       => 'one to many',
        },
    
        cat_ref_tipo_nivel3 => {
            class      => 'C4::Modelo::CatRefTipoNivel3',
            column_map => { tipo_documento => 'id_tipo_doc' },
            type       => 'one to many',
        },

        ref_soporte => {
            class      => 'C4::Modelo::RefSoporte',
            column_map => { soporte => 'idSupport' },
            type       => 'one to many',
        },

        ref_idioma => {
            class      => 'C4::Modelo::RefIdioma',
            column_map => { lenguaje => 'idLanguage' },
            type       => 'one to many',
        },
    ],
);

sub agregar{

    my ($self)=shift;
    use C4::Modelo::CatNivel2Repetible;

    my ($data_hash)=@_;

    $self->setId1($data_hash->{'id1'});
    $self->setTipo_documento($data_hash->{'tipo_documento'});
    $self->setSoporte($data_hash->{'soporte'});
    $self->setNivel_bibliografico($data_hash->{'nivel_bibliografico'});
    $self->setPais_publicacion($data_hash->{'pais_publicacion'});
    $self->setLenguaje($data_hash->{'lenguaje'});
    $self->setCiudad_publicacion($data_hash->{'ciudad_publicacion'});
    $self->setAnio_publicacion($data_hash->{'anio_publicacion'});
#     $self->setTipo_documento('LIB');
#     $self->setSoporte('PAP');
#     $self->setNivel_bibliografico('AL');
#     $self->setPais_publicacion('AR');
#     $self->setLenguaje('es');
#     $self->setCiudad_publicacion('LA PLATA');
#     $self->setAnio_publicacion('2009');

    $self->save();
    my $id2= $self->getId2;

    if ($data_hash->{'hayRepetibles'}){
        my $infoArrayNivel2= $data_hash->{'infoArrayNivel2'};
        #se agrega el nivel 2 repetible
        foreach my $infoNivel2 (@$infoArrayNivel2){
            $infoNivel2->{'id2'}= $id2;
            
            my $nivel2Repetible;

            if ($data_hash->{'modificado'}){
               $nivel2Repetible = C4::Modelo::CatNivel2Repetible->new(db => $self->db, rep_n2_id => $infoNivel2->{'rep_n2_id'});
               $nivel2Repetible->load();
            }else{
               $nivel2Repetible = C4::Modelo::CatNivel2Repetible->new(db => $self->db);
            }

            $nivel2Repetible->setId2($infoNivel2->{'id2'});
            $nivel2Repetible->setCampo($infoNivel2->{'campo'});
            $nivel2Repetible->setSubcampo($infoNivel2->{'subcampo'});
            $nivel2Repetible->setDato($infoNivel2->{'dato'});
            $nivel2Repetible->save(); 
        }
    }

    return $self;
}


sub eliminar{

    my ($self)=shift;

    use C4::Modelo::CatNivel2Repetible;
    use C4::Modelo::CatNivel2Repetible::Manager;
    use C4::Modelo::CatNivel3;
    use C4::Modelo::CatNivel3::Manager;


    my ($nivel3) = C4::Modelo::CatNivel3::Manager->get_cat_nivel3(query => [ id2 => { eq => $self->getId2 } ] );
    foreach my $n3 (@$nivel3){
      $n3->eliminar();
    }


    my ($repetiblesNivel2) = C4::Modelo::CatNivel2Repetible::Manager->get_cat_nivel2_repetible(query => [ id2 => { eq => $self->getId2() } ] );
    foreach my $n2Rep (@$repetiblesNivel2){
      $n2Rep->eliminar();
    }
    $self->delete();

}


sub getAnio_publicacion{
    my ($self) = shift;
    return ($self->anio_publicacion);
}

sub setAnio_publicacion{
    my ($self) = shift;
    my ($anio_publicacion) = @_;
    $self->anio_publicacion($anio_publicacion);
}

sub getCiudad_publicacion{
    my ($self) = shift;
    return ($self->ciudad_publicacion);
}

sub setCiudad_publicacion{
    my ($self) = shift;
    my ($ciudad_publicacion) = @_;
    $self->ciudad_publicacion($ciudad_publicacion);
}

sub getLenguaje{
    my ($self) = shift;
    return ($self->lenguaje);
}

sub setLenguaje{
    my ($self) = shift;
    my ($lenguaje) = @_;
    $self->lenguaje($lenguaje);
}

sub getPais_publicacion{
    my ($self) = shift;
    return ($self->pais_publicacion);
}

sub setPais_publicacion{
    my ($self) = shift;
    my ($pais_publicacion) = @_;
    $self->pais_publicacion($pais_publicacion);
}

sub getSoporte{
    my ($self) = shift;
    return ($self->soporte);
}

sub setSoporte{
    my ($self) = shift;
    my ($soporte) = @_;
    $self->soporte($soporte);
}

sub getNivel_bibliografico{
    my ($self) = shift;
    return ($self->nivel_bibliografico);
}

sub setNivel_bibliografico{
    my ($self) = shift;
    my ($nivel_bibliografico) = @_;
    $self->nivel_bibliografico($nivel_bibliografico);
}

sub getId2{
    my ($self) = shift;
    return ($self->id2);
}

sub setId2{
    my ($self) = shift;
    my ($id2) = @_;
    $self->id2($id2);
}

sub getId1{
    my ($self) = shift;
    return ($self->id1);
}

sub setId1{
    my ($self) = shift;
    my ($id1) = @_;
    $self->id1($id1);
}

sub setTipo_documento{
    my ($self) = shift;
    my ($tipo_documento) = @_;
    $self->tipo_documento($tipo_documento);
}

sub getTipo_documento{
    my ($self) = shift;
    return ($self->tipo_documento);
}

sub getTimestamp{
    my ($self) = shift;
    return ($self->timestamp);
}

sub setTimestamp{
    my ($self) = shift;
    my ($timestamp) = @_;
    $self->timestamp($timestamp);
}


1;

