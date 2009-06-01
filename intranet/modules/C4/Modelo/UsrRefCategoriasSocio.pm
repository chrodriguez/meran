package C4::Modelo::UsrRefCategoriasSocio;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup
  (
    table   => 'usr_ref_categoria_socio',
    columns =>
        [
            categorycode    => { type => 'char', not_null => 1 , length => 2},
            description  => { type => 'varchar', length => 255, not_null => 1 },
        ],
    primary_key_columns => 'categorycode',
    unique_key => 'categorycode',
    relationships => [],
);

# 
# categorycode    char(2)     latin1_swedish_ci       No                Navegar los valores distintivos         Cambiar         Eliminar        Primaria        Único       Índice     Texto completo
#     description     text    latin1_swedish_ci       Sí  NULL        Navegar los valores distintivos     Cambiar     Eliminar    Primaria    Único   Índice  Texto completo
#     enrolmentperiod     smallint(6)             Sí  NULL        Navegar los valores distintivos     Cambiar     Eliminar    Primaria    Único   Índice  Texto completo
#     upperagelimit   smallint(6)             Sí  NULL        Navegar los valores distintivos     Cambiar     Eliminar    Primaria    Único   Índice  Texto completo
#     dateofbirthrequired     tinyint(1)          Sí  NULL        Navegar los valores distintivos     Cambiar     Eliminar    Primaria    Único   Índice  Texto completo
#     finetype    varchar(30)     latin1_swedish_ci       Sí  NULL        Navegar los valores distintivos     Cambiar     Eliminar    Primaria    Único   Índice  Texto completo
#     bulk    tinyint(1)          Sí  NULL        Navegar los valores distintivos     Cambiar     Eliminar    Primaria    Único   Índice  Texto completo
#     enrolmentfee    decimal(28,6)           Sí  NULL        Navegar los valores distintivos     Cambiar     Eliminar    Primaria    Único   Índice  Texto completo
#     overduenoticerequired   tinyint(1)          Sí  NULL        Navegar los valores distintivos     Cambiar     Eliminar    Primaria    Único   Índice  Texto completo
#     issuelimit  smallint(6)             Sí  NULL        Navegar los valores distintivos     Cambiar     Eliminar    Primaria    Único   Índice  Texto completo
#     reservefee  decimal(28,6)           Sí  NULL        Navegar los valores distintivos     Cambiar     Eliminar    Primaria    Único   Índice  Texto completo
#     borrowingdays   smallint(30)
# 
# 
#   __PACKAGE__->meta->setup
#   (
#     table => 'usr_ref_categoria_socio',
#     auto  => 1,
#   );


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
    return ($self->description);
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

	use C4::Modelo::UsrRefCategoriasSocio::Manager;
 	my $ref_valores = C4::Modelo::UsrRefCategoriasSocio::Manager->get_usr_ref_categoria_socio
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
	use C4::Modelo::UsrRefCategoriasSocio::Manager;
 	my $ref_valores = C4::Modelo::UsrRefCategoriasSocio::Manager->get_usr_ref_categoria_socio
						( select   => [$campo],
						  query =>[ categorycode => { eq => $id} ]);
    	
	return ($ref_valores->[0]->getCampo($campo));
}

sub getCampo{
    my ($self) = shift;
	my ($campo)=@_;
    
	if ($campo eq "categorycode") {return $self->getCategory_code;}
	if ($campo eq "description") {return $self->getDescription;}

	return (0);
}


sub nextMember{
    use C4::Modelo::CatTema;
    return(C4::Modelo::CatTema->new());
}
1;
