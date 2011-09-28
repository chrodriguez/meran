package C4::Modelo::CatRegistroMarcN2;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_registro_marc_n2',

    columns => [
        id              => { type => 'serial', overflow => 'truncate', not_null => 1 },
        marc_record     => { type => 'text', overflow => 'truncate' },
        id1             => { type => 'integer', overflow => 'truncate', not_null => 1 },
        indice          => { type => 'text', overflow => 'truncate' },
        template        => { type => 'varchar', overflow => 'truncate', not_null => 1 },
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
# use C4::Modelo::CatRegistroMarcN2::Manager qw(get_cat_registro_marc_n2);
use C4::Modelo::CatRegistroMarcN2::Manager;
use C4::Modelo::CatRegistroMarcN2Analitica::Manager;
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

=item sub getTemplate

  retorna el esquema/template utilizado para la carga de datos
=cut
sub getTemplate{
    my ($self)  = shift;

#     return C4::AR::Referencias::obtenerEsquemaById($self->template);
    return $self->template;
}

sub setTemplate{
    my ($self)      = shift;
    my ($template)  = @_;

    $self->template($template);
}

sub getTemplateId{
    my ($self)  = shift;

    return $self->template;
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

sub getIndice{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->indice));
}

sub setIndice{
    my ($self)          = shift;
    my ($indice)   = @_;

    $self->indice($indice);
}

sub tiene_indice {
    my ($self) = shift;

    return (C4::AR::Utilidades::validateString($self->getIndice));	
}

sub agregar{
    my ($self) = shift;
    my ($params, $marc_record, $db)    = @_;

    $self->setId1($params->{'id1'});    
    $self->setMarcRecord($marc_record);
    $self->setTemplate($params->{'id_tipo_doc'});

    my $mr = MARC::Record->new_from_usmarc($marc_record);    

# TODO ver si tiene analica
#     my $cat_registro_n2_analitica = C4::Modelo::CatRegistroMarcN2Analitica->new( db => $db );
#     $cat_registro_n2_analitica->setId2Padre(C4::AR::Catalogacion::getRefFromStringConArrobas($mr->subfield("773","a")));
#     $cat_registro_n2_analitica->setId2Hijo($self->getId2());
#     $cat_registro_n2_analitica->save();

    $self->save();
}

sub modificar{
    my ($self)           = shift;
    my ($marc_record)    = @_;

    $self->setMarcRecord($marc_record);
    
    my $mr = MARC::Record->new_from_usmarc($marc_record);  

# TODO ver si tiene analica
#     my $cat_registro_n2_analitica = C4::Modelo::CatRegistroMarcN2Analitica->new( db => $self->db );
#     $cat_registro_n2_analitica->setId2Padre(C4::AR::Catalogacion::getRefFromStringConArrobas($mr->subfield("773","a")));
#     $cat_registro_n2_analitica->setId2Hijo($self->getId2());
#     $cat_registro_n2_analitica->save();

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

# TODO que se hace con la analítica

    $self->delete();    
}

sub getAnalitica{
    my ($self)      = shift;
     
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
 
#     C4::AR::Debug::debug("getAnalitica =>>>>>>>>>>>>>>> ".$marc_record->subfield("773","a"));

    return C4::AR::Catalogacion::getRefFromStringConArrobas($marc_record->subfield("773","a"));
}

sub getAnaliticas{
    my ($self)      = shift;

#     C4::AR::Debug::debug("C4::AR::CatRegistroMarcN2::getAnaliticas del grupo ".$self->getId2());
    
    my $db = C4::Modelo::CatRegistroMarcN2->new()->db();
    
    my $nivel2_analiticas_array_ref = C4::Modelo::CatRegistroMarcN2Analitica::Manager->get_cat_registro_marc_n2_analitica(
                                                                        db => $db,    
                                                                        query => [ 
                                                                                    cat_registro_marc_n2_id => { eq => $self->getId2() },
                                                                            ]
                                                                );

#     C4::AR::Debug::debug("C4::AR::CatRegistroMarcN2::getAnaliticas => el grupo ".$self->getId2()." tiene ".scalar(@$nivel2_analiticas_array_ref)." analiticas");
  
    if( scalar(@$nivel2_analiticas_array_ref) > 0){
        return ($nivel2_analiticas_array_ref);
    }else{
        return 0;
    }
}

sub getSignaturas{
    my ($self)          = shift;

    my $array_nivel3 = C4::AR::Nivel3::getNivel3FromId2($self->getId2);
    
    my @signaturas;
    
    foreach my $nivel3 (@$array_nivel3){
    	my $signatura_nivel3 = $nivel3->getSignatura;
    	if (!C4::AR::Utilidades::existeInArray($signatura_nivel3,@signaturas)){
            push (@signaturas, $signatura_nivel3);
    	}
    }   
    
    return (\@signaturas);
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
    
    my %result  = {};
    my $isbn            = $self->getISBN();
    if (C4::AR::Utilidades::validateString($isbn)) {
        my $portada     = C4::AR::PortadasRegistros::getPortadaByIsbn($isbn);

        if ($portada){    
            $result{'S'}    = $portada->getSmall();
            $result{'M'}    = $portada->getMedium();
            $result{'L'}    = $portada->getLarge();
            return \%result;    
        }
    }
    
    return undef;
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
# sub getEditor{
#     my ($self)      = shift;
#     
#     my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
# 
#     return $marc_record->subfield("260","b");
# }

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


sub obtenerValorCampo {
  my ($self) = shift;
  my ($campo,$id) = @_;

  my $ref_valores = C4::Modelo::CatRegistroMarcN2::Manager->get_cat_registro_marc_n2
                        ( select   => [$campo],
                          query =>[ id => { eq => $id} ]);

#   C4::AR::Debug::debug("CatRgistroMarcN2 => obtenerValorCampo => campo tabla => ".$campo);
#   C4::AR::Debug::debug("CatRgistroMarcN2 => obtenerValorCampo => id tabla => ".$id);  


  if(scalar(@$ref_valores) > 0){
    return ($ref_valores->[0]->getCampo($campo));
  }else{
    C4::AR::Debug::debug("CatRegistroMarcN2 => obtenerValorCampo => no se pudo recuperar el objeto");
    return 'NO TIENE';
  }
}

sub getCampo{
    my ($self) = shift;
    my ($campo)=@_;
    
    if ($campo eq "id") {return $self->getId2;}
#     if ($campo eq "nombre") {return $self->getNombre;}

    return (0);
}

=head2 sub toMARC_Opac

=cut
sub toMARC_Opac{
    my ($self) = shift;

    #obtengo el marc_record del NIVEL 2
    my $marc_record             = MARC::Record->new_from_usmarc($self->getMarcRecord());

    my $params;
    $params->{'nivel'}          = '2';
    $params->{'id_tipo_doc'}    = $self->getTemplate()||'ALL';
    my $MARC_result_array       = C4::AR::Catalogacion::marc_record_to_opac_view($marc_record, $params,$self->db);

    return ($MARC_result_array);
}


=head2 sub toMARC

=cut
sub toMARC{
    my ($self) = shift;

    #obtengo el marc_record del NIVEL 2
    my $marc_record             = MARC::Record->new_from_usmarc($self->getMarcRecord());

    my $params;
    $params->{'nivel'}          = '2';
    $params->{'id_tipo_doc'}    = $self->getTemplate()||'ALL';
    my $MARC_result_array       = &C4::AR::Catalogacion::marc_record_to_meran_por_nivel($marc_record, $params);

    return ($MARC_result_array);
}

# FIXME dos metodos toMARC??????????? creo q este no se usa
=head2 sub toMARC_Opac

=cut
sub toMARC_Intra{
    my ($self) = shift;

    my $params;
    #obtengo el marc_record del NIVEL 2
    my $marc_record             = MARC::Record->new_from_usmarc($self->getMarcRecord());
    $params->{'nivel'}          = '2';
    $params->{'id_tipo_doc'}    = $self->getTipoDocumento;
    my $MARC_result_array       = C4::AR::Catalogacion::marc_record_to_intra_view($marc_record, $params, $self->db);

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

sub getNroSerie{
    my ($self)      = shift;

    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());

    return $marc_record->subfield("440","v");
}


sub getPais{
    my ($self)      = shift;

    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());

    return $marc_record->subfield("043","c");
}



sub getInvolvedCount{

    my ($self) = shift;
    my ($tabla, $value)= @_;
    
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



sub toString {
    my ($self) = shift;
    my $string="";

    if ($self->getTipoDocumento){
	if($string){$string.=" ";}
	$string.= $self->getTipoDocumentoObject->getNombre." -";
    }
    
    if ($self->getNroSerie){
	if($string){$string.=" ";}
	$string.= $self->getNroSerie;
    }

    if ($self->getEdicion){
	if($string){$string.=" ";}
	$string.= $self->getEdicion;
    }

    if ($self->getVolumen){
	if($string){$string.=" ";}
	$string.= $self->getVolumen;
    }

    if ($self->getAnio_publicacion){
	if($string){$string.=" ";}
	$string.= "(".$self->getAnio_publicacion.")";
    }
    
    return ($string);
}

1;

