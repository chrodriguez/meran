package C4::AR::Novedades;

use strict;
use HTML::Entities;
require Exporter;
use C4::Modelo::SysNovedad;
use C4::Modelo::SysNovedad::Manager;
use C4::Modelo::SysNovedadNoMostrar;
use C4::Modelo::SysNovedadNoMostrar::Manager;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw( 
    &getNovedadesNoMostrar
    &getUltimasNovedades
    &getNovedad
    &listar
    &agregar
);


sub agregar{

    my ($input) = @_;
    my %params;
    my $novedad = C4::Modelo::SysNovedad->new();

    my $contenido = $input->param('contenido');

#   Escapa codigo HTML
    encode_entities($contenido);
#     C4::AR::Debug::debug($contenido);

    %params = $input->Vars;
    $params{'contenido'} = $contenido;

    return ($novedad->agregar(%params));
}


sub editar{

    my ($input) = @_;
    my %params;
    my $novedad = getNovedad($input->param('novedad_id'));

    use HTML::Entities;
    my $contenido = $input->param('contenido');

    %params = $input->Vars;
    $params{'contenido'} = $contenido;
    $novedad->delete();
    $novedad = C4::Modelo::SysNovedad->new();
    
    return ($novedad->agregar(%params));
}


sub listar{
    my ($ini,$cantR) = @_;
    my $novedades_array_ref = C4::Modelo::SysNovedad::Manager->get_sys_novedad( 
                                                                                sort_by => ['id DESC'],
                                                                                limit   => $cantR,
                                                                                offset  => $ini,
                                                                              );

    #Obtengo la cant total de sys_novedads para el paginador
    my $novedades_array_ref_count = C4::Modelo::SysNovedad::Manager->get_sys_novedad_count();
    if(scalar(@$novedades_array_ref) > 0){
        return ($novedades_array_ref_count, $novedades_array_ref);
    }else{
        return (0,0);
    }
}

=item
    Esta funcion obtiene las novedades que no hay que mostrarle al socio recibido como parametro
=cut
sub getNovedadesNoMostrar{

    my ($nro_socio) = @_;
    
    my @filtros;
    
    push (@filtros, (usuario_novedad => {eq => $nro_socio}) );

    my $novedades_array_ref = C4::Modelo::SysNovedadNoMostrar::Manager->get_sys_novedad_no_mostrar( query => \@filtros,
                                                                              );
    if(scalar(@$novedades_array_ref) > 0){
        return ($novedades_array_ref);
    }else{
        return (0);
    }
}

sub getUltimasNovedades{

    my $novedades_array_ref = C4::Modelo::SysNovedad::Manager->get_sys_novedad( 
                                                                                sort_by => ['id DESC'],
                                                                                limit   => 3,
                                                                              );

    #Obtengo la cant total de sys_novedads para el paginador
    my $novedades_array_ref_count = C4::Modelo::SysNovedad::Manager->get_sys_novedad_count();
    if(scalar(@$novedades_array_ref) > 0){
        return ($novedades_array_ref_count, $novedades_array_ref);
    }else{
        return (0,0);
    }
}

sub getNovedad{

    my ($id_novedad) = @_;
    my @filtros;

    push (@filtros, (id => {eq => $id_novedad}) );
    
    my $novedades_array_ref = C4::Modelo::SysNovedad::Manager->get_sys_novedad( query => \@filtros,
                                                                              );

    #Obtengo la cant total de sys_novedads para el paginador
    if(scalar(@$novedades_array_ref) > 0){
        return ($novedades_array_ref->[0]);
    }else{
        return (0);
    }
}

sub eliminar{

    my ($id_novedad) = @_;
    my @filtros;

    push (@filtros, (id => {eq => $id_novedad}) );
    
    my $novedades_array_ref = C4::Modelo::SysNovedad::Manager->get_sys_novedad( query => \@filtros,
                                                                              );

    #Obtengo la cant total de sys_novedads para el paginador
    if(scalar(@$novedades_array_ref) > 0){
    C4::AR::Debug::debug("que pasa???????????????????");
        return ($novedades_array_ref->[0]->delete());
    }else{
        return (0);
    }
}


1;
