package C4::Modelo::CatNivel1;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_nivel1',

    columns => [
        id1       => { type => 'serial', not_null => 1 },
        titulo    => { type => 'varchar', length => 100, not_null => 1 },
        autor     => { type => 'integer', not_null => 1 },
        timestamp => { type => 'timestamp' },
    ],

    primary_key_columns => [ 'id1' ],

    relationships => [
        cat_autor => {
            class      => 'C4::Modelo::CatAutor',
            column_map => { autor => 'id' },
            type       => 'one to many',
        },
    ],

);



sub agregar{

    my ($self)=shift;
    use C4::Modelo::CatNivel1Repetible;

    my ($data_hash)=@_;
    $self->setTitulo($data_hash->{'titulo'});
    $self->setAutor($data_hash->{'autor'});
    $self->save();
    my $id1= $self->getId1;
#     $self->save(); que hace aca esto???????????

    if ($data_hash->{'hayRepetibles'}){
        my $infoArrayNivel1= $data_hash->{'infoArrayNivel1'};
        #se agrega el nivel 1 repetible
        foreach my $infoNivel1 (@$infoArrayNivel1){
            $infoNivel1->{'id1'}= $id1;
            my $nivel1Repetible = C4::Modelo::CatNivel1Repetible->new(db => $self->db);
            $nivel1Repetible->setId1($infoNivel1->{'id1'});
            $nivel1Repetible->setCampo($infoNivel1->{'campo'});
            $nivel1Repetible->setSubcampo($infoNivel1->{'subcampo'});
            $nivel1Repetible->setDato($infoNivel1->{'dato'});
            $nivel1Repetible->save(); 
        }
    }
}

sub eliminar{

    my ($self)=shift;
    use C4::Modelo::CatNivel1Repetible;
    use C4::Modelo::CatNivel1Repetible::Manager;
    
    use C4::Modelo::CatNivel2Repetible;
    use C4::Modelo::CatNivel2Repetible::Manager;

    use C4::Modelo::CatNivel3Repetible;
    use C4::Modelo::CatNivel3Repetible::Manager;


    my ($repetiblesNivel2) = C4::Modelo::CatNivel2::Manager::get_cat_nivel2(id1 => $self->getId1());
    foreach my $n2Rep (@$repetiblesNivel2){
      $n2Rep->eliminar();
    }


    my ($repetiblesNivel1) = C4::Modelo::CatNivel1Repetible::Manager::get_cat_nivel1_repetible(id1 => $self->getId1());
    foreach my $n1Rep (@$repetiblesNivel1){
      $n1Rep->delete();
    }
    $self->delete();
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

sub getTitulo{
    my ($self) = shift;
    return ($self->titulo);
}

sub setTitulo{
    my ($self) = shift;
    my ($titulo) = @_;
    $self->titulo($titulo);
}

sub getAutor{
    my ($self) = shift;
    return ($self->autor);
}

sub setAutor{
    my ($self) = shift;
    my ($autor) = @_;
    $self->autor($autor);
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

