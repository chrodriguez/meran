package C4::Modelo::Contacto;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'contacto',

    columns => [
        id                    => { type => 'serial', not_null => 1 },
        trato          => { type => 'varchar', length => 255, not_null => 1 },
        nombre         => { type => 'varchar', length => 255, not_null => 1 },
        apellido       => { type => 'varchar', length => 255, not_null => 1 },
        direccion      => { type => 'varchar', length => 255, not_null => 0 },
        codigo_postal  => { type => 'varchar', length => 255, not_null => 0 },
        ciudad         => { type => 'varchar', length => 255, not_null => 0 },
        pais           => { type => 'varchar', length => 255, not_null => 0 },
        telefono       => { type => 'varchar', length => 255, not_null => 0 },
        email          => { type => 'varchar', length => 255, not_null => 1 },
        asunto         => { type => 'varchar', length => 255, not_null => 1 },
        mensaje        => { type => 'text', not_null => 1 },
        fecha          => { type => 'varchar', length => 255, not_null => 0 },
        leido          => { type => 'integer', not_null => 1, default => 0 },
    ],
    primary_key_columns => [ 'id' ],
);

sub agregar{
    my ($self) = shift;
    my ($data_hash) = @_;

    $self->setTrato($data_hash->{'trato'});
    $self->setNombre($data_hash->{'nombre'});
    $self->setApellido($data_hash->{'apellido'});
    $self->setDireccion($data_hash->{'direccion'});
    $self->setCodigoPostal($data_hash->{'codigo_postal'});
    $self->setCiudad($data_hash->{'ciudad'});
    $self->setPais($data_hash->{'pais'});
    $self->setTelefono($data_hash->{'telefono'});
    $self->setEmail($data_hash->{'email'});
    $self->setAsunto($data_hash->{'asunto'});
    $self->setMensaje($data_hash->{'mensaje'});
    $self->setFecha();

    $self->save();
}



sub getObjeto{
	my ($self) = shift;
	my ($id) = @_;

	my $objecto= C4::Modelo::RefIdioma->new(idLanguage => $id);
	$objecto->load();
	return $objecto;
}

sub getTrato{
    my ($self) = shift;

    return ($self->trato);
}

sub setTrato{
    my ($self) = shift;
    my ($trato) = @_;

    $self->trato($trato);
}

sub getFecha{
    my ($self) = shift;
    my $dateformat = C4::Date::get_date_format();

    return ( C4::Date::format_date($self->fecha,$dateformat) );
}

sub setFecha{
    my ($self) = shift;

    my $dateformat = C4::Date::get_date_format();

    my $fecha = C4::Date::format_date_in_iso(C4::AR::Utilidades::getToday(),$dateformat);

    $self->fecha($fecha);
	
}
sub getNombre{
    my ($self) = shift;

    return ($self->nombre);
}

sub setNombre{
    my ($self) = shift;
    my ($string) = @_;

    $self->nombre($string);
}

sub getApellido{
    my ($self) = shift;

    return ($self->apellido);
}

sub setApellido{
    my ($self) = shift;
    my ($string) = @_;

    $self->apellido($string);
}

sub getDireccion{
    my ($self) = shift;

    return ($self->direccion);
}

sub setDireccion{
    my ($self) = shift;
    my ($string) = @_;

    $self->direccion($string);
}

sub getCodigoPostal{
    my ($self) = shift;

    return ($self->codigo_postal);
}

sub setCodigoPostal{
    my ($self) = shift;
    my ($string) = @_;

    $self->codigo_postal($string);
}

sub getCiudad{
    my ($self) = shift;

    return ($self->ciudad);
}

sub setCiudad{
    my ($self) = shift;
    my ($string) = @_;

    $self->ciudad($string);
}

sub getPais{
    my ($self) = shift;

    return ($self->pais);
}

sub setPais{
    my ($self) = shift;
    my ($string) = @_;

    $self->pais($string);
}

sub getTelefono{
    my ($self) = shift;

    return ($self->telefono);
}

sub setTelefono{
    my ($self) = shift;
    my ($string) = @_;

    $self->telefono($string);
}

sub getEmail{
    my ($self) = shift;

    return ($self->email);
}

sub setEmail{
    my ($self) = shift;
    my ($string) = @_;

    $self->email($string);
}

sub getAsunto{
    my ($self) = shift;

    return ($self->asunto);
}

sub setAsunto{
    my ($self) = shift;
    my ($string) = @_;

    $self->asunto($string);
}

sub getMensaje{
    my ($self) = shift;

    return ($self->mensaje);
}

sub setMensaje{
    my ($self) = shift;
    my ($string) = @_;

    $self->mensaje($string);
}

sub getLeido{
    my ($self) = shift;

    return ($self->leido);
}

sub setLeido{
    my ($self) = shift;

    $self->leido(1);

    $self->save();
}

sub setNoLeido{
    my ($self) = shift;

    $self->leido(0);

    $self->save();
}

sub switchState{
    my ($self) = shift;

    if ($self->getLeido){
        $self->setNoLeido();
    }else{
        $self->setLeido();
    }

    $self->save();
}

1;

