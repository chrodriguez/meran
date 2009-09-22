package C4::Modelo::RefEstado;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'ref_estado',

    columns => [
        codigo => { type => 'integer', not_null => 1 },
        nombre => { type => 'varchar', default => '', length => 255, not_null => 1 },
    ],

    primary_key_columns => [ 'codigo' ],
    unique_key => [ 'nombre' ],
);

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
    my ($campo,$orden)=@_;
	use C4::Modelo::RefEstado::Manager;
 	my $ref_valores = C4::Modelo::RefEstado::Manager->get_ref_estado
						( select   => [ $self->meta->primary_key , $campo],
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
	use C4::Modelo::RefEstado::Manager;
 	my $ref_valores = C4::Modelo::RefEstado::Manager->get_ref_estado
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
    use C4::Modelo::RefLocalidad;
    return(C4::Modelo::RefLocalidad->new());
}

sub getAll{

    my ($self) = shift;
    my ($limit,$offset,$matchig_or_not)=@_;
    use C4::Modelo::RefEstado::Manager;
    use Text::LevenshteinXS;
    $matchig_or_not = $matchig_or_not || 0;
    my @filtros;

    push(@filtros, ($self->getPk => {ne => $self->getPkValue}) );
    my $ref_valores;
    if ($matchig_or_not){ #ESTOY BUSCANDO SIMILARES, POR LO TANTO NO TENGO QUE LIMITAR PARA PERDER RESULTADOS
        $ref_valores = C4::Modelo::RefEstado::Manager->get_ref_estado(query => \@filtros,);
    }else{
        $ref_valores = C4::Modelo::RefEstado::Manager->get_ref_estado(query => \@filtros,
                                                                    limit => $limit, 
                                                                    offset => $offset, 
                                                                    sort_by => ['nombre'] 
                                                                   );
    }
    my $self_nombre = $self->getNombre;

    my $match = 0;
    if ($matchig_or_not){
        my @matched_array;
        foreach my $each (@$ref_valores){
          $match = ((distance($self_nombre,$each->getNombre)<=1));
          if ($match){
            push (@matched_array,$each);
          }
        }
        return (\@matched_array);
    }
    else{
      return($ref_valores);
    }
}

1;

