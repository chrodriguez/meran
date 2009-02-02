package C4::Modelo::CircReserva;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'circ_reserva',

    columns => [
        id2              => { type => 'integer', not_null => 1 },
        id3              => { type => 'integer' },
        id_reserva       => { type => 'serial', not_null => 1 },
        nro_socio	 => { type => 'integer', default => '0', not_null => 1 },
        fecha_reserva    => { type => 'date', default => '0000-00-00', not_null => 1 },
        estado           => { type => 'character', length => 1 },
        id_ui		 => { type => 'varchar', length => 4 },
        fecha_notificacion => { type => 'date' },
        fecha_recodatorio     => { type => 'date' },
        timestamp        => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id_reserva' ],

    unique_key => [ 'nro_socio', 'id3' ],

    foreign_keys => [
        cat_nivel3 => {
            class       => 'C4::Modelo::CatNivel3',
            key_columns => { id3 => 'id3' },
        },
    ],
);

sub agregar{
    my ($self)=shift;
    my ($data_hash)=@_;
    #Asignando data...
	$params->{'id3'}||undef,
	$params->{'id2'},
	$params->{'borrowernumber'},
	$params->{'reservedate'},
	$params->{'reminderdate'},
	$params->{'branchcode'},
	$params->{'estado'}


    $self->setFuente($data_hash->{'fuente'});
    $self->setRegular($data_hash->{'regular'});
    $self->setCategoria($data_hash->{'categoria'});
    $self->save();
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

sub getId2{
    my ($self) = shift;
    return ($self->id2);
}

sub setId2{
    my ($self) = shift;
    my ($id2) = @_;
    $self->id2($id2);
}

1;

