package C4::Modelo::PrefPreferenciaSistema;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'pref_preferencia_sistema',

    columns => [
        variable    => { type => 'varchar', length => 50, not_null => 1 },
        value       => { type => 'text', length => 65535 },
        explanation => { type => 'varchar', default => '', length => 200, not_null => 1 },
        options     => { type => 'text', length => 65535 },
        type        => { type => 'varchar', length => 20 },
    ],

    primary_key_columns => [ 'variable' ],
);

sub defaultSort {
     return ('variable');
}

sub getVariable{
    my ($self) = shift;
    return ($self->variable);
}

sub setVariable{
    my ($self) = shift;
    my ($variable) = @_;
    $self->variable($variable);
}

sub getValue{
    my ($self) = shift;
    return ($self->value);
}

sub setValue{
    my ($self) = shift;
    my ($value) = @_;
    $self->value($value);
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
										query => [ category => { eq => trim($self->getOptions)} , 
										authorised_value => { eq => trim($self->getValue)}]);
			$show=$valAuto_array_ref->[0]->getLib;
		}
	elsif($self->getType eq 'referencia'){
	
	}
	else{$show=$self->getValue;}

    return ($show);
}


sub getExplanation{
    my ($self) = shift;
    return ($self->explanation);
}

sub setExplanation{
    my ($self) = shift;
    my ($explanation) = @_;
    $self->explanation($explanation);
}

sub getOptions{
    my ($self) = shift;
    return ($self->options);
}

sub setOptions{
    my ($self) = shift;
    my ($options) = @_;
    $self->options($options);
}

sub getType{
    my ($self) = shift;
    return ($self->type);
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
    my ($self)=shift;
    my ($data_hash)=@_;
	$self->setValue($data_hash->{'value'});
    $self->setExplanation($data_hash->{'explanation'});
    $self->save();
}


1;

