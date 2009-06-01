package C4::Modelo::CatEditorial;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_editorial',

    columns => [
        id     => { type => 'serial', not_null => 1 },
        editorial => { type => 'text', length => 255, not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],
);


sub toString{
	my ($self) = shift;

    return ($self->getEditorial);
}    

sub getObjeto{
	my ($self) = shift;
	my ($id) = @_;

	my $objecto= C4::Modelo::CatTema->new(id => $id);
	$objecto->load();
	return $objecto;
}


sub getId{
    my ($self) = shift;

    return ($self->id);
}
    
sub setId{
    my ($self) = shift;
    my ($id) = @_;

    $self->id($id);
}

    
sub getEditorial{
    my ($self) = shift;

    return ($self->editorial);
}
    
sub setEditorial{
    my ($self) = shift;
    my ($editorial) = @_;

    $self->editorial($editorial);
}

sub obtenerValoresCampo {
    my ($self)=shift;
    my ($campo,$orden)=@_;
	use C4::Modelo::CatTema::Manager;
 	my $ref_valores = C4::Modelo::CatTema::Manager->get_cat_tema
						( select   => [$self->meta->primary_key , $campo],
						  sort_by => ($orden) );
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
	if ($campo eq "editorial") {return $self->getEditorial;}

	return (0);
}


sub nextMember{
    use C4::Modelo::RefEstado;

    return(C4::Modelo::RefEstado->new());
}

1;

