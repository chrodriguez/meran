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

sub agregar{
    my ($self)      = shift;
    my ($params)    = @_;


    $self->setMarcRecord($params->{'marc_record'});
    $self->save();
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
    my $ref_autor = $marc_record->subfield("110","a");

    C4::AR::Debug::debug("ref_autor ================================".$ref_autor);

    my $autor = C4::AR::Referencias::getAutor($ref_autor);

    if(!$autor){
        C4::AR::Debug::debug("CatRegistroMarcN1 => getAutorObject()=> EL OBJECTO (ID) AUTOR NO EXISTE");
        $autor = C4::Modelo::CatAutor->new();
    }

    return ($autor);
}


sub toMARC{
    my ($self)      = shift;

    my %hash;
    my @marc_array;

    $hash{'campo'}      = '110';
    $hash{'subcampo'}   = 'a';
    $hash{'header'}     = "NO SE";
    $hash{'dato'}       = $self->getAutorObject()->getCompleto();
    $hash{'id1'}        = $self->getId1;
    my $estructura      = C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($hash{'campo'}, $hash{'subcampo'});

    if($estructura){
        $hash{'liblibrarian'}   = $estructura->getLiblibrarian;
    }

    push (@marc_array, \%hash);
    my %hash;

    $hash{'campo'}      = '245';
    $hash{'subcampo'}   = 'a';
    $hash{'header'}     = "NO SE";
    $hash{'dato'}       = $self->getTitulo();
    $hash{'id1'}        = $self->getId1;
    my $estructura      = C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($hash{'campo'}, $hash{'subcampo'});

    if($estructura){
        $hash{'liblibrarian'} = $estructura->getLiblibrarian;
    }

    push (@marc_array, \%hash);
    
    return (\@marc_array);
}

1;

