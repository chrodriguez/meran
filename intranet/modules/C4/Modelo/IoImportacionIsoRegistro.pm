package C4::Modelo::IoImportacionIsoRegistro;

use strict;

use C4::Modelo::IoImportacionIsoRegistro;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'io_importacion_iso_registro',

    columns => [
        id                             => { type => 'serial', overflow => 'truncate', not_null => 1 },
        id_importacion_iso             => { type => 'integer', overflow => 'truncate', not_null => 1},
        type                           => { type => 'varchar', overflow => 'truncate', length => 25},
        estado                         => { type => 'varchar', overflow => 'truncate', length => 25},
        matching                       => { type => 'integer', overflow => 'truncate'},
        id_matching                    => { type => 'integer', overflow => 'truncate'},
        identificacion                 => { type => 'varchar', overflow => 'truncate', length => 255},
        relacion                       => { type => 'varchar', overflow => 'truncate', length => 255},
        id1                            => { type => 'integer', overflow => 'truncate'},
        id2                            => { type => 'integer', overflow => 'truncate'},
        id3                            => { type => 'integer', overflow => 'truncate'},
        marc_record                    => { type => 'text', overflow => 'truncate', not_null => 1},
    ],


    relationships =>
    [
      ref_importacion =>
      {
         class       => 'C4::Modelo::IoImportacionIso',
         key_columns => {id_importacion_iso => 'id' },
         type        => 'one to one',
       },
    ],

    primary_key_columns => [ 'id' ],
    unique_key          => ['id'],

);

#----------------------------------- FUNCIONES DEL MODELO ------------------------------------------------


sub agregar{
    my ($self)   = shift;
    my ($params) = @_;

    $self->setIdImportacionIso($params->{'id_importacion_iso'});
    $self->setMarcRecord($params->{'marc_record'});
    if ($params->{'estado'}){
          $self->setEstado($params->{'estado'});
      }
    
    $self->save();
}


sub eliminar{
    my ($self)      = shift;
    my ($params)    = @_;

    #HACER ALGO SI ES NECESARIO

    $self->delete();
}


sub getRegistroMARCOriginal{
    my ($self)      = shift;
    my ($params) = @_;

    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
    return $marc_record;
    }

sub getRegistroMARCResultado{
    my ($self)      = shift;
    my ($params) = @_;

    my $marc_record_original = $self->getRegistroMARCOriginal();
    my $marc_record = MARC::Record->new();
    my $detalle_destino = $self->ref_importacion->esquema->getDetalleDestino();

    foreach my $detalle (@$detalle_destino){
        my $new_field=0;
        my $dato = $self->getCampoSubcampoJoined($detalle->getCampoDestino,$detalle->getSubcampoDestino);
        if($dato){
            #Hay dato en el campo
            if ($detalle->getCampoDestino ne 'ZZZ'){
                #Sino no esta configurado
                if($detalle->getCampoDestino < '010'){
                    #CONTROL FIELD
                    $new_field = MARC::Field->new( $detalle->getCampoDestino, $dato );
                   }
                else {
                    my $field = $marc_record->field($detalle->getCampoDestino);
                    if($field){
                        #Existe el campo, se agrega el subcampo
                        $field->add_subfields( $detalle->getSubcampoDestino => $dato );
                        }
                    else{
                        #No existe el campo, se crea uno nuevo
                        my $ind1='#';
                        my $ind2='#';
                        $new_field= MARC::Field->new($detalle->getCampoDestino, $ind1, $ind2,$detalle->getSubcampoDestino => $dato);
                    }
                    }
                if($new_field){
                    $marc_record->append_fields($new_field);
                }
             }
        }
       }

    #Ahora agregamos los registros hijo
    my $registros_hijo = $self->getRegistrosHijo();
    if($registros_hijo){
        foreach my $registro (@$registros_hijo){
            my $mc=$registro->getRegistroMARCResultado();
             $marc_record->append_fields($mc->fields());
        }
    }
    return $marc_record;
    }

#----------------------------------- FIN - FUNCIONES DEL MODELO -------------------------------------------



#----------------------------------- GETTERS y SETTERS------------------------------------------------

sub setIdImportacionIso{
    my ($self) = shift;
    my ($id_imporatcion) = @_;
    utf8::encode($id_imporatcion);
    $self->id_importacion_iso($id_imporatcion);
}

sub setMarcRecord{
    my ($self)  = shift;
    my ($marc_record) = @_;
    $self->marc_record($marc_record);
}

sub getId{
    my ($self) = shift;
    return ($self->id);
}

sub getIdImportacionIso{
    my ($self) = shift;
    return ($self->id_importacion_iso);
}

sub getMarcRecord{
    my ($self) = shift;
    return ($self->marc_record);
}



sub getEstado{
    my ($self) = shift;
    return ($self->estado);
}


sub setEstado{
    my ($self) = shift;
    my ($estado) = @_;
    $self->estado($estado);
}

sub getMatching{
    my ($self) = shift;
    return ($self->matching);
}

sub setMatching{
    my ($self) = shift;
    my ($matching) = @_;
    $self->matching($matching);
}


sub getIdMatching{
    my ($self) = shift;
    return ($self->id_matching);
}

sub setIdMatching{
    my ($self) = shift;
    my ($matching) = @_;
    $self->id_matching($matching);
}


sub getCampoSubcampoJoined{
    my ($self) = shift;
    my ($campo,$subcampo) = @_;

    my $marc = $self->getRegistroMARCOriginal;

    my $detalle_completo = $self->ref_importacion->esquema->getDetalleByCampoSubcampoDestino($campo,$subcampo);

    my $join='';
    foreach my $detalle (@$detalle_completo){
        my $dato ='';
        my $field = $marc->field($detalle->getCampoOrigen);
        if ($field){
            if($field->is_control_field()){
                    #Campo de Control
                   $dato = $field->data();
                }
                else {
                    $dato = $field->subfield($detalle->getSubcampoOrigen);
                }
            if ($dato){
				if($detalle->getSeparador){
                    $join.=$detalle->getSeparador.$dato;
                    #C4::AR::Debug::debug("SEPARADOR  ###".$detalle->getSeparador."###" );
                   }
                   else{
					   $join.=$dato;
					   }
             }
        }
     }

    return (C4::AR::Utilidades::trim($join));
}

sub getIdentificacion{
    my ($self)   = shift;
    return ($self->identificacion);
}

sub getTitulo{
    my ($self) = shift;
    my $titulo = ($self->getCampoSubcampoJoined('245','a'));

    if(!$titulo){
        my $padre=$self->getRegistroPadre;
        if ($padre){
            $titulo=$padre->getTitulo;
            }
        }
    return $titulo;
}

sub getAutor{
    my ($self) = shift;
    my $autor = ($self->getCampoSubcampoJoined('100','a'));

    if(!$autor){
        my $padre=$self->getRegistroPadre;
        if ($padre){
            $autor=$padre->getAutor;
            }
        }
    return $autor;
}


sub setIdentificacion{
    my ($self)   = shift;
    my ($ident) = @_;
    $self->identificacion($ident);
}

sub getIdentificacionFromRecord{
    my ($self)   = shift;

    my $identificacion='';
    my $marc = $self->getRegistroMARCOriginal();

    my $campo =$self->ref_importacion->getCampoFromCampoIdentificacion;
    if ($campo){
        my $field = $marc->field($campo);
        if ($field){
            if ($field->is_control_field()){
                #Si es de control devuelvo el dato;
                $identificacion = $field->data();
                }
            else{
                #Si no es de control tiene subcampo
                my $subcampo =$self->ref_importacion->getSubcampoFromCampoIdentificacion;
                if ($subcampo){
                    $identificacion = $field->subfield($subcampo);
                    }
            }
        }
    }

    return $identificacion;
}


sub setRelacion{
    my ($self)   = shift;
    my ($rel) = @_;
    $self->relacion($rel);
}

sub getRelacionFromRecord{
    my ($self)   = shift;

    my $relacion='';
    my $marc = $self->getRegistroMARCOriginal();

    my $campo =$self->ref_importacion->getCampoFromCampoRelacion;
    if ($campo){
        my $field = $marc->field($campo);
        if ($field->is_control_field()){
            #Si es de control devuelvo el dato;
            $relacion = $field->data();
            }
        else{
            #Si no es de control tiene subcampo
            my $subcampo =$self->ref_importacion->getSubcampoFromCampoRelacion;
            if ($subcampo){
                $relacion = $field->subfield($subcampo);
                }
        }


        if ($relacion){
            #Para identificar si es un campo de realcion debe comenzar con este string
            my $pre =$self->ref_importacion->getPreambuloFromCampoRelacion;
            if($pre){
                #todo a  minuscula
                $relacion=lc($relacion);
                $pre=lc($pre);
                if($relacion =~ m/^$pre/){
                    $relacion =~ s/^$pre//;
                }
                else{
                    $relacion ='';
                    }
            }
        }
    }

    return $relacion;
}


sub getRelacion{
    my ($self)   = shift;
    return ($self->relacion);
}


sub getCantidadDeRegistrosHijo{
     my ($self)   = shift;

     my ($cantidad,$registros) = C4::AR::ImportacionIsoMARC::getRegistrosHijoFromRegistroDeImportacionById($self->getId);

    return $cantidad;
}

sub getRegistrosHijo{
     my ($self)   = shift;

     my ($cantidad,$registros) = C4::AR::ImportacionIsoMARC::getRegistrosHijoFromRegistroDeImportacionById($self->getId);

    return $registros;
}

sub getRegistroPadre{
     my ($self)   = shift;

     my $registro_padre = C4::AR::ImportacionIsoMARC::getRegistroPadreFromRegistroDeImportacionById($self->getId);

    return $registro_padre;
}

sub getTipo{
     my ($self)   = shift;

    if($self->getIdentificacion){
        if(($self->getRelacion)&&($self->getRegistroPadre)) {
             return "Registro Hijo";
            }
        else{
        return "Registro";
        }
    }
    return "Desconocido";
}


sub getDatosFromReglasMatcheo{
     my ($self)   = shift;
     my ($reglas) = @_;

    my @reglas_datos=();

    foreach my $regla (@$reglas){

        my $dato = $self->getCampoSubcampoJoined($regla->{'campo'},$regla->{'subcampo'});

        if ($dato){
            $regla->{'dato'}=$dato;
            push (@reglas_datos,$regla);
            }
        }
    return  \@reglas_datos;
}


sub getNiveles {
     my ($self)   = shift;

    my $niveles= C4::AR::ImportacionIsoMARC::getNivelesFromRegistro($self->getId);
    return  $niveles;
}


sub getDetalleCompleto{
     my ($self)   = shift;

     my $detalle_completo = C4::AR::ImportacionIsoMARC::detalleCompletoRegistro($self->getId);

    return $detalle_completo;
}

sub aplicarImportacion {
     my ($self)   = shift;

     my $detalle = $self->getDetalleCompleto();
	
=begin DETALLE_REGISTRO
	$detalle->{'nivel1'} 		   => MARC Array_
												 |=> {'campo'}           		= CAMPO
												 |=> {'subcampo'}        		= SUBCAMPO
												 |=> {'liblibrarian'}			= NOMBRE
												 |=> {'orden'}					= ORDEN
												 |=> {'dato'}					= DATO
												 |=> {'referencia'}				= ES UNA REFERENCIA?
												 |=> {'referencia_encontrada'}	= SE ENCONTRO EN LA BASE? (SI SE ENCUENTRA TIENE EL id)
												 |=> {'referencia_tabla'}		= TABLA DE LA REFERENCIA
												 |_
    $detalle->{'marc_record'}      => MARC Record del Nivel 1
    $detalle->{'nivel1_template'}  => Template a usar por el Nivel 1
    $detalle->{'cantItemN1'}       => Cantidad de Ejemplares (lo usa la vista previa)
    $detalle->{'nivel2'}           => Arreglo de Niveles 2 =>
												 |=> {'nivel2_array'}           	= MARC Array_
												 |												 |=> {'campo'}           		= CAMPO
												 |												 |=> {'subcampo'}        		= SUBCAMPO
												 |												 |=> {'liblibrarian'}			= NOMBRE
												 |												 |=> {'orden'}					= ORDEN
												 |												 |=> {'dato'}					= DATO
											 	 |												 |=> {'referencia'}				= ES UNA REFERENCIA?
												 |												 |=> {'referencia_encontrada'}	= SE ENCONTRO EN LA BASE? (SI SE ENCUENTRA TIENE EL id)
												 |												 |=> {'referencia_tabla'}		= TABLA DE LA REFERENCIA
												 |												 |_
												 |=> {'marc_record'}           		= MARC Record del Nivel 2																							 
												 |=> {'nivel2_template'}       		= Template a usar por el Nivel 2
												 |=> {'tipo_documento'}       		= Objeto Tipo de Documento (CatRefTipoNivel3)
												 |=> {'nivel_bibliografico'}       	= Objeto Nivel Bibliográfico (RefNivelBibliografico)
												 |=> {'tiene_indice'}       		= Indice del Nivel 2 (865&a)
												 |=> {'disponibles'}       			= Cant. ejemplares disponibles
												 |=> {'no_disponibles'}       		= Cant. ejemplares NO disponibles
												 |=> {'disponibles_sala'}       	= Cant. ejemplares disponibles para Sala
												 |=> {'disponibles_domiciliario'}   = Cant. ejemplares disponibles para Domicilio
												 |=> {'cant_nivel3'}   				= Cant. Niveles 3
												 |=> {'nivel3'}   					= ARREGLO DE NIVELES 3
												 |												 |=> {'marc_record'}           	= MARC Record del Nivel 3
												 |												 |=> {'tipo_documento'}        	= Tipo de Documento (CatRefTipoNivel3->id_tipo_doc)
												 |												 |=> {'barcode'}				= BARCODE
												 |												 |=> {'signatura_topografica'}	= SIGNATURA TOPOGRAFICA
												 |												 |=> {'disponibilidad'}			= OBJETO Disponibilidad (RefDisponibilidad)
											 	 |												 |=> {'estado'}					= OBJETO Estado (RefEstado)
												 |												 |_
												 |_
        
=cut
     #Proceso el nivel 1 agregando las referencias que no existen!!
   
	 my $infoArrayNivel1 =  $self->prepararNivelParaImportar($detalle->{'marc_record'},$detalle->{'nivel1_template'},1);
   
   my $params_n1;
	 $params_n1->{'id_tipo_doc'} = $detalle->{'nivel1_template'};
	 $params_n1->{'infoArrayNivel1'} = $infoArrayNivel1;
   my ($msg_object, $id1) = C4::AR::Nivel1::t_guardarNivel1($params_n1);
   
   C4::AR::Debug::debug("Nivel 1 creado ".$id1);
   
   
   if (!$msg_object->{'error'}){
    my $niveles2 = $detalle->{'nivel2'};
    foreach my $nivel2 (@$niveles2){
      my $infoArrayNivel2 =  $self->prepararNivelParaImportar($nivel2->{'marc_record'},$nivel2->{'nivel2_template'},2);   
      my $params_n2;
      $params_n2->{'id_tipo_doc'} = $nivel2->{'nivel2_template'};
      $params_n2->{'tipo_ejemplar'} = $nivel2->{'nivel2_template'};
      $params_n2->{'infoArrayNivel2'} = $infoArrayNivel2;
      $params_n2->{'id1'}=$id1;
      my ($msg_object2,$id1,$id2) = C4::AR::Nivel2::t_guardarNivel2($params_n2);
      # Hay que agregar el indice aca
      #  $nivel2->{'tiene_indice'}
        if (!$msg_object2->{'error'}){  
          my $niveles3 = $nivel2->{'nivel3'};

          foreach my $nivel3 (@$niveles3){
            my $params_n3;
            $params_n3->{'id_tipo_doc'} = $nivel3->{'tipo_documento'};
            $params_n3->{'tipo_ejemplar'} = $nivel3->{'tipo_documento'};
            $params_n3->{'id1'}=$id1;
            $params_n3->{'id2'}=$id2;
            $params_n3->{'ui_origen'}=$nivel3->{'ui_origen'};
            $params_n3->{'ui_duenio'}=$nivel3->{'ui_duenio'};
            $params_n3->{'cantEjemplares'} = 1;
            
            #Hay que autogenerar el barcode o no???
            if (!$nivel3->{'generar_barcode'}){
              $params_n3->{'esPorBarcode'} = 'true';
              my @barcodes_array=();
              $barcodes_array[0]=$nivel3->{'barcode'};
              $params_n3->{'BARCODES_ARRAY'} = \@barcodes_array;
            }
            
            my @infoArrayNivel=();
            
            my %hash_temp = {};
            $hash_temp{'indicador_primario'}  = '#';
            $hash_temp{'indicador_secundario'}  = '#';
            $hash_temp{'campo'}   = '995';
            $hash_temp{'subcampos_array'}	=();
            $hash_temp{'cant_subcampos'}   = 0;
        
        
            my %hash_sub_temp = {};
            
            #UI origen
            my $hash;
            $hash->{'d'}= $params_n3->{'ui_origen'};
            $hash_sub_temp{$hash_temp{'cant_subcampos'}} = $hash;
            $hash_temp{'cant_subcampos'}++;
            #UI duenio
            my $hash;
            $hash->{'c'}= $params_n3->{'ui_duenio'};
            $hash_sub_temp{$hash_temp{'cant_subcampos'}} = $hash;
            $hash_temp{'cant_subcampos'}++;
            #Estado
            my $hash;
            $hash->{'e'}= $nivel3->{'estado'}->getCodigo();
            $hash_sub_temp{$hash_temp{'cant_subcampos'}} = $hash;
            $hash_temp{'cant_subcampos'}++;
            #Disponibilidad
            my $hash;
            $hash->{'o'}= $nivel3->{'disponibilidad'}->getCodigo();
            $hash_sub_temp{$hash_temp{'cant_subcampos'}} = $hash;
            $hash_temp{'cant_subcampos'}++;
            #Signatura
            my $hash;
            $hash->{'t'}= $nivel3->{'signatura_topografica'};
            $hash_sub_temp{$hash_temp{'cant_subcampos'}} = $hash;
            $hash_temp{'cant_subcampos'}++;
            
            $hash_temp{'subcampos_hash'} =\%hash_sub_temp;
          
            if ($hash_temp{'cant_subcampos'}){
              push (@infoArrayNivel,\%hash_temp)
            }
            
            $params_n3->{'infoArrayNivel3'} = \@infoArrayNivel;
            my ($msg_object3) = C4::AR::Nivel3::t_guardarNivel3($params_n3);
            
          }
         } 
      }
    }
    
    if ($msg_object->{'error'}){
		$self->setEstado('ERROR');
		}
	else{
		$self->setEstado('IMPORTADO');
		}
	return $msg_object;
}


sub prepararNivelParaImportar{
     my ($self)   = shift;
     my ($marc_record, $itemtype, $nivel) = @_;


   my @infoArrayNivel=();
   
   
       foreach my $field ($marc_record->fields) {
        if(! $field->is_control_field){
            
            my %hash_temp = {};
            $hash_temp{'campo'}               = $field->tag;
            $hash_temp{'indicador_primario'}  = $field->indicator(1);
            $hash_temp{'indicador_secundario'}= $field->indicator(2);
            $hash_temp{'subcampos_array'}	    = ();
            $hash_temp{'subcampos_hash'}	    = ();
            $hash_temp{'cant_subcampos'}      = 0;
            
            my %hash_sub_temp = {};
            my @subcampos_array;
            #proceso todos los subcampos del campo
            foreach my $subfield ($field->subfields()) {
                my $subcampo          = $subfield->[0];
                my $dato              = $subfield->[1];
                my $estructura = C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo( $hash_temp{'campo'}, $subcampo, $itemtype, $nivel);
                if($estructura->getReferencia){
                    #es una referencia, yo tengo el dato nomás (luego se verá si hay que crear una nueva o ya existe en la base)
                    my ($clave_tabla_referer_involved,$tabla_referer_involved) =  C4::AR::Referencias::getTablaInstanceByAlias($estructura->infoReferencia->getReferencia);
                    my ($ref_cantidad,$ref_valores) = $tabla_referer_involved->getAll(1,0,0,$dato);
                    my $tabla = $estructura->infoReferencia->getReferencia;

                    if ($ref_cantidad){
                      #REFERENCIA ENCONTRADA
                        $dato =  $ref_valores->[0]->get_key_value;
                      }
                    else { #no existe la referencia, hay que crearla 
                      $dato = C4::AR::ImportacionIsoMARC::procesarReferencia($dato,$tabla,$clave_tabla_referer_involved,$tabla_referer_involved);
                    }
                 }  
                #ahora guardo el dato para importar 
                if ($dato){
                    
                  C4::AR::Debug::debug("CAMPO: ". $hash_temp{'campo'}." SUBCAMPO: ".$subcampo." => ".$dato);
                  my $hash; 
                  $hash->{$subcampo}= $dato;
                  
                  $hash_sub_temp{$hash_temp{'cant_subcampos'}} = $hash;
                  push(@subcampos_array, ($subcampo => $dato));
                  
                  $hash_temp{'cant_subcampos'}++;
                }
                 
              }
                    
          if ($hash_temp{'cant_subcampos'}){
            $hash_temp{'subcampos_hash'} =\%hash_sub_temp;
            $hash_temp{'subcampos_array'} =\@subcampos_array;
            push (@infoArrayNivel,\%hash_temp)
          }
        }
      }
    
    return  \@infoArrayNivel;
}
