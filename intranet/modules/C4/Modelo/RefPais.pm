package C4::Modelo::RefPais;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'ref_pais',

    columns => [
        iso          => { type => 'character', length => 2, not_null => 1 },
        iso3         => { type => 'character', default => '', length => 3, not_null => 1 },
        nombre       => { type => 'varchar', length => 80, not_null => 1 },
        nombre_largo => { type => 'varchar', length => 80, not_null => 1 },
        codigo       => { type => 'varchar', length => 11, not_null => 1 },
    ],

    primary_key_columns => [ 'iso' ],
);

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
    my ($campo)=@_;
	use C4::Modelo::RefPais::Manager;
 	my $ref_valores = C4::Modelo::RefPais::Manager->get_ref_pais
						( select   => [$self->meta->primary_key , $campo],
						  sort_by => ($campo) );
    my @array_valores;

    for(my $i=0; $i<scalar(@$ref_valores); $i++ ){
		my $valor;
		$valor->{"clave"}=$ref_valores->[$i]->getIso;
		$valor->{"valor"}=$ref_valores->[$i]->getCampo($campo);
        push (@array_valores, $valor);
    }
	
    return (scalar(@array_valores), \@array_valores);
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

1;

