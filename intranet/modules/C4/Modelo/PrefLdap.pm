package C4::Modelo::PrefLdap;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'pref_ldap',

    columns => [
        id          => { type => 'serial' },
        variable    => { type => 'varchar', length => 50, not_null => 1 },
        value       => { type => 'text', length => 65535 },
        explanation => { type => 'varchar', default => '', length => 512, not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],
    unique_key => [ 'variable' ],
);

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

1;
__END__

