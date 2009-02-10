package C4::Modelo::PrefTablaReferencia;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'pref_tabla_referencia',

    columns => [
        id      => { type => 'serial'},
        nombre_tabla => { type => 'varchar', length => 30, not_null => 1 },
        alias_tabla  => { type => 'varchar', length => 20, not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],
);


sub getAliasForTable{
    use C4::Modelo::PrefTablaReferencia::Manager;
    my ($self) = shift;
    my ($nombre_tabla) = @_;
    
    my $db = C4::Modelo::PrefTablaReferencia::Manager->get_pref_tabla_referencia(
                                                                                query => [ 
                                                                                           nombre_tabla => { eq  => $nombre_tabla } ,
                                                                                         ],
                                                                            );
    return ($db->[0]->getAlias_tabla);
}


#SE REDEFINE createFromAlias PORQUE ES QUIEN DEFINE CUAL ES LA PRIMER CLASE (TABLA) DE LA CADENA

#EL ORDEN DE LA CADENA ESTA COMPRENDIDO POR: 

# cat_autor -> cat_ref_tipo_nivel3 -> pref_unidad_informacion -> ref_idioma -> ref_pais -> ref_disponibilidad -> circ_ref_tipo_prestamo -> ref_soporte -> ref_nivel_bibliografico -> cat_tema

sub createFromAlias{

    my ($self)=shift;
    my $classAlias = shift;
    my $firstTable = C4::Modelo::CatAutor->new();
       return( $firstTable->createFromAlias($classAlias) );
}

sub getId{
    my ($self) = shift;
    return ($self->id);
}


sub getNombre_tabla{
    my ($self) = shift;
    return ($self->nombre_tabla);
}

sub setNombre_tabla{
    my ($self) = shift;
    my ($nombre_tabla) = @_;
    $self->nombre_tabla($nombre_tabla);
}

sub getAlias_tabla{
    my ($self) = shift;
    return ($self->alias_tabla);
}

sub setAlias_tabla{
    my ($self) = shift;
    my ($alias_tabla) = @_;
    $self->alias_tabla($alias_tabla);
}

1;

