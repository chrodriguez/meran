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

use C4::Modelo::CircReserva;
use C4::Modelo::CircReserva::Manager;
use MARC::Record; #FIXME creo que esta funcion es interna qw(new_from_usmarc);
use C4::AR::Catalogacion qw(getRefFromStringConArrobas);
use C4::Modelo::CatRegistroMarcN3::Manager qw(get_cat_registro_marc_n3_count);
# use vars qw(@EXPORT_OK @ISA);
# 
# @ISA=qw(Exporter);
# 
# @EXPORT_OK = qw(
#                   &getRefFromStringConArrobas
# );


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
 
     return $marc_record->subfield("020","a");
}

=head2
sub getVolumen

Funcion que devuelve el volumen del grupo
=cut

sub getVolumen{
     my ($self)      = shift;
     
     my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
 
     return $marc_record->subfield("300","a");
}

sub getAllImage {
    my ($self)      = shift;
    
    my %result;
    my $isbn            = $self->getISBN();
    
    if ($isbn) {
        my $portada     = C4::AR::PortadasRegistros::getPortadaByIsbn($isbn);
    
        if($portada){    
            $result{'S'}    = $portada->getSmall();
            $result{'M'}    = $portada->getMedium();
            $result{'L'}    = $portada->getLarge();
        } else {
            $result{'S'}    = '';
            $result{'M'}    = '';
            $result{'L'}    = '';
        }
    }
    
    return \%result;
}

=head2
sub getISSN

Funcion que devuelve el issn
=cut

sub getISSN{
     my ($self)      = shift;
     
     my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());    
 
     return $marc_record->subfield("022","a");
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

sub getNombreSubSerie{
     my ($self)      = shift;
     
     my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());    
 
     return $marc_record->subfield("440","p");
}

sub getNumeroSerie{
     my ($self)      = shift;
     
     my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());    
 
     return $marc_record->subfield("440","v");
}

sub getNotaGeneral{
     my ($self)      = shift;
     
     my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());    
 
     return $marc_record->subfield("500","a");
}

=head2
sub getTipoDocumento

Funcion que devuelve la referencia al tipo de Documento
=cut
sub getTipoDocumento{
    my ($self)      = shift;
    
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
    my $tipo_doc    = $marc_record->subfield("910","a");

#     C4::AR::Debug::debug("CatRegistroMarcN2 => getTipoDocumento => ".$tipo_doc);
#     C4::AR::Debug::debug("CatRegistroMarcN2 => getTipoDocumento => ".C4::AR::Catalogacion::getRefFromStringConArrobas($tipo_doc));
    return C4::AR::Catalogacion::getRefFromStringConArrobas($tipo_doc);
}

=head2
sub getTipoDocumentoObject

Funcion que devuelve un objeto tipo de documento de acuerdo al id de referencia a TipoDocumento que tiene
=cut

sub getTipoDocumentoObject{
    my ($self)      = shift;
        
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
    my $tipo_doc    = C4::AR::Catalogacion::getRefFromStringConArrobas($marc_record->subfield("910","a"));

#     C4::AR::Debug::debug("CatRegistroMarcN2 => getTipoDocumentoObject => ".$tipo_doc);
        
    my $tipo_doc_object = C4::Modelo::CatRefTipoNivel3::Manager->get_cat_ref_tipo_nivel3 ( query => [  'id_tipo_doc' => { eq => $tipo_doc } ] );
        
    if(scalar($tipo_doc_object) > 0){
        return $tipo_doc_object->[0];
    } else {
        C4::AR::Debug::debug("CatRegistroMarcN2 => getTipoDocumentoObject()=> EL OBJECTO (ID) CatRefTipoNivel3 NO EXISTE");
        $tipo_doc = C4::Modelo::CatRefTipoNivel3->new();
    }
    
    return $tipo_doc;
}


sub getEditor{
    my ($self)      = shift;
    
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());

    my $editor      = $marc_record->subfield("260","b");
#     C4::AR::Debug::debug("CatRegistroMarcN2 => getEditor => editor => ".$editor);
    return ($editor);
}

sub getDescripcionFisica{
    my ($self)          = shift;
    
    my $marc_record     = MARC::Record->new_from_usmarc($self->getMarcRecord());
    my $descripcion     = $marc_record->subfield("300","a");
#     C4::AR::Debug::debug("CatRegistroMarcN2 => getDescripcionFisica => $descripcion => ".$$descripcion);
    return ($descripcion);
}

=head2 sub getSoporte

=cut
sub getSoporte{
    my ($self)      = shift;
    
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());

    my $soporte     = $marc_record->subfield("245","h");
#     C4::AR::Debug::debug("CatRegistroMarcN2 => getSoporte => soporte => ".$soporte);
    return $soporte;
}

=head2 getSoporteObject

=cut
sub getSoporteObject{
    my ($self)          = shift;
     
    my $marc_record     = MARC::Record->new_from_usmarc($self->getMarcRecord());
    my $ref             = C4::AR::Catalogacion::getRefFromStringConArrobas($self->getSoporte());
     
    my $soporte_object  = C4::Modelo::RefSoporte->getByPk($ref);
        
    if(!$soporte_object){
            C4::AR::Debug::debug("CatRegistroMarcN2 => getSoporteObject()=> EL OBJECTO (ID) RefSoporte NO EXISTE => ".$ref);
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

=head2 sub getEditor
Recupera la Editor segun el MARC 260,b
=cut
sub getEditor{
    my ($self)      = shift;
    
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());

    return $marc_record->subfield("260","b");
}

=head2 getCiudadObject

=cut
sub getCiudadObject{
    my ($self)          = shift;
     
    my $marc_record     = MARC::Record->new_from_usmarc($self->getMarcRecord());
    my $ref             = C4::AR::Catalogacion::getRefFromStringConArrobas($self->getCiudadPublicacion);
     
    my $ciudad_object   = C4::Modelo::RefLocalidad->getByPk($ref);
        
    if(!$ciudad_object){
            C4::AR::Debug::debug("CatRegistroMarcN2 => getCiudadObject()=> EL OBJECTO (ID) RefLocalidad NO EXISTE");
            $ciudad_object = C4::Modelo::RefLocalidad->new();
    }

    return $ciudad_object;
}

=head2 sub getIdioma
Recupera el Idioma segun el MARC 041,h
=cut
sub getIdioma{
    my ($self)      = shift;
    
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());

    return $marc_record->subfield("041","h");
}

=head2 sub getIdiomaObject
    Recupera el objeto 
=cut
sub getIdiomaObject{
    my ($self)          = shift;
     
    my $marc_record     = MARC::Record->new_from_usmarc($self->getMarcRecord());
    my $ref             = C4::AR::Catalogacion::getRefFromStringConArrobas($self->getIdioma());
     
#     C4::AR::Debug::debug("CatRegistroMarcN2 => getIdioma => ".$self->getIdioma());
#     C4::AR::Debug::debug("CatRegistroMarcN2 => getIdiomaObject()=> ref => ".$ref);
    my $idioma_object   = C4::Modelo::RefIdioma->getByPk($ref);

        
    if(!$idioma_object){
            C4::AR::Debug::debug("CatRegistroMarcN2 => getIdiomaObject()=> EL OBJECTO (ID) RefIdioma NO EXISTE");
            $idioma_object = C4::Modelo::RefIdioma->new();
    }

    return $idioma_object;
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
    my $marc_record             = MARC::Record->new_from_usmarc($self->getMarcRecord());

    my $params;
    $params->{'nivel'}          = '2';
    $params->{'id_tipo_doc'}    = $self->getTipoDocumento;
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

    #obtengo el marc_record del NIVEL 2
    my $marc_record             = MARC::Record->new_from_usmarc($self->getMarcRecord());


    my $params;
    $params->{'nivel'} = '2';
    $params->{'id_tipo_doc'}    = $self->getTipoDocumento;
    my $MARC_result_array       = &C4::AR::Catalogacion::marc_record_to_opac_view($marc_record, $params);

#     my $orden = 'orden';
#     my @return_array_sorted = sort{$b->{$orden} cmp $a->{$orden}} @$MARC_result_array;
# 
#     return (\@return_array_sorted);

    return ($MARC_result_array);
}


=head2 sub toMARC_Opac

=cut
sub toMARC_Intra{
    my ($self) = shift;

    my $params;
    #obtengo el marc_record del NIVEL 2
    my $marc_record             = MARC::Record->new_from_usmarc($self->getMarcRecord());
    $params->{'nivel'}          = '2';
    $params->{'id_tipo_doc'}    = $self->getTipoDocumento;
    my $MARC_result_array       = &C4::AR::Catalogacion::marc_record_to_intra_view($marc_record, $params);

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

sub getPais{
    my ($self)      = shift;

    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());

    return $marc_record->subfield("043","c");
}



sub getInvolvedCount{

    my ($self) = shift;
    my ($tabla, $value)= @_;
    
   C4::AR::Debug::debug("InvolvedCount en Nivel2 =========> TABLA $tabla VALUE $value");
    my ($filter_string,$filtros) = $self->getInvolvedFilterString($tabla, $value);
    my $cat_registro_marc_n2_count = C4::Modelo::CatRegistroMarcN2::Manager->get_cat_registro_marc_n2_count( query => $filtros );

    return ($cat_registro_marc_n2_count);
}


sub getReferenced{

    my ($self) = shift;
    my ($tabla, $value)= @_;

    my ($filter_string,$filtros) = $self->getInvolvedFilterString($tabla, $value);

    my $cat_registro_marc_n2 = C4::Modelo::CatRegistroMarcN2::Manager->get_cat_registro_marc_n2( query => $filtros );
    return ($cat_registro_marc_n2);
}


1;

