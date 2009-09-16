package C4::AR::Estantes;

use strict;
require Exporter;
use DBI;
use C4::AR::Utilidades;
use vars qw(@ISA @EXPORT);
=head1 NAME

C4::AR::Estantes- Funciones para manipular los estantes Virtuales

=head1 SYNOPSIS

  use C4::AR::Estantes;

=head1 DESCRIPTION

Este módulo provee funciones para manipular estantes virtuales, incluyendo la creación y el borrado de estantes, y el alta y baja de contenido de un estante.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(
		&getListaEstantesPublicos
        &getEstante
        &getSubEstantes
);

sub getListaEstantesPublicos {

    use C4::Modelo::CatEstante;
    use C4::Modelo::CatEstante::Manager;
    my @filtros;
    push(@filtros, ( tipo    => { eq => 'public'}));
    push(@filtros, ( padre  => { eq => 0} ));

    my $estantes_array_ref = C4::Modelo::CatEstante::Manager->get_cat_estante( query => \@filtros);

    return ($estantes_array_ref);
}

sub getSubEstantes {
    my ($id_estante) = @_;

    use C4::Modelo::CatEstante;
    use C4::Modelo::CatEstante::Manager;
    my @filtros;
    push(@filtros, ( padre  => { eq => $id_estante} ));
    my $estantes_array_ref = C4::Modelo::CatEstante::Manager->get_cat_estante( query => \@filtros);

    return ($estantes_array_ref);
}

sub getEstante {
    my ($id_estante) = @_;

    use C4::Modelo::CatEstante;
    use C4::Modelo::CatEstante::Manager;
    my ($estante) = C4::Modelo::CatEstante->new(id => $id_estante);
    $estante->load();

    return ($estante);
}
1;

