package C4::AR::VisualizacionOpac;

#
#Este modulo sera el encargado del manejo de la carga de datos en las tablas MARC
#Tambien en la carga de los items en los distintos niveles.
#

use strict;
require Exporter;
use C4::Context;
use C4::Modelo::CatVisualizacionOpac;
use C4::Modelo::CatVisualizacionOpac::Manager;

use vars qw($VERSION @EXPORT @ISA);

# set the version for version checking
$VERSION = 0.01;

@ISA=qw(Exporter);

@EXPORT=qw(

	&getConfiguracion

);


sub getConfiguracion{
    my ($perfil) = @_;
    my @filtros;

    $perfil = $perfil || C4::AR::Preferencias->getValorPreferencia('perfil_opac');
    push (@filtros, (id_perfil => { eq => $perfil }) );
    my $configuracion = C4::Modelo::CatVisualizacionOpac::Manager->get_cat_visualizacion_opac(query => \@filtros,);

    return ($configuracion);
}

sub addConfiguracion{
    my ($params) = @_;
    my @filtros;

    my $configuracion = C4::Modelo::CatVisualizacionOpac->new();

    $configuracion->agregar($params);
    
    return ($configuracion);
}

1;