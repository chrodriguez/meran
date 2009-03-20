package C4::Modelo::CircPrestamo;

use strict;
use Date::Manip;
use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'circ_prestamo',

    columns => [
        id_prestamo      => { type => 'serial', not_null => 1 },
        id3              => { type => 'integer' },
        nro_socio	 => { type => 'integer', default => '0', not_null => 1 },
	tipo_prestamo    => { type => 'character', length => 2, default => 'DO', not_null => 1 },
        fecha_prestamo   => { type => 'date', default => '0000-00-00', not_null => 1 },
        id_ui		 => { type => 'varchar', length => 4 },
	id_ui_prestamo	 => { type => 'varchar', length => 4 },
        fecha_devolucion => { type => 'date' },
 	renovaciones     => { type => 'integer', default => '0', not_null => 1},
        fecha_ultima_renovacion  => { type => 'date' },
        timestamp        => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id_prestamo' ],

    relationships => [
        nivel3 => {
            class       => 'C4::Modelo::CatNivel3',
            key_columns => { id3 => 'id3' },
	    type        => 'one to one',
        },
        tipo => {
            class       => 'C4::Modelo::CircRefTipoPrestamo',
            key_columns => { tipo_prestamo => 'issuecode' },
	    type        => 'one to one',
        },
	socio => {
            class       => 'C4::Modelo::UsrSocio',
            key_columns => { nro_socio => 'nro_socio' },
	    type        => 'one to one',
        },
      	ui =>  {
            class       => 'C4::Modelo::PrefUnidadInformacion',
            key_columns => { id_ui => 'id_ui' },
            type        => 'one to one',
      },
      	ui_prestamo =>  {
            class       => 'C4::Modelo::PrefUnidadInformacion',
            key_columns => { id_ui_prestamo => 'id_ui' },
            type        => 'one to one',
      },
    ],
);

sub getId_prestamo{
    my ($self) = shift;
    return ($self->id_prestamo);
}

sub setId_prestamo{
    my ($self) = shift;
    my ($id_prestamo) = @_;
    $self->id_reserva($id_prestamo);
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

sub getNro_socio{
    my ($self) = shift;
    return ($self->nro_socio);
}

sub setNro_socio{
    my ($self) = shift;
    my ($nro_socio) = @_;
    $self->nro_socio($nro_socio);
}

sub getTipo_prestamo{
    my ($self) = shift;
    return ($self->tipo_prestamo);
}

sub setTipo_prestamo{
    my ($self) = shift;
    my ($tipo_prestamo) = @_;
    $self->tipo_prestamo($tipo_prestamo);
}

sub getFecha_prestamo{
    my ($self) = shift;
    return ($self->fecha_prestamo);
}

sub setFecha_prestamo{
    my ($self) = shift;
    my ($fecha_prestamo) = @_;
    $self->fecha_prestamo($fecha_prestamo);
}

sub getId_ui{
    my ($self) = shift;
    return ($self->id_ui);
}

sub setId_ui{
    my ($self) = shift;
    my ($id_ui) = @_;
    $self->id_ui($id_ui);
}

sub getId_ui_prestamo{
    my ($self) = shift;
    return ($self->id_ui_prestamo);
}

sub setId_ui_prestamo{
    my ($self) = shift;
    my ($id_ui_prestamo) = @_;
    $self->id_ui_prestamo($id_ui_prestamo);
}

sub getFecha_devolucion{
    my ($self) = shift;
    return ($self->fecha_devolucion);
}

sub setFecha_devolucion{
    my ($self) = shift;
    my ($fecha_devolucion) = @_;
    $self->fecha_devolucion($fecha_devolucion);
}

sub getRenovaciones{
    my ($self) = shift;
    return ($self->renovaciones);
}

sub setRenovaciones{
    my ($self) = shift;
    my ($renovaciones) = @_;
    $self->renovaciones($renovaciones);
}

sub getFecha_ultima_renovacion{
    my ($self) = shift;
    return ($self->fecha_ultima_renovacion);
}

sub setFecha_ultima_renovacion{
    my ($self) = shift;
    my ($fecha_ultima_renovacion) = @_;
    $self->fecha_ultima_renovacion($fecha_ultima_renovacion);
}

sub getTimestamp{
    my ($self) = shift;
    return ($self->timestamp);
}

=item
agregar
Funcion que agrega un prestamo
=cut

sub agregar {
    my ($self)=shift;
    my ($data_hash)=@_;
    #Asignando data...
    $self->setId3($data_hash->{'id3'});
    $self->setNro_socio($data_hash->{'nro_socio'});
    $self->setFecha_prestamo($data_hash->{'fecha_prestamo'});
    $self->setTipo_prestamo($data_hash->{'tipo_prestamo'});
    $self->setId_ui($data_hash->{'id_ui'});
    $self->setId_ui_prestamo($data_hash->{'id_ui_prestamo'});
    $self->setRenovaciones(0);
    $self->save();

}
1;

