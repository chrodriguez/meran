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
        nombre  => { type => 'varchar', length => 255, not_null => 1},
        direccion    => { type => 'varchar', length =>  255 },
        telefono => { type => 'varchar', length => 255 },
        email  => { type => 'varchar', length => 255},
        activo => { type => 'integer', default => 0, not_null => 1},
    ],
    
    primary_key_columns => [ 'id_proveedor' ],

);



sub desactivar{
    my ($self) = shift;
    $self->setActivo(0);
    $self->save();
}

sub agregarProveedor{


    my ($self) = shift;
    my ($params) = @_;



    $self->setNombreProveedor($params->{'nombre'});
    $self->setDireccion($params->{'direccion'});
    $self->setTelefono($params->{'telefono'});
    $self->setMail($params->{'email'});
    $self->setActivo(1);

    $self->save();

C4::AR::Debug::debug("entro a adqproveedor");
}


sub setActivo{
    my ($self) = shift;
    my ($activo) = @_;
   $self->activo($activo);
}

sub setMail{
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

sub setNombreProveedor{
    my ($self) = shift;
    my ($nombre) = @_;
    utf8::encode($nombre);
    if (C4::AR::Utilidades::validateString($nombre)){
      $self->nombre($nombre);
    }
}

sub setDireccion{
    my ($self) = shift;
    my ($direccion) = @_;
    utf8::encode($direccion);
    if (C4::AR::Utilidades::validateString($direccion)){
      $self->direccion($direccion);
    }
}

1;



