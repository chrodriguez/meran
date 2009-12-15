package C4::Modelo::CatRegistroMarcN2;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_registro_marc_n2',

    columns => [
        id              => { type => 'serial', not_null => 1 },
        marc_record     => { type => 'text' },
        id1             => { type => 'integer', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

    relationships => [
        nivel1  => {
            class       => 'C4::Modelo::CatRegistroMarcN1',
            key_columns => { id1 => 'id' },
            type        => 'one to one',
        },
    ],
);


sub getId2{
    my ($self)  = shift;

    return $self->id;
}

sub getId1{
    my ($self)  = shift;

    return $self->id1;
}

sub setId1{
    my ($self)  = shift;
    my ($id1)   = @_;

    $self->id1($id1);
}

sub getMarcRecord{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->marc_record));
}

sub setMarcRecord{
    my ($self)          = shift;
    my ($marc_record)   = @_;

    $self->marc_record($marc_record);
}

sub agregar{
    my ($self)      = shift;
    my ($id1,$marc_record)    = @_;

    $self->setId1($id1);    
    $self->setMarcRecord($marc_record);

    $self->save();
}

sub modificar{
    my ($self)           = shift;
    my ($marc_record)    = @_;

    $self->setMarcRecord($marc_record);

    $self->save();
}

sub eliminar{
    my ($self)      = shift;
    my ($params)    = @_;

    #HACER ALGO SI ES NECESARIO

    my ($nivel3) = C4::AR::Nivel3::getNivel3FromId2($self->getId2(), $self->db);

    foreach my $n3 (@$nivel3){
      $n3->eliminar();
    }

    $self->delete();    
}


=head2
sub getISBN

Funcion que devuelve el isbn
=cut

sub getISBN{
     my ($self)      = shift;
     
     my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
 
     return $marc_record->subfield("20","a");
}

=head2
sub getISSN

Funcion que devuelve el issn
=cut

sub getISSN{
     my ($self)      = shift;
     
     my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());    
 
     return $marc_record->subfield("22","a");
}

=head2
sub getSeriesTitulo

Funcion que devuelve el series_titulo
=cut

sub getSeriesTitulo{
     my ($self)      = shift;
     
     my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());    
 
     return $marc_record->subfield("440","a");
}

=head2
sub getTipoDocumento

Funcion que devuelve la referencia al tipo de Documento
=cut
sub getTipoDocumento{
    my ($self)      = shift;
    
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
    my $tipo_doc    = $marc_record->subfield("910","a");

    C4::AR::Debug::debug("CatRegistroMarcN2 => getTipoDocumento => getTipoDocumento => ".$tipo_doc);
    return $tipo_doc;
}

=head2
sub getTipoDocumentoObject

Funcion que devuelve un objeto tipo de documento de acuerdo al id de referencia a TipoDocumento que tiene
=cut

sub getTipoDocumentoObject{
    my ($self)      = shift;
        
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
    my $ref         = C4::AR::Catalogacion::getRefFromStringConArrobas($self->getTipoDocumento());
        
    my $tipo_doc    = C4::AR::Referencias::getTipoDocumentoObject($ref);
        
    if(!$tipo_doc){
            C4::AR::Debug::debug("CatRegistroMarcN2 => getTipoDocumentoObject()=> EL OBJECTO (ID) CatRefTipoNivel3 NO EXISTE");
            $tipo_doc = C4::Modelo::CatRefTipoNivel3->new();
    }
    
    return $tipo_doc;
}


=head2 sub getSoporte

=cut
sub getSoporte{
    my ($self)      = shift;
    
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());

    my $soporte     = $marc_record->subfield("245","h");
    C4::AR::Debug::debug("CatRegistroMarcN2 => getSoporte => soporte => ".$soporte);
    return $soporte;
}

=head2 getSoporteObject

=cut
sub getSoporteObject{
    my ($self)          = shift;
     
    my $marc_record     = MARC::Record->new_from_usmarc($self->getMarcRecord());
    my $ref             = C4::AR::Catalogacion::getRefFromStringConArrobas($self->getSoporte());
     
    my $soporte_object  = C4::AR::Referencias::getSoporteObject($ref);
        
    if(!$soporte_object){
            C4::AR::Debug::debug("CatRegistroMarcN2 => getSoporteObject()=> EL OBJECTO (ID) RefSoporte NO EXISTE");
            $soporte_object = C4::Modelo::RefSoporte->new();
    }

    return $soporte_object;
}

=head2 sub getCiudadPublicacion
Recupera la Ciudad de Publicacion segun el MARC 260,a
=cut
sub getCiudadPublicacion{
    my ($self)      = shift;
    
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());

    return $marc_record->subfield("260","a");
}

=head2 getCiudadObject

=cut
sub getCiudadObject{
    my ($self)          = shift;
     
    my $marc_record     = MARC::Record->new_from_usmarc($self->getMarcRecord());
    my $ref             = C4::AR::Catalogacion::getRefFromStringConArrobas($self->getCiudadPublicacion);
     
    my $ciudad_object   = C4::AR::Referencias::getCiudadObject($ref);
        
    if(!$ciudad_object){
            C4::AR::Debug::debug("CatRegistroMarcN2 => getCiudadObject()=> EL OBJECTO (ID) RefLocalidad NO EXISTE");
            $ciudad_object = C4::Modelo::RefLocalidad->new();
    }

    return $ciudad_object;
}

=head2 sub getIdioma
Recupera el Idioma segun el MARC 041,a
=cut
sub getIdioma{
    my ($self)      = shift;
    
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());

    return $marc_record->subfield("041","a");
}

=head2 sub getIdiomaObject
    Recupera el objeto 
=cut
sub getIdiomaObject{
    my ($self)          = shift;
     
    my $marc_record     = MARC::Record->new_from_usmarc($self->getMarcRecord());
    my $ref             = C4::AR::Catalogacion::getRefFromStringConArrobas($self->getIdioma());
     
    my $idioma_object   = C4::AR::Referencias::getIdiomaObject($ref);
        
    if(!$idioma_object){
            C4::AR::Debug::debug("CatRegistroMarcN2 => getSoporteObject()=> EL OBJECTO (ID) RefSoporte NO EXISTE");
            $idioma_object = C4::Modelo::RefIdioma->new();
    }

    return $idioma_object;
}

=head2 sub getNivelBibliografico
Recupera el Nivel Bibliografico segun el MARC 900,b
=cut
sub getNivelBibliografico{
    my ($self)      = shift;
    
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());

    return $marc_record->subfield("900","b");
}

=head2 sub getNivelBibliograficoObject
    Recupera el objeto 
=cut
sub getNivelBibliograficoObject{
    my ($self)      = shift;
     
    my $marc_record     = MARC::Record->new_from_usmarc($self->getMarcRecord());
    my $ref             = C4::AR::Catalogacion::getRefFromStringConArrobas($self->getNivelBibliografico());
     
    my $nivel_bibliografico_objecto = C4::AR::Referencias::getNivelBibliograficoObject($ref);
        
    if(!$nivel_bibliografico_objecto){
            C4::AR::Debug::debug("CatRegistroMarcN2 => getSoporteObject()=> EL OBJECTO (ID) RefSoporte NO EXISTE");
            $nivel_bibliografico_objecto = C4::Modelo::RefNivelBibliografico->new();
    }

    return $nivel_bibliografico_objecto;
}

=head2 sub getAnio_publicacion
 Recupera la ciudad de la publicacion segun el MARC 260,c
=cut
sub getAnio_publicacion{
    my ($self)      = shift;
    
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());

    return $marc_record->subfield("260","c");
}

=head2 sub tienePrestamos
    Verifica si el nivel 2 pasado por parametro tiene ejemplares con prestamos o no
=cut
sub tienePrestamos {
    my ($self) = shift;

    my $cant = C4::AR::Prestamos::getCountPrestamosDeGrupo($self->getId2);

    return ($cant > 0)?1:0;
}


=head2 sub toMARC

=cut
sub toMARC{
    my ($self) = shift;

    #obtengo el marc_record del NIVEL 2
    my $marc_record         = MARC::Record->new_from_usmarc($self->getMarcRecord());


    my $MARC_result_array   = &C4::AR::Catalogacion::detalleMARC($marc_record);

#     foreach my $m (@$MARC_result_array){
#         C4::AR::Debug::debug("campo => ".$m->{'campo'});
#         foreach my $s (@{$m->{'subcampos_array'}}){
#             C4::AR::Debug::debug("liblibrarian => ".$s->{'subcampo'});        
#             C4::AR::Debug::debug("liblibrarian => ".$s->{'liblibrarian'});        
#         }
#     }

    return ($MARC_result_array);
}



#==================================================VERRRRRRRRRRRRRRRRRR==========================================================


=item
retorna la canitdad de items prestados para el grupo pasado por parametro
=cut
sub getCantPrestados{
    my ($self)  = shift;
    my ($id2)   = @_;

    my ($cantPrestamos_count) = C4::AR::Nivel2::getCantPrestados($id2);

    return $cantPrestamos_count;
}


=head2 sub tieneReservas
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

=head2 sub getCantEjemplares
retorna la canitdad de ejemplares del grupo
=cut
sub getCantEjemplares{
    my ($self) = shift;

    my $cantEjemplares_count = C4::Modelo::CatRegistroMarcN3::Manager->get_cat_registro_marc_n3_count(

                                                                query => [  'id1' => { eq => $self->getId1 },
                                                                            'id2' => { eq => $self->getId2 }
                                                                         ],

                                        );


    return $cantEjemplares_count;
}


sub getEdicion{
    my ($self)      = shift;

    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());

    return $marc_record->subfield("250","a");
}

# DEPRECATEDD
# actualizar segun tablas nuevas
=item
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
     my ($arrayNivel2Repetibles)= C4::AR::EstructuraCatalogacionBase::getSubCampos(2); #Todos los campos MARC del nivel 2

    #Se guardan los datos en Nivel 1 repetibles
    foreach my $infoNivel2  (@$arrayNivel2Repetibles){

        my $campo = $infoNivel2->getCampo;
        my $subcampo = $infoNivel2->getSubcampo;

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
=cut

1;

