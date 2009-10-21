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


=item
    Returns true (1) if the row was loaded successfully
    undef if the row could not be loaded due to an error, 
    zero (0) if the row does not exist.
=cut
sub load{
    my $self = $_[0]; # Copy, not shift
    

    my $error = 1;

    eval {
    
         unless( $self->SUPER::load(speculative => 1) ){
                 C4::AR::Debug::debug("CatAutor=>  dentro del unless, no existe el objeto SUPER load");
                $error = 0;
         }

        C4::AR::Debug::debug("CatAutor=>  SUPER load");
        return $self->SUPER::load(@_);
    };

    if($@){
        C4::AR::Debug::debug("CatAutor=>  no existe el objeto");
        $error = undef;
    }

    return $error;
}

sub toString{
	my ($self) = shift;

    return ($self->getCompleto);
}

sub getObjeto{
	my ($self) = shift;
	my ($id) = @_;

	my $autor= C4::Modelo::CatAutor->new(id => $id);
	$autor->load();
	return $autor;
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
    my ($campo, $orden)=@_;

	use C4::Modelo::CatAutor::Manager;
 	my $ref_valores = C4::Modelo::CatAutor::Manager->get_cat_autor
						( select   => [$campo],
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

sub getAll{

    my ($self) = shift;
    my ($limit,$offset,$matchig_or_not,$filtro)=@_;
    use C4::Modelo::CatAutor::Manager;
    use Text::LevenshteinXS;
    $matchig_or_not = $matchig_or_not || 0;
    my @filtros;
    if ($filtro){
        my @filtros_or;
        push(@filtros_or, (nombre => {like => '%'.$filtro.'%'}) );
        push(@filtros_or, (apellido => {like => '%'.$filtro.'%'}) );
        push(@filtros, (or => \@filtros_or) );
    }
    my $ref_valores;
    if ($matchig_or_not){ #ESTOY BUSCANDO SIMILARES, POR LO TANTO NO TENGO QUE LIMITAR PARA PERDER RESULTADOS
        push(@filtros, ($self->getPk => {ne => $self->getPkValue}) );
        $ref_valores = C4::Modelo::CatAutor::Manager->get_cat_autor(query => \@filtros,);
    }else{
        $ref_valores = C4::Modelo::CatAutor::Manager->get_cat_autor(query => \@filtros,
                                                                    limit => $limit, 
                                                                    offset => $offset, 
                                                                    sort_by => ['nombre'] 
                                                                   );
    }
    my $self_nombre = $self->getNombre;
    my $self_apellido = $self->getApellido;

    my $match = 0;
    if ($matchig_or_not){
        my @matched_array;
        foreach my $autor (@$ref_valores){
          $match = ((distance($self_nombre,$autor->getNombre)<=1) or (distance($self_apellido,$autor->getApellido)<=1));
          if ($match){
            push (@matched_array,$autor);
          }
        }
        return (\@matched_array);
    }
    else{
      return($ref_valores);
    }
}

1;

