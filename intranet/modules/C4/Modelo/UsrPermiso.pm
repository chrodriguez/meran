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

sub agregar{

    my ($self)=shift;
    my ($data_hash)=@_;
    
    $self->setId_persona($data_hash->{'id_persona'});
    $self->setNro_socio($data_hash->{'nro_socio'});
    $self->setId_ui($data_hash->{'id_ui'});
    $self->setCod_categoria($data_hash->{'cod_categoria'});
    $self->setFecha_alta($data_hash->{'fecha_alta'});
    $self->setExpira($data_hash->{'expira'});
    $self->setFlags($data_hash->{'flags'});
    $self->setPassword($data_hash->{'password'});
    $self->setLast_login($data_hash->{'last_login'});
    $self->setLast_change_password($data_hash->{'last_change_password'});
    $self->setChange_password($data_hash->{'change_password'});
    $self->setCumple_requisito($data_hash->{'cumple_requisito'});
    $self->setId_estado($data_hash->{'id_estado'});

    if (C4::Context->preference("autoActivarPersona")){
        $self->activar();
    }

    $self->save();
}

sub modificar{

    my ($self)=shift;
    my ($data_hash)=@_;
    
    $self->setNro_socio($data_hash->{'nro_socio'});
    $self->setId_ui($data_hash->{'id_ui'});
    $self->setCod_categoria($data_hash->{'cod_categoria'});
    $self->persona->modificar($data_hash);

    $self->save();
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

