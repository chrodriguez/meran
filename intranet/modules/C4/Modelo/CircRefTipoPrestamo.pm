package C4::Modelo::CircRefTipoPrestamo;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'circ_ref_tipo_prestamo',

    columns => [
        issuecode    => { type => 'character', length => 2, not_null => 1 },
        description  => { type => 'text', length => 65535 },
        notforloan   => { type => 'integer', default => '0', not_null => 1 },
        maxissues    => { type => 'integer', default => '0', not_null => 1 },
        daysissues   => { type => 'integer', default => '0', not_null => 1 },
        renew        => { type => 'integer', default => '0', not_null => 1 },
        renewdays    => { type => 'integer', default => '0', not_null => 1 },
        dayscanrenew => { type => 'integer', default => '0', not_null => 1 },
        enabled      => { type => 'integer', default => 1 },
    ],

    primary_key_columns => [ 'issuecode' ],
);

sub getIssuecode{
    my ($self) = shift;
    return ($self->issuecode);
}
    
sub setIssuecode{
    my ($self) = shift;
    my ($issuecode) = @_;
    $self->issuecode($issuecode);
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

sub getNotforloan{
    my ($self) = shift;

    return ($self->notforloan);
}
    
sub setNotforloan{
    my ($self) = shift;
    my ($notforloan) = @_;

    $self->notforloan($notforloan);
}

sub getMaxissues{
    my ($self) = shift;
    return ($self->maxissues);
}
    
sub setMaxissues{
    my ($self) = shift;
    my ($maxissues) = @_;
    $self->maxissues($maxissues);
}

sub getDaysissues{
    my ($self) = shift;
    return ($self->daysissues);
}
    
sub setDaysissues{
    my ($self) = shift;
    my ($daysissues) = @_;
    $self->daysissues($daysissues);
}


sub getRenewdays{
    my ($self) = shift;
    return ($self->renewdays);
}
    
sub setRenewdays{
    my ($self) = shift;
    my ($renewdays) = @_;
    $self->renewdays($renewdays);
}


sub getRenew{
    my ($self) = shift;
    return ($self->renew);
}
    
sub setRenew{
    my ($self) = shift;
    my ($renew) = @_;
    $self->renew($renew);
}

sub getDayscanrenew{
    my ($self) = shift;
    return ($self->dayscanrenew);
}
    
sub setDayscanrenew{
    my ($self) = shift;
    my ($dayscanrenew) = @_;
    $self->dayscanrenew($dayscanrenew);
}

sub getEnabled{
    my ($self) = shift;
    return ($self->enabled);
}
    
sub setEenabled{
    my ($self) = shift;
    my ($enabled) = @_;
    $self->enabled($enabled);
}

sub obtenerValoresCampo {
	my ($self)=shift;
    my ($campo)=@_;
	use C4::Modelo::CircRefTipoPrestamo::Manager;
 	my $ref_valores = C4::Modelo::CircRefTipoPrestamo::Manager->get_circ_ref_tipo_prestamo
						( select   => [$self->meta->primary_key , $campo],
						  sort_by => ($campo) );
    my @array_valores;

    for(my $i=0; $i<scalar(@$ref_valores); $i++ ){
		my $valor;
		$valor->{"clave"}=$ref_valores->[$i]->getIssuecode;
		$valor->{"valor"}=$ref_valores->[$i]->getCampo($campo);
        push (@array_valores, $valor);
    }
	
    return (scalar(@array_valores), \@array_valores);
}

sub obtenerValorCampo {
	my ($self)=shift;
    	my ($campo,$id)=@_;
	use C4::Modelo::CircRefTipoPrestamo::Manager;
 	my $ref_valores = C4::Modelo::CircRefTipoPrestamo::Manager->get_circ_ref_tipo_prestamo
						( select   => [$campo],
						  query =>[ issuecode => { eq => $id} ]);
    	
	return ($ref_valores->[0]->getCampo($campo));
}

sub getCampo{
    my ($self) = shift;
	my ($campo)=@_;
    
	if ($campo eq "issuecode") {return $self->getIssuecode;}
	if ($campo eq "description") {return $self->getDescription;}
	if ($campo eq "notforloan") {return $self->getNotforloan;}
	if ($campo eq "maxissues") {return $self->getMaxissues;}
	if ($campo eq "daysissues") {return $self->getDaysissues;}
	if ($campo eq "renew") {return $self->getRenew;}
	if ($campo eq "renewdays") {return $self->getRenewdays;}
	if ($campo eq "dayscanrenew") {return $self->getDayscanrenew;}
	if ($campo eq "enabled") {return $self->getEnabled;}

	return (0);
}


sub nextMember{
    use C4::Modelo::RefSoporte;
    return(C4::Modelo::RefSoporte->new());
}

1;

