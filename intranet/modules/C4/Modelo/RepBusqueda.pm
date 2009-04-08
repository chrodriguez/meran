package C4::Modelo::RepBusqueda;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'rep_busqueda',

    columns => [
        idBusqueda => { type => 'serial', not_null => 1 },
        id_socio   => { type => 'integer' },
        fecha      => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'idBusqueda' ],
   
    relationships => [
         socio =>  {
            class       => 'C4::Modelo::UsrSocio',
            key_columns => { id_socio => 'id_socio' },
            type        => 'one to one',
      },
         
    ],
);


sub agregar{

   my $self = shift;
   my $nro_socio = @_;
   $self->setId_socio($nro_socio);
   $self->setFecha(C4::AR::Date::today());
   $self->save();
}

sub getIdBusqueda{

   my $self = shift;
   return ($self->idBusqueda);
}

sub getId_socio{

   my $self = shift;
   return ($self->id_socio);
}

sub getFecha{

   my $self = shift;
   return ($self->fecha);
}

sub setId_socio{

   my $self = shift;
   my $nro_socio = @_;
   $self->id_socio($nro_socio);
}

sub setFecha{

   my $self = shift;
   my $fecha = @_;
   $self->fecha($fecha);
}

1;

