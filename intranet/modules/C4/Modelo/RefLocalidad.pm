package C4::Modelo::RefLocalidad;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'ref_localidad',

    columns => [
        id                    => { type => 'serial', not_null => 1 },
        LOCALIDAD        => { type => 'varchar', length => 11, not_null => 1 },
        NOMBRE           => { type => 'varchar', length => 100 },
        NOMBRE_ABREVIADO => { type => 'varchar', length => 40 },
        DPTO_PARTIDO     => { type => 'varchar', length => 11 },
        DDN              => { type => 'varchar', length => 11 },
    ],

    primary_key_columns => [ 'id' ],
    unique_key => [ 'LOCALIDAD' ],
);

sub toString{
	my ($self) = shift;

    return ($self->getNombre);
}    

sub getObjeto{
	my ($self) = shift;
	my ($id) = @_;

	my $objecto= C4::Modelo::RefLocalidad->new(LOCALIDAD => $id);
	$objecto->load();
	return $objecto;
}


sub getIdLocalidad{
    my ($self) = shift;
    return ($self->LOCALIDAD);
}

sub getNombre{
    my ($self) = shift;
    return ($self->NOMBRE);
}

sub getNombre_abreviado{
    my ($self) = shift;
    return ($self->NOMBRE_ABREVIADO);
}

sub setId_persona{
    my ($self) = shift;
    my ($nombre) = @_;
    $self->NOMBRE($nombre);
}


sub obtenerValoresCampo {
    my ($self)=shift;
    my ($campo,$orden)=@_;
	use C4::Modelo::RefLocalidad::Manager;
 	my $ref_valores = C4::Modelo::RefLocalidad::Manager->get_ref_localidad
						( select   => [$self->meta->primary_key , $campo],
						  sort_by => ($orden) );
    my @array_valores;

    for(my $i=0; $i<scalar(@$ref_valores); $i++ ){
		my $valor;
		$valor->{"clave"}=$ref_valores->[$i]->getIdLocalidad;
		$valor->{"valor"}=$ref_valores->[$i]->getCampo($campo);
        push (@array_valores, $valor);
    }
	
    return (scalar(@array_valores), \@array_valores);
}

sub obtenerValorCampo {
	my ($self)=shift;
    	my ($campo,$id)=@_;
	use C4::Modelo::RefLocalidad::Manager;
 	my $ref_valores = C4::Modelo::RefLocalidad::Manager->get_ref_localidad
						( select   => [$campo],
						  query =>[ LOCALIDAD => { eq => $id} ]);
    	
	return ($ref_valores->[0]->getCampo($campo));
}

sub getCampo{
    my ($self) = shift;
	my ($campo)=@_;
    
	if ($campo eq "LOCALIDAD") {return $self->LOCALIDAD;}
	if ($campo eq "NOMBRE") {return $self->NOMBRE;}
	if ($campo eq "NOMBRE_ABREVIADO") {return $self->NOMBRE_ABREVIADO;}
	if ($campo eq "DPTO_PARTIDO") {return $self->DPTO_PARTIDO;}
	if ($campo eq "DDN") {return $self->DDN;}
	return (0);
}


sub lastTable{
    
    return(1);
}

sub getAll{

    my ($self) = shift;
    my ($limit,$offset,$matchig_or_not,$filtro)=@_;
    use C4::Modelo::RefLocalidad::Manager;
    use Text::LevenshteinXS;
    $matchig_or_not = $matchig_or_not || 0;
    my @filtros;

    if ($filtro){
        my @filtros_or;
        push(@filtros_or, (NOMBRE => {like => '%'.$filtro.'%'}) );
        push(@filtros_or, (NOMBRE_ABREVIADO => {like => '%'.$filtro.'%'}) );
        push(@filtros, (or => \@filtros_or) );
    }
    my $ref_valores;
    if ($matchig_or_not){ #ESTOY BUSCANDO SIMILARES, POR LO TANTO NO TENGO QUE LIMITAR PARA PERDER RESULTADOS
        push(@filtros, ($self->getPk => {ne => $self->getPkValue}) );
        $ref_valores = C4::Modelo::RefLocalidad::Manager->get_ref_localidad(query => \@filtros,);
    }else{
        $ref_valores = C4::Modelo::RefLocalidad::Manager->get_ref_localidad(query => \@filtros,
                                                                    limit => $limit, 
                                                                    offset => $offset, 
                                                                    sort_by => ['nombre'] 
                                                                   );
    }
    my $ref_cant = C4::Modelo::RefLocalidad::Manager->get_ref_localidad_count(query => \@filtros,);
    my $self_nombre = $self->getNombre;

    my $match = 0;
    if ($matchig_or_not){
        my @matched_array;
        foreach my $each (@$ref_valores){
          $match = ((distance($self_nombre,$each->getNombre)<=1) || (distance($self_nombre,$each->getNombre_abreviado)<=1));
          if ($match){
            push (@matched_array,$each);
          }
        }
        return (scalar(@matched_array),\@matched_array);
    }
    else{
      return($ref_cant,$ref_valores);
    }
}

1;

