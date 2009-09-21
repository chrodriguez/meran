package C4::AR::Estantes;

use strict;
require Exporter;
use DBI;
use C4::AR::Utilidades;
use vars qw(@ISA @EXPORT);
=head1 NAME

C4::AR::Estantes- Funciones para manipular los estantes Virtuales

=head1 SYNOPSIS

  use C4::AR::Estantes;

=head1 DESCRIPTION

Este módulo provee funciones para manipular estantes virtuales, incluyendo la creación y el borrado de estantes, y el alta y baja de contenido de un estante.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(
		&getListaEstantesPublicos
        &getEstante
        &getSubEstantes
);

sub getListaEstantesPublicos {

    use C4::Modelo::CatEstante;
    use C4::Modelo::CatEstante::Manager;
    my @filtros;
    push(@filtros, ( tipo    => { eq => 'public'}));
    push(@filtros, ( padre  => { eq => 0} ));

    my $estantes_array_ref = C4::Modelo::CatEstante::Manager->get_cat_estante( query => \@filtros, sort_by => 'estante');

    return ($estantes_array_ref);
}

sub getSubEstantes {
    my ($id_estante) = @_;

    use C4::Modelo::CatEstante;
    use C4::Modelo::CatEstante::Manager;
    my @filtros;
    push(@filtros, ( padre  => { eq => $id_estante} ));
    my $estantes_array_ref = C4::Modelo::CatEstante::Manager->get_cat_estante( query => \@filtros, sort_by => 'estante');

    return ($estantes_array_ref);
}

sub getEstante {
    my ($id_estante) = @_;

    use C4::Modelo::CatEstante;
    use C4::Modelo::CatEstante::Manager;
    my ($estante) = C4::Modelo::CatEstante->new(id => $id_estante);
    $estante->load();

    return ($estante);
}

sub borrarEstantes {
    my ($estantes_array_ref)=@_;

    my $msg_object= C4::AR::Mensajes::create();
    $msg_object->{'tipo'}="INTRA";


        foreach my $id_estante (@$estantes_array_ref){

          my ($estante) = C4::Modelo::CatEstante->new(id => $id_estante);
            $estante->load();

          my $db = $estante->db;
          $db->{connect_options}->{AutoCommit} = 0;
          $db->begin_work;

           eval {
           C4::AR::Estantes::_verificacionesParaBorrar($msg_object,$estante);
           if(!$msg_object->{'error'}){
            #No hay error
                C4::AR::Debug::debug("VAMOS A ELIMINAR EL ESTANTE");
                $estante->delete();
                 $db->commit;
                $msg_object->{'error'}= 0;
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'E004', 'params' => [$estante->getEstante]} ) ;
                C4::AR::Debug::debug("EL ESTANTE SE ELIMINO CON EXITO");
            }
            };
        if ($@){
            C4::AR::Debug::debug("ERROR");
            eval {$db->rollback};
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'E003', 'params' => [$estante->getEstante]} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;
        $msg_object->{'error'}= 0;
        }
    return ($msg_object);
}

sub borrarContenido {
    my ($id_estante,$id2)=@_;

    my ($estante) = C4::Modelo::CatEstante->new(id => $id_estante);
    $estante->load();

    C4::AR::Debug::debug("Antes de verificar");
    my ($msg_object)= C4::AR::Estantes::_verificacionesParaBorrar($estante);

    if(!$msg_object->{'error'}){
    #No hay error
    my $db = $estante->db;
    $db->{connect_options}->{AutoCommit} = 0;
    $db->begin_work;

    eval{
        C4::AR::Debug::debug("VAMOS A ELIMINAR EL ESTANTE");
        $estante->delete();
        $db->commit;
        $msg_object->{'error'}= 0;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'E004', 'params' => [$estante->getEstante]} ) ;
        C4::AR::Debug::debug("EL ESTANTE SE ELIMINO CON EXITO");
    };
    if ($@){
        C4::AR::Debug::debug("ERROR");
        eval {$db->rollback};
        #Se setea error para el usuario
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'E003', 'params' => [$estante->getEstante]} ) ;
    }
    $db->{connect_options}->{AutoCommit} = 1;
    }
    return ($msg_object);
}



#VERIFICACIONES PREVIAS
sub _verificacionesParaBorrar {
    my($msg_object,$estante)=@_;

    if (scalar($estante->contenido) gt 0){
    #El estante posee contenido
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'E001', 'params' => [$estante->getEstante]} ) ;
            C4::AR::Debug::debug("Entro al if de contenido\n");
      }
      elsif(scalar(C4::AR::Estantes::getSubEstantes($estante->getId))) {
          $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'E002', 'params' => [$estante->getEstante]} ) ;
            C4::AR::Debug::debug("Entro al if de subestantes\n");
        }
}

1;