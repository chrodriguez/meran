package C4::Modelo::UsrRefCategoriaSocio;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup
  (
    table   => 'usr_ref_categoria_socio',
    columns =>
        [
#             id                    => { type => 'serial', not_null => 1 }, MAS ADELANTE DESCOMENTAAR; CUANDO LA DB SE HAGA NUEVA
            categorycode    => { type => 'char', not_null => 1 , length => 2},
            description  => { type => 'varchar', length => 255, not_null => 1 },
        ],
#     primary_key_columns => ['id'],MAS ADELANTE DESCOMENTAAR; CUANDO LA DB SE HAGA NUEVA
    primary_key_columns => ['categorycode'], #MAS ADELANTE ELIMINAR; CUANDO LA DB SE HAGA NUEVA
    unique_key => ['categorycode'],

);

sub nextMember{
    use C4::Modelo::UsrRefTipoDocumento;
    return(C4::Modelo::UsrRefTipoDocumento->new());
}

sub getCategory_code{
    my ($self) = shift;
    return ($self->categorycode);
}

sub setCategory_code{
    my ($self) = shift;
    my ($category_code) = @_;
    $self->categorycode($category_code);
}


sub getDescription{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->description));
}

sub setDescription{
    my ($self) = shift;
    my ($description) = @_;
    $self->description($description);
}

sub getEnrolment_period{
    my ($self) = shift;
    return ($self->enrolment_period);
}

sub setEnrolment_period{
    my ($self) = shift;
    my ($enrolment_period) = @_;
    $self->enrolment_period($enrolment_period);
}

sub getUpper_age_limit{
    my ($self) = shift;
    return ($self->upper_age_limit);
}

sub setUpper_age_limit{
    my ($self) = shift;
    my ($upper_age_limit) = @_;
    $self->upper_age_limit($upper_age_limit);
}

sub getDate_of_birth_required{
    my ($self) = shift;
    return ($self->date_of_birth_required);
}

sub setDate_of_birth_required{
    my ($self) = shift;
    my ($date_of_birth_required) = @_;
    $self->date_of_birth_required($date_of_birth_required);
}

sub getFine_type{
    my ($self) = shift;
    return ($self->fine_type);
}

sub setFine_type{
    my ($self) = shift;
    my ($fine_type) = @_;
    $self->fine_type($fine_type);
}

sub getBulk{
    my ($self) = shift;
    return ($self->bulk);
}

sub setBulk{
    my ($self) = shift;
    my ($bulk) = @_;
    $self->bulk($bulk);
}

sub getEnrolment_fee{
    my ($self) = shift;
    return ($self->enrolment_fee);
}

sub setEnrolment_fee{
    my ($self) = shift;
    my ($enrolment_fee) = @_;
    $self->enrolment_fee($enrolment_fee);
}

sub getOver_due_notice_required{
    my ($self) = shift;
    return ($self->over_due_notice_required);
}

sub setOver_due_notice_required{
    my ($self) = shift;
    my ($over_due_notice_required) = @_;
    $self->over_due_notice_required($over_due_notice_required);
}

sub getIssue_limit{
    my ($self) = shift;
    return ($self->issue_limit);
}

sub setIssue_limit{
    my ($self) = shift;
    my ($issue_limit) = @_;
    $self->issue_limit($issue_limit);
}

sub getReserve_fee{
    my ($self) = shift;
    return ($self->reserve_fee);
}

sub setReserve_fee{
    my ($self) = shift;
    my ($reserve_fee) = @_;
    $self->reserve_fee($reserve_fee);
}

sub getBorrowing_days{
    my ($self) = shift;
    return ($self->borrowing_days);
}

sub setBorrowing_days{
    my ($self) = shift;
    my ($borrowing_days) = @_;
    $self->borrowing_days($borrowing_days);
}


sub obtenerValoresCampo {
    my ($self)=shift;
    my ($campo, $orden)=@_;

    use C4::Modelo::UsrRefCategoriaSocio::Manager;
    my $ref_valores = C4::Modelo::UsrRefCategoriaSocio::Manager->get_usr_ref_categoria_socio
                        ( select   => [$self->meta->primary_key ,$campo],
                          sort_by => ($orden) );
    my @array_valores;

    for(my $i=0; $i<scalar(@$ref_valores); $i++ ){
        my $valor;
        $valor->{"clave"}=$ref_valores->[$i]->getCategory_code;
        $valor->{"valor"}=$ref_valores->[$i]->getCampo($campo);
        push (@array_valores, $valor);
    }
    
    return (scalar(@array_valores), \@array_valores);
}

sub obtenerValorCampo {
    my ($self)=shift;
        my ($campo,$id)=@_;
    use C4::Modelo::UsrRefCategoriaSocio::Manager;
    my $ref_valores = C4::Modelo::UsrRefCategoriaSocio::Manager->get_usr_ref_categoria_socio
                        ( select   => [$campo],
                          query =>[ categorycode => { eq => $id} ]);
        
#   return ($ref_valores->[0]->getCampo($campo));
  if(scalar(@$ref_valores) > 0){
    return ($ref_valores->[0]->getCampo($campo));
  }else{
    C4::AR::Debug::debug("UsrRefCategoriaSocio => obtenerValorCampo => no se pudo recuperar el objeto");
    return 'NO TIENE';
  }
}

sub getCampo{
    my ($self) = shift;
    my ($campo)=@_;
    
    if ($campo eq "categorycode") {return $self->getCategory_code;}
    if ($campo eq "description") {return $self->getDescription;}

    return (0);
}


sub getAll{

    my ($self) = shift;
    my ($limit,$offset,$matchig_or_not,$filtro)=@_;
    use C4::Modelo::UsrRefCategoriaSocio::Manager;
    use Text::LevenshteinXS;
    $matchig_or_not = $matchig_or_not || 0;
    my @filtros;
    if ($filtro){
        my @filtros_or;
        push(@filtros_or, (categorycode => {like => '%'.$filtro.'%'}) );
        push(@filtros_or, (description => {like => '%'.$filtro.'%'}) );
        push(@filtros, (or => \@filtros_or) );
    }
    my $ref_valores;
    if ($matchig_or_not){ #ESTOY BUSCANDO SIMILARES, POR LO TANTO NO TENGO QUE LIMITAR PARA PERDER RESULTADOS
        push(@filtros, ($self->getPk => {ne => $self->getPkValue}) );
        $ref_valores = C4::Modelo::UsrRefCategoriaSocio::Manager->get_usr_ref_categoria_socio(query => \@filtros,);
    }else{
        $ref_valores = C4::Modelo::UsrRefCategoriaSocio::Manager->get_usr_ref_categoria_socio(query => \@filtros,
                                                                    limit => $limit, 
                                                                    offset => $offset, 
                                                                    sort_by => ['description'] 
                                                                   );
    }
    my $ref_cant = C4::Modelo::UsrRefCategoriaSocio::Manager->get_usr_ref_categoria_socio_count(query => \@filtros,);
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