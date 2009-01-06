package C4::Modelo::UsrPersona;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'usr_persona',

    columns => [
        id_persona       => { type => 'serial', not_null => 1 },
        version_documento => { type => 'character', default => 'P', length => 1, not_null => 1 },
        nro_documento    => { type => 'varchar', length => 16, not_null => 1 },
        tipo_documento   => { type => 'character', length => 3, not_null => 1 },
        apellido         => { type => 'varchar', length => 255, not_null => 1 },
        nombre           => { type => 'varchar', length => 255, not_null => 1 },
        titulo           => { type => 'varchar', length => 255 },
        otros_nombres    => { type => 'varchar', length => 255 },
        iniciales        => { type => 'varchar', length => 255, not_null => 1 },
        calle            => { type => 'varchar', length => 255, not_null => 1 },
        barrio           => { type => 'varchar', length => 255 },
        ciudad           => { type => 'varchar', length => 11 },
        telefono         => { type => 'varchar', length => 255 },
        email            => { type => 'varchar', length => 255 },
        fax              => { type => 'varchar', length => 255 },
        msg_texto        => { type => 'varchar', length => 255 },
        alt_calle        => { type => 'varchar', length => 255 },
        alt_barrio       => { type => 'varchar', length => 255 },
        alt_ciudad       => { type => 'varchar', length => 255 },
        alt_telefono     => { type => 'varchar', length => 255 },
        nacimiento       => { type => 'date' },
        fecha_alta       => { type => 'date' },
        sexo             => { type => 'character', length => 1 },
        telefono_laboral => { type => 'varchar', length => 50 },
        cumple_condicion => { type => 'integer', default => '0', not_null => 1 },
        activo           => { type => 'integer', default => 1, not_null => 1 },
    ],

    primary_key_columns => [ 'id_persona' ],
);

sub convertirEnSocio{
    my ($self)=shift;
    my ($data_hash)=@_;

    use C4::Modelo::UsrSocio;
    
    my $socio = C4::Modelo::UsrSocio->new();
    $data_hash->{'id_persona'} = $self->getId_persona;
    $data_hash->{'nro_socio'} = $self->getNro_documento;
    $socio->agregar($data_hash);
}

sub _printHASH {
    my ($hash_ref) = @_;
    open(Z, ">>/tmp/debug.txt");
    print Z "\n";
    print Z "PRINT HASH: \n";
    
    if($hash_ref){
        while ( my ($key, $value) = each(%$hash_ref) ) {
                print Z "key: $key => value: $value\n";
            }
    }
    print Z "\n";
    close(Z);
}

sub agregar{
    my ($self)=shift;
    my ($data_hash)=@_;
    #Asignando data...
    $self-> setNombre($data_hash->{'nombre'});
    $self-> setApellido($data_hash->{'apellido'});
    $self-> setVersion_documento($data_hash->{'version_documento'});
    $self-> setNro_documento($data_hash->{'nro_documento'});
    $self-> setTipo_documento($data_hash->{'tipo_documento'});
    $self-> setTitulo($data_hash->{'titulo'});
    $self-> setOtros_nombres($data_hash->{'otros_nombres'});
    $self-> setIniciales($data_hash->{'iniciales'});
    $self-> setCalle($data_hash->{'calle'});
    $self-> setBarrio($data_hash->{'barrio'});
    $self-> setCiudad($data_hash->{'ciudad'});
    $self-> setTelefono($data_hash->{'telefono'});
    $self-> setEmail($data_hash->{'email'});
    $self-> setFax($data_hash->{'fax'});
    $self-> setMsg_texto($data_hash->{'msg_texto'});
    $self-> setAlt_calle($data_hash->{'alt_calle'});
    $self-> setAlt_barrio($data_hash->{'alt_barrio'});
    $self-> setAlt_ciudad($data_hash->{'alt_ciudad'});
    $self-> setAlt_telefono($data_hash->{'alt_telefono'});
    $self-> setNacimiento($data_hash->{'nacimiento'});
    $self-> setFecha_alta($data_hash->{'fecha_alta'});
    $self-> setSexo($data_hash->{'sexo'});
    $self-> setTelefono_laboral($data_hash->{'telefono_laboral'});
    $self-> setCumple_condicion($data_hash->{'cumple_condicion'});
    $self->activar;
}    

sub activar{
    my ($self) = shift;
    $self->setActivo(1);
    $self->save();
}    


sub eliminar{
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

sub getVersion_documento{
    my ($self) = shift;
    return ($self->version_documento);
}

sub setVersion_documento{
    my ($self) = shift;
    my ($version_documento) = @_;
    $self->version_documento($version_documento);
}


sub getNro_documento{
    my ($self) = shift;
    return ($self->nro_documento);
}

sub setNro_documento{
    my ($self) = shift;
    my ($nro_documento) = @_;
    $self->nro_documento($nro_documento);
}

sub getTipo_documento{
    my ($self) = shift;
    return ($self->tipo_documento);
}

sub setTipo_documento{
    my ($self) = shift;
    my ($tipo_documento) = @_;
    $self->tipo_documento($tipo_documento);
}

sub getApellido{
    my ($self) = shift;
    return ($self->apellido);
}

sub setApellido{
    my ($self) = shift;
    my ($apellido) = @_;
    $self->apellido($apellido);
}

sub getNombre{
    my ($self) = shift;
    return ($self->nombre);
}

sub setNombre{
    my ($self) = shift;
    my ($nombre) = @_;
    $self->nombre($nombre);
}

sub getTitulo{
    my ($self) = shift;
    return ($self->titulo);
}

sub setTitulo{
    my ($self) = shift;
    my ($titulo) = @_;
    $self->titulo($titulo);
}


sub getOtros_nombres{
    my ($self) = shift;
    return ($self->otros_nombres);
}

sub setOtros_nombres{
    my ($self) = shift;
    my ($otros_nombres) = @_;
    $self->otros_nombres($otros_nombres);
}

sub getIniciales{
    my ($self) = shift;
    return ($self->iniciales);
}

sub setIniciales{
    my ($self) = shift;
    my ($iniciales) = @_;
    $self->iniciales($iniciales);
}

sub getCalle{
    my ($self) = shift;
    return ($self->calle);
}

sub setCalle{
    my ($self) = shift;
    my ($calle) = @_;
    $self->calle($calle);
}

sub getBarrio{
    my ($self) = shift;
    return ($self->barrio);
}

sub setBarrio{
    my ($self) = shift;
    my ($barrio) = @_;
    $self->barrio($barrio);
}

sub getCiudad{
    my ($self) = shift;
    return ($self->ciudad);
}

sub setCiudad{
    my ($self) = shift;
    my ($ciudad) = @_;
    $self->ciudad($ciudad);
}

sub getTelefono{
    my ($self) = shift;
    return ($self->telefono);
}

sub setTelefono{
    my ($self) = shift;
    my ($telefono) = @_;
    $self->telefono($telefono);
}

sub getEmail{
    my ($self) = shift;
    return ($self->email);
}

sub setEmail{
    my ($self) = shift;
    my ($email) = @_;
    $self->email($email);
}

sub getFax{
    my ($self) = shift;
    return ($self->fax);
}

sub setFax{
    my ($self) = shift;
    my ($fax) = @_;
    $self->fax($fax);
}

sub getMsg_texto{
    my ($self) = shift;
    return ($self->msg_texto);
}

sub setMsg_texto{
    my ($self) = shift;
    my ($msg_texto) = @_;
    $self->msg_texto($msg_texto);
}

sub getAlt_calle{
    my ($self) = shift;
    return ($self->alt_calle);
}

sub setAlt_calle{
    my ($self) = shift;
    my ($alt_calle) = @_;
    $self->alt_calle($alt_calle);
}

sub getAlt_barrio{
    my ($self) = shift;
    return ($self->alt_barrio);
}

sub setAlt_barrio{
    my ($self) = shift;
    my ($alt_barrio) = @_;
    $self->alt_barrio($alt_barrio);
}

sub getAlt_ciudad{
    my ($self) = shift;
    return ($self->alt_ciudad);
}

sub setAlt_ciudad{
    my ($self) = shift;
    my ($alt_ciudad) = @_;
    $self->alt_ciudad($alt_ciudad);
}

sub getAlt_telefono{
    my ($self) = shift;
    return ($self->alt_telefono);
}

sub setAlt_telefono{
    my ($self) = shift;
    my ($alt_telefono) = @_;
    $self->alt_telefono($alt_telefono);
}

sub getNacimiento{
    my ($self) = shift;
    return ($self->nacimiento);
}

sub setNacimiento{
    my ($self) = shift;
    my ($nacimiento) = @_;
    $self->nacimiento($nacimiento);
}

sub getFecha_alta{
    my ($self) = shift;
    return ($self->fecha_alta);
}

sub setFecha_alta{
    my ($self) = shift;
    my ($fecha_alta) = @_;
    $self->fecha_alta($fecha_alta);
}

sub getSexo{
    my ($self) = shift;
    return ($self->sexo);
}

sub setSexo{
    my ($self) = shift;
    my ($sexo) = @_;
    $self->sexo($sexo);
}

sub getTelefono_laboral{
    my ($self) = shift;
    return ($self->telefono_laboral);
}

sub setTelefono_laboral{
    my ($self) = shift;
    my ($telefono_laboral) = @_;
    $self->telefono_laboral($telefono_laboral);
}

sub getCumple_condicion{
    my ($self) = shift;
    return ($self->cumple_condicion);
}

sub setCumple_condicion{
    my ($self) = shift;
    my ($cumple_condicion) = @_;
    $self->cumple_condicion($cumple_condicion);
}
1;

