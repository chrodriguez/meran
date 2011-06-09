package C4::AR::MensajesContacto;

use strict;
require Exporter;
use C4::Modelo::Contacto;
use C4::Modelo::Contacto::Manager;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw( 

    &marcarLeido
    &marcarNoLeido
    &eliminar
    &noLeidos
    &ver
    &listar
    &marcar
);


sub marcarLeido{

    my ($id_mensaje) = @_;
    my @filtros;

    push (@filtros, (id => {eq =>$id_mensaje}) );

    my  $contacto = C4::Modelo::Contacto::Manager->get_contacto(query => \@filtros,);

    if (scalar(@$contacto)){
        $contacto->[0]->setLeido();
    }

}

sub noLeidos{

    my ($params) = @_;
    my @filtros;

    push (@filtros, (leido => {eq =>0}) );

    my  $noLeidos = C4::Modelo::Contacto::Manager->get_contacto(query => \@filtros,
                                                                sort_by => ['id'] );
    

    
    my $cant_noLeidos= scalar(@$noLeidos);


    return ($noLeidos, $cant_noLeidos);

}


sub marcarNoLeido{

    my ($id_mensaje) = @_;
    my @filtros;

    push (@filtros, (id => {eq =>$id_mensaje}) );

    my $contacto = C4::Modelo::Contacto::Manager->get_contacto(query => \@filtros,);
    
    if (scalar(@$contacto)){
        $contacto->[0]->setNoLeido();
    }

}

sub eliminar{

    my ($id_mensaje) = @_;
    my @filtros;

    push (@filtros, (id => {eq =>$id_mensaje}) );

    my $contacto = C4::Modelo::Contacto::Manager->get_contacto(query => \@filtros,);

    if (scalar(@$contacto)){
        $contacto->[0]->delete();
    }
}

sub ver{

    my ($id_mensaje) = @_;
    my @filtros;

    push (@filtros, (id => {eq =>$id_mensaje}) );

    my  $contacto = C4::Modelo::Contacto::Manager->get_contacto(query => \@filtros,);

    if (scalar(@$contacto)){
        marcarLeido($id_mensaje);
        return ($contacto->[0]);
    }else{
        return (0);
    }

}

sub listar{

    my ($orden,$ini,$cantR) = @_;

    my $mensajes_array_ref = C4::Modelo::Contacto::Manager->get_contacto(   limit   => $cantR,
                                                                            offset  => $ini,
                                                                            sort_by => ['leido','id DESC']
     );

    #Obtengo la cant total de contactos para el paginador
    my $mensajes_array_ref_count = C4::Modelo::Contacto::Manager->get_contacto_count();
    if(scalar(@$mensajes_array_ref) > 0){
        return ($mensajes_array_ref_count, $mensajes_array_ref);
    }else{
        return (0,0);
    }
}


sub marcar{

    my ($id_mensaje) = @_;
    my @filtros;

    push (@filtros, (id => {eq =>$id_mensaje}) );

    my  $contacto = C4::Modelo::Contacto::Manager->get_contacto(query => \@filtros,);

    if (scalar(@$contacto)){
        $contacto->[0]->switchState();
    }
}
1;
