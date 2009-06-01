package C4::Modelo::CircRefTipoPrestamo;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'circ_ref_tipo_prestamo',

    columns => [
        id_tipo_prestamo    => { type => 'character', length => 2, not_null => 1 },
        descripcion  => { type => 'text', length => 65535 },
        id_disponibilidad   => { type => 'integer', default => '0', not_null => 1 },
        prestamos    => { type => 'integer', default => '0', not_null => 1 },
        dias_prestamo   => { type => 'integer', default => '0', not_null => 1 },
        renovaciones        => { type => 'integer', default => '0', not_null => 1 },
        dias_renovacion    => { type => 'integer', default => '0', not_null => 1 },
        dias_antes_renovacion => { type => 'integer', default => '0', not_null => 1 },
        habilitado      => { type => 'integer', default => 1 },
    ],

    primary_key_columns => [ 'id_tipo_prestamo' ],
    
	relationships => [
	    disponibilidad => {
            class      => 'C4::Modelo::RefDisponibilidad',
            column_map => { id_disponibilidad => 'codigo' },
            type       => 'one to one',
        },
    ],
);

sub getId_tipo_prestamo{
    my ($self) = shift;
    return ($self->id_tipo_prestamo);
}
    
sub setId_tipo_prestamo{
    my ($self) = shift;
    my ($id_tipo_prestamo) = @_;
    $self->id_tipo_prestamo($id_tipo_prestamo);
}

sub getDescripcion{
    my ($self) = shift;

    return ($self->descripcion);
}
    
sub setDescripcion{
    my ($self) = shift;
    my ($descripcion) = @_;

    $self->descripcion($descripcion);
}

sub getId_disponibilidad{
    my ($self) = shift;

    return ($self->id_disponibilidad);
}
    
sub setId_disponibilidad{
    my ($self) = shift;
    my ($id_disponibilidad) = @_;

    $self->id_disponibilidad($id_disponibilidad);
}

sub getPrestamos{
    my ($self) = shift;
    return ($self->prestamos);
}
    
sub setPrestamos{
    my ($self) = shift;
    my ($prestamos) = @_;
    $self->prestamos($prestamos);
}

sub getDias_prestamo{
    my ($self) = shift;
    return ($self->dias_prestamo);
}
    
sub setDias_prestamo{
    my ($self) = shift;
    my ($dias_prestamo) = @_;
    $self->dias_prestamo($dias_prestamo);
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


sub getDias_renovacion{
    my ($self) = shift;
    return ($self->dias_renovacion);
}
    
sub setDias_renovacion{
    my ($self) = shift;
    my ($dias_renovacion) = @_;
    $self->renew($dias_renovacion);
}

sub getDias_antes_renovacion{
    my ($self) = shift;
    return ($self->dias_antes_renovacion);
}
    
sub setDias_antes_renovacion{
    my ($self) = shift;
    my ($dias_antes_renovacion) = @_;
    $self->dias_antes_renovacion($dias_antes_renovacion);
}

sub getHabilitado{
    my ($self) = shift;
    return ($self->habilitado);
}
    
sub setHabilitado{
    my ($self) = shift;
    my ($habilitado) = @_;
    $self->habilitado($habilitado);
}

sub obtenerValoresCampo {
    my ($self)=shift;
    my ($campo,$orden)=@_;
	use C4::Modelo::CircRefTipoPrestamo::Manager;
 	my $ref_valores = C4::Modelo::CircRefTipoPrestamo::Manager->get_circ_ref_tipo_prestamo
						( select  => [$self->meta->primary_key ,$campo],
						  sort_by => ($orden) );
    my @array_valores;

    for(my $i=0; $i<scalar(@$ref_valores); $i++ ){
		my $valor;
		$valor->{"clave"}=$ref_valores->[$i]->getId_tipo_prestamo;
		$valor->{"valor"}=$ref_valores->[$i]->getCampo($campo);
        push (@array_valores, $valor);
    }
	
    return (scalar(@array_valores), \@array_valores);
}

sub obtenerValorCampo {
	my ($self)=shift;
    my ($campo,$id)=@_;

	use C4::Modelo::CircRefTipoPrestamo::Manager;
 	my $ref_valores = C4::Modelo::CircRefTipoPrestamo::Manager->get_circ_ref_tipo_prestamo
						( select   => [$campo],
						  query =>[ id_tipo_prestamo => { eq => $id} ]);
    	
	return ($ref_valores->[0]->getCampo($campo));
}

sub getCampo{
    my ($self) = shift;
	my ($campo)=@_;

	if ($campo eq "id_tipo_prestamo") {return $self->getId_tipo_prestamo;}
	if ($campo eq "descripcion") {return $self->getDescripcion;}
	if ($campo eq "id_disponibilidad") {return $self->getId_disponibilidad;}
	if ($campo eq "prestamos") {return $self->getPrestamos;}
	if ($campo eq "dias_prestamo") {return $self->getDias_prestamo;}
	if ($campo eq "renovaciones") {return $self->getRenovaciones;}
	if ($campo eq "dias_renovacion") {return $self->getDias_renovacion;}
	if ($campo eq "dias_antes_renovacion") {return $self->getDias_antes_renovacion;}
	if ($campo eq "habilitado") {return $self->getHabilitado;}

	return (0);
}

sub nextMember{
    use C4::Modelo::RefSoporte;
    return(C4::Modelo::RefSoporte->new());
}

1;

