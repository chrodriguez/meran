package C4::Modelo::CatNivel3;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);
use base 'Rose::DB::Object::Cached';

__PACKAGE__->meta->setup(
    table   => 'cat_nivel3',

    columns => [
        id3                   => { type => 'serial', not_null => 1 },
        id1                   => { type => 'integer', not_null => 1 },
        id2                   => { type => 'integer', not_null => 1 },
        barcode               => { type => 'varchar', length => 20 },
        signatura_topografica => { type => 'varchar', length => 30 },
        id_ui_poseedora       => { type => 'varchar', length => 4 }, #ui que tiene el item
        id_ui_origen          => { type => 'varchar', length => 4 }, #ui de donde viene el item
        id_disponibilidad     => { type => 'integer', length => 5, default => '0', not_null => 1 },
        id_estado             => { type => 'character', default => '0', length => 2 },
        timestamp             => { type => 'timestamp', not_null => 1 },
        agregacion_temp       => { type => 'varchar', length => 255 },
    ],

    primary_key_columns => [ 'id3' ],

    relationships => [
	    nivel2 => {
            class      => 'C4::Modelo::CatNivel2',
            column_map => { id2 => 'id2' },
            type       => 'one to one',
        },

		nivel1 => {
            class      => 'C4::Modelo::CatNivel3',
            column_map => { id1 => 'id1' },
            type       => 'one to one',
        },

        cat_nivel3_repetible => {
            class      => 'C4::Modelo::CatNivel3Repetible',
            column_map => { id3 => 'id3' },
            type       => 'one to many',
        },

        circ_reserva => {
            class      => 'C4::Modelo::CircReserva',
            column_map => { id3 => 'id3' },
            type       => 'one to many',
        },
        
        ref_disponibilidad => {
            class      => 'C4::Modelo::RefDisponibilidad',
            column_map => { id_disponibilidad => 'codigo' },
            type       => 'one to one',
        },

	 	ref_estado => {
            class      => 'C4::Modelo::RefEstado',
            column_map => { id_estado => 'codigo' },
            type       => 'one to one',
        },

#         ref_ui_poseedora => {
#             class      => 'C4::Modelo::RefUnidadInformacion',
#             column_map => { id_ui_poseedora => 'id_ui' },
#             type       => 'one to many',
#         },
#         
#         ref_ui_origen => {
#             class      => 'C4::Modelo::RefUnidadInformacion',
#             column_map => { id_ui_origen => 'id_ui' },
#             type       => 'one to many',
#         },
    ],
);


sub agregar{
    my ($self)=shift;
    my ($data_hash)=@_;

    use C4::Modelo::CatNivel2Repetible;

    my @arrayNivel3;
    my @arrayNivel3Repetibles;
    my $infoArrayNivel3 = $data_hash->{'infoArrayNivel3'}; #seteo el arreglo de campos repetibles y no repetibles
	#se separa la info en arreglo de repetibles y no repetibles
    foreach my $infoNivel3 (@$infoArrayNivel3){
        if($infoNivel3->{'repetible'}){
            push(@arrayNivel3Repetibles, $infoNivel3);
        }else{
            push(@arrayNivel3, $infoNivel3);
        }
    }

    $self->setId1($data_hash->{'id1'});
    $self->setId2($data_hash->{'id2'});

    #se guardan los datos de Nivel3
    foreach my $infoNivel3 (@arrayNivel3){  
        $self->setDato($infoNivel3);
    } #END foreach my $infoNivel3 (@arrayNivel3)


    if(!$data_hash->{'modificado'}){
        $self->setBarcode($data_hash->{'barcode'});
    }
    
    $self->save(); #guardo un nivel 3

    my $id3= $self->getId3;

    #Se guradan los datos en Nivel 3 repetibles
    foreach my $infoNivel3 (@arrayNivel3Repetibles){
        $infoNivel3->{'id3'}= $id3;
        my $nivel3Repetible;
        C4::AR::Debug::debug("CatNivel3 => campo, subcampo: ".$infoNivel3->{'campo'}.", ".$infoNivel3->{'subcampo'});

        if ( $infoNivel3->{'Id_rep'} != 0 ){
            C4::AR::Debug::debug("CatNivel3 => agregar => Se va a modificar CatNivel3, Id_rep: ". $infoNivel3->{'Id_rep'});
            $nivel3Repetible = C4::Modelo::CatNivel3Repetible->new(db => $self->db, rep_n3_id => $infoNivel3->{'Id_rep'});
            $nivel3Repetible->load();
        }else{
            C4::AR::Debug::debug("CatNivel3 => agregar => No existe el REPETIBLE se crea uno");
            $nivel3Repetible = C4::Modelo::CatNivel3Repetible->new(db => $self->db);
        }

        $nivel3Repetible->setId3($infoNivel3->{'id3'});
        $nivel3Repetible->setCampo($infoNivel3->{'campo'});
        $nivel3Repetible->setSubcampo($infoNivel3->{'subcampo'});
		if ($infoNivel3->{'referencia'}) {
            C4::AR::Debug::debug("CatNivel3 => REPETIBLE con REFERENCIA: ".$infoNivel3->{'datoReferencia'});
            $nivel3Repetible->dato($infoNivel3->{'datoReferencia'});
        }else{
            C4::AR::Debug::debug("CatNivel3 => REPETIBLE sin REFERENCIA: ".$infoNivel3->{'dato'});
            $nivel3Repetible->dato($infoNivel3->{'dato'});
		}

        $nivel3Repetible->save();
    }
}

sub eliminar{

    my ($self)=shift;

    use C4::Modelo::CatNivel3Repetible;
    use C4::Modelo::CatNivel3Repetible::Manager;

    my ($repetiblesNivel3) = C4::Modelo::CatNivel3Repetible::Manager->get_cat_nivel3_repetible( 
																
																					query => [ id3 => { eq => $self->getId3 } ] 
																				);
    foreach my $n3Rep (@$repetiblesNivel3){
	  	$n3Rep->load( db => $self->db );
		$n3Rep->eliminar();
    }

    $self->delete();

}

sub setDato{
	my ($self) = shift;
	my ($data_hash)=@_;
	my $barcode;

# 	if( ($data_hash->{'campo'} eq '995')&&($data_hash->{'subcampo'} eq 'f') ){
	#tipo de documento
=item
		if($data_hash->{'agregarPorBarcodes'}){
		#se esta haciendo un alta de 1 o mas barcodes
			$barcode= $data_hash->{'barcode'};
		}else {		
			$barcode= $data_hash->{'dato'}
		}
=cut

#         $barcode= $data_hash->{'barcode'};
# 		$self->setBarcode($barcode);
# 		$self->debug ("Se agrega el BARCODE: ".$barcode);
# 	}
    if( ($data_hash->{'campo'} eq '995')&&($data_hash->{'subcampo'} eq 'f') ){
        if($data_hash->{'modificado'}){
            $self->setBarcode($data_hash->{'dato'});
        }
    }

# 	elsif( ($data_hash->{'campo'} eq '995')&&($data_hash->{'subcampo'} eq 't') ){
    if( ($data_hash->{'campo'} eq '995')&&($data_hash->{'subcampo'} eq 't') ){
	#signatura_topografica
		if( ($data_hash->{'modificado'})&&($data_hash->{'referencia'}) ){
				$self->setSignatura_topografica($data_hash->{'datoReferencia'});
			}else{
				$self->setSignatura_topografica($data_hash->{'dato'});
		}
	}

	elsif( ($data_hash->{'campo'} eq '995')&&($data_hash->{'subcampo'} eq 'c') ){
	#UI poseedora
		if( ($data_hash->{'modificado'})&&($data_hash->{'referencia'}) ){
				$self->setId_ui_poseedora($data_hash->{'datoReferencia'});
			}else{
				$self->setId_ui_poseedora($data_hash->{'dato'});
		}
	}

	elsif( ($data_hash->{'campo'} eq '995')&&($data_hash->{'subcampo'} eq 'd') ){
	#UI origen
		if( ($data_hash->{'modificado'})&&($data_hash->{'referencia'}) ){
				$self->setId_ui_origen($data_hash->{'datoReferencia'});
			}else{
				$self->setId_ui_origen($data_hash->{'dato'});
		}
	}

	elsif( ($data_hash->{'campo'} eq '995')&&($data_hash->{'subcampo'} eq 'o') ){
	#disponibilidad
		if( ($data_hash->{'modificado'})&&($data_hash->{'referencia'}) ){
				$self->setId_disponibilidad($data_hash->{'datoReferencia'});
			}else{
				$self->setId_disponibilidad($data_hash->{'dato'});
		}
	}

	elsif( ($data_hash->{'campo'} eq '995')&&($data_hash->{'subcampo'} eq 'e') ){
	#estado del ejemplar
		if( ($data_hash->{'modificado'})&&($data_hash->{'referencia'}) ){
				$self->setId_estado($data_hash->{'datoReferencia'});
			}else{
				$self->setId_estado($data_hash->{'dato'});
		}
	}
}

sub getId_ui_poseedora{
    my ($self) = shift;
    return ($self->id_ui_poseedora);
}

sub setId_ui_poseedora{
    my ($self) = shift;
    my ($id_ui_poseedora) = @_;
    $self->id_ui_poseedora($id_ui_poseedora);
}

sub getId_ui_origen{
    my ($self) = shift;
    return ($self->id_ui_origen);
}

sub setId_ui_origen{
    my ($self) = shift;
    my ($id_ui_origen) = @_;
    $self->id_ui_origen($id_ui_origen);
}

sub getId1{
    my ($self) = shift;
    return ($self->id1);
}

sub setId1{
    my ($self) = shift;
    my ($id1) = @_;
    $self->id1($id1);
}

sub getId2{
    my ($self) = shift;
    return ($self->id2);
}

sub setId2{
    my ($self) = shift;
    my ($id2) = @_;
    $self->id2($id2);
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

sub getBarcode{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->barcode));
}

sub setBarcode{
    my ($self) = shift;
    my ($barcode) = @_;
    $self->barcode($barcode);
}

sub getSignatura_topografica{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->signatura_topografica));
}

sub setSignatura_topografica{
    my ($self) = shift;
    my ($signatura_topografica) = @_;
    $self->signatura_topografica($signatura_topografica);
}

sub getId_disponibilidad{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->id_disponibilidad));
}

sub setId_disponibilidad{
    my ($self) = shift;
    my ($id_disponibilidad) = @_;
    $self->id_disponibilidad($id_disponibilidad);
}

sub setId_estado{
    my ($self) = shift;
    my ($id_estado) = @_;
    $self->id_estado($id_estado);
}

sub getId_estado{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->id_estado));
}

sub getTimestamp{
    my ($self) = shift;
    return ($self->timestamp);
}

sub setTimestamp{
    my ($self) = shift;
    my ($timestamp) = @_;
    $self->timestamp($timestamp);
}

sub estaPrestado{
	my ($self) = shift;
	return 0;
}

sub estadoDisponible{
	my ($self) = shift;
	return (C4::AR::Referencias::getNombreEstado($self->getId_estado) eq "Disponible");
}

sub esParaSala{
	my ($self) = shift;
	return (C4::AR::Referencias::getNombreDisponibilidad($self->getId_estado) eq "Sala de Lectura");
}

sub getEstado{
	my ($self) = shift;

	return (C4::AR::Referencias::getNombreEstado($self->getId_estado));
}

sub estaPrestado {
  	my ($self) = shift;

    return (C4::AR::Prestamos::estaPrestado($self->getId3));
}


# ===================================================SOPORTE=====ESTRUCTURA CATALOGACION=================================================

=item
Esta funcion devuelve los campos de nivel 3 mapeados en un arreglo de {campo, subcampo, dato}
=cut
sub toMARC{
    my ($self) = shift;
	my @marc_array;

	my $campo= '995';
	my $subcampo= 'd';
	my %hash;
	$hash{'campo'}= $campo;
	$hash{'subcampo'}= $subcampo;
	$hash{'header'}= C4::AR::Busquedas::getHeader($campo);
	$hash{'dato'}= C4::AR::Referencias::getNombreUI($self->getId_ui_origen);
	my $estructura= C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($campo, $subcampo);
	$hash{'liblibrarian'}= $estructura->[0]->getLiblibrarian;
	if($estructura->[0]->getReferencia){
	#tiene referencia
		$hash{'datoReferencia'}= $self->getId_ui_origen;
	}

	push (@marc_array, \%hash);

	$campo= '995';
	$subcampo= 'f';
	my %hash;
	$hash{'campo'}= $campo;
	$hash{'subcampo'}= $subcampo;
	$hash{'header'}= C4::AR::Busquedas::getHeader($campo);
	$hash{'dato'}= $self->getBarcode;

	push (@marc_array, \%hash);

	$campo= '995';
	$subcampo= 'c';
	my %hash;
	$hash{'campo'}= $campo;
	$hash{'subcampo'}= $subcampo;
	$hash{'header'}= C4::AR::Busquedas::getHeader($campo);
	$hash{'dato'}= C4::AR::Referencias::getNombreUI($self->getId_ui_poseedora);
	my $estructura= C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($campo, $subcampo);
	$hash{'liblibrarian'}= $estructura->[0]->getLiblibrarian;
	if($estructura->[0]->getReferencia){
	#tiene referencia
		$hash{'datoReferencia'}= $self->getId_ui_poseedora;
	}

	push (@marc_array, \%hash);

	$campo= '995';
	$subcampo= 't';
	my %hash;
	$hash{'campo'}= $campo;
	$hash{'subcampo'}= $subcampo;
	$hash{'header'}= C4::AR::Busquedas::getHeader($campo);
	$hash{'dato'}= $self->getSignatura_topografica;

	push (@marc_array, \%hash);

	$campo= '995';
	$subcampo= 'e';
	my %hash;
	$hash{'campo'}= $campo;
	$hash{'subcampo'}= $subcampo;
	$hash{'header'}= C4::AR::Busquedas::getHeader($campo);
	$hash{'dato'}= C4::AR::Referencias::getNombreEstado($self->getId_estado);
	my $estructura= C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($campo, $subcampo);
	$hash{'liblibrarian'}= $estructura->[0]->getLiblibrarian;
	if($estructura->[0]->getReferencia){
	#tiene referencia
		$hash{'datoReferencia'}= $self->getId_estado;
	}

	push (@marc_array, \%hash);

	$campo= '995';
	$subcampo= 'o';
	my %hash;
	$hash{'campo'}= $campo;
	$hash{'subcampo'}= $subcampo;
	$hash{'header'}= C4::AR::Busquedas::getHeader($campo);
	$hash{'dato'}= C4::AR::Referencias::getNombreDisponibilidad($self->getId_disponibilidad);
	my $estructura= C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($campo, $subcampo);
	$hash{'liblibrarian'}= $estructura->[0]->getLiblibrarian;
	if($estructura->[0]->getReferencia){
	#tiene referencia
		$hash{'datoReferencia'}= $self->getId_disponibilidad;
	}


	push (@marc_array, \%hash);

	
	return (\@marc_array);
}

=item
Esta funcion devuelve los campos de nivel 3 y nivel3Repetible mapeados en un arreglo de {campo, subcampo, dato}
=cut
sub nivel3CompletoToMARC{
    my ($self) = shift;

	my ($marc_array)= $self->toMARC;
	my ($nivel3Repetible_object_array) = C4::Modelo::CatNivel3Repetible::Manager->get_cat_nivel3_repetible( 
																						query => [ id3 => { eq => $self->getId3 } ]
																		);

	my $campo;
	my $subcampo;
	my $dato;	

	foreach my $marc_object (@$nivel3Repetible_object_array){
		$campo= $marc_object->getCampo;
		$subcampo= $marc_object->getSubcampo;
		$dato= $marc_object->getDato;
		my %hash;
		$hash{'header'}= C4::AR::Busquedas::getHeader($campo);
		$hash{'campo'}= $campo;
		$hash{'subcampo'}= $subcampo;
		$hash{'liblibrarian'}= C4::AR::Busquedas::getLiblibrarian($campo, $subcampo);
		$hash{'dato'}= $dato;

 		push(@$marc_array, \%hash);
C4::AR::Debug::debug("nivel3CompletoToMARC => ".$campo.", ".$subcampo."  ".$dato);		
	}

C4::AR::Debug::debug("nivel3CompletoToMARC => cant: ".scalar(@$marc_array));
	
	return ($marc_array);
}

# ==============================================FIN===SOPORTE=====ESTRUCTURA CATALOGACION================================================


sub getInvolvedCount{
 
    my ($self) = shift;

    my ($campo, $value)= @_;
    
    my @filtros;

    push (@filtros, ( $campo => $value ) );

    my $cat_nivel3_count = C4::Modelo::CatNivel3::Manager->get_cat_nivel3_count( query => \@filtros );

    return ($cat_nivel3_count);
}

sub replaceBy{
 
    my ($self) = shift;

    my ($campo,$value,$new_value)= @_;
    
    my @filtros;

    push (  @filtros, ( $campo => { eq => $value},) );


    my $replaced = C4::Modelo::CatNivel3::Manager->update_cat_nivel3(   where => \@filtros,
                                                                        set   => { $campo => $new_value });
}


1;

