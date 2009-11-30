package C4::Modelo::CatRegistroMarcN3;

use strict;

=head1 NAME

 C4::Modelo::CatRegistroMarcN3- Funciones que manipulan datos del catálogo a nivel 3

=head1 SYNOPSIS

  use C4::Modelo::CatRegistroMarcN3;

=head1 DESCRIPTION

Modulo para manejar objetos del ORM de los datos del nivel3 del catalogo

=head1 FUNCTIONS

=over 2
=cut

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_registro_marc_n3',

    columns => [
        id              => { type => 'serial', not_null => 1 },
        marc_record     => { type => 'text' },
        id1             => { type => 'integer', not_null => 1 },
        id2             => { type => 'integer', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

    relationships => [
        cat_registro_marc_n1  => {
            class       => 'C4::Modelo::CatRegistroMarcN1',
            key_columns => { id1 => 'id' },
            type        => 'one to one',
        },

        cat_registro_marc_n2  => {
            class       => 'C4::Modelo::CatRegistroMarcN2',
            key_columns => { id2 => 'id' },
            type        => 'one to one',
        },
    ],
);

=head2
sub getId3

Obteniendo el id del elemento
=cut

sub getId3{
    my ($self)  = shift;

    return $self->id;
}

=head2
sub getId2

Obteniendo el id2 al que pertenece el elemento de nivel3
=cut


sub getId2{
    my ($self)  = shift;

    return $self->id;
}

=head2
sub getId1

Obteniendo el id1 al que pertenece el elemento de nivel3
=cut


sub getId1{
    my ($self)  = shift;

    return $self->id;
}

=head2
sub getId1

Setea el id1 al que pertenece el elemento de nivel3
=cut

sub setId1{
    my ($self)  = shift;
    my ($id1)   = @_;

    $self->id1($id1);
}

=head2
sub setId2

Setea el id2 al que pertenece el elemento de nivel3
=cut

sub setId2{
    my ($self)  = shift;
    my ($id2)   = @_;

    $self->id2($id2);
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
    my ($db, $params)    = @_;

    $self->setId2($params->{'id2'});
    $self->setId1($params->{'id1'});
    $self->setMarcRecord($params->{'marc_record'});

    $self->save();
}

sub getBarcode{
    my ($self)      = shift;

    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());

    return C4::AR::Utilidades::trim($marc_record->subfield("995","f"));
}

sub getSignatura_topografica{
    my ($self)      = shift;

    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());

    return C4::AR::Utilidades::trim($marc_record->subfield("995","t"));
}


sub getId_ui_origen{
    my ($self)      = shift;

    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());

    return C4::AR::Utilidades::trim($marc_record->subfield("995","d"));
}

sub getId_ui_poseedora{
    my ($self)      = shift;

    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());

    return C4::AR::Utilidades::trim($marc_record->subfield("995","c"));
}

sub getIdEstado{
    my ($self)      = shift;

    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());

    return C4::AR::Utilidades::trim($marc_record->subfield("995","e"));
}

sub getEstadoObject{
    my ($self)      = shift;

    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
     
    my $estado      = C4::AR::Referencias::getNombreEstado($self->getIdEstado());
        
    if(!$estado){
            C4::AR::Debug::debug("CatRegistroMarcN3 => getEstadoObject()=> EL OBJECTO (ID) RefEstado NO EXISTE");
            $estado = C4::Modelo::RefEstado->new();
    }

    return C4::AR::Utilidades::trim($estado);
}

sub getIdDisponibilidad{
    my ($self)      = shift;

    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());

    return C4::AR::Utilidades::trim($marc_record->subfield("995","o"));
}

sub getDisponibilidadObject{
    my ($self)              = shift;

    my $marc_record         = MARC::Record->new_from_usmarc($self->getMarcRecord());
     
    my $disponibilidad      = C4::AR::Referencias::getNombreDisponibilidad($self->getIdDisponibilidad());
        
    if(!$disponibilidad){
            C4::AR::Debug::debug("CatRegistroMarcN3 => getDisponibilidadObject()=> EL OBJECTO (ID) RefDisponibilidad NO EXISTE");
            $disponibilidad = C4::Modelo::RefDisponibilidad->new();
    }

    return C4::AR::Utilidades::trim($disponibilidad);
}

sub estaPrestado {
    my ($self) = shift;

    return (C4::AR::Prestamos::estaPrestado($self->getId3));
}

sub getEstado{
    my ($self) = shift;

    return (C4::AR::Referencias::getNombreEstado($self->getIdEstado));
}

sub estadoDisponible{
    my ($self) = shift;

    return (C4::AR::Referencias::getNombreEstado($self->getIdEstado) eq "Disponible");
}

sub esParaSala{
    my ($self) = shift;

    return (C4::AR::Referencias::getNombreDisponibilidad($self->getIdEstado) eq "Sala de Lectura");
}


1;

