package C4::Modelo::CatNivel3;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_nivel3',

    columns => [
        id3                   => { type => 'serial', not_null => 1 },
        id1                   => { type => 'integer', not_null => 1 },
        id2                   => { type => 'integer', not_null => 1 },
        barcode               => { type => 'varchar', length => 20 },
        signatura_topografica => { type => 'varchar', length => 30 },
        id_ui_poseedora       => { type => 'varchar', length => 4 }, #ui que tiene el item
        id_ui_origen          => { type => 'varchar', length => 4 }, #ui de donde viene el item
        id_disponibilidad     => { type => 'integer', length => 5, default => '0', not_null => 1 },
        para_sala             => { type => 'character', default => '0', length => 2 },
        timestamp             => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id3' ],

    relationships => [
        cat_nivel3_repetible => {
            class      => 'C4::Modelo::CatNivel3Repetible',
            column_map => { id3 => 'id3' },
            type       => 'one to many',
        },

        circ_reserva => {
            class      => 'C4::Modelo::CircReserva',
            column_map => { id3 => 'id3' },
            type       => 'one to many',
        },
        
        ref_disponibilidad => {
            class      => 'C4::Modelo::RefDisponibilidad',
            column_map => { id_disponibilidad => 'codigo' },
            type       => 'one to many',
        },
    ],
);


sub agregar{

    my ($self)=shift;
    use C4::Modelo::CatNivel2Repetible;

    my ($data_hash)=@_;
#     $self->setId1($data_hash->{'id1'});
    $self->setId1($data_hash->{'id1'});
    $self->setId2($data_hash->{'id2'}); 

    $self->setBarcode('BARCODE');
    $self->setSignatura_topografica('SIG TOPO');
    $self->setId_ui_poseedora('DEO');
    $self->setId_ui_origen('DEO');
    $self->setId_disponibilidad('2009');
    $self->setParaSala(0);

    $self->save();
    my $id3= $self->getId3;

    if ($data_hash->{'hayRepetibles'}){
        my $infoArrayNivel3= $data_hash->{'infoArrayNivel3'};
        #se agrega el nivel 2 repetible
        foreach my $infoNivel3 (@$infoArrayNivel3){
            $infoNivel3->{'id3'}= $id3;
            my $nivel3Repetible = C4::Modelo::CatNivel3Repetible->new(db => $self->db);
            $nivel3Repetible->setId3($infoNivel3->{'id3'});
            $nivel3Repetible->setCampo($infoNivel3->{'campo'});
            $nivel3Repetible->setSubcampo($infoNivel3->{'subcampo'});
            $nivel3Repetible->setDato($infoNivel3->{'dato'});
            $nivel3Repetible->save();
        }
    }
}


sub eliminar{

    my ($self)=shift;

    use C4::Modelo::CatNivel3Repetible;
    use C4::Modelo::CatNivel3Repetible::Manager;

    my ($repetiblesNivel3) = C4::Modelo::CatNivel3Repetible::Manager->get_cat_nivel3_repetible( query => [ id3 => { eq => $self->getId3 } ] );
    foreach my $n3Rep (@$repetiblesNivel3){
      $n3Rep->eliminar();
    }
    $self->delete();

}


sub getId_ui_poseedora{
    my ($self) = shift;
    return ($self->id_ui_poseedora);
}

sub setId_ui_poseedora{
    my ($self) = shift;
    my ($id_ui_poseedora) = @_;
    $self->id_ui_poseedora($id_ui_poseedora);
}

sub getId_ui_origen{
    my ($self) = shift;
    return ($self->id_ui_origen);
}

sub setId_ui_origen{
    my ($self) = shift;
    my ($id_ui_origen) = @_;
    $self->id_ui_origen($id_ui_origen);
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

sub getId2{
    my ($self) = shift;
    return ($self->id2);
}

sub setId2{
    my ($self) = shift;
    my ($id2) = @_;
    $self->id2($id2);
}

sub getId3{
    my ($self) = shift;
    return ($self->id3);
}

sub setId3{
    my ($self) = shift;
    my ($id3) = @_;
    $self->id3($id3);
}

sub getBarcode{
    my ($self) = shift;
    return ($self->barcode);
}

sub setBarcode{
    my ($self) = shift;
    my ($barcode) = @_;
    $self->barcode($barcode);
}

sub getSignatura_topografica{
    my ($self) = shift;
    return ($self->signatura_topografica);
}

sub setSignatura_topografica{
    my ($self) = shift;
    my ($signatura_topografica) = @_;
    $self->signatura_topografica($signatura_topografica);
}

sub getId_disponibilidad{
    my ($self) = shift;
    return ($self->id_disponibilidad);
}

sub setId_disponibilidad{
    my ($self) = shift;
    my ($id_disponibilidad) = @_;
    $self->id_disponibilidad($id_disponibilidad);
}

sub setParaSala{
    my ($self) = shift;
    my ($para_sala) = @_;
    $self->para_sala($para_sala);
}

sub getPara_Sala{
    my ($self) = shift;
    return ($self->para_sala);
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

