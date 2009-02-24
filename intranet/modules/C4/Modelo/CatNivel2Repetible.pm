package C4::Modelo::CatNivel2Repetible;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_nivel2_repetible',

    columns => [
        rep_n2_id => { type => 'serial', not_null => 1 },
        id2       => { type => 'integer', not_null => 1 },
        campo     => { type => 'varchar', length => 3 },
        subcampo  => { type => 'varchar', length => 3, not_null => 1 },
        dato      => { type => 'varchar', length => 250 },
        timestamp => { type => 'timestamp' },
    ],

    primary_key_columns => [ 'rep_n2_id' ],

    foreign_keys => [
        cat_nivel2 => {
            class       => 'C4::Modelo::CatNivel2',
            key_columns => { id2 => 'id2' },
        },
    ],
);

sub agregar{

    my ($self)=shift;
    my ($data_hash)=@_;
    $self->setId2($data_hash->{'id2'});
    $self->setCampo($data_hash->{'campo'});
    $self->setSubcampo($data_hash->{'subcampo'});
    $self->setDato($data_hash->{'dato'});
    $self->save();
}


sub eliminar{

   my ($self)=shift;   
   $self->delete();
}


sub getRep_n2_id{
    my ($self) = shift;
    return ($self->rep_n2_id);
}

sub setRep_n2_id{
    my ($self) = shift;
    my ($rep_n2_id) = @_;
    $self->rep_n2_id($rep_n2_id);
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

sub getCampo{
    my ($self) = shift;
    return ($self->campo);
}

sub setCampo{
    my ($self) = shift;
    my ($campo) = @_;
    $self->campo($campo);
}

sub getSubcampo{
    my ($self) = shift;
    return ($self->subcampo);
}

sub setSubcampo{
    my ($self) = shift;
    my ($subcampo) = @_;
    $self->subcampo($subcampo);
}

sub getDato{
    my ($self) = shift;
    return ($self->dato);
}

sub setDato{
    my ($self) = shift;
    my ($dato) = @_;
    $self->dato($dato);
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

