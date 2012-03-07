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
    getNovedadesNoMostrar
    getUltimasNovedades
    getNovedad
    listar
    agregar
    getNovedadesByFecha
    getPortadaOpac
);


sub agregar{

    my ($input) = @_;
    my %params;
    my $novedad = C4::Modelo::SysNovedad->new();

    my $contenido = $input->param('contenido');

#   Escapa codigo HTML
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
        return (scalar(@$novedades_array_ref),$novedades_array_ref);
    }else{
        return (0,0);
    }
}

=item
    Esta funcion "elimina" la novedad recibida como parametro, la agrega a la tabla para no motrarla mas al user
=cut
sub noMostrarNovedad{

    my ($id_novedad) = @_;
    my %params;
    $params{'id_novedad'} = $id_novedad;
    
    my $novedad_no_borrar = C4::Modelo::SysNovedadNoMostrar->new();
    
    $novedad_no_borrar->agregar(%params);
    
    return "ok";
}

sub getUltimasNovedades{
    my ($limit) = @_;
    
    my $pref_limite = $limit || C4::AR::Preferencias::getValorPreferencia('limite_novedades');

    my $novedades_array_ref = C4::Modelo::SysNovedad::Manager->get_sys_novedad( 
                                                                                sort_by => ['id DESC'],
                                                                                limit   => $pref_limite,
                                                                              );

    #Obtengo la cant total de sys_novedads para el paginador
    my $novedades_array_ref_count = C4::Modelo::SysNovedad::Manager->get_sys_novedad_count();
    if(scalar(@$novedades_array_ref) > 0){
    	if ($limit == 1){
            return ($novedades_array_ref_count, $novedades_array_ref->[0]);
    	}else{
            return ($novedades_array_ref_count, $novedades_array_ref);
    	}
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

=item
    Trae las novedades ordenadas por fecha
=cut
sub getNovedadesByFecha{
#    my ($ini,$cantR) = @_;
    my $novedades_array_ref = C4::Modelo::SysNovedad::Manager->get_sys_novedad( 
                                                                                sort_by => ['fecha DESC'],
#                                                                                limit   => $cantR,
#                                                                                offset  => $ini,
                                                                              );

    #Obtengo la cant total de sys_novedads para el paginador
    my $novedades_array_ref_count = C4::Modelo::SysNovedad::Manager->get_sys_novedad_count();
    if(scalar(@$novedades_array_ref) > 0){
        return ($novedades_array_ref_count, $novedades_array_ref);
    }else{
        return (0,0);
    }
}


sub getPortadaOpac{
	
	use C4::Modelo::PortadaOpac::Manager;
	
	my @filtros;
	
	my $portada = C4::Modelo::PortadaOpac::Manager->get_portada_opac();
	
	return $portada;
}

1;
