package C4::Modelo::AdqFormaEnvio;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'adq_forma_envio',

    columns => [
        id   => { type => 'integer', length => 11, not_null => 1 },
        nombre  => { type => 'varchar', length => 255, not_null => 1},
    ],

    primary_key_columns => [ 'id' ],

);

# **********************************************************************FIN FUNCIONES DEL MODELO | MONEDA************************************************************





# *********************************************************************************Getter y Setter*******************************************************************


sub setNombre{
    my ($self) = shift;
    my ($nombre) = @_;
    utf8::encode($nombre);
    if (C4::AR::Utilidades::validateString($nombre)){
      $self->nombre($nombre);
    }
}

sub getNombre{
    my ($self) = shift;
    return ($self->nombre);
    
}




1;