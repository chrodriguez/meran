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
use vars qw($VERSION @EXPORT_OK @ISA);

# set the version for version checking
$VERSION = 0.01;

@ISA=qw(Exporter);

@EXPORT_OK=qw(
    &updateNewOrder
    &getConfiguracionByOrder
	&getConfiguracion
    &deleteConfiguracion

);

=item
    Funcion que actializa el orden de los campos. 
    Parametros: array con los ids en el orden nuevo
=cut
sub updateNewOrder{
    my ($newOrderArray) = @_;
    my $msg_object      = C4::AR::Mensajes::create();
    
    # ordeno los ids que llegan desordenados primero, para obtener un clon de los ids, y ahora usarlo de indice para el orden
    # esto es porque no todos los campos de cat_visualizacion_intra se muestran en el template a ordenar ( ej 8 y 9 )
    # entonces no puedo usar un simple indice como id.
    my @array = sort { $a <=> $b } @$newOrderArray;
    
    my $i = 0;
    my @filtros;
    
    # hay que hacer update de todos los campos porque si viene un nuevo orden y es justo ordenado (igual que @array : 1,2,3...)
    # tambien hay que actualizarlo
    foreach my $campo (@$newOrderArray){
    
        my $config_temp   = C4::Modelo::CatVisualizacionIntra::Manager->get_cat_visualizacion_intra(
                                                                    query   => [ id => { eq => $campo}], 
                               );
        my $configuracion = $config_temp->[0];
        
#        C4::AR::Debug::debug("nuevo orden de id : ".$campo." es :  ".@array[$i]);
        
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
    my ($ejemplar) = @_;

    my @filtros;
    
    push ( @filtros, ( or   => [    tipo_ejemplar   => { eq => $ejemplar }, 
                                tipo_ejemplar   => { eq => 'ALL'     } ]) #TODOS
    );

    my $configuracion = C4::Modelo::CatVisualizacionIntra::Manager->get_cat_visualizacion_intra(query => \@filtros, sort_by => ('orden'),);

    return ($configuracion);
}


sub getConfiguracion{
    my ($ejemplar) = @_;

    my @filtros;

    push ( @filtros, ( or   => [    tipo_ejemplar   => { eq => $ejemplar }, 
                                    tipo_ejemplar   => { eq => 'ALL'     } ]) #TODOS
                );

    my $configuracion = C4::Modelo::CatVisualizacionIntra::Manager->get_cat_visualizacion_intra(query => \@filtros, sort_by => ('campo, subcampo'),);

    return ($configuracion);
}

sub addConfiguracion{
    my ($params, $db) = @_;
    my @filtros;

    my $configuracion = C4::Modelo::CatVisualizacionIntra->new( db => $db);

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

=head2 sub getVisualizacionFromCampoSubCampo
    Este funcion devuelve la configuracion de la estructura de catalogacion de un campo, subcampo, realizada por el usuario
=cut
sub getVisualizacionFromCampoSubCampo{
    my ($campo, $subcampo, $itemtype) = @_;

    my @filtros;

    push(@filtros, ( campo          => { eq => $campo } ) );
    push(@filtros, ( subcampo       => { eq => $subcampo } ) );
#     push (@filtros,( tipo_ejemplar  => { eq => 'ALL' })); 
    push (  @filtros, ( or   => [   tipo_ejemplar   => { eq => $itemtype }, 
                                    tipo_ejemplar   => { eq => 'ALL'     } ])
                     );


    my $cat_estruct_info_array = C4::Modelo::CatVisualizacionIntra::Manager->get_cat_visualizacion_intra(  
                                                                                query           =>  \@filtros, 

                                        );  

    if(scalar(@$cat_estruct_info_array) > 0){
      return $cat_estruct_info_array->[0];
    }else{
      return 0;
    }
}

sub existeConfiguracion{
    my ($params) = @_;

    my @filtros;

    push(@filtros, ( campo          => { eq => $params->{'campo'} } ));
    push(@filtros, ( subcampo       => { eq => $params->{'subcampo'} } ));
#     push(@filtros, ( tipo_ejemplar  => { eq => $params->{'ejemplar'} } ));
    push ( @filtros, ( or   => [    tipo_ejemplar   => { eq => $params->{'ejemplar'} }, 
                                    tipo_ejemplar   => { eq => 'ALL'     } ]) #TODOS
    );


    my $cat_estruct_info_array = C4::Modelo::CatVisualizacionIntra::Manager->get_cat_visualizacion_intra(  
                                                                                query           =>  \@filtros, 

                                        );  

    if(scalar(@$cat_estruct_info_array) > 0){
      return 1;
    }else{
      return 0;
    }
}

=head2 sub t_agregar_configuracion
   
=cut
sub t_agregar_configuracion {
    my ($params) = @_;

    my $visualizacion_intra = C4::Modelo::CatVisualizacionIntra->new();  
    my $db                  = $visualizacion_intra->db;
    my $msg_object          = C4::AR::Mensajes::create();

    if(existeConfiguracion($params)){

        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U602', 'params' => [$params->{'campo'}, $params->{'subcampo'}, $params->{'ejemplar'}]} ) ;

    } else {
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
    
        eval {

            C4::AR::VisualizacionIntra::addConfiguracion($params, $db);
            $msg_object->{'error'} = 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U604', 'params' => [$params->{'campo'}, $params->{'subcampo'}, $params->{'ejemplar'}]} ) ;

            $db->commit;
        };

        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B432',"INTRA");
            $db->rollback;
            #Se setea error para el usuario
            $msg_object->{'error'} = 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U603', 'params' => [$params->{'campo'}, $params->{'subcampo'}, $params->{'ejemplar'}]} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object);
}



END { }       # module clean-up code here (global destructor)

1;
__END__
