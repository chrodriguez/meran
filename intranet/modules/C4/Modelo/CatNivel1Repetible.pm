package C4::Modelo::CatNivel1Repetible;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_nivel1_repetible',

    columns => [
        rep_n1_id => { type => 'serial'},
        id1       => { type => 'integer', length => 11 ,not_null => 1 },
        campo     => { type => 'varchar', length => 3 },
        subcampo  => { type => 'varchar', length => 3, not_null => 1 },
        dato      => { type => 'varchar', length => 255, not_null => 1 },
        timestamp => { type => 'timestamp' },
    ],

    primary_key_columns => [ 'rep_n1_id' ],

    relationships => [
        # relacion a cat_nivel1
        cat_nivel1 => {
            class       => 'C4::Modelo::CatNivel1',
            key_columns => { id1 => 'id1' },
            type        => 'one to one',
        },

       # relacion a cat_estructura_catalogacion
       CEC => {  
            class       => 'C4::Modelo::CatEstructuraCatalogacion',
            key_columns => { 
                             campo => 'campo',
                             subcampo => 'subcampo' },
            type        => 'one to one',
        },
    ],

   
);

sub agregar{

    my ($self)=shift;
    my ($data_hash)=@_;
    $self->setId1($data_hash->{'id1'});
    $self->setCampo($data_hash->{'campo'});
    $self->setSubcampo($data_hash->{'subcampo'});
    $self->setDato($data_hash->{'dato'});
    $self->save();
}

sub eliminar{

   my ($self)=shift;   
   $self->delete();
}

sub getRep_n1_id{
    my ($self) = shift;
    return ($self->rep_n1_id);
}

sub setRep_n1_id{
    my ($self) = shift;
    my ($rep_n1_id) = @_;
    $self->rep_n1_id($rep_n1_id);
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

