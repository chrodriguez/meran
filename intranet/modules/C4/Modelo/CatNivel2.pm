package C4::Modelo::CatNivel2;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_nivel2',

    columns => [
        id2                 => { type => 'serial', not_null => 1 },
        id1                 => { type => 'integer', not_null => 1 },
        tipo_documento      => { type => 'varchar', length => 4, not_null => 1 },
        nivel_bibliografico => { type => 'varchar', length => 2, not_null => 0 },
        soporte             => { type => 'varchar', length => 3, not_null => 0 },
        pais_publicacion    => { type => 'character', length => 2, not_null => 0 },
        lenguaje            => { type => 'character', length => 2, not_null => 0 },
        ciudad_publicacion  => { type => 'varchar', length => 255, not_null => 0 },
        anio_publicacion    => { type => 'varchar', length => 15 },
        timestamp           => { type => 'timestamp' },
    ],

    primary_key_columns => [ 'id2' ],

    relationships => [
       nivel1 => {
            class      => 'C4::Modelo::CatNivel1',
            column_map => { id1 => 'id1' },
            type       => 'one to one',
        },

        cat_nivel2_repetible => {
            class      => 'C4::Modelo::CatNivel2Repetible',
            column_map => { id2 => 'id2' },
            type       => 'one to many',
        },
    
        cat_ref_tipo_nivel3 => {
            class      => 'C4::Modelo::CatRefTipoNivel3',
            column_map => { tipo_documento => 'id_tipo_doc' },
            type       => 'one to many',
        },

        ref_soporte => {
            class      => 'C4::Modelo::RefSoporte',
            column_map => { soporte => 'idSupport' },
            type       => 'one to many',
        },

        ref_idioma => {
            class      => 'C4::Modelo::RefIdioma',
            column_map => { lenguaje => 'idLanguage' },
            type       => 'one to many',
        },
		ref_nivel_bibliografico => {
            class      => 'C4::Modelo::RefNivelBibliografico',
            column_map => { nivel_bibliografico => 'code' },
            type       => 'one to many',
        },
		ref_pais_publicacion => {
            class      => 'C4::Modelo::RefPais',
            column_map => { pais_publicacion => 'iso' },
            type       => 'one to many',
        },
		ref_ciudad_publicacion => {
            class      => 'C4::Modelo::RefLocalidad',
            column_map => { ciudad_publicacion => 'LOCALIDAD' },
            type       => 'one to many',
        },
		
    ],
);


sub agregar{

    my ($self)=shift;
    use C4::Modelo::CatNivel2Repetible;

    my ($data_hash)=@_;

    my @arrayNivel2;
    my @arrayNivel2Repetibles;

    my $infoArrayNivel2= $data_hash->{'infoArrayNivel2'};
	#se guardan los datos de Nivel2
    foreach my $infoNivel2 (@$infoArrayNivel2){

        if($infoNivel2->{'repetible'}){
            push(@arrayNivel2Repetibles, $infoNivel2);
        }else{
            push(@arrayNivel2, $infoNivel2);
        }
    }
    
    #se guardan los datos de Nivel2
    foreach my $infoNivel2 (@arrayNivel2){  
		$self->setDato($infoNivel2);
    } #END foreach my $infoNivel2 (@arrayNivel2)

    $self->setId1($data_hash->{'id1'});
    $self->save();

    my $id2= $self->getId2;

    #Se guradan los datos en Nivel 2 repetibles
    foreach my $infoNivel2 (@arrayNivel2Repetibles){
        $infoNivel2->{'id2'}= $id2;
            
        my $nivel2Repetible;
        C4::AR::Debug::debug("CatNivel2 => campo, subcampo: ".$infoNivel2->{'campo'}.", ".$infoNivel2->{'subcampo'});

        if ( $infoNivel2->{'Id_rep'} != 0 ){
            C4::AR::Debug::debug("CatNivel2 => agregar => Se va a modificar CatNivel2, Id_rep: ". $infoNivel2->{'Id_rep'});
            $nivel2Repetible = C4::Modelo::CatNivel2Repetible->new(db => $self->db, rep_n2_id => $infoNivel2->{'Id_rep'});
            $nivel2Repetible->load();
        }else{
            C4::AR::Debug::debug("CatNivel2 => agregar => No existe el REPETIBLE se crea uno");
            $nivel2Repetible = C4::Modelo::CatNivel2Repetible->new(db => $self->db);
        }

        $nivel2Repetible->setId2($infoNivel2->{'id2'});
        $nivel2Repetible->setCampo($infoNivel2->{'campo'});
        $nivel2Repetible->setSubcampo($infoNivel2->{'subcampo'});

        if($infoNivel2->{'referencia'}){
            C4::AR::Debug::debug("CatNivel2 => REPETIBLE con REFERENCIA: ".$infoNivel2->{'datoReferencia'});
			$nivel2Repetible->dato($infoNivel2->{'datoReferencia'});
		}else{
            C4::AR::Debug::debug("CatNivel2 => REPETIBLE sin REFERENCIA: ".$infoNivel2->{'dato'});
			$nivel2Repetible->dato($infoNivel2->{'dato'});
		}

        $nivel2Repetible->save(); 
    }

    return $self;
}

sub eliminar{

    my ($self)=shift;
    my ($db) = @_;

    $db = $db || $self->db;

    use C4::Modelo::CatNivel2Repetible;
    use C4::Modelo::CatNivel2Repetible::Manager;
    use C4::Modelo::CatNivel3;
    use C4::Modelo::CatNivel3::Manager;


    my ($nivel3) = C4::Modelo::CatNivel3::Manager->get_cat_nivel3(  db => $db, 
                                                                    query => [ id2 => { eq => $self->getId2 } ] 
                                                            );
    foreach my $n3 (@$nivel3){
      $n3->eliminar();
    }


    my ($repetiblesNivel2) = C4::Modelo::CatNivel2Repetible::Manager->get_cat_nivel2_repetible(
                                                                                db => $db,    
                                                                                query => [
                                                                                            id2 => { eq => $self->getId2() } 
                                                                                    ] 
                                                                                );
    foreach my $n2Rep (@$repetiblesNivel2){
      $n2Rep->eliminar();
    }

    $self->delete();

}

sub setDato{
	my ($self) = shift;
	my ($data_hash)=@_;

	 if( ($data_hash->{'campo'} eq '910')&&($data_hash->{'subcampo'} eq 'a') ){
	#tipo de documento
# 		if( ($data_hash->{'modificado'})&&($data_hash->{'referencia'}) ){
        if ($data_hash->{'referencia'}){
				$self->setTipo_documento($data_hash->{'datoReferencia'});
			}else{
				$self->setTipo_documento($data_hash->{'dato'});
		}
	}

	elsif( ($data_hash->{'campo'} eq '245')&&($data_hash->{'subcampo'} eq 'h') ){
	#soporte
# 		if( ($data_hash->{'modificado'})&&($data_hash->{'referencia'}) ){
        if ($data_hash->{'referencia'}) {
				$self->setSoporte($data_hash->{'datoReferencia'});
			}else{
				$self->setSoporte($data_hash->{'dato'});
		}
	}

	elsif( ($data_hash->{'campo'} eq '900')&&($data_hash->{'subcampo'} eq 'b') ){
	#nivel bibliografico
# 		if( ($data_hash->{'modificado'})&&($data_hash->{'referencia'}) ){
        if ($data_hash->{'referencia'}) {
				$self->setNivel_bibliografico($data_hash->{'datoReferencia'});
			}else{
				$self->setNivel_bibliografico($data_hash->{'dato'});
		}
	}

	elsif( ($data_hash->{'campo'} eq '043')&&($data_hash->{'subcampo'} eq 'c') ){
	#pais publicacion
# 		if( ($data_hash->{'modificado'})&&($data_hash->{'referencia'}) ){
        if ($data_hash->{'referencia'}) {
				$self->setPais_publicacion($data_hash->{'datoReferencia'});
			}else{
				$self->setPais_publicacion($data_hash->{'dato'});
		}
	}

	elsif( ($data_hash->{'campo'} eq '041')&&($data_hash->{'subcampo'} eq 'h') ){
	#lenguaje
# 		if( ($data_hash->{'modificado'})&&($data_hash->{'referencia'}) ){
    if ($data_hash->{'referencia'}) {
				$self->setLenguaje($data_hash->{'datoReferencia'});
			}else{
				$self->setLenguaje($data_hash->{'dato'});
		}
	}

	elsif( ($data_hash->{'campo'} eq '260')&&($data_hash->{'subcampo'} eq 'a') ){
	#ciudad de publicacion
# 		if( ($data_hash->{'modificado'})&&($data_hash->{'referencia'}) ){
        if($data_hash->{'referencia'}){
				$self->setCiudad_publicacion($data_hash->{'datoReferencia'});
			}else{
				$self->setCiudad_publicacion($data_hash->{'dato'});
		}
	}

	elsif( ($data_hash->{'campo'} eq '260')&&($data_hash->{'subcampo'} eq 'c') ){
	#anio de publicacion
# 		if( ($data_hash->{'modificado'})&&($data_hash->{'referencia'}) ){
        if ($data_hash->{'referencia'}){
				$self->setAnio_publicacion($data_hash->{'datoReferencia'});
			}else{
				$self->setAnio_publicacion($data_hash->{'dato'});
		}
	}
}

sub getAnio_publicacion{
    my ($self) = shift;
    return ($self->anio_publicacion);
}

sub setAnio_publicacion{
    my ($self) = shift;
    my ($anio_publicacion) = @_;
    $self->anio_publicacion($anio_publicacion);
}

sub getCiudad_publicacion{
    my ($self) = shift;
    return ($self->ciudad_publicacion);
}

sub setCiudad_publicacion{
    my ($self) = shift;
    my ($ciudad_publicacion) = @_;
    $self->ciudad_publicacion($ciudad_publicacion);
}

sub getLenguaje{
    my ($self) = shift;
    return ($self->lenguaje);
}

sub setLenguaje{
    my ($self) = shift;
    my ($lenguaje) = @_;
    $self->lenguaje($lenguaje);
}

sub getPais_publicacion{
    my ($self) = shift;
    return ($self->pais_publicacion);
}

sub setPais_publicacion{
    my ($self) = shift;
    my ($pais_publicacion) = @_;
    $self->pais_publicacion($pais_publicacion);
}

sub getSoporte{
    my ($self) = shift;
    return ($self->soporte);
}

sub setSoporte{
    my ($self) = shift;
    my ($soporte) = @_;
    $self->soporte($soporte);
}

sub getNivel_bibliografico{
    my ($self) = shift;
    return ($self->nivel_bibliografico);
}

sub setNivel_bibliografico{
    my ($self) = shift;
    my ($nivel_bibliografico) = @_;
    $self->nivel_bibliografico($nivel_bibliografico);
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

sub getId1{
    my ($self) = shift;
    return ($self->id1);
}

sub setId1{
    my ($self) = shift;
    my ($id1) = @_;
    $self->id1($id1);
}

sub setTipo_documento{
    my ($self) = shift;
    my ($tipo_documento) = @_;
    $self->tipo_documento($tipo_documento);
}

sub getTipo_documento{
    my ($self) = shift;
    return ($self->tipo_documento);
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

# ===================================================SOPORTE=====ESTRUCTURA CATALOGACION=================================================

=item
Esta funcion devuelve los campos de nivel 3 mapeados en un arreglo de {campo, subcampo, dato}
=cut
sub toMARC{
    my ($self) = shift;
	my @marc_array;

	my $campo= '910';
	my $subcampo= 'a';
	my %hash;
	$hash{'campo'}= $campo;
	$hash{'subcampo'}= $subcampo;
	$hash{'header'}= C4::AR::Busquedas::getHeader($campo);
	$hash{'dato'}= C4::AR::Referencias::getNombreTipoDocumento($self->getTipo_documento);
	my $estructura= C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($campo, $subcampo);
    if ($estructura->[0]){
	    $hash{'liblibrarian'}= $estructura->[0]->getLiblibrarian;
		$hash{'datoReferencia'}= $self->getTipo_documento
	}

	push (@marc_array, \%hash);

	$campo= '043';
	$subcampo= 'c';
	my %hash;
	$hash{'campo'}= $campo;
	$hash{'subcampo'}= $subcampo;
	$hash{'header'}= C4::AR::Busquedas::getHeader($campo);
	$hash{'dato'}= C4::AR::Referencias::getNombrePais($self->getPais_publicacion);
	my $estructura= C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($campo, $subcampo);
	$hash{'liblibrarian'}= $estructura->[0]->getLiblibrarian;
	if($estructura->[0]){
		$hash{'datoReferencia'}= $self->getPais_publicacion;
	}

	push (@marc_array, \%hash);

	$campo= '260';
	$subcampo= 'c';
	my %hash;
	$hash{'campo'}= $campo;
	$hash{'subcampo'}= $subcampo;
	$hash{'header'}= C4::AR::Busquedas::getHeader($campo);
	$hash{'dato'}= $self->getAnio_publicacion;
	my $estructura= C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($campo, $subcampo);
    if($estructura->[0]){
	    $hash{'liblibrarian'}= $estructura->[0]->getLiblibrarian;
    }

	push (@marc_array, \%hash);

	$campo= '260';
	$subcampo= 'a';
	my %hash;
	$hash{'campo'}= $campo;
	$hash{'subcampo'}= $subcampo;
	$hash{'header'}= C4::AR::Busquedas::getHeader($campo);
 	$hash{'dato'}= C4::AR::Referencias::getNombreCiudad($self->getCiudad_publicacion);
	my $estructura= C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($campo, $subcampo);
	$hash{'liblibrarian'}= $estructura->[0]->getLiblibrarian;
	if($estructura->[0]){
	#tiene referencia
		$hash{'datoReferencia'}= $self->getCiudad_publicacion;
	}

	push (@marc_array, \%hash);

	$campo= '041';
	$subcampo= 'h';
	my %hash;
	$hash{'campo'}= $campo;
	$hash{'subcampo'}= $subcampo;
	$hash{'header'}= C4::AR::Busquedas::getHeader($campo);
	$hash{'dato'}= C4::AR::Referencias::getNombreLenguaje($self->getLenguaje);
	my $estructura= C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($campo, $subcampo);
	$hash{'liblibrarian'}= $estructura->[0]->getLiblibrarian;
	if($estructura->[0]->getReferencia){
	#tiene referencia
		$hash{'datoReferencia'}= $self->getLenguaje;
	}

	push (@marc_array, \%hash);

	$campo= '245';
	$subcampo= 'h';
	my %hash;
	$hash{'campo'}= $campo;
	$hash{'subcampo'}= $subcampo;
	$hash{'header'}= C4::AR::Busquedas::getHeader($campo);
	$hash{'dato'}= C4::AR::Referencias::getNombreSoporte($self->getSoporte);
	my $estructura= C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($campo, $subcampo);
	$hash{'liblibrarian'}= $estructura->[0]->getLiblibrarian;
	if($estructura->[0]->getReferencia){
	#tiene referencia
		$hash{'datoReferencia'}= $self->getSoporte;
	}

	push (@marc_array, \%hash);

	$campo= '900';
	$subcampo= 'b';
	my %hash;
	$hash{'campo'}= $campo;
	$hash{'subcampo'}= $subcampo;
	$hash{'header'}= C4::AR::Busquedas::getHeader($campo);
	$hash{'dato'}= C4::AR::Referencias::getNombreNivelBibliografico($self->getNivel_bibliografico);
	my $estructura= C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($campo, $subcampo);
	$hash{'liblibrarian'}= $estructura->[0]->getLiblibrarian;
	if($estructura->[0]->getReferencia){
	#tiene referencia
		$hash{'datoReferencia'}= $self->getNivel_bibliografico;
	}
	
	push (@marc_array, \%hash);
	
	return (\@marc_array);
}

=item
Esta funcion devuelve los campos de nivel 2 y nivel2Repetible mapeados en un arreglo de {campo, subcampo, dato}
=cut
sub nivel2CompletoToMARC{
    my ($self) = shift;

	my ($marc_array)= $self->toMARC;
	my ($nivel2Repetible_object_array) = C4::Modelo::CatNivel2Repetible::Manager->get_cat_nivel2_repetible( 
																						query => [ id2 => { eq => $self->getId2 } ]
																		);

	my $campo;
	my $subcampo;
	my $dato;
  my $id1 = $self->getId1;

	foreach my $marc_object (@$nivel2Repetible_object_array){
		$campo= $marc_object->getCampo;
		$subcampo= $marc_object->getSubcampo;
		$dato= $marc_object->getDato;
		my %hash;
		$hash{'header'}= C4::AR::Busquedas::getHeader($campo);
		$hash{'campo'}= $campo;
		$hash{'subcampo'}= $subcampo;
		$hash{'liblibrarian'}= C4::AR::Busquedas::getLiblibrarian($campo, $subcampo);
		$hash{'dato'}= $dato;
    $hash{'id1'}= $id1;

		C4::AR::Debug::debug("nivel2CompletoToMARC => ".$campo.", ".$subcampo."  ".$dato);	

 		push(@$marc_array, \%hash);
	}

	C4::AR::Debug::debug("nivel2CompletoToMARC => ******************************* cant: ".scalar(@$marc_array));
	return ($marc_array);
}

# ==============================================FIN===SOPORTE=====ESTRUCTURA CATALOGACION================================================


=item
Esta funcion retorna la edicion
=cut
sub getEdicion{
    my ($self) = shift;
	my $aux="";
	foreach my $repetible ($self->cat_nivel2_repetible){
		if(($repetible->getCampo eq "250")and($repetible->getSubcampo eq "a")){
			if ($aux eq "")
				{$aux= $repetible->getDato;}else{$aux.=" ".$repetible->getDato;}
		}
	}
	return $aux;
}

=item
Esta funcion retorna el volumen segun un id2
=cut

sub getVolumen{
    my ($self) = shift;
	my $aux="";
	foreach my $repetible ($self->cat_nivel2_repetible){
		if(($repetible->getCampo eq "740")and($repetible->getSubcampo eq "n")){
			if ($aux eq "")
				{$aux= $repetible->getDato;}else{$aux.=" ".$repetible->getDato;}
		}
	}
	return $aux;
}

=item
Esta funcion retorna la descripcion del volumen segun un id2
=cut
sub getVolumenDesc{
    my ($self) = shift;
	my $aux="";
	foreach my $repetible ($self->cat_nivel2_repetible){
		if(($repetible->getCampo eq "740")and($repetible->getSubcampo eq "a")){
			if ($aux eq "")
				{$aux= $repetible->getDato;}else{$aux.=" ".$repetible->getDato;}
		}
	}
	return $aux;
}

=item
retorna la canitdad de items prestados para el grupo pasado por parametro
=cut
sub getCantPrestados{
	my ($self) = shift;
	my ($id2)=@_;

=item
	my $cantPrestamos_count = C4::Modelo::CircPrestamo::Manager->get_circ_prestamo_count(
                                                               	query => [ 	id2 => { eq => $self->getId2 },
# FIXME #ojo no se si funciona el NULL
 																			fecha_devolucion => { eq => 'NULL' }  
																		 ],
																require_objects => ['nivel3.nivel2'],
																with_objects => ['nivel3'],
										);
=cut
	my ($cantPrestamos_count)= C4::AR::Nivel2::getCantPrestados($id2);

# 	C4::AR::Debug::debug("C4::AR::Nivel2::getCantPrestados ".$cantPrestamos_count);

	return $cantPrestamos_count;
}


sub getInvolvedCount{
 
    my ($self) = shift;

    my ($campo, $value)= @_;
    
    my @filtros;

    push (@filtros, ( $campo => $value ) );

    my $cat_nivel2_count = C4::Modelo::CatNivel2::Manager->get_cat_nivel2_count( query => \@filtros );

    return ($cat_nivel2_count);
}

sub replaceBy{
 
    my ($self) = shift;

    my ($campo,$value,$new_value)= @_;
    
    my @filtros;

    push (  @filtros, ( $campo => { eq => $value},) );


    my $replaced = C4::Modelo::CatNivel2::Manager->update_cat_nivel2(   where => \@filtros,
                                                                        set   => { $campo => $new_value });
}

=item sub getCantEjemplares
retorna la canitdad de ejemplares del grupo
=cut
sub getCantEjemplares{
    my ($self) = shift;

    my $cantEjemplares_count = C4::Modelo::CatNivel3::Manager->get_cat_nivel3_count(

                                                                query => [  'id1' => { eq => $self->getId1 },
                                                                            'id2' => { eq => $self->getId2 }
                                                                         ],

                                        );


    return $cantEjemplares_count;
}

=item sub tienePrestamos
    Verifica si el nivel 2 pasado por parametro tiene ejemplares con prestamos o no
=cut
sub tienePrestamos {
    my ($self) = shift;

    my $cant = C4::AR::Prestamos::getCountPrestamosDeGrupo($self->getId2);

    return ($cant > 0)?1:0;
}

=item sub tieneReservas
    Devuelve 1 si tiene ejemplares reservados en el grupo, 0 caso contrario
=cut
sub tieneReservas {
    my ($self) = shift;

    use C4::Modelo::CircReserva;
    use C4::Modelo::CircReserva::Manager;
    my @filtros;
    push(@filtros, ( id2    => { eq => $self->getId2}));

    my ($reservas_array_ref) = C4::Modelo::CircReserva::Manager->get_circ_reserva( query => \@filtros);

    if (scalar(@$reservas_array_ref) > 0){
        return 1;
    }else{
        return 0;
    }
}


sub agregarDesdeMARC {

   my ($self)=shift;
   my ($id1,$marc)=@_;
   
    $self->setId1($id1);

    my $leader= $marc->leader();
    my @leaderarray = split(//, $leader);
    #Tipo de Documento LEADER 06
    my $tipo_documento=$leaderarray[6];
    if($tipo_documento){$self->setTipo_documento("LIB");} # FIXME lo deje fijo por ahora

    #Nivel bibliográfico LEADER 07
    my $nivel_bibliografico=$leaderarray[7];
    if($nivel_bibliografico){$self->setNivel_bibliografico($nivel_bibliografico);} # FIXME lo deje fijo por ahora

    #Soporte 245 h
#     my $soporte = $marc->subfield("245","h");
#     if($soporte){$self->setSoporte($soporte);}

    #Pais 043 c
    my $pais_publicacion = $marc->subfield("043","c");
    if($pais_publicacion){$self->setPais_publicacion($pais_publicacion);}

    #Lenguaje 043 c
    my $lenguaje = $marc->subfield("041","h");
    if($lenguaje){$self->setLenguaje($lenguaje);}
    
    #Ciudad 260 a
    my $ciudad_publicacion = $marc->subfield("260","a");
    if($ciudad_publicacion){$self->setCiudad_publicacion($ciudad_publicacion);}

    #Año publicacion 260 c
    my $anio_publicacion = $marc->subfield("260","c");
    if($anio_publicacion){$self->setAnio_publicacion($anio_publicacion);}
 
    $self->save();
    
          C4::AR::Debug::debug("agregarDesdeMARC => Se guardo el nivel 2");

    use C4::Modelo::CatNivel2Repetible;
    my $arrayNivel2Repetibles;

    my $id2 = $self->getId2;
     my ($arrayNivel2Repetibles)= C4::AR::Catalogacion::getSubCampos(2); #Todos los campos MARC del nivel 2

    #Se guardan los datos en Nivel 1 repetibles
    foreach my $infoNivel2  (@$arrayNivel2Repetibles){

        my $campo = $infoNivel2->getTagfield;
        my $subcampo = $infoNivel2->getTagSubField;

        if (!( (($campo eq "245") && ($subcampo eq "h")) ||
               (($campo eq "043") && ($subcampo eq "c")) || 
               (($campo eq "041") && ($subcampo eq "h")) ||
               (($campo eq "260") && ($subcampo eq "a")) || 
               (($campo eq "260") && ($subcampo eq "c")) )) { # si no es ninguno de los fijos
        
            my $datoRepetible=$marc->subfield($campo,$subcampo);

            if($datoRepetible){
                my $nivel2Repetible = C4::Modelo::CatNivel2Repetible->new(db => $self->db);
                $nivel2Repetible->setId2($id2);
                $nivel2Repetible->setCampo($campo);
                $nivel2Repetible->setSubcampo($subcampo);
                $nivel2Repetible->dato($datoRepetible);
                $nivel2Repetible->save();
   C4::AR::Debug::debug("agregarDesdeMARC => Se guarda el nivel 2 repetible => ".$campo." - ".$subcampo);
            }
        }
        }

}

1;

