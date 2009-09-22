package C4::Modelo::SistSesion;

use strict;

use C4::Context;
use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'sist_sesion',

    columns => [
        sessionID => { type => 'varchar', length => 255, not_null => 1 },
        userid    => { type => 'varchar', length => 255 },
        nroRandom    => { type => 'varchar', length => 255 },
		token    => { type => 'varchar', length => 255 },
        ip        => { type => 'varchar', length => 16 },
        lasttime  => { type => 'integer', length => 11 },
        flag  => { type => 'varchar', length => 255 },
    ],

    primary_key_columns => [ 'sessionID' ],
);

sub load{
    my $self = $_[0]; # Copy, not shift

    my $error = 0;

    eval {
    
         unless( $self->SUPER::load(speculative => 1) ){
                 C4::AR::Debug::debug("SistSesion=>  dentro del unless, no existe el objeto SUPER load");
                $error = 1;
         }

        C4::AR::Debug::debug("SistSesion=>  SUPER load");
        return $self->SUPER::load(@_);
    };

    if($@){
        C4::AR::Debug::debug("SistSesion=>  no existe el objeto");
        $error = 1;
    }

    return $error;
}

=item
Se redefine el metodo delte para poder loguear
=cut
sub delete{
    my $self = $_[0]; # Copy, not shift
    my $context = new C4::Context;

    if($context->config('debug')){
open(Z, ">>/tmp/debug.txt");
print Z "\n";
print Z "SistSesion=> DELETE\n";
        foreach my $param (@_){
print Z "SistSesion=> DELETE param: ".$param."\n";            
        }
print Z "\n";
close(Z);        
    }
    
    #se llama a delete
    return $self->SUPER::delete(@_);
}

sub setSessionId{
    my ($self) = shift;
    my ($sessionID) = @_;

    $self->sessionID($sessionID);
}

sub getSessionId{
    my ($self) = shift;
    return ($self->sessionID);
}

sub getUserid{
    my ($self) = shift;
    return ($self->userid);
}

sub setUserid{
    my ($self) = shift;
    my ($userid) = @_;
    $self->userid($userid);
}

sub getFlag{
    my ($self) = shift;
    return ($self->flag);
}

sub setFlag{
    my ($self) = shift;
    return ($self->flag);
}

sub getNroRandom{
    my ($self) = shift;
    return ($self->nroRandom);
}

sub setNroRandom{
    my ($self) = shift;
    my ($nroRandom) = @_;
    $self->nroRandom($nroRandom);
}

sub getToken{
    my ($self) = shift;
    return ($self->token);
}

sub setToken{
    my ($self) = shift;
    my ($token) = @_;
    $self->token($token);
}

sub getIp{
    my ($self) = shift;
    return ($self->ip);
}

sub setIp{
    my ($self) = shift;
    my ($ip) = @_;
    $self->ip($ip);
}

sub getLasttime{
    my ($self) = shift;
    return ($self->lasttime);
}

sub setLasttime{
    my ($self) = shift;
    my ($lasttime) = @_;    
    
    $self->lasttime($lasttime);
}

1;

