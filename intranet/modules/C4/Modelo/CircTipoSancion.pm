package C4::Modelo::CircTipoSancion;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'circ_tipo_sancion',

    columns => [
        tipo_sancion        => { type => 'serial', not_null => 1 },
        categoria_socio     => { type => 'character', default => '', length => 2, not_null => 1 },
        tipo_prestamo       => { type => 'character', default => '', length => 2, not_null => 1 },
    ],

    primary_key_columns => [ 'tipo_sancion' ],

    unique_key => [ 'categoria_socio', 'tipo_prestamo' ],

	relationships => [
	    ref_tipo_prestamo => {
            class      => 'C4::Modelo::CircRefTipoPrestamo',
            column_map => { tipo_prestamo => 'id_tipo_prestamo' },
            type       => 'one to one',
        },

		ref_tipo_prestamo_sancion => {
            class      => 'C4::Modelo::CircTipoPrestamoSancion',
            column_map => { tipo_sancion => 'tipo_sancion' },
            type       => 'one to many',
        },

        ref_regla_tipo_sancion => {
            class      => 'C4::Modelo::CircReglaTipoSancion',
            column_map => { tipo_sancion => 'tipo_sancion' },
            type       => 'one to many',
            manager_args => { sort_by =>  'orden' },
        },

	    ref_categoria_socio => {
            class      => 'C4::Modelo::UsrRefCategoriaSocio',
            column_map => { categoria_socio => 'categorycode' },
            type       => 'one to one',
        },
    ],

);




sub getTipo_prestamo{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->tipo_prestamo));
}

sub setTipo_prestamo{
    my ($self) = shift;
    my ($tipo_prestamo) = @_;
    $self->tipo_prestamo($tipo_prestamo);
}

sub getTipo_sancion{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->tipo_sancion));
}

sub setTipo_sancion{
    my ($self) = shift;
    my ($tipo_sancion) = @_;
    $self->tipo_sancion($tipo_sancion);
}

sub getCategoria_socio{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->categoria_socio));
}

sub setCategoria_socio{
    my ($self) = shift;
    my ($categoria_socio) = @_;
    $self->categoria_socio($categoria_socio);
}

sub aplicaAlTipoDePrestamo{
    my ($self) = shift;
    my ($tipo_prestamo) = @_;
	
	foreach my $tps ($self->ref_tipo_prestamo_sancion) {
		if($tps->getTipo_prestamo eq $tipo_prestamo){ return 1; }
	}

    return 0;
}

sub actualizarTiposPrestamoQueAplica {
    my ($self)                  = shift;
    my ($tiposQueAplica,$db)    = @_;
    
    $self->debug("en actualizarTiposPrestamoQueAplica ");

	foreach my $tps ($self->ref_tipo_prestamo_sancion) {
		$self->debug($tps->getTipo_prestamo);
		$tps->delete();
	}

    foreach my $tpa (@$tiposQueAplica) {
		$self->debug("tipo tipo ".$tpa);
		my $ta = C4::Modelo::CircTipoPrestamoSancion->new(db=>$db);
		$ta->setTipo_prestamo($tpa);
		$ta->setTipo_sancion($self->getTipo_sancion);
   		$ta->save();
    }
}

1;

