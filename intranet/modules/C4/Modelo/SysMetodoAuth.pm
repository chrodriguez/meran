package C4::Modelo::SysMetodoAuth;

use strict;


use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'sys_metodo_auth',

    columns => [
        id          => { type => 'serial', length => 12, not_null => 1 },
        metodo      => { type => 'varchar', length => 255, not_null => 1 },
        orden       => { type => 'integer', length => 12, not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],
    unique_key          => [ 'metodo' ],
);


sub getMetodo{
    my ($self) = shift;
    return ($self->metodo);
}

sub setMetodo{
    my ($self) = shift;
    my ($string) = @_;    
    
    $self->metodo($string);
}

sub getOrden{
    my ($self) = shift;
    return ($self->orden);
}

sub setOrden{
    my ($self) = shift;
    my ($number) = @_;    
    
    $self->orden($number);
    $self->save();
}

1;

