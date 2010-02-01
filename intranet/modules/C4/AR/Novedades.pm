package C4::AR::Novedades;

use strict;
require Exporter;
use C4::Modelo::SysNovedad;
use C4::Modelo::SysNovedad::Manager;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw( 

    &getUltimasNovedades
    &getNovedad
    &listar
    &agregar
);


sub agregar{

    my ($input) = @_;
    my %params;
    my $novedad = C4::Modelo::SysNovedad->new();

    use HTML::Entities;
    my $contenido = $input->param('contenido');

    $contenido = encode_entities($contenido);
    $contenido=~ s/&lt;/</gi;
    $contenido=~ s/&gt;/>/gi;
    $contenido=~ s/<script>/_/gi;
    $contenido=~ s/<\/script>/_/gi;
    %params = $input->Vars;
    $params{'contenido'} = $contenido;

    return ($novedad->agregar(%params));
}


sub editar{

    my ($input) = @_;
    my %params;
    my $novedad = getNovedad($input->param('id'));

    use HTML::Entities;
    my $contenido = $input->param('contenido');

    $contenido = encode_entities($contenido);
    $contenido=~ s/&lt;/</gi;
    $contenido=~ s/&gt;/>/gi;
    $contenido=~ s/<script>/_/gi;
    $contenido=~ s/<\/script>/_/gi;
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
        return ($novedades_array_ref->[0]->delete());
    }else{
        return (0);
    }
}


1;