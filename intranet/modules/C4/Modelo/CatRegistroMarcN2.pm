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

sub getISBN
     my ($self)      = shift;
     
     my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
     
 #     C4::AR::Debug::debug("CatRegistroMarcN1 => titulo ".$marc_record->subfield("245","a")); 
 
     return $marc_record->subfield("20","a");
}

=head2
sub getISSN

Funcion que devuelve el issn
=cut

sub getISSN
     my ($self)      = shift;
     
     my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
     
 #     C4::AR::Debug::debug("CatRegistroMarcN1 => titulo ".$marc_record->subfield("245","a")); 
 
     return $marc_record->subfield("22","a");
}

=head2
sub getSeriesTitulo

Funcion que devuelve el series_titulo
=cut

sub getSeriesTitulo
     my ($self)      = shift;
     
     my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
     
 #     C4::AR::Debug::debug("CatRegistroMarcN1 => titulo ".$marc_record->subfield("245","a")); 
 
     return $marc_record->subfield("440","a");
}

=head2
sub getTipoDocumento

Funcion que devuelve el isbn
=cut

sub getTipoDocumento
     my ($self)      = shift;
     
     my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
     
 #     C4::AR::Debug::debug("CatRegistroMarcN1 => titulo ".$marc_record->subfield("245","a")); 
 
     return $marc_record->subfield("910","a");
}



1;

