package C4::Modelo::Rating;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'rating',

    columns => [
        nro_socio     => { type => 'varchar', not_null => 1, length => 11 },
        id2           => { type => 'integer', not_null => 1, length => 11 },
        rate          => { type => 'float', not_null => 1 },
    ],

    primary_key_columns => [ 'nro_socio','id2' ],

);


sub toString{
	my ($self) = shift;

    return ($self->getRate);
}

sub getObjeto{
	my ($self) = shift;
	my ($socio,$id2) = @_;

	my $objecto= C4::Modelo::Rating->new(nro_socio => $socio, id2 => $id2);
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



1;

