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
        fecha_recodatorio  => { type => 'date' },
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
# 	$params->{'id3'}||undef,
# 	$params->{'id2'},
# 	$params->{'borrowernumber'},
# 	$params->{'reservedate'},
# 	$params->{'reminderdate'},
# 	$params->{'branchcode'},
# 	$params->{'estado'}


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

sub getNro_socio{
    my ($self) = shift;
    return ($self->nro_socio);
}

sub setNro_socio{
    my ($self) = shift;
    my ($nro_socio) = @_;
    $self->nro_socio($nro_socio);
}

sub getFecha_reserva{
    my ($self) = shift;
    return ($self->fecha_reserva);
}

sub setFecha_reserva{
    my ($self) = shift;
    my ($fecha_reserva) = @_;
    $self->fecha_reserva($fecha_reserva);
}

sub getFecha_notificacion{
    my ($self) = shift;
    return ($self->fecha_notificacion);
}

sub setFecha_notificacion{
    my ($self) = shift;
    my ($fecha_notificacion) = @_;
    $self->fecha_notificacion($fecha_notificacion);
}

sub getUi_id{
    my ($self) = shift;
    return ($self->ui_id);
}

sub setUi_id{
    my ($self) = shift;
    my ($ui_id) = @_;
    $self->ui_id($ui_id);
}
1;

