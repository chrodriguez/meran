package C4::Modelo::CircSancion;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'circ_sancion',

    columns => [
        id_sancion   => { type => 'serial', not_null => 1 },
        tipo_sancion => { type => 'integer', default => '0' },
        id_reserva    => { type => 'integer' },
        nro_socio   => { type => 'integer', default => '0', not_null => 1 },
        fecha_comienzo        => { type => 'varchar', default => '0000-00-00', not_null => 1 },
        fecha_final          => { type => 'varchar', default => '0000-00-00', not_null => 1 },
        dias_sancion        => { type => 'integer', default => '0' },
        id3       => { type => 'integer' },
    ],

    primary_key_columns => [ 'id_sancion' ],

	relationships => [
	    reserva => {
            class      => 'C4::Modelo::CircReserva',
            column_map => { id_reserva => 'id_reserva' },
            type       => 'one to one',
        },
    ],
);


sub getId_sancion{
    my ($self) = shift;
    return ($self->id_sancion);
}

sub setId_sancion{
    my ($self) = shift;
    my ($id_sancion) = @_;
    $self->id_sancion($id_sancion);
}

sub getId3{
    my ($self) = shift;
    return ($self->id3);
}

sub setId3{
    my ($self) = shift;
    my ($id3) = @_;
    $self->id3($id3);
}

sub getTipo_sancion{
    my ($self) = shift;
    return ($self->tipo_sancion);
}

sub setTipo_sancion{
    my ($self) = shift;
    my ($tipo_sancion) = @_;
    $self->tipo_sancion($tipo_sancion);
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

sub getId_reserva{
    my ($self) = shift;
    return ($self->id_reserva);
}

sub setId_reserva{
    my ($self) = shift;
    my ($id_reserva) = @_;
    $self->id_reserva($id_reserva);
}

sub getFecha_comienzo{
    my ($self) = shift;
    return ($self->fecha_comienzo);
}

sub setFecha_comienzo{
    my ($self) = shift;
    my ($fecha_comienzo) = @_;
    $self->fecha_comienzo($fecha_comienzo);
}

sub getFecha_final{
    my ($self) = shift;
    return ($self->fecha_final);
}

sub setFecha_final{
    my ($self) = shift;
    my ($fecha_final) = @_;
    $self->fecha_final($fecha_final);
}

sub getDias_sancion{
    my ($self) = shift;
    return ($self->dias_sancion);
}

sub setDias_sancion{
    my ($self) = shift;
    my ($dias_sancion) = @_;
    $self->dias_sancion($dias_sancion);
}

=item
agregar
Funcion que agrega una sancion
=cut

sub agregar {
    my ($self)=shift;
    my ($data_hash)=@_;
    #Asignando data...
    $self->setId3($data_hash->{'id3'}||undef);
    $self->setId_reserva($data_hash->{'id_reserva'}||undef);
    $self->setNro_socio($data_hash->{'nro_socio'});
    $self->setTipo_sancion($data_hash->{'tipo_sancion'}||undef);
    $self->setFecha_comienzo($data_hash->{'fecha_comienzo'});
    $self->setFecha_final($data_hash->{'fecha_final'});
    $self->setDias_sancion($data_hash->{'dias_sancion'}||undef);
    $self->save();

}


sub insertar_sancion {
    my ($self)=shift;
	my ($data_hash)=@_;
 #Esta funcion da de alta una sancion
  	my $dateformat = C4::Date::get_date_format();
 #Hay varios casos:
 #Si no existe una tupla con una posible sancion y debe ser sancionado por $delaydays
 #Si existe se sanciona con la mayor cantidad de dias

 #Busco si tiene una sancion pendiente
    use C4::Modelo::CircSancion::Manager;
    my $sanciones_array_ref = C4::Modelo::CircSancion::Manager->get_circ_sancion( db=>$self->db,
							query => [ nro_socio => { eq => $data_hash->{'nro_socio'} },
									   fecha_comienzo => { eq => undef },
									   fecha_final => { eq => undef }] 
							);
	
	if (my $sancion_existente=@$sanciones_array_ref[0]){
	#Hay sancion pendiente
		if ( $sancion_existente->getDias_sancion < $data_hash->{'dias_sancion'}) {
		#La Sancion pendiente es menor a la actual, recalculo la fecha de fin
		my $err;
		my $fecha_final_nueva= C4::Date::format_date_in_iso(DateCalc($data_hash->{'fecha_comienzo'},"+ ".$data_hash->{'dias_sancion'}." days",\$err),$dateformat);

		$sancion_existente->setTipo_sancion($data_hash->{'tipo_sancion'});
		$sancion_existente->setDias_sancion($data_hash->{'dias_sancion'});
		$sancion_existente->setFecha_final($fecha_final_nueva);
		$sancion_existente->setFecha_comienzo($data_hash->{'fecha_comienzo'});
		$sancion_existente->save();
		}
	}
	else {
	#No tiene sanciones pendientes
	$self->agregar($data_hash);
	}


}



sub actualizar_sancion {
    my ($self)=shift;
	my ($params)=@_;
	
	$self->setId3($params->{'id3'});
	$self->save();

#**********************************Se registra el movimiento en historicSanction***************************
   use C4::Modelo::RepHistorialSancion;
   my ($historial_sancion) = C4::Modelo::RepHistorialSancion->new(db=>$self->db);
   $params->{'tipo'}= 'Update';
   $historial_sancion->agregar($params);
#*******************************Fin***Se registra el movimiento en historicSanction*************************
}



1;

