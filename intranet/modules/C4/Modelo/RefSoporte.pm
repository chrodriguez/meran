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
    my ($campo)=@_;
	use C4::Modelo::RefSoporte::Manager;
 	my $ref_valores = C4::Modelo::RefSoporte::Manager->get_ref_soporte
						( select   => [$self->meta->primary_key , $campo],
						  sort_by => ($campo) );
    my @array_valores;

    for(my $i=0; $i<scalar(@$ref_valores); $i++ ){
		my $valor;
		$valor->{"clave"}=$ref_valores->[$i]->getIdSupport;
		$valor->{"valor"}=$ref_valores->[$i]->getCampo($campo);
        push (@array_valores, $valor);
    }
	
    return (scalar(@array_valores), \@array_valores);
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

1;

