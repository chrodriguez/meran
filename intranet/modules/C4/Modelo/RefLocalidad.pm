package C4::Modelo::RefLocalidad;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'ref_localidad',

    columns => [
        LOCALIDAD        => { type => 'varchar', length => 11, not_null => 1 },
        NOMBRE           => { type => 'varchar', length => 100 },
        NOMBRE_ABREVIADO => { type => 'varchar', length => 40 },
        DPTO_PARTIDO     => { type => 'varchar', length => 11 },
        DDN              => { type => 'varchar', length => 11 },
    ],

    primary_key_columns => [ 'LOCALIDAD' ],
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

sub setId_persona{
    my ($self) = shift;
    my ($nombre) = @_;
    $self->NOMBRE($nombre);
}


sub obtenerValoresCampo {
	my ($self)=shift;
    my ($campo)=@_;
	use C4::Modelo::RefLocalidad::Manager;
 	my $ref_valores = C4::Modelo::RefLocalidad::Manager->get_ref_localidad
						( select   => [$self->meta->primary_key , $campo],
						  sort_by => ($campo) );
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

1;

