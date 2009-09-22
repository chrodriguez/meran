package C4::Modelo::RefSoporte;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'ref_soporte',

    columns => [
        idSupport   => { type => 'varchar',length => 10 ,not_null => 1 },
        description  => { type => 'varchar', length => 30, not_null => 1 },
    ],

    primary_key_columns => [ 'idSupport' ],
);

sub toString{
	my ($self) = shift;

    return ($self->getDescription);
}    

sub getObjeto{
	my ($self) = shift;
	my ($id) = @_;

	my $objecto= C4::Modelo::RefSoporte->new(idSupport => $id);
	$objecto->load();
	return $objecto;
}

sub getIdSupport{
    my ($self) = shift;

    return ($self->idSupport);
}
    
sub setIdSupport{
    my ($self) = shift;
    my ($idSupport) = @_;

    $self->idSupport($idSupport);
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
	use C4::Modelo::RefSoporte::Manager;
 	my $ref_valores = C4::Modelo::RefSoporte::Manager->get_ref_soporte
						( select   => [$self->meta->primary_key , $campo],
						  sort_by => ($orden) );
    my @array_valores;

    for(my $i=0; $i<scalar(@$ref_valores); $i++ ){
		my $valor;
		$valor->{"clave"}=$ref_valores->[$i]->getIdSupport;
		$valor->{"valor"}=$ref_valores->[$i]->getCampo($campo);
        push (@array_valores, $valor);
    }
	
    return (scalar(@array_valores), \@array_valores);
}

sub obtenerValorCampo {
	my ($self)=shift;
    	my ($campo,$id)=@_;
	use C4::Modelo::RefSoporte::Manager;
 	my $ref_valores = C4::Modelo::RefSoporte::Manager->get_ref_soporte
						( select   => [$campo],
						  query =>[ idSupport => { eq => $id} ]);
	return ($ref_valores->[0]->getCampo($campo));
}

sub getCampo{
    my ($self) = shift;
	my ($campo)=@_;
    
	if ($campo eq "idSupport") {return $self->getIdSupport;}
	if ($campo eq "description") {return $self->getDescription;}

	return (0);
}


sub nextMember{
    use C4::Modelo::RefNivelBibliografico;
    return(C4::Modelo::RefNivelBibliografico->new());
}

sub getAll{

    my ($self) = shift;
    my ($limit,$offset,$matchig_or_not)=@_;
    use C4::Modelo::RefSoporte::Manager;
    use Text::LevenshteinXS;
    $matchig_or_not = $matchig_or_not || 0;
    my @filtros;
    push(@filtros, ($self->getPk => {ne => $self->getPkValue}) );
    my $ref_valores;
    if ($matchig_or_not){ #ESTOY BUSCANDO SIMILARES, POR LO TANTO NO TENGO QUE LIMITAR PARA PERDER RESULTADOS
        $ref_valores = C4::Modelo::RefSoporte::Manager->get_ref_soporte(query => \@filtros,);
    }else{
        $ref_valores = C4::Modelo::RefSoporte::Manager->get_ref_soporte(query => \@filtros,
                                                                    limit => $limit, 
                                                                    offset => $offset, 
                                                                    sort_by => ['description'],
                                                                   );
    }
    my $self_description = $self->getDescription;

    my $match = 0;
    if ($matchig_or_not){
        my @matched_array;
        foreach my $each (@$ref_valores){
          $match = ((distance($self_description,$each->getDescription)<=1) );
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

