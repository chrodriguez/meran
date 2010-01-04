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
    &deleteConfiguracion

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

sub deleteConfiguracion{
    my ($params) = @_;
    my @filtros;
    my $vista_id = $params->{'vista_id'};

    push (@filtros, (id => { eq => $vista_id }) );
    my $configuracion = C4::Modelo::CatVisualizacionOpac::Manager->get_cat_visualizacion_opac(query => \@filtros,);

    if ($configuracion->[0]){
        return ( $configuracion->[0]->delete() );
    }else{
        return(0);
    }
}

sub editConfiguracion{
    my ($vista_id,$value) = @_;
    my @filtros;

    push (@filtros, (id => { eq => $vista_id }) );
    my $configuracion = C4::Modelo::CatVisualizacionOpac::Manager->get_cat_visualizacion_opac(query => \@filtros,);

    if ($configuracion->[0]){
        $configuracion->[0]->modificar($value);
        return ( $configuracion->[0]->getVistaOpac() );
    }else{
        return(0);
    }
}

1;