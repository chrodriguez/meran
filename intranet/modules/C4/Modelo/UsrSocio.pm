package C4::Modelo::UsrSocio;

use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
use utf8;

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

#===================================VA A PERMISOS==========================================

sub read_grants {
    my ($permisos) = @_;
    my $flag;
    $flag= 'OTRO';

    if($permisos eq "00010000"){
        $flag= 'TODOS';
    }elsif($permisos eq "00001000"){
        $flag= 'ALTA';
    }elsif($permisos eq "00000100"){
        $flag= 'BAJA';
    }elsif($permisos eq "00000010"){
        $flag= 'MODIFICACION';
    }elsif($permisos eq "00000001"){
        $flag= 'CONSULTA';
    }

    return $flag;
}

sub permisos_str_to_bin {
    my ($permisos) = @_;
    my $flag;
    $flag= '00000000';

    if($permisos eq 'TODOS'){
        $flag= '00010000';
    }elsif($permisos eq 'BAJA'){
        $flag= '00001000';
    }elsif($permisos eq 'MODIFICACION'){
        $flag= '00000100';
    }elsif($permisos eq 'ALTA'){
        $flag= '00000010';
    }elsif($permisos eq 'CONSULTA'){
        $flag= '00000001';
    }

    return $flag;
}

sub tiene_permiso_consulta{
    my ($permiso) = @_;

    return $permiso eq '00000001';
}

sub tiene_permiso_alta{
    my ($permiso) = @_;

    return $permiso eq '00000010';
}

sub tiene_permiso_modificacion{
    my ($permiso) = @_;

    return $permiso eq '00000100';
}

sub tiene_permiso_baja{
    my ($permiso) = @_;

    return $permiso eq '00001000';
}

sub tiene_permiso_todos{
    my ($permiso) = @_;

    return $permiso eq '00010000';
}

# 
# sub strBinToDec{
#     my ($numero) = @_;
# 
#     if($numero eq '00010000'){
#         $num_dec= 32;
#     }elsif($numero eq 'BAJA'){
#         $flag= '00001000';
#     }elsif($permisos eq 'MODIFICACION'){
#         $flag= '00000100';
#     }elsif($permisos eq 'ALTA'){
#         $flag= '00000010';
#     }elsif($permisos eq 'CONSULTA'){
#         $flag= '00000001';
#     }
# 
#     return $flag;    
# }
=item
Recibe un permiso por ej '00001000' y se chequea si existe el permiso
=cut
# sub tiene_permiso{
#     my ($permiso_requirido, $permiso_usuario) = @_;
#     my @array_permisos;
# 
#     if('TODOS' eq $permiso_requirido){
#             return 1;
#     }
# 
#     my $num = bin2dec($permisos_array_ref_level1->[0]->{$flagsrequired->{'entorno'}});
#     C4::AR::Debug::debug("=================bin2dec: ".$num);
# 
#     foreach my $permiso (@array_permisos){
#         if($permiso eq $permiso_requirido){
#             return 1;
#         }
#     }
#     
# }

sub bin2dec {
    return unpack("N", pack("B32", substr("0" x 32 . shift, -32)));
}

sub dec2bin {
    my $str = unpack("B32", pack("N", shift));
    $str =~ s/^0+(?=\d)//;   # otherwise you'll get leading zeros
    return $str;
}

sub verificar_permisos_por_nivel{
    my ($flagsrequired) = @_;

# FIXME falta verificar los parametros de entrada, que sean numeros y ademas q sean validos

    C4::AR::Debug::debug("verificar_permisos_por_nivel => ui=================: ".$flagsrequired->{'ui'});
    C4::AR::Debug::debug("verificar_permisos_por_nivel => tipo_documento=================: ".$flagsrequired->{'tipo_documento'});
    C4::AR::Debug::debug("verificar_permisos_por_nivel => nro_socio=================: ".$flagsrequired->{'nro_socio'});

    my $permisos_hash_ref= C4::AR::Usuarios::get_permisos_catalogo({
                                                        ui => $flagsrequired->{'ui'}, 
                                                        tipo_documento => $flagsrequired->{'tipo_documento'}, 
                                                        nro_socio => $flagsrequired->{'nro_socio'},
                                            });

    if($permisos_hash_ref ne 0){
        C4::AR::Debug::debug("verificar_permisos_por_nivel");
        #se encontraron permisos level1
    
        my $permiso_dec_del_usuario = bin2dec($permisos_hash_ref->{$flagsrequired->{'entorno'}});
        C4::AR::Debug::debug("verificar_permisos_por_nivel => PERMISOS DEL USUARIO=================bin2dec: ".$permiso_dec_del_usuario);
        my $permiso_dec_requerido = bin2dec($flagsrequired->{'accion'});
        C4::AR::Debug::debug("verificar_permisos_por_nivel => PERMISOS REQUERIDOS=================bin2dec: ".$permiso_dec_requerido);
        C4::AR::Debug::debug("verificar_permisos_por_nivel => ENTORNO=================: ".$flagsrequired->{'entorno'});
    
        if( $permiso_dec_del_usuario >= $permiso_dec_requerido ){
            return 1;
        }
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

    $self->log($flagsrequired,'tienePermisos => permisos requeridos');
    #Obtengo los permisos del socio
    my $flags= $self->getPermisos;


    # Se setean los flags requeridos
    $flagsrequired->{'ui'}= $self->getId_ui;
    $flagsrequired->{'nro_socio'}= $self->getNro_socio;

    $flagsrequired->{'tipo_documento'}= 'LIB';
    $flagsrequired->{'entorno'}= 'datos_nivel3';
    $flagsrequired->{'accion'}= 'ALTA';
   
#========TEST

    my $permisos_hash_ref_level1;
    my $permisos_hash_ref_level2;
    my $permisos_hash_ref_level3;
    my $grants_level1= 0;
    my $grants_level2= 0;
    my $grants_level3= 0;
=item
    # Obtengo los permisos del usuario
    $permisos_hash_ref_level1= C4::AR::Usuarios::get_permisos_catalogo({
                                                        ui => $flagsrequired->{'ui'}, 
                                                        tipo_documento => $flagsrequired->{'tipo_documento'}, 
                                                        nro_socio => $self->getNro_socio 
                                            });


    if($permisos_hash_ref_level1 ne 0){
        C4::AR::Debug::debug("=====================================INTENTO level1");
        #se encontraron permisos level1

        my $num = bin2dec($permisos_hash_ref_level1->{$flagsrequired->{'entorno'}});
        C4::AR::Debug::debug("PERMISOS DEL USUARIO=================bin2dec: ".$num);
        $num = bin2dec($flagsrequired->{'accion'});
        C4::AR::Debug::debug("PERMISOS REQUERIDOS=================bin2dec: ".$num);

        if( bin2dec($permisos_hash_ref_level1->{$flagsrequired->{'entorno'}}) >= bin2dec($flagsrequired->{'accion'}) ){
            C4::AR::Debug::debug("(level1) TIENE EL PERMISO PARA EL ENTORNO: ".$flagsrequired->{'entorno'}." ACCION: ".$flagsrequired->{'accion'});
            $grants_level1= 1;
            return 1;
        }
    }

    if(($permisos_hash_ref_level1 eq 0)||(!$grants_level1)){
        C4::AR::Debug::debug("=====================================NO TIENE PERMITOS level1, INTENTO level2");
        #if($permisos_array_ref_level1 eq 0)
        #no se encontraron permisos level1, se intenta con tipo_documento = 'ALL'
        $permisos_hash_ref_level2= C4::AR::Usuarios::get_permisos_catalogo({
                                                        ui => $flagsrequired->{'ui'}, 
                                                        tipo_documento => 'ALL', 
                                                        nro_socio => $self->getNro_socio 
                                            });
    }



    if($permisos_hash_ref_level2 ne 0){
        C4::AR::Debug::debug("=====================================INTENTO level2");
        #se encontraron permisos level2
        if( bin2dec($permisos_hash_ref_level2->{$flagsrequired->{'entorno'}}) >= bin2dec($flagsrequired->{'accion'}) ){
            C4::AR::Debug::debug("(level2) TIENE EL PERMISO PARA EL ENTORNO: ".$flagsrequired->{'entorno'}." ACCION: ".$flagsrequired->{'accion'});
            $grants_level2= 1;
            return 1;
        }
    }
    
    if(($permisos_hash_ref_level2 eq 0)||(!$grants_level2)){
        C4::AR::Debug::debug("=====================================NO TIENE PERMITOS level2, INTENTO level3");
        #if($permisos_array_ref_level2 eq 0){
        #no se encontraron permisos level2, se intenta con tipo_documento = 'ALL' y ui = 'ALL' 
        $permisos_hash_ref_level3= C4::AR::Usuarios::get_permisos_catalogo({
                                                        ui => 'ALL', 
                                                        tipo_documento => 'ALL', 
                                                        nro_socio => $self->getNro_socio 
                                            });
    }

    if($permisos_hash_ref_level3 ne 0){
        C4::AR::Debug::debug("=====================================INTENTO level3");
        #se encontraron permisos level3
        if( bin2dec($permisos_hash_ref_level3->{$flagsrequired->{'entorno'}}) >= bin2dec($flagsrequired->{'accion'}) ){
            C4::AR::Debug::debug("(level3) TIENE EL PERMISO PARA EL ENTORNO: ".$flagsrequired->{'entorno'}." ACCION: ".$flagsrequired->{'accion'});
            $grants_level3= 1;
            return 1;
        }
    }
=cut

    #se verifican permisos level1
    if(verificar_permisos_por_nivel($flagsrequired)){return 1}

    $flagsrequired->{'tipo_documento'}= 'ALL';
    #se verifican permisos level2
    if(verificar_permisos_por_nivel($flagsrequired)){return 1}
    
    $flagsrequired->{'tipo_documento'}= 'ALL';
    $flagsrequired->{'ui'}= 'ALL';
    #se verifican permisos level3
    if(verificar_permisos_por_nivel($flagsrequired)){
        return 1;
    }else{
        #el usuario no tiene permisos
        C4::AR::Debug::debug("NO TIENE EL PERMISO");
        return 0
    }

=item
    if(($permisos_hash_ref_level3 eq 0)||(!$grants_level3)){
        #no se encontraron permisos level3
        #if($permisos_array_ref_level3 eq 0){
        C4::AR::Debug::debug("NO TIENE EL PERMISO");
        return 0
    }
=cut

=item
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
=cut
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
    $self->nombre_apellido_autorizado($nombre_apellido_autorizado);
}

sub getTelefono_autorizado{
    my ($self) = shift;
    return ($self->telefono_autorizado);
}

sub setTelefono_autorizado{
    my ($self) = shift;
    my ($telefono_autorizado) = @_;
    utf8::encode($telefono_autorizado);
    $self->telefono_autorizado($telefono_autorizado);
}

sub getDni_autorizado{
    my ($self) = shift;
    return ($self->dni_autorizado);
}

sub setDni_autorizado{
    my ($self) = shift;
    my ($dni_autorizado) = @_;
    utf8::encode($dni_autorizado);
    $self->dni_autorizado($dni_autorizado);
}
1;
