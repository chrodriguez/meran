package C4::Modelo::UsrSocio;

use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
use utf8;
use C4::AR::Permisos;

__PACKAGE__->meta->setup(
    table   => 'usr_socio',

    columns => [
        id_persona                       => { type => 'integer', not_null => 1 , length => 11},
        id_socio                         => { type => 'serial', not_null => 1 , length => 11},
        nro_socio                        => { type => 'varchar', length => 16, not_null => 1 },
        id_ui                            => { type => 'varchar', length => 4, not_null => 1 },
        cod_categoria                    => { type => 'character', length => 2, not_null => 1 },
        fecha_alta                       => { type => 'date' },
        expira                           => { type => 'date' },
        flags                            => { type => 'integer' },
        password                         => { type => 'varchar', length => 30 },
        last_login                       => { type => 'datetime' },
        last_change_password             => { type => 'date' },
        change_password                  => { type => 'integer', default => '0', not_null => 1 },
        cumple_requisito                 => { type => 'integer', not_null => 1, default => '0'},
        id_estado                        => { type => 'integer', not_null => 1 },
        activo                           => { type => 'integer', default => 0, not_null => 1 },
        agregacion_temp                  => { type => 'varchar', length => 255 },
        nombre_apellido_autorizado       => { type => 'varchar', length => 255, not_null => 0 },
        dni_autorizado                   => { type => 'varchar', length => 255, not_null => 0 },
        telefono_autorizado              => { type => 'varchar', length => 255, not_null => 0 },

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

    if ($data_hash->{'auto_nro_socio'}){
        if (C4::AR::Preferencias->getValorPreferencia("auto-nro_socio_from_dni")){
            $self->setNro_socio( $self->setNro_socio($self->persona->getNro_documento) );
        }else{
             $self->setNro_socio( $self->nextNro_socio )
        }
    }else{
        $self->setNro_socio($data_hash->{'nro_socio'});
    }

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

    if (C4::AR::Preferencias->getValorPreferencia("autoActivarPersona")){
        C4::AR::Debug::debug("Desde UsrSocio->agregar(), se tiene autoActivarPersona en 1, ojimetro");
        $self->activar();
    }
    $self->save();

}

sub agregarAutorizado{

    my ($self)=shift;
    my ($params) = @_;

    $self->setNombre_apellido_autorizado($params->{'auth_nombre'});
    $self->setDni_autorizado($params->{'auth_dni'});
    $self->setTelefono_autorizado($params->{'auth_telefono'});

    $self->save();
}

sub desautorizarTercero{

    my ($self)=shift;
    my ($params) = @_;

    $self->setNombre_apellido_autorizado('');
    $self->setDni_autorizado('');
    $self->setTelefono_autorizado('');

    $self->save();
}

sub tieneAutorizado{
    
    my ($self)=shift;
    return (
            C4::AR::Utilidades::validateString($self->getNombre_apellido_autorizado)
                            &&
            C4::AR::Utilidades::validateString($self->getDni_autorizado)
                            && 
            C4::AR::Utilidades::validateString($self->getTelefono_autorizado)
            );
}

sub nextNro_socio{

     my ($self)=shift;

     my $nro_socio = C4::Modelo::UsrSocio::Manager->get_usr_socio(
                                                                   query => [ nro_socio => { regexp => '^(-|\\+){0,1}([0-9]+\\.[0-9]*|[0-9]*\\.[0-9]+|[0-9]+)$' },
                                                                   ],
                                                                   select => ['nro_socio'],
                                                                   sort_by => ['nro_socio DESC'],
                                                                    );
    return ($nro_socio->[0]->nro_socio + 1);
}

sub modificar{

    my ($self)=shift;
    my ($data_hash)=@_;
    $self->setId_ui($data_hash->{'id_ui'});
    $self->setCod_categoria($data_hash->{'cod_categoria'});
    $self->persona->modificar($data_hash);
    $self->agregarAutorizado($data_hash);
    $self->save();
}

sub defaultSort{
    my ($campo)=@_;

    my $personaTemp = C4::Modelo::UsrPersona->new();
	C4::AR::Debug::debug("UsrSocio => defaultSort => return: ".$personaTemp->sortByString($campo));
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
# FIXME DEPRECATED
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

#     $self->log($accessFlagsHash,'getPermisos => permisos del socio');
    
    return ($accessFlagsHash);
}

sub activar{
    my ($self) = shift;
    $self->setActivo(1);
    $self->persona->activar();
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

    my ($estado) = C4::Modelo::UsrEstado->new(id_estado => $self->getId_estado);
    $estado->load();

    return $estado->getRegular;
}

=item
Esta funcion se encarga de verificar los permisos para un entorno dado
Entorno de datos de nivel, para ABM de datos de nivel 1, 2 y 3
@entornos_datos_nivel = ('datos_nivel1','datos_nivel2','datos_nivel3'); 
Entorno de estructura de catalogacion, para ABM de estructura de catalogacion
@entornos_estructura_catalogacion= ('estructura_catalogacion_n1','estructura_catalogacion_n2','estructura_catalogacion_n3');
Entorno de usuarios, para ABM de usuarios
@entornos_manejo_usuario = ('usuarios');

La funcion recibe entre otros parametros el entorno donde se van a verificar los permisos, los arreglos sirven como indices, para saber
si el entorno existe y ademas para buscar el permiso en el entorno (TABLA) correspondiente, ya que catalogo, usuarios, circulacion, datos de nivel, etc cada uno tendra su tabla de permisos.
cualquier entorno ingresado a la funcion que no exista en alguno de los arreglos de entornos será descartado e inmediatamente se
retornará SIN PERMISOS.
=cut
sub verificar_permisos_por_nivel{
    my ($flagsrequired) = @_;
    use C4::Modelo::PermCatalogo::Manager;

    my @filtros;
    my $permisos_array_hash_ref;
#     my @entornos_datos_nivel = ('datos_nivel1','datos_nivel2','datos_nivel3'); 
#     my @entornos_estructura_catalogacion= ('estructura_catalogacion_n1','estructura_catalogacion_n2','estructura_catalogacion_n3');
    my @entornos_perm_catalogo= (   'datos_nivel1','datos_nivel2','datos_nivel3', 'estructura_catalogacion_n1',
                                    'estructura_catalogacion_n2','estructura_catalogacion_n3', 'sistema', 'undefined', 'usuarios');
    my @entornos_manejo_usuario = ('usuarios');
#     my @entornos_circulacion = ('');

# FIXME falta verificar los parametros de entrada, que sean numeros y ademas q sean validos
    C4::AR::Debug::debug("");
    C4::AR::Debug::debug("verificar_permisos_por_nivel => permisos requeridos");
    C4::AR::Debug::debug("verificar_permisos_por_nivel => ui=================: ".$flagsrequired->{'ui'});
    C4::AR::Debug::debug("verificar_permisos_por_nivel => tipo_documento=================: ".$flagsrequired->{'tipo_documento'});
    C4::AR::Debug::debug("verificar_permisos_por_nivel => nro_socio=================: ".$flagsrequired->{'nro_socio'});
    C4::AR::Debug::debug("verificar_permisos_por_nivel => entorno=================: ".$flagsrequired->{'entorno'});
    C4::AR::Debug::debug("verificar_permisos_por_nivel => accion=================: ".$flagsrequired->{'accion'});

    if( (C4::AR::Utilidades::existeInArray($flagsrequired->{'entorno'}, @entornos_perm_catalogo)) ){
   
        $permisos_array_hash_ref= C4::AR::Permisos::get_permisos_catalogo({
                                                            ui => $flagsrequired->{'ui'}, 
                                                            tipo_documento => $flagsrequired->{'tipo_documento'}, 
                                                            nro_socio => $flagsrequired->{'nro_socio'},
                                                });
    }else{
     #el entorno pasado por parametro no existe, NO TIENE PERMISOS
        C4::AR::Debug::debug("verificar_permisos_por_nivel => NO EXISTE EL ENTORNO: ".$flagsrequired->{'entorno'});
        return 0;
    }

    foreach my $permisos_hash_ref (@$permisos_array_hash_ref){
#         if($permisos_hash_ref ne 0){
            C4::AR::Debug::debug("verificar_permisos_por_nivel");
            #se encontraron permisos level1
        
            my $permiso_bin_del_usuario= $permisos_hash_ref->{$flagsrequired->{'entorno'}};
            my $permiso_bin_requerido= C4::AR::Permisos::permisos_str_to_bin($flagsrequired->{'accion'});
            my $permiso_dec_del_usuario= C4::AR::Utilidades::bin2dec($permiso_bin_del_usuario);
            my $permiso_dec_requerido = C4::AR::Utilidades::bin2dec($permiso_bin_requerido);
    
            if( ($permiso_bin_del_usuario & '00010000') > 0){
                #tiene TODOS los permisos
                C4::AR::Debug::debug("verificar_permisos_por_nivel => PERMISOS DEL USUARIO=================bin: ".$permiso_bin_del_usuario);
                C4::AR::Debug::debug("verificar_permisos_por_nivel => PERMISOS DEL USUARIO=================TODOS");
                return 1;
            }
        
            C4::AR::Debug::debug("verificar_permisos_por_nivel => PERMISOS DEL USUARIO=================bin: ".$permiso_bin_del_usuario);
            C4::AR::Debug::debug("verificar_permisos_por_nivel => PERMISOS REQUERIDOS=================bin: ".$permiso_bin_requerido);
            C4::AR::Debug::debug("verificar_permisos_por_nivel => ENTORNO=================: ".$flagsrequired->{'entorno'});
            my $resultado= $permiso_bin_del_usuario & $permiso_bin_requerido;
            if( C4::AR::Utilidades::bin2dec($resultado) > 0 ){
                return 1;
            }
#         }
    }

    return 0;
}

sub tienePermisos {
#     00000000 8bits los primeros 4 esta para uso futuro
#     000TABMC TODOS, ALTA, BAJA, MODIFICACION, CONSULTA 

#     $flagsrequired->{'tipo_documento'}
#     $flagsrequired->{'accion'}
#     $flagsrequired->{'ui'}
#     $flagsrequired->{'nivel'} #datos_nivel3 | datos_nivel2 | datos_nivel1

    my ($self) = shift;
    my ($flagsrequired) = @_;

    # Se setean los flags requeridos
    $flagsrequired->{'nro_socio'}= $self->getNro_socio;

    #se verifican permisos level1
    C4::AR::Debug::debug("tienePermisos??? => intento level1");
    if(verificar_permisos_por_nivel($flagsrequired)){return 1}

    $flagsrequired->{'tipo_documento'}= 'ALL';
    #se verifican permisos level2
    C4::AR::Debug::debug("tienePermisos??? => intento level2");
    if(verificar_permisos_por_nivel($flagsrequired)){return 1}
    
    $flagsrequired->{'ui'}= 'ALL';
    #se verifican permisos level3
    C4::AR::Debug::debug("tienePermisos??? => intento level3");
    if(verificar_permisos_por_nivel($flagsrequired)){return 1}

    $flagsrequired->{'tipo_documento'}= 'ALL';
    $flagsrequired->{'ui'}= 'ALL';
    #se verifican permisos level4
    C4::AR::Debug::debug("tienePermisos??? => intento level4");
    if(verificar_permisos_por_nivel($flagsrequired)){
        return 1;
    }else{
        #el usuario no tiene permisos
        C4::AR::Debug::debug("NO TIENE EL PERMISO");
        return 0;
    }
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

sub estaSancionado {
  #Esta funcion determina si un usuario ($nro_socio) tiene alguna sancion
  my ($nro_socio)=@_;

  my $dateformat = C4::Date::get_date_format();
  my $hoy=C4::Date::format_date_in_iso(ParseDate("today"), $dateformat);
  
  my $sanciones_array_ref = C4::Modelo::CircSancion::Manager->get_circ_sancion (   
                                                                    query => [ 
                                                                            nro_socio       => { eq => $nro_socio },
                                                                            fecha_comienzo  => { le => $hoy },
                                                                            fecha_final     => { ge => $hoy},
                                                                        ],
                                    );
  return($sanciones_array_ref->[0] || undef);

}


sub getNombre_apellido_autorizado{
    my ($self) = shift;
    return ($self->nombre_apellido_autorizado);
}

sub setNombre_apellido_autorizado{
    my ($self) = shift;
    my ($nombre_apellido_autorizado) = @_;
    utf8::encode($nombre_apellido_autorizado);
    if (C4::AR::Utilidades::validateString($nombre_apellido_autorizado)){
      $self->nombre_apellido_autorizado($nombre_apellido_autorizado);
    }
}

sub getTelefono_autorizado{
    my ($self) = shift;
    return ($self->telefono_autorizado);
}

sub setTelefono_autorizado{
    my ($self) = shift;
    my ($telefono_autorizado) = @_;
    utf8::encode($telefono_autorizado);
    if (C4::AR::Utilidades::validateString($telefono_autorizado)){
      $self->telefono_autorizado($telefono_autorizado);
    }
}

sub getDni_autorizado{
    my ($self) = shift;
    return ($self->dni_autorizado);
}

sub setDni_autorizado{
    my ($self) = shift;
    my ($dni_autorizado) = @_;
    utf8::encode($dni_autorizado);
    if (C4::AR::Utilidades::validateString($dni_autorizado)){
      $self->dni_autorizado($dni_autorizado);
    }
}
1;
