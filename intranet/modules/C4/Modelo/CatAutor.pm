package C4::Modelo::CatAutor;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_autor',

    columns => [
        id           => { type => 'serial', not_null => 1 },
        nombre       => { type => 'text', length => 65535, not_null => 1 },
        apellido     => { type => 'text', length => 65535, not_null => 1 },
        nacionalidad => { type => 'character', length => 3 },
        completo     => { type => 'text', length => 65535, not_null => 1 },
    ],
#     alias_column => ['id', 'campo'],
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

    
sub getNombre{
    my ($self) = shift;

    return ($self->nombre);
}
    
sub setNombre{
    my ($self) = shift;
    my ($nombre) = @_;

    $self->nombre($nombre);
}

    
sub getApellido{
    my ($self) = shift;

    return ($self->apellido);
}
    
sub setApellido{
    my ($self) = shift;
    my ($apellido) = @_;

    $self->apellido($apellido);
}

sub getNacionalidad{
    my ($self) = shift;

    return ($self->nacionalidad);
}
    
sub setNacionalidad{
    my ($self) = shift;
    my ($nacionalidad) = @_;

    $self->nacionalidad($nacionalidad);
}

sub getCompleto{
    my ($self) = shift;

    return ($self->completo);
}
    
sub setCompleto{
    my ($self) = shift;
    my ($completo) = @_;

    $self->completo($completo);
}

sub nextMember{
    use C4::Modelo::CatRefTipoNivel3;
    return(C4::Modelo::CatRefTipoNivel3->new());
}

sub obtenerValoresCampo {
	my ($self)=shift;
    my ($campo)=@_;
	use C4::Modelo::CatAutor::Manager;
 	my $ref_valores = C4::Modelo::CatAutor::Manager->get_cat_autor
						( select   => [$self->meta->primary_key , $campo],
						  sort_by => ($campo) );
    my @array_valores;

    for(my $i=0; $i<scalar(@$ref_valores); $i++ ){
		my $valor;
		$valor->{"clave"}=$ref_valores->[$i]->getId;
		$valor->{"valor"}=$ref_valores->[$i]->getCampo($campo);
        push (@array_valores, $valor);
    }
	
    return (scalar(@array_valores), \@array_valores);
}

sub obtenerValorCampo {
	my ($self)=shift;
    my ($campo,$id)=@_;

	use C4::Modelo::CatAutor::Manager;
 	my $ref_valores = C4::Modelo::CatAutor::Manager->get_cat_autor
						( select   => [$campo],
						  query =>[ id => { eq => $id} ]);
    	
	return ($ref_valores->[0]->getCampo($campo));
}


sub getCampo{
    my ($self) = shift;
	my ($campo)=@_;
    
	if ($campo eq "id") {return $self->getId;}
	if ($campo eq "nombre") {return $self->getNombre;}
	if ($campo eq "apellido") {return $self->getApellido;}
	if ($campo eq "completo") {return $self->getCompleto;}
	if ($campo eq "nacionalidad") {return $self->getNacionalidad;}

	return (0);
}
1;

