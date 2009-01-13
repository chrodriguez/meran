package C4::Modelo::UsrSocio;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'usr_socio',

    columns => [
        bit         => { type => 'integer', not_null => 1 , length => 11},
        flag           => { type => 'varchar', not_null => 1 , length => 255},
        flag_desc          => { type => 'varchar', length => 255, not_null => 1 },
        default_on              => { type => 'integer', length => 11, not_null => 1 }
    ],

    primary_key_columns => [ 'bit' ],

    unique_key => [ 'flag_desc' ],
);


# sub load{
#     my $self = $_[0]; # Copy, not shift
# open(Z, ">>/tmp/debug.txt");
# print Z "usr_socio=> \n";
# 
#     eval {
#     
#         unless( $self->SUPER::load(speculative => 1) ){
#                  print Z "usr_socio=>  SUPER load \n";
#             return undef;
#         }
#     };
# 
#     if($@){
#         print Z "usr_socio=>  no existe el socio \n";
# #         my $socio= C4::Modelo::UsrSocio->new();
#         return ( undef );
#     }
# 
# close(Z); 
# }


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
    return ($self->flag_desc);
}

sub setFlag_desc{
    my ($self) = shift;
    my ($flag_desc) = @_;
    $self->flag_desc($flag_desc);
}

sub getDefault_on{
    my ($self) = shift;
    return ($self->default_on);
}

sub setDefault_on{
    my ($self) = shift;
    my ($default_on) = @_;
    $self->default_on($default_on);
}

1;

