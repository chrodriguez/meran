package C4::Modelo::UsrLoginAttempts;

use strict;


use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'usr_login_attempts',

    columns => [
        id           => { type => 'varchar', length => 255, not_null => 1 },
        nro_socio    => { type => 'varchar', length => 16, not_null => 1 },
        attempts     => { type => 'integer', length => 32, default => 0 },
    ],

    primary_key_columns => [ 'nro_socio' ],
);



sub increase{
	my ($self) = shift;
	
	my $attempts = $self->attempts;

	$attempts++;

	$self->attempts($attempts);
	
	$self->save();
}

sub reset{
    my ($self) = shift;
    
    $self->attempts(0);
    
    $self->save();
}

#METODO STATIC
sub loginFailed{
	my ($nro_socio) = shift;
	
	my $attempts_object = _getAttemptsObject($nro_socio);
	
	$attempts_object->increase;
	
}

#METODO STATIC
sub _getAttemptsObject{
	
	my ($nro_socio) = shift;
	
	my $object = C4::Modelo::UsrLoginAttempts->new(nro_socio => $nro_socio);
	
	return ($object);
}

#METODO STATIC
sub loginSuccess{
    my ($nro_socio) = shift;
    
    my $attempts_object = _getAttemptsObject($nro_socio);
    
    $attempts_object->reset;
    
}

#METODO STATIC
sub getSocioAttempts{
    
    my ($nro_socio) = shift;
    
    my $object = C4::Modelo::UsrLoginAttempts->new(nro_socio => $nro_socio);
    
    return ($object->attempts);
}
1;