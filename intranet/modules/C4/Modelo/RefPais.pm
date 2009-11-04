package C4::Modelo::RefPais;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'ref_pais',

    columns => [
        id           => { type => 'serial', not_null => 1 },
        iso          => { type => 'character', length => 2, not_null => 1 },
        iso3         => { type => 'character', default => '', length => 3, not_null => 1 },
        nombre       => { type => 'varchar', length => 80, not_null => 1 },
        nombre_largo => { type => 'varchar', length => 80, not_null => 1 },
        codigo       => { type => 'varchar', length => 11, not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],
    unique_key => [ 'iso' ],

);

sub toString{
	my ($self) = shift;

    return ($self->getIso);
}    

sub getObjeto{
	my ($self) = shift;
	my ($id) = @_;

	my $objecto= C4::Modelo::RefPais->new(codigo => $id);
	$objecto->load();
	return $objecto;
}


sub getIso{
    my ($self) = shift;

    return ($self->iso);
}
    
sub setIso{
    my ($self) = shift;
    my ($iso) = @_;
    $self->iso($iso);
}

sub getIso3{
    my ($self) = shift;
    return ($self->iso3);
}
    
sub setIso3{
    my ($self) = shift;
    my ($iso3) = @_;
    $self->iso3($iso3);
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

sub getNombre_largo{
    my ($self) = shift;
    return ($self->nombre_largo);
}
    
sub setNombre_largo{
    my ($self) = shift;
    my ($nombre) = @_;
    $self->nombre_largo($nombre);
}

sub getCodigo{
    my ($self) = shift;
    return ($self->codigo);
}
    
sub setCodigo{
    my ($self) = shift;
    my ($codigo) = @_;
    $self->codigo($codigo);
}

sub obtenerValoresCampo {
    my ($self)=shift;
    my ($campo,$orden)=@_;
	  use C4::Modelo::RefPais::Manager;
    my $ref_valores = C4::Modelo::RefPais::Manager->get_ref_pais
						  ( select   => ['iso' , $campo],
						    sort_by => ($orden) );
    my @array_valores;

    for(my $i=0; $i<scalar(@$ref_valores); $i++ ){
		  my $valor;
		  $valor->{"clave"}=$ref_valores->[$i]->getIso;
		  $valor->{"valor"}=$ref_valores->[$i]->getCampo($campo);
      push (@array_valores, $valor);
    }
	
    return (scalar(@array_valores), \@array_valores);
}

sub obtenerValorCampo {
	my ($self)=shift;
    	my ($campo,$id)=@_;
	use C4::Modelo::RefPais::Manager;
 	my $ref_valores = C4::Modelo::RefPais::Manager->get_ref_pais
						( select   => [$campo],
						  query =>[ iso => { eq => $id} ]);
# 	return ($ref_valores->[0]->getCampo($campo));
  if(scalar(@$ref_valores) > 0){
    return ($ref_valores->[0]->getCampo($campo));
  }else{
    C4::AR::Debug::debug("RefPais => obtenerValorCampo => no se pudo recuperar el objeto");
    return 'NO TIENE';
  }
}

sub getCampo{
    my ($self) = shift;
	my ($campo)=@_;
    
	if ($campo eq "iso") {return $self->getIso;}
	if ($campo eq "iso3") {return $self->getIso3;}
	if ($campo eq "nombre") {return $self->getNombre;}
	if ($campo eq "nombre_largo") {return $self->getNombre_largo;}
	if ($campo eq "codigo") {return $self->getCodigo;}
	return (0);
}


sub nextMember{
    use C4::Modelo::RefDisponibilidad;
    return(C4::Modelo::RefDisponibilidad->new());
}

sub getAll{

    my ($self) = shift;
    my ($limit,$offset,$matchig_or_not,$filtro)=@_;
    use C4::Modelo::RefPais::Manager;
    use Text::LevenshteinXS;
    $matchig_or_not = $matchig_or_not || 0;
    my @filtros;
    if ($filtro){
        my @filtros_or;
        push(@filtros_or, (nombre => {like => '%'.$filtro.'%'}) );
        push(@filtros_or, (nombre_largo => {like => '%'.$filtro.'%'}) );
        push(@filtros, (or => \@filtros_or) );
    }
    my $ref_valores;
    if ($matchig_or_not){ #ESTOY BUSCANDO SIMILARES, POR LO TANTO NO TENGO QUE LIMITAR PARA PERDER RESULTADOS
        push(@filtros, ($self->getPk => {ne => $self->getPkValue}) );
        $ref_valores = C4::Modelo::RefPais::Manager->get_ref_pais(query => \@filtros,);
    }else{
        $ref_valores = C4::Modelo::RefPais::Manager->get_ref_pais(query => \@filtros,
                                                                    limit => $limit, 
                                                                    offset => $offset, 
                                                                    sort_by => ['nombre','nombre_largo'] 
                                                                   );
    }
    my $ref_cant = C4::Modelo::RefPais::Manager->get_ref_pais_count(query => \@filtros,);
    my $self_nombre = $self->getNombre;
    my $self_nombre_largo = $self->getNombre_largo;

    my $match = 0;
    if ($matchig_or_not){
        my @matched_array;
        foreach my $each (@$ref_valores){
          $match = ((distance($self_nombre,$each->getNombre)<=1) or (distance($self_nombre_largo,$each->getNombre_largo)<=1));
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

