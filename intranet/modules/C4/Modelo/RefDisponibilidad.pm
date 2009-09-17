package C4::Modelo::RefDisponibilidad;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'ref_disponibilidad',

    columns => [
        codigo => { type => 'integer', not_null => 1 },
        nombre => { type => 'varchar', default => '', length => 255, not_null => 1 },
    ],

    primary_key_columns => [ 'codigo' ],
    unique_key => [ 'nombre' ],
);

sub toString{
	my ($self) = shift;

    return ($self->getNombre);
}    

sub getObjeto{
	my ($self) = shift;
	my ($id) = @_;

	my $objecto= C4::Modelo::RefDisponibilidad->new(codigo => $id);
	$objecto->load();
	return $objecto;
}


sub getCodigo{
    my ($self) = shift;

    return ($self->codigo);
}
    
sub setCodigo{
    my ($self) = shift;
    my ($codigo) = @_;

    $self->codigo($codigo);
}
    

sub getNombre{
    my ($self) = shift;
    return ($self->nombre);
}
    
sub setNombre{
    my ($self) = shift;
    my ($nombre) = @_;
    $self->nombre($nombre);
}

sub obtenerValoresCampo {
	my ($self)=shift;
    my ($campo, $orden)=@_;

	use C4::Modelo::RefDisponibilidad::Manager;
 	my $ref_valores = C4::Modelo::RefDisponibilidad::Manager->get_ref_disponibilidad
						( select   => [ $self->meta->primary_key ,$campo],
						  sort_by => ($orden) );
    my @array_valores;

    for(my $i=0; $i<scalar(@$ref_valores); $i++ ){
		my $valor;
		$valor->{"clave"}=$ref_valores->[$i]->getCodigo;
		$valor->{"valor"}=$ref_valores->[$i]->getCampo($campo);
        push (@array_valores, $valor);
    }
	
    return (scalar(@array_valores), \@array_valores);
}

sub obtenerValorCampo {
	my ($self)=shift;
    	my ($campo,$id)=@_;
	use C4::Modelo::RefDisponibilidad::Manager;
 	my $ref_valores = C4::Modelo::RefDisponibilidad::Manager->get_ref_disponibilidad
						( select   => [$campo],
						  query =>[ codigo => { eq => $id} ]);
    	
	return ($ref_valores->[0]->getCampo($campo));
}


sub getCampo{
    my ($self) = shift;
	my ($campo)=@_;
    
	if ($campo eq "codigo") {return $self->getCodigo;}
	if ($campo eq "nombre") {return $self->getNombre;}

	return (0);
}

sub nextMember{
    use C4::Modelo::CircRefTipoPrestamo;
    return(C4::Modelo::CircRefTipoPrestamo->new());
}


sub getAll{

    my ($self) = shift;
    my ($limit,$offset)=@_;
    use C4::Modelo::RefDisponibilidad::Manager;
    
    my $ref_valores = C4::Modelo::RefDisponibilidad::Manager->get_ref_disponibilidad( limit => $limit, offset => $offset);
        
    return ($ref_valores);
}

1;

