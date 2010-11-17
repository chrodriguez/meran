package C4::Modelo::AdqProveedor;

use strict;
use utf8;
use C4::AR::Permisos;
use C4::AR::Utilidades;
use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'adq_proveedor',

    columns => [
        id_proveedor   => { type => 'integer', not_null => 1 },
        apellido  => { type => 'varchar', length => 255, not_null => 1},
        nombre  => { type => 'varchar', length => 255, not_null => 1},
        tipo_doc => { type => 'integer', not_null => 1},
        dni => { type => 'varchar', length => 12, not_null => 1 },
        razon_social => { type => 'varchar', length => 255, not_null => 1 },
        cuit_cuil => { type => 'varchar', length => 32, not_null => 1 },
        pais => { type => 'integer', not_null => 1},
        provincia => { type => 'integer', not_null => 1},
        ciudad => { type => 'integer', not_null => 1},
        domicilio    => { type => 'varchar', length =>  255, not_null => 1 },
        telefono => { type => 'varchar', length => 32, not_null => 1 },
        fax  => { type => 'varchar', length => 32},
        email  => { type => 'varchar', length => 255},
        plazo_reclamo => { type => 'integer', length => 11},
        activo => { type => 'integer', default => 0, not_null => 1},
    ],

    relationships =>
    [
      
      tipo_doc_ref{
        class       => 'C4::Modelo::RefTipoDocumento',
        key_columns => { tipo_doc => 'idTipoDoc' },
        type        => 'one to one',
      },

      pais_ref => 
      {
        class       => 'C4::Modelo::RefPais',
        key_columns => { pais => 'id' },
        type        => 'one to one',
      },

      provincia_ref => 
      {
        class       => 'C4::Modelo::RefProvincia',
        key_columns => { provincia => 'provincia' },
        type        => 'one to one',
      },

      cuidad_ref => 
      {
        class       => 'C4::Modelo::RefCiudad',
        key_columns => { provincia => 'id' },
        type        => 'one to one',
      },

    ],
    
    primary_key_columns => [ 'id_proveedor' ],
    unique_key => ['tipo_documento','nro_documento'],

);

# *************************************************************************FUNCIONES DEL MODELO | PROVEEDORES************************************************************

sub desactivar{
    my ($self) = shift;
    $self->setActivo(0);
    $self->save();
}

sub agregarProveedor{

    my ($self) = shift;
    my ($params) = @_;

    $self->setNombre($params->{'nombre'});
    $self->setApellido($params->{'apellido'});
    $self->setDomicilio($params->{'domicilio'});
    $self->setTelefono($params->{'telefono'});
    $self->setEmail($params->{'email'});
    $self->setTipoDoc($params->{'tipo_doc'});
    $self->setDni($params->{'dni'});
    $self->setRazonSocial($params->{' razon_social'});
    $self->setCuitCuil($params->{'cuit_cuil'});
    $self->setFax($params->{'fax'});
    $self->setPais($params->{'pais'});
    $self->setProvincia($params->{'provincia'});
    $self->setCiudad($params->{'ciudad'});
    $self->setActivo(1);

    $self->save();
}

sub editarProveedor{

    my ($self) = shift;
    my ($params) = @_;
   
    $self->setNombre($params->{'nombre'});
    $self->setApellido($params->{'apellido'});
    $self->setDomicilio($params->{'domicilio'});
    $self->setTelefono($params->{'telefono'});
    $self->setEmail($params->{'email'});
    $self->setTipoDoc($params->{'tipo_doc'});
    $self->setDni($params->{'dni'});
    $self->setRazonSocial($params->{' razon_social'});
    $self->setCuitCuil($params->{'cuit_cuil'});
    $self->setFax($params->{'fax'});
    $self->setPais($params->{'pais'});
    $self->setProvincia($params->{'provincia'});
    $self->setCiudad($params->{'ciudad'});
    $self->setActivo(1);

    $self->save();
}

# ****************************************************FIN FUNCIONES DEL MODELO | PROVEEDORES**************************************************************




# *********************************************************************************Getter y Setter*******************************************************************


sub setNombre{
    my ($self) = shift;
    my ($nombre) = @_;
    utf8::encode($nombre);
    if (C4::AR::Utilidades::validateString($nombre)){
      $self->nombre($nombre);
    }
}

sub setApellido{
    my ($self) = shift;
    my ($apellido) = @_;
    utf8::encode($apellido);
    if (C4::AR::Utilidades::validateString($apellido)){
      $self->apellido($apellido);
    }
}

sub setTipoDoc{
    my ($self) = shift;
    my ($tipoDoc) = @_;
    utf8::encode($tipoDoc);
    if (C4::AR::Utilidades::validateString($tipoDoc)){
      $self->tipo_doc($tipoDoc);
    }
}

#VER COMO VALIDARLO
 sub setDni{
     my ($self) = shift;
     my ($dni) = @_;
     utf8::encode($dni);
     if (C4::AR::Utilidades::validateString($dni)){
       $self->dni($dni);
     }
 }

sub setRazonSocial{
    my ($self) = shift;
    my ($razonSocial) = @_;
    utf8::encode($razonSocial);
    if (C4::AR::Utilidades::validateString($razonSocial)){
      $self->razon_social($razonSocial);
    }
}

# VER COMO VALIDARLO

sub setCuitCuil{
    my ($self) = shift;
    my ($cuitCuil) = @_;
    utf8::encode($cuitCuil);
    if (C4::AR::Utilidades::validateString($cuitCuil)){
      $self->cuit_cuil($cuitCuil);
    }
}

sub setPais{
    my ($self) = shift;
    my ($pais) = @_;
    utf8::encode($pais);
    $self->pais($pais);
}

sub setProvincia{
    my ($self) = shift;
    my ($prov) = @_;
    utf8::encode($prov);
    $self->provincia($prov);  
}

sub setCiudad{
    my ($self) = shift;
    my ($ciu) = @_;
    utf8::encode($ciu);
    $self->ciudad($ciu);
    
}

sub setActivo{
    my ($self) = shift;
    my ($activo) = @_;
   $self->activo($activo);
}

sub setEmail{
    my ($self) = shift;
    my ($email) = @_;
    utf8::encode($email);
    if (C4::AR::Utilidades::validateString($email)){
      $self->email($email);
    }
}

sub setTelefono{
    my ($self) = shift;
    my ($telefono) = @_;
    utf8::encode($telefono);
    if (C4::AR::Utilidades::validateString($telefono)){
      $self->telefono($telefono);
    }
}



sub getId{
    my ($self) = shift;
    return ($self->id_proveedor);
}


sub getNombre{
    my ($self) = shift;
    return ($self->nombre);
}

sub getDireccion{
    my ($self) = shift;
    return ($self->direccion);
}

sub getTelefono{
    my ($self) = shift;
    return ($self->telefono);
}

sub getEmail{
    my ($self) = shift;
    return ($self->email);
}

sub setDireccion{
    my ($self) = shift;
    my ($direccion) = @_;
    utf8::encode($direccion);
    if (C4::AR::Utilidades::validateString($direccion)){
      $self->direccion($direccion);
    }
}


# *************************************************************************************FIN Getter y Setter*******************************************************************

1;



