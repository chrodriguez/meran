package C4::Modelo::UsrRefTipoDocumento;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'usr_ref_tipo_documento',

    columns => [
        nombre            => { type => 'varchar', length => 50, not_null => 1 },
        descripcion       => { type => 'varchar', length => 250, not_null => 1 },
    ],

    primary_key_columns => [ 'nombre' ],
);


sub getDescripcion{
    my ($self) = shift;
    return ($self->descripcion);
}
    
sub setDescripcion{
    my ($self) = shift;
    my ($descripcion) = @_;
    $self->descripcion($descripcion);
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
	use C4::Modelo::UsrRefTipoDocumento::Manager;
 	my $ref_valores = C4::Modelo::UsrRefTipoDocumento::Manager->get_usr_ref_tipo_documento
						( select   => [$self->meta->primary_key , $campo],
						  sort_by => ($campo) );
    my @array_valores;

    for(my $i=0; $i<scalar(@$ref_valores); $i++ ){
		my $valor;
		$valor->{"clave"}=$ref_valores->[$i]->getNombre;
		$valor->{"valor"}=$ref_valores->[$i]->getCampo($campo);
        push (@array_valores, $valor);
    }
	
    return (scalar(@array_valores), \@array_valores);
}

sub obtenerValorCampo {
	my ($self)=shift;
    	my ($campo,$id)=@_;
	use C4::Modelo::UsrRefTipoDocumento::Manager;
 	my $ref_valores = C4::Modelo::UsrRefTipoDocumento::Manager->get_usr_ref_tipo_documento
						( select   => [$campo],
						  query =>[ descripcion => { eq => $id} ]);
	return ($ref_valores->[0]->getCampo($campo));
}

sub getCampo{
    my ($self) = shift;
	my ($campo)=@_;
    
	if ($campo eq "descripcion") {return $self->getDescripcion;}
	if ($campo eq "nombre") {return $self->getNombre;}

	return (0);
}


sub nextMember{
    use C4::Modelo::UsrRefCategoriasSocio;
    return(C4::Modelo::UsrRefCategoriasSocio->new());
}


1;

