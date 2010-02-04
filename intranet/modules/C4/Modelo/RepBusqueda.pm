package C4::Modelo::RepBusqueda;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'rep_busqueda',

    columns => [
        idBusqueda => { type => 'serial', not_null => 1 },
        nro_socio   => { type => 'varchar' , length => 16},
        fecha      => { type => 'varchar', length => 12, not_null => 1 },
    ],

    primary_key_columns => [ 'idBusqueda' ],
   
    relationships => [
         socio =>  {
            class       => 'C4::Modelo::UsrSocio',
            key_columns => { nro_socio => 'nro_socio' },
            type        => 'one to one',
      },
         
    ],
);


sub agregar{

   my ($self) = shift;
   my ($nro_socio) = @_;
   $self->setNro_socio($nro_socio);
   $self->setFecha(C4::AR::Utilidades::getToday());
   $self->save();
}

sub getIdBusqueda{

   my ($self) = shift;
   return ($self->idBusqueda);
}

sub getNro_socio{

   my ($self) = shift;
   return ($self->nro_socio);
}

sub getFecha{

   my ($self) = shift;
   return ($self->fecha);
}

sub setNro_socio{

   my ($self) = shift;
   my ($nro_socio) = @_;
   $self->nro_socio($nro_socio);
}

sub setFecha{

   my ($self) = shift;
   my ($fecha) = @_;
   $self->fecha($fecha);
}

1;

