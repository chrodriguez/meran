package C4::Modelo::RefIdioma;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'ref_idioma',

    columns => [
        idLanguage   => { type => 'character',length => 2 ,not_null => 1 },
        description  => { type => 'varchar', length => 30, not_null => 1 },
    ],

    primary_key_columns => [ 'idLanguage' ],
);

sub toString{
	my ($self) = shift;

    return ($self->getDescription);
}    

sub getObjeto{
	my ($self) = shift;
	my ($id) = @_;

	my $objecto= C4::Modelo::RefIdioma->new(idLanguage => $id);
	$objecto->load();
	return $objecto;
}

    
sub getIdLanguage{
    my ($self) = shift;

    return ($self->idLanguage);
}
    
sub setIdLanguage{
    my ($self) = shift;
    my ($idLanguage) = @_;

    $self->idLanguage($idLanguage);
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
	use C4::Modelo::RefIdioma::Manager;
 	my $ref_valores = C4::Modelo::RefIdioma::Manager->get_ref_idioma
						( select   => [$self->meta->primary_key , $campo],
						  sort_by => ($orden) );
    my @array_valores;

    for(my $i=0; $i<scalar(@$ref_valores); $i++ ){
		my $valor;
		$valor->{"clave"}=$ref_valores->[$i]->getIdLanguage;
		$valor->{"valor"}=$ref_valores->[$i]->getCampo($campo);
        push (@array_valores, $valor);
    }
	
    return (scalar(@array_valores), \@array_valores);
}

sub obtenerValorCampo {
	my ($self)=shift;
    	my ($campo,$id)=@_;
	use C4::Modelo::RefIdioma::Manager;
 	my $ref_valores = C4::Modelo::RefIdioma::Manager->get_ref_idioma
						( select   => [$campo],
						  query =>[ idLanguage => { eq => $id} ]);
    	
	return ($ref_valores->[0]->getCampo($campo));
}

sub getCampo{
    my ($self) = shift;
	my ($campo)=@_;
    
	if ($campo eq "idLanguage") {return $self->getIdLanguage;}
	if ($campo eq "description") {return $self->getDescription;}

	return (0);
}



sub nextMember{
    use C4::Modelo::RefPais;
    return(C4::Modelo::RefPais->new());
}

sub getAll{

    my ($self) = shift;
    my ($limit,$offset)=@_;
    use C4::Modelo::RefIdioma::Manager;
    
    my $ref_valores = C4::Modelo::RefIdioma::Manager->get_ref_idioma( limit => $limit, offset => $offset);
        
    return ($ref_valores);
}

1;

