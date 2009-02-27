package C4::Modelo::UsrSocio;

use strict;
#  QUE PASA CON ACTIVO??????????????????????????????????????????????????????????????????????????????????? ACA O EN PERSONA?????
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
        cumple_requisito   => { type => 'integer', not_null => 1, default => '0'},
        id_estado          => { type => 'integer', not_null => 1 },
        activo           => { type => 'integer', default => 0, not_null => 1 },
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

     estado => 
      {
        class       => 'C4::Modelo::UsrEstado',
        key_columns => { id_estado => 'id_estado' },
        type        => 'one to one',
      },

    ],

    primary_key_columns => [ 'id_socio' ],

    unique_key => [ 'nro_socio' ],
);


# 
# sub new{
#     my $self = $_[0]; # Copy, not shift
# open(Z, ">>/tmp/debug.txt");
# print Z "usr_socio=> new\n";
# 
#     eval {
# print Z "usr_socio=> dentro del eval, intento crear el objeto\n";    
#           return shift->SUPER::new(@_);
#     };
#     
#     if($@){
# print Z "usr_socio=>  no existe el socio, creo uno vacio \n";
#         my $socio= C4::Modelo::UsrSocio->new();
#         $socio->setId_ui('');
#         $socio->setActive(0);
#         $socio->persona->setApellido('');
#         $socio->persona->setNombre('');
#         $socio->persona->setNro_documento('');
#         $socio->setPassword('');
# 
#         return ( $socio );
#     }
# }

sub load{
    my $self = $_[0]; # Copy, not shift
open(Z, ">>/tmp/debug.txt");
print Z "usr_socio=> \n";

    eval {
    
        unless( $self->SUPER::load(speculative => 1) ){
                 print Z "usr_socio=>  SUPER load \n";
            return 0;
        }

        return $self->SUPER::load(@_);
    };

    if($@){
        print Z "usr_socio=>  no existe el socio \n";
#         my $socio= C4::Modelo::UsrSocio->new();
        return ( 0 );
    }

close(Z); 
}

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
#     $self->setLast_login($data_hash->{'last_login'});
    $self->setChange_password($data_hash->{'changepassword'});
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

sub defaultSort{
     my ($campo)=@_;

     my $personaTemp = C4::Modelo::UsrPersona->new();
     return ($personaTemp->sortByString($campo));
}


sub cambiarPassword{
    
    use C4::Date;
    my ($self)=shift;
    my ($password)=@_;

    $self->setPassword( C4::Auth::md5_base64($password) );
    my $today = Date::Manip::ParseDate("today");
    $self->setLast_change_password($today);
    $self->setChange_password(0);
    
    $self->save();
}

sub resetPassword{
    my ($self)=shift;

#     use Switch;
#     if ( C4::Context->preference("defaultPassword") ){
#         my $defaultPassword = C4::Context->preference("defaultPassword");
#         
#         switch ($defaultPassword) {
# 
#         case "documento"      { $self->setPassword(""); }
# 
#         else                 { $self->cambiarPassword($defaultPassword); }
# 
#         }
#     } 
#     else
#         {
#             $self->setPassword("");
#         }
    $self->setPassword("");
    $self->setChange_password(1);
    $self->save();
}

sub cambiarPermisos{
    my ($self)=shift;
    my ($params) = @_;

    my $array_permisos= $params->{'array_permisos'};
    my $loop=scalar(@$array_permisos);

    my $flags=0;
    for(my $i=0;$i<$loop;$i++){
        my $flag= $array_permisos->[$i];
        $flags=$flags+2**$flag;
    }

    $self->setFlags($flags);
    $self->save();
}

=item
Retorna los permisos del socio
=cut
sub getPermisos{
    my ($self) = shift;
    
    use C4::Modelo::UsrPermiso;
    use C4::Modelo::UsrPermiso::Manager;

    #retorna todos los permisos
    my $permisos_array_ref = C4::Modelo::UsrPermiso::Manager->get_usr_permiso();

    my $accessFlagsHash;
    foreach my $permiso (@$permisos_array_ref){
        if ( $self->getFlags & 2**$permiso->{'bit'} ) {
            $accessFlagsHash->{ $permiso->{'flag'} }= 1;
        }
    }

    $self->log($accessFlagsHash,'getPermisos => permisos del socio');
    
    return ($accessFlagsHash);
}

sub activar{
    my ($self) = shift;
    $self->setActivo(1);
    $self->save();
}

sub desactivar{
    my ($self) = shift;
    $self->setActivo(0);
    $self->save();
}

sub getActivo{
    my ($self) = shift;
    return ($self->activo);
}

sub setActivo{
    my ($self) = shift;
    my ($activo) = @_;
    $self->activo($activo);
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
    my $dateformat = C4::Date::get_date_format();
    $last_login = C4::Date::format_date_in_iso($last_login,$dateformat);
    $self->last_login($last_login);
}

sub getLast_change_password{
    my ($self) = shift;
    return ($self->last_change_password);
}

sub setLast_change_password{
    my ($self) = shift;
    my $dateformat = C4::Date::get_date_format();
    my ($last_change_password) = @_;
    $last_change_password = C4::Date::format_date_in_iso($last_change_password,$dateformat);
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

sub esRegular{
    my ($self) = shift;

    my ($estado) = C4::Modelo::UsrEstado->new(id_estado => $self->getEstado);
    $estado->load();

    return $estado->getRegular;
}

sub tienePermisos {
    my ($self) = shift;
    my ($flagsrequired) = @_;

    $self->log($flagsrequired,'tienePermisos => permisos requeridos');
    #Obtengo los permisos del socio
    my $flags= $self->getPermisos;

    if($flagsrequired){
        #se verifica si el socio tiene los permisos pasados por parametro
        foreach (keys %$flagsrequired) {
            return $flags if $flags->{'superlibrarian'};
            return $flags if $flags->{$_};
        }
    }else{
        #si no hay flags requeridos, tiene permisos
        return 1
    }

    return 0;
}


=item
Retorna la persona que corresponde al socio
=cut
sub getPersona{
    my ($self) = shift;
    
    use C4::Modelo::UsrPersona;
    use C4::Modelo::UsrPersona::Manager;

    my $persona = C4::Modelo::UsrPersona::Manager->get_usr_persona( query => [ id_persona => { eq => $self->getId_persona } ]);

    return ($persona);
}


1;

