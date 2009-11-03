package C4::AR::BusquedasFullText;


use strict;
require Exporter;
use C4::Context;
use Date::Manip;
use C4::Date;
use C4::AR::Catalogacion;
use C4::AR::Utilidades;
use C4::AR::Reservas;
use C4::AR::Nivel1;
use C4::AR::Nivel2;
use C4::AR::Nivel3;
use C4::AR::PortadasRegistros;


use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(
		&busquedaAvanzada
);

sub test{
   use Sphinx::Search;

    $sphinx = Sphinx::Search->new();

    $results = $sphinx->SetMatchMode(SPH_MATCH_ALL)
                                    ->SetSortMode(SPH_SORT_RELEVANCE)
                                    ->Query("Ahorro");

    
}

1;
__END__
