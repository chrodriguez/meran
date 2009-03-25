package C4::Modelo::RepHistorialSancion;

use strict;
use Date::Manip;
use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'rep_historial_sancion',

    columns => [
        id               => { type => 'serial', not_null => 1 },
        tipo             => { type => 'varchar', default => '', length => 15, not_null => 1 },
        nro_socio		 => { type => 'integer', default => '0', not_null => 1 },
        responsable      => { type => 'varchar', length => 20, not_null => 1 },
        timestamp        => { type => 'timestamp', not_null => 1 },
        fecha             => { type => 'varchar', default => '0000-00-00', not_null => 1 },
        fecha_final       => { type => 'varchar' },
        tipo_sancion      => { type => 'integer', default => '0' },
    ],

    primary_key_columns => [ 'id' ],
);


sub getId{
    my ($self) = shift;
    return ($self->id);
}

sub setId{
    my ($self) = shift;
    my ($id) = @_;
    $self->id($id);
}

sub getTipo{
    my ($self) = shift;
    return ($self->tipo);
}

sub setTipo{
    my ($self) = shift;
    my ($tipo) = @_;
    $self->tipo($tipo);
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

sub getResponsable{
    my ($self) = shift;
    return ($self->responsable);
}

sub setResponsable{
    my ($self) = shift;
    my ($responsable) = @_;
    $self->responsable($responsable);
}

sub getFecha{
    my ($self) = shift;
    return ($self->fecha);
}

sub setFecha{
    my ($self) = shift;
    my ($fecha) = @_;
    $self->fecha($fecha);
}

sub getFecha_final{
    my ($self) = shift;
    return ($self->fecha_final);
}

sub setFecha_final{
    my ($self) = shift;
    my ($fecha_final) = @_;
    $self->fecha_final($fecha_final);
}

sub getTipo_sancion{
    my ($self) = shift;
    return ($self->tipo_sancion);
}

sub setTipo_sancion{
    my ($self) = shift;
    my ($tipo_sancion) = @_;
    $self->tipo_sancion($tipo_sancion);
}


sub agregar {
    my ($self)=shift;
    my ($data_hash)=@_;

	$self->setTipo($data_hash->{'tipo'});
    $self->setNro_socio($data_hash->{'nro_socio'});
    $self->setResponsable($data_hash->{'loggedinuser'});
    $self->setFecha(ParseDate("today"));
    $self->setFecha_final($data_hash->{'fecha_final'});
    $self->setTipo_sancion($data_hash->{'tipo_sancion'});

    $self->save();
}

1;

