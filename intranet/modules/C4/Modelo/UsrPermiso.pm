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

# sub getPermisos{
# #     my $dbh=C4::Context->dbh();
# #     my $sth=$dbh->prepare("SELECT bit,flag,flagdesc FROM usr_permiso ORDER BY bit");
# #     $sth->execute;
# 
# #     use C4::Modelo::UsrSocio;
#     my $permisos_array_ref = C4::Modelo::UsrPermiso::Manager->get_usr_permiso();
# 
# #     return ($socio_array_ref->[0]->categoria->getDescription);
# #     my @loop;
# 
# #     while (my ($bit, $flag, $flagdesc) = $sth->fetchrow) {
# #     foreach $permiso ($@permisos_array_ref){
# #         my $checked='';
# #         if ( $accessflags->{$flag} ) {
# #             $checked='checked';
# #         }
# #         
# #         my %row = (     bit => $bit,
# #                 flag => $flag,
# #                 checked => $checked,
# #                 flagdesc => $flagdesc );
# # 
# #         push @loop, \%row;
# #     }
# 
#     return ($permisos_array_ref);
# }

1;

