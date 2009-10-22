package C4::Modelo::RefNivelBibliografico;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'ref_nivel_bibliografico',

    columns => [
        id                    => { type => 'serial', not_null => 1 },
        code        => { type => 'varchar', length => 4, not_null => 1 },
        description => { type => 'varchar', default => '', length => 20, not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],
    unique_key => [ 'code' ],

);

sub toString{
	my ($self) = shift;

    return ($self->getDescription);
}    

sub getObjeto{
	my ($self) = shift;
	my ($id) = @_;

	my $objecto= C4::Modelo::RefNivelBibliografico->new(code => $id);
	$objecto->load();
	return $objecto;
}


sub getCode{
    my ($self) = shift;

    return ($self->code);
}
    
sub setCode{
    my ($self) = shift;
    my ($code) = @_;

    $self->code($code);
}

    
sub getDescription{
    my ($self) = shift;

    return ($self->description);
}
    
sub setDescription{
    my ($self) = shift;
    my ($description) = @_;

    $self->description($description);
}

sub obtenerValoresCampo {
    my ($self)=shift;
    my ($campo,$orden)=@_;
	use C4::Modelo::RefNivelBibliografico::Manager;
 	my $ref_valores = C4::Modelo::RefNivelBibliografico::Manager->get_ref_nivel_bibliografico
						( select   => [$self->meta->primary_key , $campo],
						  sort_by => ($orden) );
    my @array_valores;

    for(my $i=0; $i<scalar(@$ref_valores); $i++ ){
		my $valor;
		$valor->{"clave"}=$ref_valores->[$i]->getCode;
		$valor->{"valor"}=$ref_valores->[$i]->getCampo($campo);
        push (@array_valores, $valor);
    }
	
    return (scalar(@array_valores), \@array_valores);
}

sub obtenerValorCampo {
	my ($self)=shift;
    	my ($campo,$id)=@_;
	use C4::Modelo::RefNivelBibliografico::Manager;
 	my $ref_valores = C4::Modelo::RefNivelBibliografico::Manager->get_ref_nivel_bibliografico
						( select   => [$campo],
						  query =>[ code => { eq => $id} ]);
	return ($ref_valores->[0]->getCampo($campo));
}


sub getCampo{
    my ($self) = shift;
	my ($campo)=@_;
    
	if ($campo eq "code") {return $self->getCode;}
	if ($campo eq "description") {return $self->getDescription;}

	return (0);
}


sub nextMember{
    use C4::Modelo::CatTema;
    return(C4::Modelo::CatTema->new());
}

sub getAll{

    my ($self) = shift;
    my ($limit,$offset,$matchig_or_not,$filtro)=@_;
    use C4::Modelo::RefNivelBibliografico::Manager;
    use Text::LevenshteinXS;
    $matchig_or_not = $matchig_or_not || 0;
    my @filtros;
    if ($filtro){
        my @filtros_or;
        push(@filtros_or, (code => {like => '%'.$filtro.'%'}) );
        push(@filtros_or, (description => {like => '%'.$filtro.'%'}) );
        push(@filtros, (or => \@filtros_or) );
    }
    my $ref_valores;
    if ($matchig_or_not){ #ESTOY BUSCANDO SIMILARES, POR LO TANTO NO TENGO QUE LIMITAR PARA PERDER RESULTADOS
        push(@filtros, ($self->getPk => {ne => $self->getPkValue}) );
        $ref_valores = C4::Modelo::RefNivelBibliografico::Manager->get_ref_nivel_bibliografico(query => \@filtros,);
    }else{
        $ref_valores = C4::Modelo::RefNivelBibliografico::Manager->get_ref_nivel_bibliografico(query => \@filtros,
                                                                    limit => $limit, 
                                                                    offset => $offset, 
                                                                    sort_by => ['description'] 
                                                                   );
    }
    my $ref_cant = C4::Modelo::RefNivelBibliografico::Manager->get_ref_nivel_bibliografico_count(query => \@filtros,);
    my $self_descripcion = $self->getDescription;

    my $match = 0;
    if ($matchig_or_not){
        my @matched_array;
        foreach my $each (@$ref_valores){
          $match = ((distance($self_descripcion,$each->getDescription)<=1));
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

