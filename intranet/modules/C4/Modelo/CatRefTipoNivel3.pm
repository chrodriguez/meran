package C4::Modelo::CatRefTipoNivel3;

use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_ref_tipo_nivel3',

    columns => [
        id_tipo_doc           => { type => 'varchar', length => 4, not_null => 1 },
        nombre                => { type => 'varchar', length => 255, not_null => 1 },
        agregacion_temp       => { type => 'varchar', length => 250 },

    ],

    primary_key_columns => [ 'id_tipo_doc' ],
);

use C4::Modelo::PrefUnidadInformacion;
use C4::Modelo::CatRefTipoNivel3::Manager;
use Text::LevenshteinXS;


sub getId_tipo_doc{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->id_tipo_doc));
}

sub setId_tipo_doc{
    my ($self) = shift;
    my ($id_tipo_doc) = @_;
    $self->id_tipo_doc($id_tipo_doc);
}

sub getNombre{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->nombre));
}

sub setNombre{
    my ($self) = shift;
    my ($nombre) = @_;
    $self->nombre($nombre);
}

sub nextMember{
    return(C4::Modelo::PrefUnidadInformacion->new());
}


sub obtenerValoresCampo {
    my ($self)=shift;
    my ($campo,$orden)=@_;
	
 	my $ref_valores = C4::Modelo::CatRefTipoNivel3::Manager->get_cat_ref_tipo_nivel3
# 						( select   => [$self->meta->primary_key , $campo],
              ( select   => ['id_tipo_doc' , $campo],
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
    my $ref_valores = C4::Modelo::CatRefTipoNivel3::Manager->get_cat_ref_tipo_nivel3
						( select   => [$campo],
						  query =>[ id_tipo_doc => { eq => $id} ]);
    	
# 	return ($ref_valores->[0]->getCampo($campo));
  if(scalar(@$ref_valores) > 0){
    return ($ref_valores->[0]->getCampo($campo));
  }else{
    C4::AR::Debug::debug("CatRefTipoNivel3 => obtenerValorCampo => no se pudo recuperar el objeto");
    return 'NO TIENE';
  }
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
    my ($limit,$offset,$matchig_or_not,$filtro)=@_;
    $matchig_or_not = $matchig_or_not || 0;
    my @filtros;
    if ($filtro){
        my @filtros_or;
        push(@filtros_or, (nombre => {like => '%'.$filtro.'%'}) );
        push(@filtros, (or => \@filtros_or) );
    }
    my $ref_valores;
    if ($matchig_or_not){ #ESTOY BUSCANDO SIMILARES, POR LO TANTO NO TENGO QUE LIMITAR PARA PERDER RESULTADOS
        push(@filtros, ($self->getPk => {ne => $self->getPkValue}) );
        $ref_valores = C4::Modelo::CatRefTipoNivel3::Manager->get_cat_ref_tipo_nivel3(query => \@filtros,);
    }else{
        $ref_valores = C4::Modelo::CatRefTipoNivel3::Manager->get_cat_ref_tipo_nivel3(query => \@filtros,
                                                                    limit => $limit, 
                                                                    offset => $offset, 
                                                                    sort_by => ['nombre'] 
                                                                   );
    }
    my $ref_cant = C4::Modelo::CatRefTipoNivel3::Manager->get_cat_ref_tipo_nivel3_count(query => \@filtros,);

    my $self_nombre = $self->getNombre;

    my $match = 0;
    if ($matchig_or_not){
        my @matched_array;
        foreach my $autor (@$ref_valores){
          $match = ((distance($self_nombre,$autor->getNombre)<=1));
          if ($match){
            push (@matched_array,$autor);
          }
        }
        return (scalar(@matched_array),\@matched_array);
    }
    else{
      return($ref_cant,$ref_valores);
    }
}

1;

