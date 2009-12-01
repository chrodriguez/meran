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
        cat_registro_marc_n1  => {
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
    my ($params)    = @_;

    $self->setId1($params->{'id1'});    
    $self->setMarcRecord($params->{'marc_record'});

    $self->save();
}

=head2
sub getISBN

Funcion que devuelve el isbn
=cut

sub getISBN{
     my ($self)      = shift;
     
     my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
     
 #     C4::AR::Debug::debug("CatRegistroMarcN1 => titulo ".$marc_record->subfield("245","a")); 
 
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
 
    return $marc_record->subfield("910","a");
}

=head2
sub getTipoDocumentoObject

Funcion que devuelve un objeto tipo de documento de acuerdo al id de referencia a TipoDocumento que tiene
=cut

sub getTipoDocumentoObject{
    my ($self)      = shift;
     
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
     
    my $tipo_doc    = C4::AR::Referencias::getTipoDocumentoObject($self->getTipoDocumento());
        
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

    return $marc_record->subfield("245","h");
}

=head2 getSoporteObject

=cut
sub getSoporteObject{
    my ($self)          = shift;
     
    my $marc_record     = MARC::Record->new_from_usmarc($self->getMarcRecord());
     
    my $soporte_object  = C4::AR::Referencias::getSoporteObject($self->getSoporte());
        
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
     
    my $ciudad_object   = C4::AR::Referencias::getCiudadObject($self->getSoporte());
        
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
    my ($self)      = shift;
     
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
     
    my $tipo_doc    = C4::AR::Referencias::getSoporteObject($self->getSoporte());
        
    if(!$tipo_doc){
            C4::AR::Debug::debug("CatRegistroMarcN2 => getSoporteObject()=> EL OBJECTO (ID) RefSoporte NO EXISTE");
            $tipo_doc = C4::Modelo::RefIdioma->new();
    }

    return $tipo_doc;
}

=head2 sub getNivelBibliografico
Recupera el Nivel Bibliografico segun el MARC ?,?
=cut
sub getNivelBibliografico{
    my ($self)      = shift;
    
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());

    return $marc_record->subfield("041","a");
}

=head2 sub getNivelBibliograficoObject
    Recupera el objeto 
=cut
sub getNivelBibliograficoObject{
    my ($self)      = shift;
     
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
     
    my $nivel_bibliografico_objecto = C4::AR::Referencias::getNivelBibliograficoObject($self->getNivelBibliografico());
        
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



1;

