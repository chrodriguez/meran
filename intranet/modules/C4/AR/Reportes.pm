package C4::AR::Reportes;

use strict;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(

    &getReportFilter
);


sub getReportFilter{
    my ($params) = @_;

    my $tabla_ref = C4::Modelo::PrefTablaReferencia->new();
    my $alias_tabla = $params->{'alias_tabla'};

    $tabla_ref->createFromAlias($alias_tabla);
    

}