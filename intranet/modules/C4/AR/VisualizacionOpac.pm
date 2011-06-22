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
use C4::Modelo::CatEstructuraCatalogacion;
use C4::Modelo::CatEstructuraCatalogacion::Manager;
use vars qw($VERSION @EXPORT_OK @ISA);

# set the version for version checking
$VERSION = 0.01;

@ISA=qw(Exporter);

@EXPORT_OK=qw(
    &addConfiguracion
    &updateNewOrder
    &getConfiguracionByOrder
	&getConfiguracion
    &deleteConfiguracion
    &editConfiguracion
    &getSubCamposLike
    &getCamposXLike
    &getVisualizacionFromCampoSubCampo
);


=item
    Funcion que actializa el orden de los campos. 
    Parametros: array con los ids en el orden nuevo
=cut
sub updateNewOrder{
    my ($newOrderArray) = @_;
    my $msg_object      = C4::AR::Mensajes::create();
    
    # ordeno los ids que llegan desordenados primero, para obtener un clon de los ids, y ahora usarlo de indice para el orden
    # esto es porque no todos los campos de cat_visualizacion_opac se muestran en el template a ordenar 
    # entonces no puedo usar un simple indice como id.
    my @array = sort { $a <=> $b } @$newOrderArray;
    
    my $i = 0;
    my @filtros;
    
    # hay que hacer update de todos los campos porque si viene un nuevo orden y es justo ordenado (igual que @array : 1,2,3...)
    # tambien hay que actualizarlo
    foreach my $campo (@$newOrderArray){
    
        my $config_temp = C4::Modelo::CatVisualizacionOpac::Manager->get_cat_visualizacion_opac(
                                                                    query   => [ id => { eq => $campo}], 
                               );
        my $configuracion = $config_temp->[0];
        
#        C4::AR::Debug::debug("nuevo orden de id : ".@array[$i]." es :  ".$campo);
        
        $configuracion->setOrden(@array[$i]);
    
        $i++;
    }
    
    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'M000', 'params' => []} ) ;

    return ($msg_object);
}


=item
    Funcion que devuelve TODOS los campos ordenados por orden
=cut
sub getConfiguracionByOrder{
    my ($perfil) = @_;

    my @filtros;
    
    push ( @filtros, ( or   => [    id_perfil   => { eq => $perfil }, 
                                    id_perfil   => { eq => '0'     } ]) #PERFIL TODOS
                );

    my $configuracion = C4::Modelo::CatVisualizacionOpac::Manager->get_cat_visualizacion_opac(query => \@filtros, sort_by => ('orden'),);

    return ($configuracion);
}


sub getConfiguracion{
    my ($perfil) = @_;
    my @filtros;

    $perfil = $perfil || C4::AR::Preferencias::getValorPreferencia('perfil_opac');

    push ( @filtros, ( or   => [    id_perfil   => { eq => $perfil }, 
                                    id_perfil   => { eq => '0'     } ]) #PERFIL TODOS
                );

    my $configuracion = C4::Modelo::CatVisualizacionOpac::Manager->get_cat_visualizacion_opac(query => \@filtros, sort_by => ('campo, subcampo'),);

    return ($configuracion);
}

sub addConfiguracion {
    my ($params, $db) = @_;

    my @filtros;

    my $configuracion = C4::Modelo::CatVisualizacionOpac->new( db => $db );

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

=head2 sub getVisualizacionFromCampoSubCampo
    Este funcion devuelve la configuracion de la estructura de catalogacion de un campo, subcampo, realizada por el usuario
=cut
sub getVisualizacionFromCampoSubCampo{
    my ($campo, $subcampo, $perfil) = @_;

    my @filtros;

    push(@filtros, ( campo          => { eq => $campo } ) );
    push(@filtros, ( subcampo       => { eq => $subcampo } ) );
#     push (@filtros,( tipo_ejemplar  => { eq => 'ALL' })); 
    push (  @filtros, ( or   => [   id_perfil   => { eq => $perfil } ]) );


    my $cat_estruct_info_array = C4::Modelo::CatVisualizacionOpac::Manager->get_cat_visualizacion_opac(  
                                                                                query           =>  \@filtros, 

                                        );  

    if(scalar(@$cat_estruct_info_array) > 0){
      return $cat_estruct_info_array->[0];
    }else{
      return 0;
    }
}



END { }       # module clean-up code here (global destructor)

1;
__END__
