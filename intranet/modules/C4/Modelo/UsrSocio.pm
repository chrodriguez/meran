package C4::Modelo::UsrSocio;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'usr_socio',

    columns => [
        id_persona         => { type => 'integer', not_null => 1 , length => 11},
        id_socio           => { type => 'serial', not_null => 1 , length => 11},
        nro_socio          => { type => 'varchar', length => 16, not_null => 1 },
        id_ui              => { type => 'varchar', length => 4, not_null => 1 },
        cod_categoria      => { type => 'character', length => 2, not_null => 1 },
        fecha_alta         => { type => 'date' },
        expira             => { type => 'date' },
        flags              => { type => 'integer' },
        password           => { type => 'varchar', length => 30 },
        last_login          => { type => 'datetime' },
        last_change_password => { type => 'date' },
        change_password     => { type => 'integer', default => '0', not_null => 1 },
        cumple_requisito   => { type => 'date' },
        id_estado          => { type => 'integer', not_null => 1 },
    ],

     relationships =>
    [
      persona => 
      {
        class       => 'C4::Modelo::UsrPersona',
        key_columns => { id_persona => 'id_persona' },
        type        => 'one to one',
      },

      ui => 
      {
        class       => 'C4::Modelo::PrefUnidadInformacion',
        key_columns => { id_ui => 'id_ui' },
        type        => 'one to one',
      },

       categoria => 
      {
        class       => 'C4::Modelo::UsrRefCategoriasSocio',
        key_columns => { cod_categoria => 'categorycode' },
        type        => 'one to one',
      },
    ],

    primary_key_columns => [ 'id_socio' ],

    unique_key => [ 'nro_socio' ],
);


# sub getUI_nombre{
# 
#     my ($self) = shift;
#     my ($id_ui) = @_;
# 
#     use C4::Modelo::RefUnidadInformacion;
# 
#     my  $ui = C4::Modelo::RefUnidadInformacion->new(id_ui => $id_ui);
#     $ui->load();
# 
#     return ($ui->nombre);   
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
sub getId_persona{
    my ($self) = shift;
    return ($self->id_persona);
}

sub setId_persona{
    my ($self) = shift;
    my ($id_persona) = @_;
    $self->id_persona($id_persona);
}

sub getId_socio{
    my ($self) = shift;
    return ($self->id_socio);
}

sub setId_socio{
    my ($self) = shift;
    my ($id_socio) = @_;
    $self->id_socio($id_socio);
}

sub getNro_socio{
    my ($self) = shift;
    return ($self->nro_socio);
}

sub setNro_socio{
    my ($self) = shift;
    my ($nro_socio) = @_;
    $self->nro_socio($nro_socio);
}

sub getId_ui{
    my ($self) = shift;
    return ($self->id_ui);
}

sub setId_ui{
    my ($self) = shift;
    my ($id_ui) = @_;
    $self->id_ui($id_ui);
}

sub getCod_categoria{
    my ($self) = shift;
    return ($self->cod_categoria);
}

sub setCod_categoria{
    my ($self) = shift;
    my ($cod_categoria) = @_;
    $self->cod_categoria($cod_categoria);
}

sub getFecha_alta{
    my ($self) = shift;
    my $dateformat = C4::Date::get_date_format();

    return ( C4::Date::format_date($self->fecha_alta,$dateformat) );
#     return ($self->fecha_alta);
}

sub setFecha_alta{
    my ($self) = shift;
    my ($fecha_alta) = @_;
    $self->fecha_alta($fecha_alta);
}

sub getExpira{
    my ($self) = shift;
    my $dateformat = C4::Date::get_date_format();

    return ( C4::Date::format_date($self->expira,$dateformat) );
#     return ($self->expira);
}

sub setExpira{
    my ($self) = shift;
    my ($expira) = @_;
    $self->expira($expira);
}

sub getFlags{
    my ($self) = shift;
    return ($self->flags);
}

sub setFlags{
    my ($self) = shift;
    my ($flags) = @_;
    $self->flags($flags);
}

sub getPassword{
    my ($self) = shift;
    return ($self->password);
}

sub setPassword{
    my ($self) = shift;
    my ($password) = @_;
    $self->password($password);
}

sub getLast_login{
    my ($self) = shift;
    return ($self->last_login);
}

sub setLast_login{
    my ($self) = shift;
    my ($last_login) = @_;
    $self->last_login($last_login);
}

sub getLast_change_password{
    my ($self) = shift;
    return ($self->last_change_password);
}

sub setLast_change_password{
    my ($self) = shift;
    my ($last_change_password) = @_;
    $self->last_change_password($last_change_password);
}

sub getChange_password{
    my ($self) = shift;
    return ($self->change_password);
}

sub setChange_password{
    my ($self) = shift;
    my ($change_password) = @_;
    $self->change_password($change_password);
}

sub getCumple_requisito{
    my ($self) = shift;
    return ($self->cumple_requisito);
}

sub setCumple_requisito{
    my ($self) = shift;
    my ($cumple_requisito) = @_;
    $self->cumple_requisito($cumple_requisito);
}

sub getId_estado{
    my ($self) = shift;
    return ($self->id_estado);
}

sub setId_estado{
    my ($self) = shift;
    my ($id_estado) = @_;
    $self->id_estado($id_estado);
}
1;

