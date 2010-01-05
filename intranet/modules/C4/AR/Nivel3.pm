package C4::AR::Nivel3;


use strict;
require Exporter;
use C4::Context;
use C4::Date;
use C4::Modelo::CatRegistroMarcN3;
use C4::Modelo::CatRegistroMarcN3::Manager;

use vars qw(@EXPORT @ISA);

@ISA=qw(Exporter);

@EXPORT=qw(

	&detalleNivel3
	&getBarcode
	&modificarEstadoItem
);

=head2
    sub t_guardarNivel3
=cut
sub t_guardarNivel3 {
    my($params) = @_;

    my $msg_object = C4::AR::Mensajes::create();
    my $catRegistroMarcN3;
    my $db;

    if(!$msg_object->{'error'}){
    #No hay error

#  my ($barcodes_para_agregar) = _generarArreglo($params, $msg_object);
# TODO no esta funcionando el generar barcodes pq se tiene que hacer aca, antes de llamar a meran_nivel3_to_meran
#         my $marc_record             = C4::AR::Catalogacion::meran_nivel3_to_meran($params);
        my $catRegistroMarcN3_tmp   = C4::Modelo::CatRegistroMarcN3->new();  
        my $db = $catRegistroMarcN3_tmp->db;
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
        $db->begin_work;
    
        eval {
    
            #obtengo el tipo de ejemplar a partir del id2 del nivel 2
            $params->{'tipo_ejemplar'} = C4::AR::Nivel2::getTipoEjemplarFromId2($params->{'id2'});
            #se genera el arreglo de barcodes validos para agregar a la base y se setean los mensajes para el usuario (mensajes de ERROR)
            my ($barcodes_para_agregar) = _generarArreglo($params, $msg_object);
            
    
            foreach my $barcode (@$barcodes_para_agregar){
                #se procesa un barcode por vez junto con la info del nivel 3 y nivel3 repetible
                my $marc_record         = C4::AR::Catalogacion::meran_nivel3_to_meran($params);
#                 C4::AR::Debug::debug("barcodes===============================".$barcode);
        
                $catRegistroMarcN3      = C4::Modelo::CatRegistroMarcN3->new(db => $db);  

                
                my $field = $marc_record->field('995');  
                $field->add_subfields( 'f' => $barcode );

                $params->{'marc_record'} = $marc_record->as_usmarc;
#                 C4::AR::Debug::debug("marc_record!!!!!!!!!!!!!!!!!!!!!!!!!!!!!=> ".$marc_record->as_usmarc);
                $catRegistroMarcN3->agregar($db, $params);
                # FIXME transaccion por ejemplar???
                $db->commit;
                #recupero el id3 recien agregado
                my $id3 = $catRegistroMarcN3->getId3;
                C4::AR::Busquedas::generar_indice($catRegistroMarcN3->getId1);
                #se agregaron los barcodes con exito
                $msg_object->{'error'} = 0;
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U370', 'params' => [$id3]} );
        }
    
#                 $db->commit;
                C4::AR::Busquedas::reindexar();
        };

      if ($@){
          #Se loguea error de Base de Datos
          &C4::AR::Mensajes::printErrorDB($@, 'B429',"INTRA");
          $db->rollback;
          #Se setea error para el usuario
          $msg_object->{'error'}= 1;
          C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U373', 'params' => []} ) ;
      }

      $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object);
}


=head2 sub t_modificarNivel3
    Modifica los ejemplares del nivel 3 pasados por parametro
    @parametros:
        $params->{'ID3_ARRAY'}: arreglo de ID3
=cut
sub t_modificarNivel3 {
    my ($params) = @_;

## FIXME ver si falta verificar algo!!!!!!!!!!
    my $msg_object = C4::AR::Mensajes::create();

    my $cat_registro_marc_n3 = C4::Modelo::CatRegistroMarcN3->new();
    my $marc_record = C4::AR::Catalogacion::meran_nivel3_to_meran($params);
    my $db = $cat_registro_marc_n3->db;
    $params->{'modificado'} = 1;
    # enable transactions, if possible
    $db->{connect_options}->{AutoCommit} = 0;
    
    eval {

            my $id3_array = $params->{'ID3_ARRAY'}; 
            my $cant = scalar(@$id3_array);
            C4::AR::Debug::debug("t_modificarNivel3 => cant de items a modificar / agregar: ".$cant);

            for(my $i=0;$i<$cant;$i++){
                  my $catNivel3;
            C4::AR::Debug::debug("t_modificarNivel3 => ID3 a modificar: ".$params->{'ID3_ARRAY'}->[$i]);

            $params->{'id3'} = $params->{'ID3_ARRAY'}->[$i];
            #verifico las condiciones para actualizar los datos
            _verificarUpdateItem($msg_object, $params);

                if(!$msg_object->{'error'}){
                    ($cat_registro_marc_n3) = getNivel3FromId3($params->{'ID3_ARRAY'}->[$i], $db);
    #                 $db = $catNivel3->db;
                    $params->{'marc_record'} = $marc_record->as_usmarc;
                    $cat_registro_marc_n3->modificar($params, $db);  #si es mas de un ejemplar, a todos les setea la misma info
                    $db->commit;
                    C4::AR::Busquedas::generar_indice($cat_registro_marc_n3->getId1);
                    #se cambio el permiso con exito
                    $msg_object->{'error'} = 0;
                    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U382', 'params' => [$cat_registro_marc_n3->getBarcode]} ) ;
                }
            }#END for(my $i=0;$i<$cant;$i++)

#             $db->commit;
            
            C4::AR::Busquedas::reindexar();
    };

    if ($@){
        #Se loguea error de Base de Datos
        &C4::AR::Mensajes::printErrorDB($@, 'B432',"INTRA");
        $db->rollback;
        #Se setea error para el usuario
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U385', 'params' => []} ) ;
    }

    $db->{connect_options}->{AutoCommit} = 1;

    return ($msg_object);
}



=head2 sub getNivel3FromId2
Recupero todos los nivel 3 a partir de un id2
=cut
sub getNivel3FromId2{
    my ($id2, $db) = @_;

    $db = $db || C4::Modelo::CatRegistroMarcN3->new()->db();

    my $nivel3_array_ref = C4::Modelo::CatRegistroMarcN3::Manager->get_cat_registro_marc_n3(   
                                                                        db  => $db,
                                                                        query => [  
                                                                                    id2 => { eq => $id2 },
                                                                            ], 
                                        );

    return $nivel3_array_ref;
}



=head2 sub t_eliminarNivel3
    Elimina los ejemplares de nivel 3 pasados por parametro
    @parametros:
        $params->{'id3_array'}: arreglo de ID3
=cut
sub t_eliminarNivel3{
    my ($params) = @_;

    my $barcode;

    my $msg_object = C4::AR::Mensajes::create();
    
    my $cat_registro_marc_n3 = C4::Modelo::CatRegistroMarcN3->new();
    my $db = $cat_registro_marc_n3->db;
    my $id1 = 0;
    # enable transactions, if possible
    $db->{connect_options}->{AutoCommit} = 0;
    $db->begin_work;
    my $id3_array = $params->{'id3_array'};

    eval {
        for(my $i=0;$i<scalar(@$id3_array);$i++){
            $params->{'id3'} = $id3_array->[$i];
            _verificarDeleteItem($msg_object, $params);
            
            if(!$msg_object->{'error'}){

                $cat_registro_marc_n3 = getNivel3FromId3($id3_array->[$i], $db);
                if ($cat_registro_marc_n3){
                    $id1 = $cat_registro_marc_n3->getId1();
                    my $barcode = $cat_registro_marc_n3->getBarcode;   
                    $cat_registro_marc_n3->eliminar();
                    #se eliminó con exito
                    $msg_object->{'error'} = 0;
                    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U376', 'params' => [$barcode]} ) ;
                }else{
                    #se esta intentando recuperar un ejemplar con un id3 inexistente
                    C4::AR::Debug::debug("Nivel3 => t_eliminarNivel3 => se esta intentando recuperar un ejemplar con ID3 inexistente ".$id3_array->[$i]);
                }
            }
        }

        $db->commit;

        if ($id1) {
            C4::AR::Busquedas::generar_indice($id1);
            C4::AR::Busquedas::reindexar();
        }
    };

    if ($@){
        #Se loguea error de Base de Datos
        &C4::AR::Mensajes::printErrorDB($@, 'B435',"INTRA");
        $db->rollback;
        #Se setea error para el usuario
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U379', 'params' => [$barcode]} ) ;
    }

    $db->{connect_options}->{AutoCommit} = 1;

    return ($msg_object);
}


=head2 sub getNivel3FromId3
Recupero un nivel 3 a partir de un id3
retorna un objeto o 0 si no existe
=cut
sub getNivel3FromId3{
    my ($id3, $db) = @_;

    $db = $db || C4::Modelo::PermCatalogo->new()->db;
    my $nivel3_array_ref = C4::Modelo::CatRegistroMarcN3::Manager->get_cat_registro_marc_n3(   
                                                                    db => $db,
                                                                    query   => [ id => { eq => $id3} ], 
#                                                                     require_objects => ['ref_disponibilidad', 'ref_estado']
                                                                );

    if( scalar(@$nivel3_array_ref) > 0){
        return ($nivel3_array_ref->[0]);
    }else{
        return 0;
    }
}

sub getNivel3FromBarcode {
    my ($barcode) = @_;
    
#     use C4::Modelo::CatNivel3;
#     use C4::Modelo::CatNivel3::Manager;

# TODO Miguel ver si esto es eficiente, de todos modos no se si se puede hacer de otra manera!!!!!!!!!!
# 1) parece q no queda otra, hay q "abrir" el marc_record y sacar el barcode para todos los ejemplares e ir comparando cada uno GARRONNNN!!!!
# 2) se podria usar el indice??????????????

    my @filtros;
    my @barcode_result;

#   push(@filtros, ( barcode=> { eq => $barcode }) );
    
    my $barcodes_array_ref = C4::Modelo::CatRegistroMarcN3::Manager->get_cat_registro_marc_n3( query => \@filtros ); 

    my $cant = scalar(@$barcodes_array_ref);

    for(my $i=0; $i < $cant; $i++){

        if($barcodes_array_ref->[$i]->getBarcode() eq $barcode){
            push(@barcode_result, $barcodes_array_ref->[$i]);
        }
    }

    if(scalar(@barcode_result) > 0){
        return (\@barcode_result);
    }else{
        return (0);
    }
}


sub getBarcodesLike {
    
    use C4::Modelo::CatRegistroMarcN3;
    use C4::Modelo::CatRegistroMarcN3::Manager;

    my ($barcode) = @_;
    my  $barcodes_array_ref;
    my @filtros;
 
	push(@filtros, ( marc_record => { like => '%'.$barcode.'%' }) );
    
    $barcodes_array_ref = C4::Modelo::CatRegistroMarcN3::Manager->get_cat_registro_marc_n3( query => \@filtros ); 
	my $cant= scalar(@$barcodes_array_ref);

	if($cant > 0){
		return ($cant, $barcodes_array_ref);
	}else{
		return ($cant, 0);
	}
}

=head2
busca un barcode segun barcode, sobre el conjunto de barcodes prestados
=cut
sub getBarcodesPrestadoLike {
    
    use C4::Modelo::CircPrestamo;
    use C4::Modelo::CircPrestamo::Manager;

    my ($barcode) = @_;
    my  $barcodes_array_ref;
    my @filtros;
 
	push(@filtros, ( barcode=> { like => $barcode.'%' }) );
	push(@filtros, ( fecha_devolucion => { eq => undef }) );
    
    $barcodes_array_ref = C4::Modelo::CircPrestamo::Manager->get_circ_prestamo( 	query => \@filtros, 
																					require_objects => [ 'nivel3' ] #INNER JOIN
										); 
	my $cant= scalar(@$barcodes_array_ref);

	if($cant > 0){
		return ($cant, $barcodes_array_ref);
	}else{
		return ($cant, 0);
	}
}

=head2
    detalleNivel3
    Trae todos los datos del nivel 3, para poder verlos en el template.
    @params 
    $id2, id de nivel2
=cut
sub detalleNivel3{
	my ($id2) = @_;

	my %hash_nivel2;	
	#recupero el nivel1 segun el id1 pasado por parametro
    my $nivel2_object = C4::AR::Nivel2::getNivel2FromId2($id2);

    if($nivel2_object){

	    $hash_nivel2{'id2'}                     = $id2;
	    $hash_nivel2{'tipo_documento'}          = $nivel2_object->getTipoDocumentoObject->getNombre();
	    $hash_nivel2{'nivel2_array'}            = $nivel2_object->toMARC_Intra; #arreglo de los campos fijos de Nivel 2 mapeado a MARC
    
	    my ($totales_nivel3, @result)           = detalleDisponibilidadNivel3($id2);
    
	    $hash_nivel2{'nivel3'}                  = \@result;
	    $hash_nivel2{'cantPrestados'}           = $totales_nivel3->{'cantPrestados'};
	    $hash_nivel2{'cantReservas'}            = $totales_nivel3->{'cantReservas'};
	    $hash_nivel2{'cantReservasEnEspera'}    = $totales_nivel3->{'cantReservasEnEspera'};
	    $hash_nivel2{'disponibles'}             = $totales_nivel3->{'disponibles'};
	    $hash_nivel2{'cantParaSala'}            = $totales_nivel3->{'cantParaSala'};
	    $hash_nivel2{'cantParaPrestamo'}        = $totales_nivel3->{'cantParaPrestamo'};
    }

	return (\%hash_nivel2);
}

=head2 sub detalleCompletoINTRA
    Genera el detalle 
=cut
sub detalleCompletoINTRA{
	my ($id1, $t_params) = @_;
	
	#recupero el nivel1 segun el id1 pasado por parametro
	my $nivel1              = &C4::AR::Nivel1::getNivel1FromId1($id1);
	#recupero todos los nivel2 segun el id1 pasado por parametro
	my $nivel2_array_ref    = &C4::AR::Nivel2::getNivel2FromId1($nivel1->getId1);

	my @nivel2;
	
	for(my $i=0;$i<scalar(@$nivel2_array_ref);$i++){

		my ($hash_nivel2) = detalleNivel3($nivel2_array_ref->[$i]->getId2);
	
		push(@nivel2, $hash_nivel2);
	}

	$t_params->{'nivel1'}   = $nivel1->toMARC_Intra,
	$t_params->{'id1'}	    = $id1;
	$t_params->{'nivel2'}   = \@nivel2,
	#se ferifica si la preferencia "circularDesdeDetalleDelRegistro" esta seteada
	$t_params->{'circularDesdeDetalleDelRegistro'}= C4::AR::Preferencias->getValorPreferencia('circularDesdeDetalleDelRegistro');
}

=head2 sub detalleDisponibilidadNivel3
    detalleDisponibilidadNivel3
    Busca los datos del nivel 3 a partir de un id2 correspondiente a nivel 2.
=cut
sub detalleDisponibilidadNivel3{
    my ($id2,$params) = @_;
    
    #recupero todos los nivel3 segun el id2 pasado por parametro
    my $nivel3_array_ref                = &C4::AR::Nivel3::getNivel3FromId2($id2);
    my @result;
    my %hash_nivel2;
    my $i = 0;
    my $cantDisponibles                 = 0;
    my %infoNivel3;
    $infoNivel3{'cantParaSala'}         = 0;
    $infoNivel3{'cantParaPrestamo'}     = 0;
    $infoNivel3{'disponibles'}          = 0;
    $infoNivel3{'cantPrestados'}        = C4::AR::Nivel2::getCantPrestados($id2);
    $infoNivel3{'cantReservas'}         = C4::AR::Reservas::cantReservasPorGrupo($id2);
    $infoNivel3{'cantReservasEnEspera'} = C4::AR::Reservas::cantReservasPorGrupoEnEspera($id2);

    for(my $i=0;$i<scalar(@$nivel3_array_ref);$i++){
        my %hash_nivel3;

# FIXME si no se setea undef, muestra al usuario de un grupo tantas veces como ejemplares tenga, si este tiene un prestamo sobre 
# un ejemplar del grupo.
# con el debug no veo el nro_socio luego de my $socio, o sea lo que se esta mamando es el template, va haber q inicializar los flags
# que van hacia el template.
        
        $hash_nivel3{'nro_socio'}           = undef;
        $hash_nivel3{'nivel3_obj'}          = $nivel3_array_ref->[$i]; 
        $hash_nivel3{'id3'}                 = $nivel3_array_ref->[$i]->getId3;
        $hash_nivel3{'paraPrestamo'}        = $nivel3_array_ref->[$i]->estaPrestado;

        my $UI_poseedora_object             = C4::AR::Referencias::getUI_infoObject($hash_nivel3{'id_ui_poseedora'});

        if($UI_poseedora_object){
            $hash_nivel3{'UI_poseedora'}    = $UI_poseedora_object->getNombre();
        }

        my $UI_origen_object                = C4::AR::Referencias::getUI_infoObject($hash_nivel3{'id_ui_origen'});

        if($UI_origen_object){
            $hash_nivel3{'UI_origen'}       = $UI_origen_object->getNombre();
        }
    
        #ESTADO
        $hash_nivel3{'estado'} = $nivel3_array_ref->[$i]->getEstado;
        if($nivel3_array_ref->[$i]->estadoDisponible){
            #ESTADO DISPONIBLE
            $hash_nivel3{'claseEstado'} = "disponible";
            $cantDisponibles++;
            $hash_nivel3{'disponible'} = 1; # lo marco como disponible
    
                if(!$nivel3_array_ref->[$i]->esParaSala){
                    #esta DISPONIBLE y es PARA PRESTAMO
                    $infoNivel3{'cantParaPrestamo'}++;
                }elsif($nivel3_array_ref->[$i]->esParaSala){
                    #es PARA SALA
                    $infoNivel3{'cantParaSala'}++;
                }

        } else {
            #ESTADO NO DISPONIBLE
            $hash_nivel3{'claseEstado'}         = "nodisponible";
            $hash_nivel3{'disponible'} = 0; # lo marco como no disponible
        }
    
        #DISPONIBILIDAD
        if(!$nivel3_array_ref->[$i]->esParaSala){
            #PARA PRESTAMO
            $hash_nivel3{'disponibilidad'}      = "Prestamo";
            $hash_nivel3{'claseDisponibilidad'} = "prestamo";
        }elsif($nivel3_array_ref->[$i]->esParaSala){
            #es PARA SALA
            $hash_nivel3{'disponibilidad'}      = "Sala de Lectura";
            $hash_nivel3{'claseDisponibilidad'} = "salaLectura";
        }
        
#         C4::AR::Debug::debug("nro_socio: ".$hash_nivel3{'nro_socio'});
        my $socio = C4::AR::Prestamos::getSocioFromPrestamo($hash_nivel3{'id3'});

        #se inicializa la hash
        $hash_nivel3{'vencimiento'}         = undef;
        $hash_nivel3{'socio'}               = undef;
        $hash_nivel3{'prestamo'}            = undef;

        if ($socio) { 

            my $prestamo                    = C4::AR::Prestamos::getPrestamoActivo($hash_nivel3{'id3'});
            $hash_nivel3{'prestamo'}        = $prestamo;
            $hash_nivel3{'socio'}           = $socio;

            if ($prestamo->estaVencido) {
                $hash_nivel3{'claseFecha'}  = "fecha_vencida";
            }else {
                $hash_nivel3{'claseFecha'}  = "fecha_cumple";
            }
        }
    
        $result[$i]= \%hash_nivel3;
    }
    $infoNivel3{'disponibles'} = $infoNivel3{'cantParaPrestamo'} + $infoNivel3{'cantParaSala'};

    return(\%infoNivel3,@result);
}

=head2
Genera el detalle 
=cut
sub detalleCompletoOPAC{
	my ($id1, $t_params) = @_;
	
	#recupero el nivel1 segun el id1 pasado por parametro
	my $nivel1= &C4::AR::Nivel1::getNivel1FromId1OPAC($id1);
    my $config_visualizacion= &C4::AR::Preferencias::getConfigVisualizacionOPAC();
	#recupero todos los nivel2 segun el id1 pasado por parametro
	my $nivel2_array_ref= &C4::AR::Nivel2::getNivel2FromId1($nivel1->getId1);

	my @nivel2;
	for(my $i=0;$i<scalar(@$nivel2_array_ref);$i++){
 		my $hash_nivel2;
		$nivel2_array_ref->[$i]->load();
		$hash_nivel2->{'id2'}= $nivel2_array_ref->[$i]->getId2;
		$hash_nivel2->{'tipo_documento'}= C4::AR::Referencias::getNombreTipoDocumento($nivel2_array_ref->[$i]->getTipoDocumentoObject);
		$hash_nivel2->{'nivel2_array'}= ($nivel2_array_ref->[$i])->toMARC_Opac; #arreglo de los campos fijos de Nivel 2 mapeado a MARC
		my ($totales_nivel3,@result)= detalleDisponibilidadNivel3($nivel2_array_ref->[$i]->getId2,$config_visualizacion);
		$hash_nivel2->{'nivel3'}= \@result;
		$hash_nivel2->{'cantPrestados'}= $totales_nivel3->{'cantPrestados'};
		$hash_nivel2->{'cantReservas'}= $totales_nivel3->{'cantReservas'};
        $hash_nivel2->{'portada_registro'}=  C4::AR::PortadasRegistros::getImageForId1($nivel2_array_ref->[$i]->getId1,'S');
        $hash_nivel2->{'portada_registro_medium'}=  C4::AR::PortadasRegistros::getImageForId1($nivel2_array_ref->[$i]->getId1,'M');
        $hash_nivel2->{'portada_registro_big'}=  C4::AR::PortadasRegistros::getImageForId1($nivel2_array_ref->[$i]->getId1,'L');
		$hash_nivel2->{'cantReservasEnEspera'}= $totales_nivel3->{'cantReservasEnEspera'};
		$hash_nivel2->{'disponibles'}= $totales_nivel3->{'disponibles'};
		$hash_nivel2->{'cantParaSala'}= $totales_nivel3->{'cantParaSala'};
		$hash_nivel2->{'cantParaPrestamo'}= $totales_nivel3->{'cantParaPrestamo'};
		$hash_nivel2->{'DivMARC'}="MARCDetail".$i;
		$hash_nivel2->{'DivDetalle'}="Detalle".$i;
		push(@nivel2, $hash_nivel2);
	}

	$t_params->{'nivel1'}   = $nivel1->toMARC_Opac,
	$t_params->{'id1'}	    = $id1;
	$t_params->{'nivel2'}   = \@nivel2,
}


=head2
generaCodigoBarra
Funcion interna al pm
Genera el codigo de barras del item automanticamente por medio de una consulta a la base de datos, esta funcion es llamada desde una transaccion.
Los parametros son el manejador de la base de datos y los parametros que necesita para generar el codigo de barra.
=cut
# FIXME no esta funcionando bien
sub generaCodigoBarra{
    my($parametros, $cant) = @_;

    my $dbh   = C4::Context->dbh;

	my $barcode;
	my @estructurabarcode = split(',',C4::AR::Preferencias->getValorPreferencia("barcodeFormat"));
    my $like = '';

	for (my $i=0; $i<@estructurabarcode; $i++) {
		if (($i % 2) == 0) {
			$like.= %$parametros->{$estructurabarcode[$i]};
		} else {
			$like.= $estructurabarcode[$i];
		}
	}

     my $sth2 = $dbh->prepare("     SELECT MAX(substring(marc_record,INSTR(marc_record, ?)+9, 
                                    INSTR(   substring(marc_record,INSTR(marc_record, ?)+9), CHAR(30))-1 )) as maximo 
                                    FROM cat_registro_marc_n3 
                                    WHERE INSTR(marc_record, ?) <> 0 ");



    $sth2->execute('f'.$like, 'f'.$like, 'f'.$like);
	my $data2= $sth2->fetchrow_hashref;
    my $numero = ($data2->{'maximo'});


    my @barcodes_array_ref;
    for(my $i=0;$i<$cant;$i++){
        $barcode  = $parametros->{'UI'}."-".$parametros->{'tipo_ejemplar'}."-".completarConCeros($numero + $i + 1);
        C4::AR::Debug::debug("Nivel3 => generaCodigoBarra => barcode => ".$barcode);
        push(@barcodes_array_ref, $barcode);
    }

    return (@barcodes_array_ref);
}

sub completarConCeros {
    my ($numero) = @_;

    my $ceros = '';
    for(my $j=0;(($j + length($numero)) < C4::Context->preference("longitud_barcode")) ;$j++){
        $ceros.= "0";
    }

    return $ceros.$numero;
}

=head2 sub getNivel3FromId1
    Recupero un nivel 3 a partir de un id1
    retorna un objeto o 0 si no existe
=cut
sub getNivel3FromId1{
    my ($id1, $db) = @_;

    $db = $db || C4::Modelo::PermCatalogo->new()->db;
    my $nivel3_array_ref = C4::Modelo::CatRegistroMarcN3::Manager->get_cat_registro_marc_n3(   
                                                                    db => $db,
                                                                    query   => [ id1 => { eq => $id1} ], 
                                                                );


    return $nivel3_array_ref;
}

=head2 sub getDisponibilidadFromId1
    Retorna la disponibilidad del registro
=cut
# sub getDisponibilidadFromId1{
#     my ($id1) = @_;
#     
#     my ($nivel3_array_ref) = getNivel3FromId1($id1);
#     my @items;
#     my $j=0;
#     foreach my $n3 (@$nivel3_array_ref){
#         my $item;
# 
#         my $marc_record = MARC::Record->new_from_usmarc($n3->getMarcRecord());
#         $n3->getIdDisponibilidad;
# 
# #         if((!$n3->estaPrestado)&&($n3->estadoDisponible)&&($nivel3aPrestar->getIdDisponibilidad eq $n3->getIdDisponibilidad)){
# #         #Si no esta prestado, esta en estado disponmible y tiene la misma disponibilidad que el novel 3 que intento prestar se agrega al combo
# #                 $item->{'label'} = $n3->getBarcode;
# #                 $item->{'value'} = $n3->getId3;
# #                 push (@items,$item);
# #             }
#     }
# 
#     return(\@items);
# }

=head2 sub buscarNiveles3PorDisponibilidad
Busca los datos del nivel 3 a partir de un id3, respetando su disponibilidad
=cut
sub buscarNivel3PorDisponibilidad{
	my ($nivel3aPrestar) = @_;
	
	my ($nivel3_array_ref) = getNivel3FromId2($nivel3aPrestar->getId2);
	my @items;
	my $j=0;
	foreach my $n3 (@$nivel3_array_ref){
		my $item;

		if((!$n3->estaPrestado)&&($n3->estadoDisponible)&&($nivel3aPrestar->getIdDisponibilidad eq $n3->getIdDisponibilidad)){
		#Si no esta prestado, esta en estado disponmible y tiene la misma disponibilidad que el novel 3 que intento prestar se agrega al combo
				$item->{'label'} = $n3->getBarcode;
				$item->{'value'} = $n3->getId3;
				push (@items,$item);
			}
	}

	return(\@items);
}

sub _verificarDeleteItem {
	my($msg_object, $params)=@_;

    $msg_object->{'error'} = 0;#no hay error

    if( !($msg_object->{'error'}) && C4::AR::Reservas::estaReservado($params->{'id3'}) ){
        #verifico que el ejemplar que quiero eliminar no esté prestado
        $msg_object->{'error'} = 1;
        C4::AR::Debug::debug("_verificarDeleteItem => Se está intentando eliminar un ejemplar que tiene una reserva");
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P122', 'params' => [$params->{'id3'}]} ) ;

    }elsif( !($msg_object->{'error'}) && C4::AR::Prestamos::estaPrestado($params->{'id3'}) ){
        #verifico que el ejemplar no se encuentre reservado
        $msg_object->{'error'} = 1;
        C4::AR::Debug::debug("_verificarDeleteItem => Se está intentando eliminar un ejemplar que tiene un prestamo");
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P121', 'params' => [$params->{'id3'}]} ) ;
    }

}

sub _verificarUpdateItem {
# FIXME no se verificar si se repiten los barcodes
    my($msg_object, $params)=@_;

    $msg_object->{'error'} = 0;#no hay error

    if( !($msg_object->{'error'}) && C4::AR::Prestamos::estaPrestado($params->{'id3'}) ){
        #verifico que el ejemplar no se encuentre reservado
        $msg_object->{'error'} = 1;
        C4::AR::Debug::debug("_verificarDeleteItem => Se está intentando modificar un ejemplar que tiene un prestamo");
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P125', 'params' => [$params->{'id3'}]} ) ;
    }

}




=head2 sub existeBarcode
Verifica si existe el barcode en la base
=cut
sub existeBarcode{
	my($barcode)=@_;

	my $nivel_array_ref= C4::AR::Nivel3::getNivel3FromBarcode($barcode);
	
	return ( $nivel_array_ref != 0);
}
#=======================================================================ABM Nivel 3======================================================


=head2
Lo que hace la funcion es verificar cada barcode y devolver un arreglo de barcodes permitidos para agregar junto con sus
respectivos mensajes, ya sea que se AGREGO con EXITO o NO se pudo AGREGAR (por algun motivo)

Tiene PRIORIDAD la carga multiple de varios barcodes sobre la carga multiple de varios ejemplares

Si el barcode ES obligatorio:

	- No puede ser blanco
	- No puede Existir

Si el barcode NO es obligatorio:
	
	- Se permite barcode en blanco
	- Si se ingresa un barcode, NO PUEDE EXISTIR

=cut

sub _generateBarcode{
  return (time());
}

=head2 sub _generarArreglo

    Esta funcion hace de "distribuidor", chequea q tipo de alta de ejemplares se va hacer, 
    por cant de ejemplares (llama a _generarArregloDeBarcodesPorCantidad) o 
    un conjunto de barcodes agregados por el usuario (llama a _generarArregloDeBarcodesPorBarcodes()).
    Devuelve un arreglo de barcodes validos (autogenerados o ingresados por el usuario)
=cut
sub _generarArreglo{	
	my ($params, $msg_object) = @_;
 
	my $cant = $params->{'cantEjemplares'}; #recupero la cantidad de ejemplares a agregar, 1 o mas
	my $barcodes_array = $params->{'BARCODES_ARRAY'}; #se esta agregando por barcodes 
	my @barcodes_para_agregar;
	$params->{'agregarPorBarcodes'} = 0;
    my $esPorBarcode = 0;
    $esPorBarcode = defined $barcodes_array;

    #se setea la cantidad de ejemplares a agregar
	if($esPorBarcode){
		$params->{'agregarPorBarcodes'} = 1;
        _generarArregloDeBarcodesPorBarcodes($msg_object, $barcodes_array, \@barcodes_para_agregar);
	}else{
		@barcodes_para_agregar = _generarArregloDeBarcodesPorCantidad($cant, $params, $msg_object);
	}

	return (\@barcodes_para_agregar);
}

=head2 sub _generarArregloDeBarcodesPorBarcodes
Esta funcion genera un arreglo de barcodes VALIDOS para agregar en la base de datos, ademas setea los mensajes de ERROR para los usuarios
=cut
sub _generarArregloDeBarcodesPorBarcodes{   
    my ($msg_object, $barcodes_array, $barcodes_para_agregar) = @_;
    C4::AR::Debug::debug("Nivel3 => _generarArregloDeBarcodesPorBarcodes !!!!!!!!!!");
 
    foreach my $barcode (@$barcodes_array){
        $msg_object->{'error'} = 0;

        if(_existeBarcodeEnArray($barcode, $barcodes_para_agregar)){
        #si el barcode existe se informa al usuario y no se agrega en el arreglo de barcodes para agregar
# C4::AR::Debug::debug("_generarArregloDeBarcodesPorBarcodes => EXISTE EL BARCODE EN EL ARREGLO");
            $msg_object->{'error'} = 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U386', 'params' => [$barcode]} ) ;
        }
# C4::AR::Debug::debug("_generarArregloDeBarcodesPorBarcodes => NO EXISTE EL BARCODE EN EL ARREGLO");
        if( !C4::AR::Utilidades::validateBarcode($barcode) ) {
            #el barcode ingresado no es valido
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U402', 'params' => [$barcode]} ) ;
        }

        if( existeBarcode($barcode) ){
            #el barcode existe en la base de datos
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U386', 'params' => [$barcode]} ) ;
        }

        if(!$msg_object->{'error'}){
        #el barcode es VALIDO, se agrega al arreglo de barcodes para agregar
# C4::AR::Debug::debug("_generarArregloDeBarcodesPorBarcodes => AGREGO A ARREGLO ".$barcode);
            push (@$barcodes_para_agregar, $barcode);
        }
    }# END foreach my $barcode (@$barcodes_array)

}

=head2 sub _generarArregloDeBarcodesPorCantidad
Esta funcion genera un arreglo de barcodes VALIDOS para agregar en la base de datos
=cut
sub _generarArregloDeBarcodesPorCantidad {   
    my($cant, $params, $msg_object) = @_;

    C4::AR::Debug::debug("Nivel3 => _generarArregloDeBarcodesPorCantidad !!!!!!!!!!");
    my $barcode;
    my $numero;
    my $tope = 1000; #puede ser preferencia

    $msg_object->{'error'} = 0;#no hay error

    if( !($msg_object->{'error'}) && $cant > $tope ){
        #se esta intentando agregar mas de $tope ejemplares
        $msg_object->{'error'} = 1;
        C4::AR::Debug::debug("_verificarGuardarNivel3 => Se está intentando agregar mas de ".$tope." ejemplares");
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U405', 'params' => [$tope]} ) ;

    }
 

    my @barcodes_para_agregar;
    if( !$msg_object->{'error'} ){

        my %parametros;
        $parametros{'UI'}               = C4::AR::Preferencias->getValorPreferencia("defaultUI");
        $parametros{'tipo_ejemplar'}    = $params->{'tipo_ejemplar'};

        (@barcodes_para_agregar) = generaCodigoBarra(\%parametros, $cant);
        

    }
    
    return (@barcodes_para_agregar); 
}


sub _existeBarcodeEnArray {
    my ($barcode, $barcodes_array)= @_;

    return C4::AR::Utilidades::existeInArray($barcode, $barcodes_array);
}



#=================================================================DEPRECATED====================================================

=head2 sub getNivel3RepetibleFromId3Repetible
Recupero el objeto nivel3_repetible a partir de un rep_n3_id
retorna un objeto o 0 si no existe ninguno
=cut
# sub getNivel3RepetibleFromId3Repetible{
#   my ($rep_n3_id, $db) = @_;
# 
#   $db = $db || C4::Modelo::PermCatalogo->new()->db;  
#   my $nivel3_repetible_array_ref = C4::Modelo::CatNivel3Repetible::Manager->get_cat_nivel3_repetible(
#                                                                         db => $db,         
#                                                                         query => [ rep_n3_id => { eq => $rep_n3_id } ] 
#                                                         );
# 
#   if( scalar(@$nivel3_repetible_array_ref) > 0){
#     return ($nivel3_repetible_array_ref->[0]);
#   }else{
#     return 0;
#   }
# }

=head2
DEPRECATED, PERO DEJAR PARA REEIMPLEMENTAR
=cut
# sub modificarEstadoItem{
#     my($params)=@_;
#     open(A, ">>/tmp/debbug.txt");
#     print  A "entro ";
#     close (A);
#     #avail y loan preguntar por estos campos
#     my $disponible= _estaDisponible($params->{'id3'});
#     my $itemActual = C4::AR::Nivel3::getDataNivel3($params->{'id3'});
#     #Si {'wthdrawn'} eq 0 significa DISPONIBLE
#     #Si {'wthdrawn'} mayor q 0 significa NO DISPONIBLE
#     #Si {'notforloan'} eq DO significa PARA PRESTAMO
#     #Si {'notforloan'} eq SA significa PARA SALA
#     #Si el items esta disponible => $disponible=1
#     
#     # ESTE CASO ES MODIFICAR UN ITEMS NO DISPONIBLE A DISPONIBLE PARA PRESTAMO DOMICILIARIO
#     if( ($disponible == 0) && ($params->{'wthdrawn'} eq 0) && ($params->{'notforloan'} eq 'DO') ){
#         _modItemNoDisponibleAPrestamo($params);
#     }
# #   else{
#         
# #   }
#     
# }

=head2 sub getNivel3RepetibleFromId3Repetible
Recupero un nivel 3 a partir de un $id3_rep (id3 repetible)
retorna un objeto o 0 si no existe
=cut
# sub getNivel3RepetibleFromId3Repetible{
#   my ($id3_rep, $db) = @_;
# 
#   $db = $db || C4::Modelo::PermCatalogo->new()->db;
#   my $nivel3_repetible_array_ref = C4::Modelo::CatNivel3Repetible::Manager->get_cat_nivel3_repetible(   
#                                                                                     db => $db,
#                                                                                     query   => [  
#                                                                                                 rep_n3_id => { eq => $id3_rep},
#                                                                                                 ], 
#                 #                                                                     require_objects => ['CEC']
#                                 );
# 
#   if( scalar(@$nivel3_repetible_array_ref) > 0){
#     return ($nivel3_repetible_array_ref->[0]);
#   }else{
#     return 0;
#   }
# }


=head2 sub t_eliminarNivel3Repetible
    Elimina el nivel 3 repetido pasado por parametro
=cut
# sub t_eliminarNivel3Repetible{
#     my ($params) = @_;
#    
#     my $msg_object = C4::AR::Mensajes::create();
#     my $campo;
#     my $subcampo;
#     my $parametro;
#     my $catNivel3Repetible;
#    
#     my $db = C4::Modelo::PermCatalogo->new()->db;
#     my $array_nivel_repetible = $params->{'id_rep_array'};
#     # enable transactions, if possible
#     $db->{connect_options}->{AutoCommit} = 0;
#     $db->begin_work;
# 
#     eval {
#         for(my $i=0;$i<scalar(@$array_nivel_repetible);$i++){  
# 
#             ($catNivel3Repetible) = getNivel3RepetibleFromId3Repetible($array_nivel_repetible->[$i], $db);
# 
#             if(!$catNivel3Repetible){
#                 #NO EXISTE EL OBJETO
#                 #Se setea error para el usuario
#                 $msg_object->{'error'} = 1;
#                 C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U409', 'params' => []} ) ;
#             }else{
#                 #EXISTE EL OBJETO
#                 #verifico condiciones necesarias antes de eliminar     
#                 $campo = $catNivel3Repetible->getCampo();
#                 $subcampo = $catNivel3Repetible->getSubcampo();
#                 $parametro = $array_nivel_repetible->[$i]." - ".$campo.", ".$subcampo;
#                 $catNivel3Repetible->eliminar;  
#                 $db->commit;
#                 #se cambio el permiso con exito
#                 $msg_object->{'error'} = 0;
#                 C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U407', 'params' => [$parametro]} ) ;
#             }
#         }# for
#     };
# 
#     if ($@){
#         #Se loguea error de Base de Datos
#         &C4::AR::Mensajes::printErrorDB($@, 'B447',"INTRA");
#         $db->rollback;
#         #Se setea error para el usuario
#         $msg_object->{'error'}= 1;
#         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U408', 'params' => [$parametro]} ) ;
#     }
# 
#     $db->{connect_options}->{AutoCommit} = 1;
# 
# 
#     return ($msg_object);
# }


=head2
Esta funcion modifica el estado de un ejemplar PASA DE DISPONIBLE PARA SALA A DISPONIBLE PARA PRESTAMO, debemos ver si existen reservas para ese grupo, y reasignar la reserva para ese ejemplar
=cut
# FIXME DEPRECATED
# sub modItemSalaAPrestamo{
#     my($params)=@_;
# 
#     C4::AR::Reservas::reasignarReservaEnEspera($params);
#     #FALTARIA CAMBIAR EL ESTADO
# }

=head2
Esta funcion modifica el estado de un ejemplar PASA DE NO DISPONIBLE A DISPONIBLE PARA PRESTAMO, debemos ver si existen reservas para ese grupo, y reasignar la reserva para ese ejemplar
=cut
# FIXME DEPRECATED
# sub _modItemNoDisponibleAPrestamo{
#     my($params)=@_;
# 
#     C4::AR::Reservas::reasignarReservaEnEspera($params);
#     #FALTARIA CAMBIAR EL ESTADOs
# }

# FIXME DEPRECATED
# sub _estaDisponible {
#     my($id3)=@_;
# 
#     my $dbh = C4::Context->dbh;
#     my $query=" SELECT FROM cat_nivel3 WHERE id3 = ? ";
# 
#     my $sth=$dbh->prepare($query);
#         $sth->execute($id3);
# 
#     my $data=$sth->fetchrow;
#     
#     if($data == 0) {return 1;} #DISPONIBLE
#     else {return 0;} #NO DISPONIBLE
# }


=head2
detalleDisponibilidad
Devuelve la disponibilidad del item que viene por paramentro.
=cut
# sub detalleDisponibilidad{
#         my ($id3) = @_;
#         my $dbh = C4::Context->dbh;
#         my $query = "SELECT * FROM cat_detalle_disponibilidad WHERE id3 = ? ORDER BY date DESC";
#         my $sth = $dbh->prepare($query);
#         $sth->execute($id3);
#   my @results;
#   my $i=0;
# 
#   while (my $data=$sth->fetchrow_hashref){
#       $results[$i]=$data; $i++; 
#   }
#   $sth->finish;
# 
#   return(scalar(@results),\@results);
# }
