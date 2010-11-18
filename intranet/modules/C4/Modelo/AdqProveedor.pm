package C4::Modelo::AdqProveedor;

use strict;
use utf8;
use C4::AR::Permisos;
use C4::AR::Utilidades;
use C4::Modelo::RefTipoDocumento;
use C4::Modelo::RefPais;
use C4::Modelo::RefProvincia;
use C4::Modelo::RefLocalidad;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'adq_proveedor',

    columns => [
        id_proveedor   => { type => 'integer', not_null => 1 },
        apellido  => { type => 'varchar', length => 255, not_null => 1},
        nombre  => { type => 'varchar', length => 255, not_null => 1},
        tipo_doc => { type => 'integer', not_null => 1},
        nro_doc => { type => 'varchar', length => 12, not_null => 1 },
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
      tipo_doc_ref => 
      {
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
        class       => 'C4::Modelo::RefLocalidad',
        key_columns => { provincia => 'id' },
        type        => 'one to one',
      },

    ],
    
    primary_key_columns => [ 'id_proveedor' ],
    unique_key => ['tipo_doc','nro_doc'],

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
    $self->setNroDoc($params->{'nro_doc'});
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
    $self->setNroDoc($params->{'nro_doc'});
    $self->setRazonSocial($params->{' razon_social'});
    $self->setCuitCuil($params->{'cuit_cuil'});
    $self->setFax($params->{'fax'});
    $self->setPais($params->{'pais'});
    $self->setProvincia($params->{'provincia'});
    $self->setCiudad($params->{'ciudad'});
    $self->setActivo(1);

    $self->save();
}

# Funcion que devuelve las monedas que tiene el proveedor
sub getMonedas{

    my ($params) = @_;
    
}

# ****************************************************FIN FUNCIONES DEL MODELO | PROVEEDORES**************************************************************




# *********************************************************************************Getters y Setters*******************************************************************

sub setApellido{
    my ($self) = shift;
    my ($apellido) = @_;
    utf8::encode($apellido);
    if (C4::AR::Utilidades::validateString($apellido)){
      $self->apellido($apellido);
    }
}

sub setNombre{
    my ($self) = shift;
    my ($nombre) = @_;
    utf8::encode($nombre);
    if (C4::AR::Utilidades::validateString($nombre)){
      $self->nombre($nombre);
    }
}

sub setTipoDoc{
    my ($self) = shift;
    my ($tipoDoc) = @_;
    utf8::encode($tipoDoc);
    $self->tipo_doc($tipoDoc);
}

sub setNroDoc{
    my ($self) = shift;
    my ($docNumber, $docType) = @_;
    utf8::encode($docNumber);
    utf8::encode($docType);
    if (C4::AR::Validator::isValidDocument($docType, $docNumber)){
      $self->nro_doc($docNumber);
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

sub setDomicilio{
    my ($self) = shift;
    my ($domicilio) = @_;
    utf8::encode($domicilio);
    if (C4::AR::Utilidades::validateString($domicilio)){
      $self->domicilio($domicilio);
    }
}

sub setEmail{
    my ($self) = shift;
    my ($email) = @_;
    utf8::encode($email);
    if (C4::AR::Validator::isValidMail($email)){
      $self->email($email);
    }
}

sub setTelefono{
    my ($self) = shift;
    my ($telefono) = @_;
    utf8::encode($telefono);
#     if (C4::AR::Validator::countAlphaNumericChars($telefono) = 0){
       $self->telefono($telefono);
#     }
}

sub setFax{
    my ($self) = shift;
    my ($fax) = @_;
    utf8::encode($fax);
 #   if ((C4::AR::Validator::countAlphaChars($fax) = 0) & (C4::AR::Validator::countSymbolChars($fax) = 0)){
      $self->fax($fax);
  #  }
}

sub setPlazoReclamo{
    my ($self) = shift;
    my ($plazoRec) = @_;
    utf8::encode($plazoRec);
 #   if (C4::AR::Validator::countAlphaChars($plazoRec) = 0) & (C4::AR::Validator::countSymbolChars($plazoRec) = 0){
      $self->plazo_reclamo($plazoRec);
    }

sub setActivo{
    my ($self) = shift;
    my ($activo) = @_;
    $self->activo($activo);
}


# ------GETTERS--------------------

sub getId{
    my ($self) = shift;
    return ($self->id_proveedor);
}

sub getApellido{
    my ($self) = shift;
    return ($self->apellido);
}

sub getNombre{
    my ($self) = shift;
    return ($self->nombre);
}

sub getTipoDoc{
    my ($self) = shift;
    return ($self->tipo_doc);
}

sub getNroDoc{
    my ($self) = shift;
    return ($self->nro_doc);
}

sub getRazonSocial{
    my ($self) = shift;
    return ($self->razon_social);
}

sub getCuitCuil{
    my ($self) = shift;
    return ($self->cuit_cuil);
}

sub getPais{
    my ($self) = shift;
    return ($self->pais);
}

sub getProvincia{
    my ($self) = shift;
    return ($self->provincia);
}

sub getCiudad{
    my ($self) = shift;
    return ($self->ciudad);
}

sub getDomicilio{
    my ($self) = shift;
    return ($self->domicilio);
}

sub getTelefono{
    my ($self) = shift;
    return ($self->telefono);
}

sub getFax{
    my ($self) = shift;
    return ($self->fax);
}

sub getEmail{
    my ($self) = shift;
    return ($self->email);
}

sub getPlazoReclamo{
    my ($self) = shift;
    return ($self->plazo_reclamo);
}

sub getActivo{
    my ($self) = shift;
    return ($self->activo);
}






# *************************************************************************************FIN Getter y Setter*******************************************************************

1;



