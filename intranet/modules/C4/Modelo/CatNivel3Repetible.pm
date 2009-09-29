package C4::Modelo::CatNivel3Repetible;

use strict;
use utf8;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_nivel3_repetible',

    columns => [
        rep_n3_id => { type => 'serial', not_null => 1 },
        id3       => { type => 'integer', not_null => 1 },
        campo     => { type => 'varchar', length => 3 },
        subcampo  => { type => 'varchar', length => 3, not_null => 1 },
        dato      => { type => 'varchar', length => 250, not_null => 1 },
        agregacion_temp      => { type => 'varchar', length => 255},
        timestamp => { type => 'timestamp' },
    ],

    primary_key_columns => [ 'rep_n3_id' ],

    relationships => [
        cat_nivel3 => {
            class       => 'C4::Modelo::CatNivel3',
            key_columns => { id3 => 'id3' },
            type        => 'one to one',
        },
		CEC => {  
            class       => 'C4::Modelo::CatEstructuraCatalogacion',
            key_columns => { 
                             campo => 'campo',
                             subcampo => 'subcampo' },
            type        => 'one to one',
        },
    ],
);

sub load{
    my $self = $_[0]; # Copy, not shift

    my $error = 0;

    eval {
    
         unless( $self->SUPER::load(speculative => 1) ){
                 C4::AR::Debug::debug("CatNivel3Repetible=>  dentro del unless, no existe el objeto SUPER load");
                $error = 1;
         }

        C4::AR::Debug::debug("CatNivel3Repetible=>  SUPER load");
        return $self->SUPER::load(@_);
    };

    if($@){
        C4::AR::Debug::debug("CatNivel3Repetible=>  no existe el objeto");
        $error = 1;
    }

    return $error;
}

sub agregar{

    my ($self)=shift;
    my ($data_hash)=@_;
    $self->setId3($data_hash->{'id3'});
    $self->setCampo($data_hash->{'campo'});
    $self->setSubcampo($data_hash->{'subcampo'});
    $self->setDato($data_hash->{'dato'});
    $self->save();
}

sub eliminar{
    my ($self) = shift;   

    $self->delete();
}

sub getId_rep{
    my ($self) = shift;
    return ($self->rep_n3_id);
}

sub getRep_n3_id{
    my ($self) = shift;
    return ($self->rep_n3_id);
}

sub setRep_n3_id{
    my ($self) = shift;
    my ($rep_n3_id) = @_;
    $self->rep_n3_id($rep_n3_id);
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
	utf8::encode($dato);
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

