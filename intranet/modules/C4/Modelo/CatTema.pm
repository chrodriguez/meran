package C4::Modelo::CatTema;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_tema',

    columns => [
        id     => { type => 'serial', not_null => 1 },
        nombre => { type => 'text', length => 65535, not_null => 1 },
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
    my ($campo)=@_;
	use C4::Modelo::CatTema::Manager;
 	my $ref_valores = C4::Modelo::CatTema::Manager->get_cat_tema
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
	use C4::Modelo::CatTema::Manager;
 	my $ref_valores = C4::Modelo::CatTema::Manager->get_cat_tema
						( select   => [$campo],
						  query =>[ id => { eq => $id} ]);
    	
	return ($ref_valores->[0]->getCampo($campo));
}


sub getCampo{
    my ($self) = shift;
	my ($campo)=@_;
    
	if ($campo eq "id") {return $self->getId;}
	if ($campo eq "nombre") {return $self->getNombre;}

	return (0);
}





=item
Devuelve si es o no la ultima tabla de la cadena de referencias
=cut
sub lastTable{
    return (1);
}

sub nextMember{

#     return(C4::Modelo::CatTema()->new());
}

1;

