package C4::Modelo::CatRating;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_rating',

    columns => [
        nro_socio     => { type => 'varchar', overflow => 'truncate', not_null => 1, length => 32 },
        id2           => { type => 'integer', overflow => 'truncate', not_null => 1, length => 11 },
        rate          => { type => 'float', not_null => 0, },
        review        => { type => 'text', overflow => 'truncate' },
        date          => { type => 'varchar', overflow => 'truncate', length => 10, not_null => 1 },
    ],

    primary_key_columns => [ 'nro_socio','id2' ],

     relationships =>
    [
      socio => 
      {
        class       => 'C4::Modelo::UsrSocio',
        key_columns => { nro_socio => 'nro_socio' },
        type        => 'one to one',
      },
    ]
);


sub toString{
	my ($self) = shift;

    return ($self->getRate);
}

sub getObjeto{
	my ($self) = shift;
	my ($socio,$id2) = @_;

	my $objecto= C4::Modelo::CatRating->new(nro_socio => $socio, id2 => $id2, date => C4::Date::getCurrentTimestamp());
	$objecto->load();
	return $objecto;
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


sub getNroSocio{
    my ($self) = shift;

    return (C4::AR::Utilidades::trim($self->nro_socio));
}

sub setNroSocio{
    my ($self) = shift;
    my ($nro_socio) = @_;

    $self->nro_socio($nro_socio);
}

sub getRate{
    my ($self) = shift;

    return ($self->rate);
}

sub setRate{
    my ($self) = shift;
    my ($rate) = @_;

    $self->rate($rate);
}

sub getReview{
    my ($self) = shift;

    return ($self->review);
}

sub setReview{
    my ($self) = shift;
    my ($review) = @_;

    $self->review($review);
}

1;

