package C4::Modelo::CatRefTipoNivel3;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_ref_tipo_nivel3',

    columns => [
        id_tipo_doc           => { type => 'varchar', length => 4, not_null => 1 },
        nombre                => { type => 'varchar', length => 255, not_null => 1 },
    ],

    primary_key_columns => [ 'id_tipo_doc' ],
);


sub getId_tipo_doc{
    my ($self) = shift;
    return ($self->id_tipo_doc);
}

sub setId_tipo_doc{
    my ($self) = shift;
    my ($id_tipo_doc) = @_;
    $self->id_tipo_doc($id_tipo_doc);
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

sub nextMember{
    use C4::Modelo::PrefUnidadInformacion;
    return(C4::Modelo::PrefUnidadInformacion->new());
}


sub obtenerValoresCampo {
    my ($self)=shift;
    my ($campo,$orden)=@_;
	
 	my $ref_valores = C4::Modelo::CatRefTipoNivel3::Manager->get_cat_ref_tipo_nivel3
						( select   => [$self->meta->primary_key , $campo],
						  sort_by => ($orden) );
    my @array_valores;

    for(my $i=0; $i<scalar(@$ref_valores); $i++ ){
		my $valor;
		$valor->{"clave"}=$ref_valores->[$i]->getId_tipo_doc;
		$valor->{"valor"}=$ref_valores->[$i]->getCampo($campo);
        push (@array_valores, $valor);
    }
	
    return (scalar(@array_valores), \@array_valores);
}

sub obtenerValorCampo {
	my ($self)=shift;
    	my ($campo,$id)=@_;
	use C4::Modelo::CatRefTipoNivel3::Manager;
 	my $ref_valores = C4::Modelo::CatRefTipoNivel3::Manager->get_cat_ref_tipo_nivel3
						( select   => [$campo],
						  query =>[ id_tipo_doc => { eq => $id} ]);
    	
	return ($ref_valores->[0]->getCampo($campo));
}


sub getCampo{
    my ($self) = shift;
	my ($campo)=@_;
    
	if ($campo eq "id_tipo_doc") {return $self->getId_tipo_doc;}
	if ($campo eq "nombre") {return $self->getNombre;}

	return (0);
}

sub getAll{

    my ($self) = shift;
    my ($limit,$offset)=@_;
    use C4::Modelo::CatRefTipoNivel3::Manager;
    
    my $ref_valores = C4::Modelo::CatRefTipoNivel3::Manager->get_cat_ref_tipo_nivel3( limit => $limit, offset => $offset);
        
    return ($ref_valores);
}

1;

