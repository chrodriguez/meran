package C4::Modelo::RepHistorialPrestamo;

use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'rep_historial_prestamo',

    columns => [
        id_historial_prestamo    => { type => 'serial', not_null => 1 },
        id3                      => { type => 'integer' },
        nro_socio	          => { type => 'varchar', length => 16, not_null => 1 },
        tipo_prestamo            => { type => 'character', length => 2, default => 'DO', not_null => 1 },
        fecha_prestamo           => { type => 'varchar', not_null => 1 },
        id_ui_origen             => { type => 'varchar', length => 4 },
        id_ui_prestamo	         => { type => 'varchar', length => 4 },
        fecha_devolucion         => { type => 'varchar' },
        renovaciones             => { type => 'integer', default => '0', not_null => 1},
        fecha_ultima_renovacion  => { type => 'varchar' },
        timestamp                => { type => 'timestamp', not_null => 1 },
        agregacion_temp          => { type => 'varchar', length => 255, not_null => 0 },
    ],

    primary_key_columns => [ 'id_historial_prestamo' ],

    relationships => [

       nivel3 => {
#             class       => 'C4::Modelo::CatNivel3',
            class       => 'C4::Modelo::CatRegistroMarcN3',
            key_columns => { id3 => 'id3' },
	        type        => 'one to one',
        },
      tipo => {
            class       => 'C4::Modelo::CircRefTipoPrestamo',
            key_columns => { tipo_prestamo => 'id_tipo_prestamo' },
	         type        => 'one to one',
        },

	   socio => {
            class       => 'C4::Modelo::UsrSocio',
            key_columns => { nro_socio => 'nro_socio' },
	         type        => 'one to one',
        },
      ui =>  {
            class       => 'C4::Modelo::PrefUnidadInformacion',
            key_columns => { id_ui_origen => 'id_ui' },
            type        => 'one to one',
      },
      ui_prestamo =>  {
            class       => 'C4::Modelo::PrefUnidadInformacion',
            key_columns => { id_ui_prestamo => 'id_ui' },
            type        => 'one to one',
      },
    ],
);

use C4::Date qw(get_date_format format_date_in_iso);

sub getId_historial_prestamo{
    my ($self) = shift;
    return ($self->id_historial_prestamo);
}

# sub setId_prestamo{
#     my ($self) = shift;
#     my ($id_prestamo) = @_;
#     $self->id_reserva($id_prestamo);
# }

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

sub getFecha_prestamo_formateada{
	my ($self)=shift;
	my $dateformat = C4::Date::get_date_format();
	return C4::Date::format_date($self->getFecha_prestamo,$dateformat);
}


sub getFecha_prestamo_formateada_ticket {
    my ($self)=shift;
    my $dateformat = C4::Date::get_date_format();
    return C4::Date::format_date_hour($self->getFecha_prestamo,$dateformat);
}

sub setFecha_prestamo{
    my ($self) = shift;
    my ($fecha_prestamo) = @_;
    $self->fecha_prestamo($fecha_prestamo);
}

sub getId_ui_origen{
    my ($self) = shift;
    return ($self->id_ui_origen);
}

sub setId_ui_origen{
    my ($self) = shift;
    my ($id_ui) = @_;
    $self->id_ui_origen($id_ui);
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

sub getFecha_devolucion_formateada{
	my ($self)=shift;
	my $dateformat = C4::Date::get_date_format();
	return C4::Date::format_date($self->getFecha_devolucion,$dateformat);
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

sub getFecha_ultima_renovacion_formateada{
	my ($self)=shift;
	my $dateformat = C4::Date::get_date_format();
	return C4::Date::format_date($self->getFecha_ultima_renovacion,$dateformat);
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

sub agregarPrestamo{
    my ($self) = shift;
    my ($prestamo) = @_;

    $self->debug("SE AGREGO EL PRESTAMO AL HISTORIAL DE PRESTAMO!!!!");
    #Asignando data...

    $self->setId3($prestamo->getId3);
    $self->setNro_socio($prestamo->getNro_socio);
    $self->setFecha_prestamo($prestamo->getFecha_prestamo);
    $self->setTipo_prestamo($prestamo->getTipo_prestamo);
    $self->setId_ui_origen($prestamo->getId_ui_origen);
    $self->setId_ui_prestamo($prestamo->getId_ui_prestamo);
    $self->setFecha_devolucion($prestamo->getFecha_devolucion);
    $self->setRenovaciones($prestamo->getRenovaciones);
    $self->setFecha_ultima_renovacion($prestamo->getFecha_ultima_renovacion);
    $self->save();

}



1;

