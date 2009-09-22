package C4::Modelo::UsrPermiso;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'usr_permiso',

    columns => [
        bit         => { type => 'integer', not_null => 1 , length => 11},
        flag           => { type => 'varchar', not_null => 1 , length => 255},
        flagdesc          => { type => 'varchar', length => 255, not_null => 1 },
        defaulton              => { type => 'integer', length => 11, not_null => 1 }
    ],

    primary_key_columns => [ 'bit' ],

    unique_key => [ 'flagdesc' ],
);


sub load{
    my $self = $_[0]; # Copy, not shift

    my $error = 0;

    eval {
    
         unless( $self->SUPER::load(speculative => 1) ){
                 C4::AR::Debug::debug("UsrPermiso=>  dentro del unless, no existe el objeto SUPER load");
                $error = 1;
         }

        C4::AR::Debug::debug("UsrPermiso=>  SUPER load");
        return $self->SUPER::load(@_);
    };

    if($@){
        C4::AR::Debug::debug("UsrPermiso=>  no existe el objeto");
        $error = 1;
    }

    return $error;
}


sub getBit{
    my ($self) = shift;
    return ($self->bit);
}

sub getFlag{
    my ($self) = shift;
    return ($self->flag);
}

sub setFlag{
    my ($self) = shift;
    my ($flag) = @_;
    $self->flag($flag);
}

sub getFlag_desc{
    my ($self) = shift;
    return ($self->flagdesc);
}

sub setFlag_desc{
    my ($self) = shift;
    my ($flagdesc) = @_;
    $self->flagdesc($flagdesc);
}

sub getDefault_on{
    my ($self) = shift;
    return ($self->defaulton);
}

sub setDefault_on{
    my ($self) = shift;
    my ($defaulton) = @_;
    $self->defaulton($defaulton);
}

1;

