package C4::AR::VisualizacionIntra;

#
#Este modulo sera el encargado del manejo de la carga de datos en las tablas MARC
#Tambien en la carga de los items en los distintos niveles.
#

use strict;
require Exporter;
use C4::Context;
use C4::Modelo::CatVisualizacionIntra;
use C4::Modelo::CatVisualizacionIntra::Manager;
use C4::Modelo::CatEstructuraCatalogacion;
use C4::Modelo::CatEstructuraCatalogacion::Manager;
use vars qw($VERSION @EXPORT @ISA);

# set the version for version checking
$VERSION = 0.01;

@ISA=qw(Exporter);

@EXPORT=qw(

	&getConfiguracion
    &deleteConfiguracion

);


sub getConfiguracion{
    my ($ejemplar) = @_;
    my @filtros;

    push ( @filtros, ( or   => [    tipo_ejemplar   => { eq => $ejemplar }, 
                                    tipo_ejemplar   => { eq => 'ALL'     } ]) #TODOS
                );

    my $configuracion = C4::Modelo::CatVisualizacionIntra::Manager->get_cat_visualizacion_intra(query => \@filtros,);

    return ($configuracion);
}

sub addConfiguracion{
    my ($params) = @_;
    my @filtros;

    my $configuracion = C4::Modelo::CatVisualizacionIntra->new();

    $configuracion->agregar($params);
    
    return ($configuracion);
}

sub deleteConfiguracion{
    my ($params) = @_;
    my @filtros;
    my $vista_id = $params->{'vista_id'};

    push (@filtros, (id => { eq => $vista_id }) );
    my $configuracion = C4::Modelo::CatVisualizacionIntra::Manager->get_cat_visualizacion_intra(query => \@filtros,);

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
    my $configuracion = C4::Modelo::CatVisualizacionIntra::Manager->get_cat_visualizacion_intra(query => \@filtros,);

    if ($configuracion->[0]){
        $configuracion->[0]->modificar($value);
        return ( $configuracion->[0]->getVistaIntra() );
    }else{
        return(0);
    }
}

=head2 sub getSubCamposLike
    Obtiene los subcampos haciendo busqueda like, para el nivel indicado
=cut
sub getSubCamposLike{
    my ($campo) = @_;

    my @filtros;

    push(@filtros, ( campo => { eq => $campo} ) );

    my $db_campos_MARC = C4::Modelo::CatEstructuraCatalogacion::Manager->get_cat_estructura_catalogacion(
                                                                query => \@filtros,
                                                                sort_by => ('subcampo'),
                                                                select   => [ 'subcampo', 'liblibrarian', 'obligatorio' ],
                                                                group_by => [ 'subcampo'],
                                                            );
    return($db_campos_MARC);
}

=head2 sub getCamposXLike
    Busca un campo like..., segun nivel indicado
=cut
sub getCamposXLike{
    my ($campoX) = @_;

    my @filtros;

    push(@filtros, ( campo => { like => $campoX.'%'} ) );

    my $db_campos_MARC = C4::Modelo::CatEstructuraCatalogacion::Manager->get_cat_estructura_catalogacion(
                                                                                        query => \@filtros,
                                                                                        sort_by => ('campo'),
                                                                                        select   => [ 'campo', 'liblibrarian'],
                                                                                        group_by => [ 'campo'],
                                                                       );
    return($db_campos_MARC);
}


1;