package C4::Modelo::CatNivel1;

use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
use utf8;


__PACKAGE__->meta->setup(
    table   => 'cat_nivel1',

    columns => [
        id1       => { type => 'serial', not_null => 1 },
        titulo    => { type => 'varchar', length => 255, not_null => 1 },
        autor     => { type => 'integer', not_null => 0 },
        timestamp => { type => 'timestamp' },
    ],

    primary_key_columns => [ 'id1' ],

    relationships => [
        cat_autor => {
            class      => 'C4::Modelo::CatAutor',
            column_map => { autor => 'id' },
            type       => 'one to one',
        },
    ],

);

sub getTitulo{
    my ($self) = shift;
    return ($self->titulo);
}

sub setTitulo{
    my ($self) = shift;

    my ($titulo) = @_;
    utf8::encode($titulo);
    $self->titulo($titulo);
}

sub getAutor{
    my ($self) = shift;
    return ($self->autor);
}

sub getAutorObject{
    my ($self) = shift;
    my $autor = C4::AR::Referencias::getAutor($self->getAutor());
    if(!$autor){
        C4::AR::Debug::debug("CatNivel1=>getAutorObject()=> EL OBJECTO (ID) AUTOR NO EXISTE");
        $autor = C4::Modelo::CatAutor->new();
    }
    return ($autor);
}


sub setAutor{
    my ($self) = shift;
    my ($autor) = @_;
    $self->autor($autor);
}

=item
sub agregar{
    my ($self)=shift;
	
	my ($data_hash)=@_;

    use C4::Modelo::CatNivel1Repetible;

    my @arrayNivel1;
    my @arrayNivel1Repetibles;
    my $infoArrayNivel1= $data_hash->{'infoArrayNivel1'};

	#separo los datos del Nivel1 de los datos del Nivel1_repetible
    foreach my $infoNivel1 (@$infoArrayNivel1){

        if($infoNivel1->{'repetible'}){
            push(@arrayNivel1Repetibles, $infoNivel1);
        }else{
            push(@arrayNivel1, $infoNivel1);
        }
    }
    
    #se guardan los datos de Nivel1
    foreach my $infoNivel1 (@arrayNivel1){  
		$self->setDato($infoNivel1);
    }

	$self->save();

    my $id1 = $self->getId1;

    #Se guradan los datos en Nivel 1 repetibles
    foreach my $infoNivel1 (@arrayNivel1Repetibles){
        $infoNivel1->{'id1'}= $id1;
# SI NO EXISTE EL rep_n1_id hay q crear una tupla, puede q sea un registro importado que no tenia este dato
        my $nivel1Repetible;

        C4::AR::Debug::debug("CatNivel1 => campo, subcampo: ".$infoNivel1->{'campo'}.", ".$infoNivel1->{'subcampo'});

        if ( $infoNivel1->{'Id_rep'} != 0 ){
            C4::AR::Debug::debug("CatNivel1 => agregar => Se va a modificar CatNivel1, Id_rep: ". $infoNivel1->{'Id_rep'});
            $nivel1Repetible = C4::Modelo::CatNivel1Repetible->new(db => $self->db, rep_n1_id => $infoNivel1->{'Id_rep'});
            $nivel1Repetible->load();
        }else{
            C4::AR::Debug::debug("CatNivel1 => agregar => No existe el REPETIBLE se crea uno");
            $nivel1Repetible = C4::Modelo::CatNivel1Repetible->new(db => $self->db);
        }

        $nivel1Repetible->setId1($infoNivel1->{'id1'});
        $nivel1Repetible->setCampo($infoNivel1->{'campo'});
        $nivel1Repetible->setSubcampo($infoNivel1->{'subcampo'});

        if ($infoNivel1->{'referencia'}) {
            C4::AR::Debug::debug("CatNivel1 => REPETIBLE con REFERENCIA: ".$infoNivel1->{'datoReferencia'});
			$nivel1Repetible->dato($infoNivel1->{'datoReferencia'});
        }else{
			$nivel1Repetible->dato($infoNivel1->{'dato'});
            C4::AR::Debug::debug("CatNivel1 => REPETIBLE sin REFERENCIA: ".$infoNivel1->{'dato'});
		}

        $nivel1Repetible->save(); 
    }

}
=cut

sub agregar{
    my ($self)=shift;
    
    my ($data_hash)=@_;

    use C4::Modelo::CatNivel1Repetible;

    my @arrayNivel1;
    my @arrayNivel1Repetibles;
    my $infoArrayNivel1 = $data_hash->{'infoArrayNivel1'};

    #separo los datos del Nivel1 de los datos del Nivel1_repetible
#     foreach my $infoNivel1 (@$infoArrayNivel1){
# 
#         if($infoNivel1->{'repetible'}){
#             push(@arrayNivel1Repetibles, $infoNivel1);
#         }else{
#             push(@arrayNivel1, $infoNivel1);
#         }
#     }
    foreach my $infoNivel1 (@$infoArrayNivel1){

        if($infoNivel1->{'tiene_estructura'} eq '1'){
            #si es fijo es un campo de la tabla cat_nivel1
#             if(($infoNivel1->{'fijo'} ne '1') || !defined $infoNivel1->{'fijo'}){
            if($infoNivel1->{'fijo'} eq '1'){
                #es es un campo de la tabla cat_nivel1_repetible
                push(@arrayNivel1, $infoNivel1);
                C4::AR::Debug::debug("CatNivel1 => agregar => push en arrayNivel1");
            }else{
                push(@arrayNivel1Repetibles, $infoNivel1);
                C4::AR::Debug::debug("CatNivel1 => agregar => push en arrayNivel1Repetibles");
            }
        }
    }
    
    #se guardan los datos de Nivel1
    foreach my $infoNivel1 (@arrayNivel1){  
        $self->setDato($infoNivel1);
    }

    $self->save();

    my $id1 = $self->getId1;

    #Se guradan los datos en Nivel 1 repetibles
    foreach my $infoNivel1 (@arrayNivel1Repetibles){
        $infoNivel1->{'id1'} = $id1;
# SI NO EXISTE EL rep_n1_id hay q crear una tupla, puede q sea un registro importado que no tenia este dato
        my $nivel1Repetible;

        C4::AR::Debug::debug("CatNivel1 => campo, subcampo: ".$infoNivel1->{'campo'}.", ".$infoNivel1->{'subcampo'});

        if ( $infoNivel1->{'Id_rep'} != 0 ){
            C4::AR::Debug::debug("CatNivel1 => agregar => Se va a modificar CatNivel1, Id_rep: ". $infoNivel1->{'Id_rep'});
# getNivel2RepetibleFromId2Repetible
#             $nivel1Repetible = C4::Modelo::CatNivel1Repetible->new(db => $self->db, rep_n1_id => $infoNivel1->{'Id_rep'});
#             $nivel1Repetible->load();
            $nivel1Repetible = C4::AR::Nivel1::getNivel1RepetibleFromId1Repetible($infoNivel1->{'Id_rep'},$self->db);
        }else{
            C4::AR::Debug::debug("CatNivel1 => agregar => No existe el REPETIBLE se crea uno");
            $nivel1Repetible = C4::Modelo::CatNivel1Repetible->new(db => $self->db);
        }

        $nivel1Repetible->setId1($infoNivel1->{'id1'});
        $nivel1Repetible->setCampo($infoNivel1->{'campo'});
        $nivel1Repetible->setSubcampo($infoNivel1->{'subcampo'});

        if ($infoNivel1->{'referencia'}) {
            C4::AR::Debug::debug("CatNivel1 => REPETIBLE con REFERENCIA: ".$infoNivel1->{'datoReferencia'});
            $nivel1Repetible->dato($infoNivel1->{'datoReferencia'});
        }else{
            $nivel1Repetible->dato($infoNivel1->{'dato'});
            C4::AR::Debug::debug("CatNivel1 => REPETIBLE sin REFERENCIA: ".$infoNivel1->{'dato'});
        }

        $nivel1Repetible->save(); 
    }

}

sub eliminar{

    my ($self)=shift;
    use C4::Modelo::CatNivel1Repetible;
    use C4::Modelo::CatNivel1Repetible::Manager;
    
    use C4::Modelo::CatNivel2;
    use C4::Modelo::CatNivel2::Manager;

    my ($nivel2) = C4::Modelo::CatNivel2::Manager->get_cat_nivel2(query => [ id1 => { eq => $self->getId1() } ] );
    foreach my $n2 (@$nivel2){
      $n2->eliminar();
    }
   
   
    my ($repetiblesNivel1) = C4::Modelo::CatNivel1Repetible::Manager->get_cat_nivel1_repetible(query => [ id1 => { eq => $self->getId1() } ] );
    foreach my $n1Rep (@$repetiblesNivel1){
      $n1Rep->eliminar();
    }

    $self->delete();
}

sub setDato{
	my ($self) = shift;
	my ($data_hash) = @_;

    C4::AR::Debug::debug("CatNivel1 => setDato => campo, subcampo: ".$data_hash->{'campo'}.", ".$data_hash->{'subcampo'});
    
	if( ($data_hash->{'campo'} eq '245')&&($data_hash->{'subcampo'} eq 'a') ){
	#titulo
        if( $data_hash->{'referencia'} ){
			$self->setTitulo($data_hash->{'datoReferencia'});
		}else{
			$self->setTitulo($data_hash->{'dato'});
		}
	}
	
	if( ($data_hash->{'campo'} eq '110')&&($data_hash->{'subcampo'} eq 'a') ){  
	#autor
        if( $data_hash->{'referencia'} ){
			$self->setAutor($data_hash->{'datoReferencia'});
            C4::AR::Debug::debug("CatNivel1 => agregar => datoReferencia: ".$data_hash->{'datoReferencia'});
		}else{
			$self->setAutor($data_hash->{'dato'});
            C4::AR::Debug::debug("CatNivel1 => agregar => dato: ".$data_hash->{'dato'});
            C4::AR::Debug::debug("CatNivel1 => agregar => datoReferencia: ".$data_hash->{'datoReferencia'});
            C4::AR::Debug::debug("CatNivel1 => agregar => modificado: ".$data_hash->{'modificado'});
		}
	}
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
Esta funcion devuelve los campos de nivel 1 mapeados en un arreglo de {campo, subcampo, dato},
ademas si es una referencia, setea el dato referente
=cut
sub toMARC{
    my ($self) = shift;

	my @marc_array;

	my $campo= '245';
	my $subcampo= 'a';
	my %hash;
	$hash{'campo'}= $campo;
	$hash{'subcampo'}= $subcampo;
	$hash{'header'}= C4::AR::Busquedas::getHeader($campo);
	$hash{'dato'}= $self->getTitulo;
	$hash{'ident'}= 'TITULO'; #parece q no es necesario
 	my $estructura= C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($campo, $subcampo);

    if($estructura){
	    $hash{'liblibrarian'}= $estructura->getLiblibrarian;
    }

    $hash{'id1'} = $self->getId1;
	

	push (@marc_array, \%hash);

	$campo= '110';
	$subcampo= 'a';
	my %hash;
	$hash{'campo'}= $campo;
	$hash{'subcampo'}= $subcampo;
	$hash{'header'}= C4::AR::Busquedas::getHeader($campo);
	$hash{'dato'}= C4::AR::Referencias::getNombreAutor($self->getAutor);
	my $estructura= C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($campo, $subcampo);

    if($estructura){
        if($estructura->getReferencia){
	        #tiene referencia
		    $hash{'datoReferencia'}= $self->getAutor;
        }
    
        $hash{'liblibrarian'}= $estructura->getLiblibrarian;
    }

    $hash{'id1'} = $self->getId1;


	push (@marc_array, \%hash);
	
	return (\@marc_array);
}


=item
Esta funcion devuelve los campos de nivel 1 y nivel1Repetible mapeados en un arreglo de {campo, subcampo, dato}
=cut
sub nivel1CompletoToMARC{
  my ($self) = shift;

	my ($marc_array)= $self->toMARC;
	my ($nivel1Repetible_object_array) = C4::Modelo::CatNivel1Repetible::Manager->get_cat_nivel1_repetible( 
																						query => [ id1 => { eq => $self->getId1 } ]
																		);

	my $campo;
	my $subcampo;
	my $dato;	
    my $id1 = $self->getId1;

	foreach my $marc_object (@$nivel1Repetible_object_array){
		$campo                  = $marc_object->getCampo;
		$subcampo               = $marc_object->getSubcampo;
		$dato                   = $marc_object->getDato;
		my %hash;
		$hash{'header'}         = C4::AR::Busquedas::getHeader($campo);
		$hash{'campo'}          = $campo;
		$hash{'subcampo'}       = $subcampo;
		$hash{'liblibrarian'}   = C4::AR::Busquedas::getLiblibrarian($campo, $subcampo);
		$hash{'dato'}           = $dato;
        $hash{'id1'}            = $id1;
        #obtengo el dato de la referencia solo si es un repetible, los campos fijos recuperan de otra forma el dato de la referencia 
        my $valor_referencia    = C4::AR::Catalogacion::getDatoFromReferencia($campo, $subcampo, $dato);
        $hash{'dato'}           = $valor_referencia;
    
        push(@$marc_array, \%hash);
        C4::AR::Debug::debug("CatNivel1 => nivel1CompletoToMARC => nivel1CompletoToMARC => campo, subcampo: ".$campo.", ".$subcampo);
        C4::AR::Debug::debug("CatNivel1 => nivel1CompletoToMARC => nivel1CompletoToMARC => id1: ".$id1);	
	}
    
    C4::AR::Debug::debug("CatNivel1 => nivel1CompletoToMARC => cant: ".scalar(@$marc_array));

	return ($marc_array);
}
# ==============================================FIN===SOPORTE=====ESTRUCTURA CATALOGACION================================================

sub getInvolvedCount{
 
    my ($self) = shift;

    my ($campo, $value)= @_;
    
    my @filtros;

    push (@filtros, ( $campo => $value ) );

    my $cat_nivel1_count = C4::Modelo::CatNivel1::Manager->get_cat_nivel1_count( query => \@filtros );

    return ($cat_nivel1_count);
}

sub replaceBy{
    my ($self) = shift;

    my ($campo,$value,$new_value)= @_;
    
    my @filtros;

    push (  @filtros, ( $campo => { eq => $value},) );


    my $replaced = C4::Modelo::CatNivel1::Manager->update_cat_nivel1(   where => \@filtros,
                                                                        set   => { $campo => $new_value });
}


=item sub getGrupos
    Recupero todos los grupos del nivel 1.
    Retorna la referencia a un arreglo de objetos
=cut
sub getGrupos {
    my ($self) = shift;

    #recupero todos los grupos de nivel 1 
    my ($nivel2_object_array) = C4::Modelo::CatNivel2::Manager->get_cat_nivel2( 
                                                                        query => [ id1 => { eq => $self->getId1 } ]
                                                                   );
    return $nivel2_object_array;
}

=item sub tienePrestamos
    Verifica si el nivel 1 pasado por parametro tiene ejemplares con prestamos o no
=cut
sub tienePrestamos{
    my ($self) = shift;

    my $cant = 0;
    #recupero todos los grupos del nivel 1
    my ($nivel2_object_array) = $self->getGrupos();
    
    #recorro los id2 del nivel 1 para verificar si tienen prestamos o no 
    foreach my $nivel2 (@$nivel2_object_array){
        $cant = C4::AR::Prestamos::getCountPrestamosDeGrupo($nivel2->getId2);        
        if($cant > 0){
            last;
        } 

    }

    return ($cant > 0)?1:0;
}



sub agregarDesdeMARC {

   my ($self)=shift;
    my ($marc)=@_;
    
    #Autor
    my $autor = $marc->subfield("100","a");
    if ($autor){
        $autor =~ s/\.//; #Saco los puntos
        my $refAutores = C4::AR::Referencias::obtenerAutoresLike($autor);
        if($refAutores) { #Se encontro una referencia al autor
            $self->setAutor($refAutores->[0]->getId);
        }
        else{ #Hay que crear el autor
                my $autoTemp = C4::Modelo::CatAutor->new();
                $autoTemp->setCompleto($autor);
                my @personal = split(/,\s/, $autor); #Divido por ,+espacio
                if ($personal[0]){$autoTemp->setApellido($personal[0]);}
                if ($personal[1]){$autoTemp->setNombre($personal[1]);}
                $autoTemp->save;
                $self->setAutor($autoTemp->getId);
        }
    }

    C4::AR::Debug::debug("agregarDesdeMARC => Autor => ".$autor);

    #Titulo
    my $titulo = $marc->subfield("245","a");
    $self->setTitulo($titulo);
    C4::AR::Debug::debug("agregarDesdeMARC => Autor => ".$titulo);
    $self->save();

    C4::AR::Debug::debug("agregarDesdeMARC => Se guarda el nivel 1 ");

    use C4::Modelo::CatNivel1Repetible;
    my $arrayNivel1Repetibles;

    my $id1 = $self->getId1;
     my ($arrayNivel1Repetibles)= C4::AR::EstructuraCatalogacionBase::getSubCampos(1); #Todos los campos MARC del nivel 1

    #Se guardan los datos en Nivel 1 repetibles
    foreach my $infoNivel1  (@$arrayNivel1Repetibles){

        my $campo = $infoNivel1->getCampo;
        my $subcampo = $infoNivel1->getSubcampo;
        if (!((($campo eq "100") || ($campo eq "245"))&&($subcampo eq "a"))){ # si es ni titulo ni autor
            my $datoRepetible=$marc->subfield($campo,$subcampo);

            if($datoRepetible){
                my $nivel1Repetible = C4::Modelo::CatNivel1Repetible->new(db => $self->db);
                $nivel1Repetible->setId1($id1);
                $nivel1Repetible->setCampo($campo);
                $nivel1Repetible->setSubcampo($subcampo);
                $nivel1Repetible->dato($datoRepetible);
                $nivel1Repetible->save();
               C4::AR::Debug::debug("agregarDesdeMARC => Se guarda el nivel 1 repetible => ".$campo." - ".$subcampo);
            }
        }
        }

          C4::AR::Debug::debug("agregarDesdeMARC => Se va a guardar el nivel 2");

        my $nivel2 = C4::Modelo::CatNivel2->new(db => $self->db);
        $nivel2->agregarDesdeMARC($id1,$marc);
}


# sub getNombreCompletoAutor{
#     my ($self) = shift;
# 
#     my $errAutor = $self->has_loaded_related(object => $self, relationship => 'cat_autor');
# 
#     if(!$errAutor){
#         return "NO EXISTE";
#     }else{
#         return $self->cat_autor->getCompleto;
#     }
# }

1;

