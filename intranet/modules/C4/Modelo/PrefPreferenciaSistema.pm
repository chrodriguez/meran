package C4::Modelo::PrefPreferenciaSistema;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'pref_preferencia_sistema',

    columns => [
        id          => { type => 'serial' },
        variable    => { type => 'varchar', length => 50, not_null => 1 },
        value       => { type => 'text', length => 65535 },
        explanation => { type => 'varchar', default => '', length => 200, not_null => 1 },
        options     => { type => 'text', length => 65535 },
        type        => { type => 'varchar', length => 20 },
        categoria   => { type => 'varchar', length => 20 },
    ],

    primary_key_columns => [ 'id' ],
    unique_key => [ 'variable' ],
);

sub defaultSort {
     return ('variable');
}

sub getVariable{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->variable));
}

sub setVariable{
    my ($self) = shift;
    my ($variable) = @_;
    $self->variable($variable);
}

sub getValue{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->value));
}

sub setValue{
    my ($self) = shift;
    my ($value) = @_;
    $self->value($value);
}

sub getCategoria{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->categoria));
}

sub setCategoria{
    my ($self) = shift;
    my ($value) = @_;
    $self->categoria($value);
}

sub getShowValue{
    my ($self) = shift;
	my $show='';
	if ($self->getType eq 'bool'){
		if($self->getValue){ $show="Si";}else{$show="No";}
	}
	elsif($self->getType eq 'valAuto'){
	    use C4::Modelo::PrefValorAutorizado;
		use C4::AR::Utilidades;
    		my $valAuto_array_ref = C4::Modelo::PrefValorAutorizado::Manager->get_pref_valor_autorizado( 
										query => [ category => { eq => $self->getOptions} , 
										           authorised_value => { eq => $self->getValue}]
								);
			if(scalar(@$valAuto_array_ref) > 0){
				$show=$valAuto_array_ref->[0]->getLib;
			}
	}
	elsif($self->getType eq 'referencia'){
		my @array=split(/\|/,$self->getOptions);
		my $tabla=$array[0];
		my $campo=$array[1];
		use C4::Modelo::PrefTablaReferencia;
		$show=C4::Modelo::PrefTablaReferencia->obtenerValorDeReferencia($tabla,$campo,$self->getValue);

	}
	else{$show=$self->getValue;}

    return ($show);
}


sub getExplanation{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->explanation));
}

sub setExplanation{
    my ($self) = shift;
    my ($explanation) = @_;
    $self->explanation($explanation);
}

sub getOptions{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->options));
}

sub setOptions{
    my ($self) = shift;
    my ($options) = @_;
    $self->options($options);
}

sub getType{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->type));
}

sub setType{
    my ($self) = shift;
    my ($type) = @_;
    $self->type($type);
}

sub agregar{
    my ($self)=shift;
    my ($data_hash)=@_;
    #Asignando data...
    $self->setVariable($data_hash->{'variable'});
    $self->setValue($data_hash->{'value'});
    $self->setExplanation($data_hash->{'explanation'});
    $self->setOptions($data_hash->{'options'});
    $self->setType($data_hash->{'type'});
    $self->save();
}

sub modificar{
    my ($self)          = shift;
    my ($data_hash)     = @_;

	$self->setValue($data_hash->{'value'});
    if($data_hash->{'explanation'} || $data_hash->{'explanation'} ne ''){
        $self->setExplanation($data_hash->{'explanation'});
    } else {
        #si no llega nada o es blanco mantengo el dato, solo se esta actualizando la variable
        $self->setExplanation($self->getExplanation());
    }

    if($data_hash->{'categoria'} || $data_hash->{'categoria'} ne ''){
        $self->setCategoria($data_hash->{'categoria'});
    } else {
        #si no llega nada o es blanco mantengo el dato, solo se esta actualizando la variable
        $self->setCategoria($self->getCategoria());
    }

    $self->save();
}


1;

