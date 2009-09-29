package C4::AR::Nivel1;

use strict;
require Exporter;
use C4::Context;

use vars qw(@EXPORT @ISA);

@ISA=qw(Exporter);

@EXPORT=qw(
	&buscarNivel1PorId3

	&getAutoresAdicionales
	&getColaboradores
	&getUnititle
);




=head1 NAME

C4::AR::Nivel1 - Funciones que manipulan datos del catálogo de nivel 1

=head1 SYNOPSIS

  use C4::AR::Nivel1;

=head1 DESCRIPTION

  Descripción del modulo COMPLETAR

=head1 FUNCTIONS

=over 2

=cut

=item buscarNivel1PorId3

	$id_Nivel1=buscarNivel1PorId3($id3);

Devuelve los datos del nivel 1 a partir de un id de nivel 3
=cut
# FIXME DEPRECATED
sub buscarNivel1PorId3{
        my ($id3) = @_;

        my $dbh = C4::Context->dbh;
        my $query = "	SELECT n1.*,a.* 
			FROM cat_nivel1 n1 INNER JOIN cat_nivel3 n3 ON n1.id1 = n3.id1 
		     	LEFT JOIN cat_autor a ON n1.autor = a.id WHERE id3=? ";

        my $sth = $dbh->prepare($query);
        $sth->execute($id3);
        my $res=$sth->fetchrow_hashref;
        $sth->finish();

        return $res;
}



sub getAutoresAdicionales(){
	my ($id)=@_;

# 	falta implementar, seria un campo de nivel 1 repetibles
}


sub getColaboradores(){
	my ($id)=@_;

# 	falta implementar, seria un campo de nivel 1 repetibles
}

=item getUnititle

	$titulo_unico=getUnititle($id_nivel1);
	Esta funcion retorna el untitle segun un id1
=cut
sub getUnititle {
	my($id1)= @_;
	return C4::AR::Busquedas::buscarDatoDeCampoRepetible($id1,"245","b","1");
}


=item getNivel1FromId1
Recupero un nivel 1 a partir de un id1
retorna un objeto o 0 si no existe
=cut
sub getNivel1FromId1{
	my ($id1) = @_;

	my $nivel1_array_ref = C4::Modelo::CatNivel1::Manager->get_cat_nivel1(   
																		query => [ 
																					id1 => { eq => $id1 },
																			], 
                                                                        with_objects => [ 'cat_autor' ]    
																);

	if( scalar(@$nivel1_array_ref) > 0){
		return ($nivel1_array_ref->[0]);
	}else{
		return 0;
	}
}



#=======================================================================ABM Nivel 1=======================================================
=item t_guardarNivel1
	guardar datos de nivel1
=cut

sub t_guardarNivel1 {
    my($params)=@_;

## FIXME ver si falta verificar algo!!!!!!!!!!
    my $msg_object= C4::AR::Mensajes::create();
    my $id1;

    if(!$msg_object->{'error'}){
    #No hay error
        my  $catNivel1;
        $catNivel1= C4::Modelo::CatNivel1->new();
        my $db= $catNivel1->db;
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
         $db->begin_work;
    
        eval {
            $catNivel1->agregar($params);  
            $id1 = $catNivel1->getId1;
            $db->commit;
            #se cambio el permiso con exito
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U368', 'params' => [$catNivel1->getId1]} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B427',"INTRA");
            $db->rollback;
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U371', 'params' => []} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object, $id1);
}

sub t_modificarNivel1 {
    my($params)=@_;

# FIXME falta verificar que no se agregue con barcode repetido
    my $msg_object= C4::AR::Mensajes::create();
    my $id1 = 0;

    my ($catNivel1) = getNivel1FromId1($params->{'id1'});

    if(!$catNivel1){
        #Se setea error para el usuario
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U404', 'params' => []} ) ;
    }

    if(!$msg_object->{'error'}){
    #No hay error
		$params->{'modificado'}=1;

        my $db = $catNivel1->db;
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
         $db->begin_work;
    
        eval {
            $catNivel1->agregar($params);  
            $id1 = $catNivel1->getId1;
            $db->commit;
            #se cambio el permiso con exito
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U380', 'params' => [$catNivel1->getId1]} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B430',"INTRA");
            $db->rollback;
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U383', 'params' => [$catNivel1->getId1]} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object, $id1);
}


sub t_eliminarNivel1{
   my ($id1) = @_;
   
   my $msg_object= C4::AR::Mensajes::create();

# FIXME falta verificar si es posible eliminar el nivel 1

    my ($catNivel1) = getNivel1FromId1($id1);

    if(!$catNivel1){
        #Se setea error para el usuario
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U404', 'params' => []} ) ;
    }

    if(!$msg_object->{'error'}){
    #No hay error
        my $db = $catNivel1->db;
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
        $db->begin_work;
    
        eval {
            $catNivel1->eliminar;  
            $db->commit;
            #se cambio el permiso con exito
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U374', 'params' => [$id1]} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B429',"INTRA");
            $db->rollback;
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U377', 'params' => [$id1]} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object);
}
#===================================================================Fin====ABM Nivel 1====================================================
#
=back

=head1 AUTHOR

Grupo de Desarrollo Meran <koha@linti.unlp.edu.ar>

=head1 SEE ALSO

C4::AR::Nivel2 C4::AR::Nivel3

=cut

