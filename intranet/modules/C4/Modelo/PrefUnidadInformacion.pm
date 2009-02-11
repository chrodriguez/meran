package C4::Modelo::PrefUnidadInformacion;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'pref_unidad_informacion',

    columns => [
        id_ui         => { type => 'varchar', not_null => 1 , length => 4},
        nombre           => { type => 'varchar', not_null => 1 , length => 255},
        direccion           => { type => 'varchar', not_null => 1 , length => 255},
        alt_direccion           => { type => 'varchar', not_null => 1 , length => 255},
        telefono           => { type => 'varchar', not_null => 1 , length => 255},
        fax           => { type => 'varchar', not_null => 1 , length => 255},
        email           => { type => 'varchar', not_null => 1 , length => 255},
    ],

    primary_key_columns => [ 'id_ui' ],

    unique_key => [ 'id_ui' ],
); 

sub getId_ui{
    my ($self) = shift;

    return ($self->id_ui);
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
    
sub getDireccion{
    my ($self) = shift;

    return ($self->direccion);
} 
    
sub setDireccion{
    my ($self) = shift;
    my ($direccion) = @_;

    $self->direccion($direccion);
}
    
sub getAlt_direccion{
    my ($self) = shift;

    return ($self->direccion);
}
    
sub setAlt_direccion{
    my ($self) = shift;
    my ($alt_direccion) = @_;

    $self->alt_direccion($alt_direccion);
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
   
sub getFax{
    my ($self) = shift;

    return ($self->fax);
}
    
sub setFax{
    my ($self) = shift;
    my ($fax) = @_;

    $self->fax($fax);
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


sub agregar{

    my ($self)=shift;
    my ($data_hash)=@_;
    
    $self->setNombre($data_hash->{'nombre'});
    $self->setDireccion($data_hash->{'direccion'});
    $self->setAlt_direccion($data_hash->{'alt_direccion'});
    $self->setTelefono($data_hash->{'telefono'});
    $self->setFax($data_hash->{'fax'});
    $self->setEmail($data_hash->{'email'});
    
    $self->save();
}


sub nextMember{
    use C4::Modelo::RefIdioma;
    return(C4::Modelo::RefIdioma->new());
}

sub obtenerValoresCampo {
	my ($self)=shift;
    my ($campo)=@_;
	
 	my $ref_valores = C4::Modelo::PrefUnidadInformacion::Manager->get_pref_unidad_informacion
						( select   => [$self->meta->primary_key , $campo],
						  sort_by => ($campo) );

    return (scalar(@$ref_valores), $ref_valores);
}

1;

