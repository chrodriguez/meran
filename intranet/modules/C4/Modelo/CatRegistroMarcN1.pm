package C4::Modelo::CatRegistroMarcN1;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_registro_marc_n1',

    columns => [
        id             => { type => 'serial', not_null => 1 },
        marc_record    => { type => 'text' },
    ],

    primary_key_columns => [ 'id' ]
);

sub getId1{
    my ($self)  = shift;

    return $self->id;
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

sub getSignaturas{
    my ($self)          = shift;
    
    use C4::Modelo::CatRegistroMarcN2;
    
    my $array_nivel2 = C4::AR::Nivel2::getNivel2FromId1($self->getId1,$self->db);
    
    my @signaturas;
    
    foreach my $nivel2 (@$array_nivel2){
    	my $signaturas_nivel2 = $nivel2->getSignaturas;
    	push (@signaturas, @$signaturas_nivel2);
    }	
    
    return (\@signaturas);
}

=item
  sub setearLeader

  setea el LEADER según lo indicado desde el cliente
=cut
# TODO getter y setter de cada bit
sub setearLeader {
    my ($self)      = shift;
    my ($params)    = @_;

    my $nivel_bibliografico = C4::Modelo::RefNivelBibliografico->getByPk($params->{'id_nivel_bibliografico'});
    my $marc_record         = MARC::Record->new_from_usmarc($self->getMarcRecord()); 

# FIXME no me funciona el substr con reemplazo
    my $leader = substr($marc_record->leader(), 0, 7).$nivel_bibliografico->getCode().substr($marc_record->leader(), 8, 24);
    #seteo el nuevo LEADER
    $marc_record->leader($leader);
    C4::AR::Debug::debug("CatRegistroMarcN1 => setearLeader !!!!!!!!!!!!! ".$marc_record->leader());
    $self->setMarcRecord($marc_record->as_usmarc);

    $self->save();
}

sub agregar{
    my ($self)                  = shift;
    my ($marc_record, $params)  = @_;

    $self->setMarcRecord($marc_record);
    $self->save();

    #seteo datos del LEADER
    $self->setearLeader($params);

    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
#     C4::AR::Debug::debug("CatRegistroMarcN1 => agregar => LEADER guardado !!!!!!!!!!!!! ".$marc_record->leader());
}

sub modificar{
    my ($self)                  = shift;
    my ($marc_record, $params)  = @_;

    $self->setMarcRecord($marc_record);
    $self->save();

    #seteo datos del LEADER
    $self->setearLeader($params);
    
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
#     C4::AR::Debug::debug("CatRegistroMarcN1 => agregar => LEADER modificado !!!!!!!!!!!!! ".$marc_record->leader());
}


sub eliminar{
    my ($self)      = shift;
    my ($params)    = @_;

    #HACER ALGO SI ES NECESARIO

    my ($nivel2) = C4::AR::Nivel2::getNivel2FromId1($self->getId1(), $self->db);

    foreach my $n2 (@$nivel2){
      $n2->eliminar();
    }

    $self->delete();    
}

sub getCDU{
    my ($self)      = shift;
    
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
    
#     C4::AR::Debug::debug("CatRegistroMarcN1 => CDU ".$marc_record->subfield("080","a")); 

    return $marc_record->subfield("080","a");
}

# sub getAutoresSecundarios{
#     my ($self)      = shift;
#     
#     my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
#     
# #     C4::AR::Debug::debug("CatRegistroMarcN1 => autores secundarios ".$marc_record->subfield("700","a")); 
# 
#     return $marc_record->subfield("700","a");
# }

# sub getAutoresSecundariosObject{
#     my ($self)      = shift;
#     
#     #obtengo la referencia del autor secundario
#     my $ref_autor   = $self->getAutoresSecundarios();
#     my $ref         = C4::AR::Catalogacion::getRefFromStringConArrobas($ref_autor);
# #     C4::AR::Debug::debug("CatRegistroMarcN1 => getAutorObject()=> ref_autor => ".$ref_autor);
# #     C4::AR::Debug::debug("CatRegistroMarcN1 => getAutorObject()=> ref => ".$ref);
# 
#     my $autor       = C4::Modelo::CatAutor->getByPk($ref);
# 
#     if(!$autor){
#         C4::AR::Debug::debug("CatRegistroMarcN1 => getAutoresSecundariosObject()=> EL OBJECTO (ID) AUTOR NO EXISTE");
#         $autor = C4::Modelo::CatAutor->new();
#     }
# 
#     return ($autor);
# }

sub getAutoresSecundarios{
    my ($self)      = shift;
    
    my @colaboradores_array;
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
    my $autor;
    

    my @campos_array = $marc_record->field("700");
    
    foreach my $campo (@campos_array){
        my $ref         = C4::AR::Catalogacion::getRefFromStringConArrobas($campo->subfield("a"));
        my $colaborador = C4::Modelo::CatAutor->getByPk($ref);
        
        if ($campo->subfield("e")) {
            $autor = $colaborador->getCompleto()." (".$campo->subfield("e").")";
        }

        push (@colaboradores_array, $autor);
    }

    return (@colaboradores_array);
}

sub getTemas{
    my ($self)      = shift;
    
    my @temas;
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
    

    my @campos_array = $marc_record->field("650");
    
    foreach my $campo (@campos_array){
#         C4::AR::Debug::debug("CatRegistroMarcN1 => getTemas ".$campo->subfield("a")); 
        my $ref     = C4::AR::Catalogacion::getRefFromStringConArrobas($campo->subfield("a"));
        my $tema    = C4::Modelo::CatTema->getByPk($ref);

        push (@temas, $tema)
    }

    return (@temas);
}


sub getTema{
    my ($self)      = shift;
    
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
    
#     C4::AR::Debug::debug("CatRegistroMarcN1 => temas ".$marc_record->subfield("700","a")); 

    return $marc_record->subfield("650","a");
}

sub getTemaObject{
    my ($self)      = shift;
    
    #obtengo la referencia del autor secundario
    my $ref_tema   = $self->getTema();
    my $ref         = C4::AR::Catalogacion::getRefFromStringConArrobas($ref_tema);
#     C4::AR::Debug::debug("CatRegistroMarcN1 => getTemasObject()=> ref_tema => ".$ref_tema);
#     C4::AR::Debug::debug("CatRegistroMarcN1 => getTemasObject()=> ref => ".$ref);

    my $autor       = C4::Modelo::CatTema->getByPk($ref);

    if(!$autor){
        C4::AR::Debug::debug("CatRegistroMarcN1 => getTemasObject()=> EL OBJECTO (ID) TEMA NO EXISTE");
        $autor = C4::Modelo::CatTema->new();
    }

    return ($autor);
}

sub getNombreGeografico{
    my ($self)      = shift;
    
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
    
#     C4::AR::Debug::debug("CatRegistroMarcN1 => nombre geografico ".$marc_record->subfield("651","a")); 

    return $marc_record->subfield("651","a");
}

sub getNombreGeograficoObject{
    my ($self)      = shift;
    
    #obtengo la referencia del autor secundario
    my $ref_pais    = $self->getNombreGeografico();
    my $ref         = C4::AR::Catalogacion::getRefFromStringConArrobas($ref_pais);
#     C4::AR::Debug::debug("CatRegistroMarcN1 => getNombreGeograficoObject()=> ref_tema => ".$ref_pais);
#     C4::AR::Debug::debug("CatRegistroMarcN1 => getNombreGeograficoObject()=> ref => ".$ref);

    my $pais        = C4::Modelo::RefPais::Manager->get_ref_pais ( 
                                                                      query     => [  'iso' => { eq => $ref } ]
                                                        );

    if(!$pais){
        C4::AR::Debug::debug("CatRegistroMarcN1 => getNombreGeograficoObject()=> EL OBJECTO (ID) PAIS NO EXISTE");
        $pais = C4::Modelo::RefPais->new();

        return ($pais);
    } else {
        return ($pais->[0]);
    }

    
}


sub getTerminoNoControlado{
    my ($self)      = shift;
    
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
    
#     C4::AR::Debug::debug("CatRegistroMarcN1 => termino no contralado ".$marc_record->subfield("653","a")); 

    return $marc_record->subfield("653","a");
}

sub getEntradaNoControlado{
    my ($self)      = shift;
    
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
    
#     C4::AR::Debug::debug("CatRegistroMarcN1 => entrada no contralado ".$marc_record->subfield("720","a")); 

    return $marc_record->subfield("720","a");
}

sub getTitulo{
    my ($self)      = shift;
    
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
    
#     C4::AR::Debug::debug("CatRegistroMarcN1 => titulo ".$marc_record->subfield("245","a")); 

    return $marc_record->subfield("245","a");
}

sub getAutorObject{
    my ($self)      = shift;
    
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
    
    #obtengo la referencia al autor
    my $ref_autor   = $marc_record->subfield("100","a");
    my $ref         = C4::AR::Catalogacion::getRefFromStringConArrobas($ref_autor);
#     C4::AR::Debug::debug("CatRegistroMarcN1 => getAutorObject()=> ref => ".$ref_autor);

    my $autor       = C4::Modelo::CatAutor->getByPk($ref);

    if(!$autor){
        C4::AR::Debug::debug("CatRegistroMarcN1 => getAutorObject()=> EL OBJECTO (ID) AUTOR NO EXISTE");
        $autor = C4::Modelo::CatAutor->new();
    }

    return ($autor);
}

=head2 sub getAutor
  Devuelve solo el completo del autor
=cut
sub getAutor{
    my ($self)      = shift;
    
    my $autor = $self->getAutorObject();

    return ($autor->getCompleto());
}

=head2 sub getNivelBibliografico
Recupera el Nivel Bibliografico (el code), bit 7 del LEADER
=cut
sub getNivelBibliografico{
    my ($self)      = shift;

# bit 7 del Leader    
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());

#     C4::AR::Debug::debug("CatRegistroMarcN1 => getNivelBibliografico => LEADER !!!!!!!!!!!!!!!! ".substr ($marc_record->leader(),7,1));
    return substr ($marc_record->leader(),7,1);
}

sub getNivelBibliograficoObject{
    my ($self)      = shift;
    
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
    my $code        = $self->getNivelBibliografico();

    my $nivel_bibliografico = C4::Modelo::RefNivelBibliografico::Manager->get_ref_nivel_bibliografico( query => [ code => { eq => $code }]);
   

    return ($nivel_bibliografico->[0]);
}

=head2 sub toMARC

=cut
sub toMARC{
    my ($self) = shift;

    #obtengo el marc_record del NIVEL 2
    my $marc_record         = MARC::Record->new_from_usmarc($self->getMarcRecord());

    my $params;
    $params->{'nivel'}          = '1';
    $params->{'id_tipo_doc'}    = 'ALL';
    my $MARC_result_array       = &C4::AR::Catalogacion::marc_record_to_meran_por_nivel($marc_record, $params);


#     my $MARC_result_array   = &C4::AR::Catalogacion::marc_record_to_meran($marc_record);

#     foreach my $m (@$MARC_result_array){
#         C4::AR::Debug::debug("campo => ".$m->{'campo'});
#         foreach my $s (@{$m->{'subcampos_array'}}){
#             C4::AR::Debug::debug("liblibrarian => ".$s->{'subcampo'});        
#             C4::AR::Debug::debug("liblibrarian => ".$s->{'liblibrarian'});        
#         }
#     }

    return ($MARC_result_array);
}


=head2 sub toMARC_Opac

=cut
sub toMARC_Opac{
    my ($self) = shift;

    #obtengo el marc_record del NIVEL 1
    my $marc_record             = MARC::Record->new_from_usmarc($self->getMarcRecord());


    my $params;
    $params->{'nivel'}          = '1';
    $params->{'id_tipo_doc'}    = 'ALL';
    my $MARC_result_array       = &C4::AR::Catalogacion::marc_record_to_opac_view($marc_record, $params);

#     my $orden = 'orden';
#     my @return_array_sorted = sort{$b->{$orden} cmp $a->{$orden}} @$MARC_result_array;
# 
#     return (\@return_array_sorted);

    return ($MARC_result_array);
}

=head2 sub toMARC_Intra

=cut
sub toMARC_Intra{
    my ($self) = shift;

    #obtengo el marc_record del NIVEL 1
    my $marc_record             = MARC::Record->new_from_usmarc($self->getMarcRecord());


    my $params;
    $params->{'nivel'}          = '1';
    $params->{'id_tipo_doc'}    = 'ALL';
    my $MARC_result_array       = &C4::AR::Catalogacion::marc_record_to_intra_view($marc_record, $params);

    return ($MARC_result_array);
}

=head2 sub getGrupos
    Recupero todos los grupos del nivel 1.
    Retorna la referencia a un arreglo de objetos
=cut
sub getGrupos {
    my ($self) = shift;

    #recupero todos los grupos de nivel 1 
    my ($nivel2_object_array) = C4::Modelo::CatRegistroMarcN2::Manager->get_cat_registro_marc_n2( 
                                                                        query => [ id => { eq => $self->getId1 } ]
                                                                   );
    return $nivel2_object_array;
}

=head2 sub tienePrestamos
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

sub getInvolvedCount{

    my ($self) = shift;
    my ($tabla, $value)= @_;

    my ($filter_string,$filtros) = $self->getInvolvedFilterString($tabla, $value);
    my $cat_registro_marc_n1_count = C4::Modelo::CatRegistroMarcN1::Manager->get_cat_registro_marc_n1_count( query => $filtros );

    return ($cat_registro_marc_n1_count);
}



sub getReferenced{

    my ($self) = shift;
    my ($tabla, $value)= @_;
   C4::AR::Debug::debug("getReferenced en Nivel1 =========> TABLA $tabla VALUE $value");

    my ($filter_string,$filtros) = $self->getInvolvedFilterString($tabla, $value);

    my $cat_registro_marc_n1 = C4::Modelo::CatRegistroMarcN1::Manager->get_cat_registro_marc_n1( query => $filtros );
    return ($cat_registro_marc_n1);
}


1;

