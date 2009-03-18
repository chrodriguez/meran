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

	&saveNivel1

	&detalleNivel1
	&detalleNivel1MARC
	&detalleNivel1OPAC

	&t_deleteNivel1

);


=item

=cut

=item
buscarNivel1PorId3
Devuelve los datos del nivel 1 a partir de un id3
=cut
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

=item
Esta funcion retorna el untitle segun un id1
=cut
sub getUnititle {
	my($id1)= @_;
	return C4::AR::Busquedas::buscarDatoDeCampoRepetible($id1,"245","b","1");
}

sub detalleNivel1MARC{
	my ($id1, $nivel1,$tipo)= @_;
	my $dbh = C4::Context->dbh;
	my @nivel1Comp;
	my $i=0;
	my $autor= $nivel1->{'autor'};
	
	$nivel1Comp[$i]->{'campo'}= "245";
	$nivel1Comp[$i]->{'subcampo'}= "a";
	$nivel1Comp[$i]->{'dato'}= $nivel1->{'titulo'};
	my $librarian= &C4::AR::Busquedas::getLibrarian('245', 'a',$nivel1->{'titulo'},'ALL',$tipo,1);
	$nivel1Comp[$i]->{'librarian'}=  $librarian->{'liblibrarian'}; 
	$i++;

	$autor= &C4::AR::Busquedas::getautor($autor);
	$nivel1Comp[$i]->{'campo'}= "100"; #$autor->{'campo'}; se va a sacar de aca
	$nivel1Comp[$i]->{'subcampo'}= "a";
	$nivel1Comp[$i]->{'dato'}= $autor->{'completo'}; 
	$nivel1Comp[$i]->{'librarian'}= "Autor";
	$i++;

#trae nive1_repetibles
	my $query="SELECT * FROM cat_nivel1_repetible WHERE id1=?";
	my $sth=$dbh->prepare($query);
        $sth->execute($id1);
	while(my $data=$sth->fetchrow_hashref){
		$nivel1Comp[$i]->{'campo'}= $data->{'campo'};
		$nivel1Comp[$i]->{'subcampo'}= $data->{'subcampo'};
		$librarian= &C4::AR::Busquedas::getLibrarian($data->{'campo'}, $data->{'subcampo'}, $data->{'dato'},'ALL',$tipo,1);
		$nivel1Comp[$i]->{'dato'}= $librarian->{'dato'};
		$nivel1Comp[$i]->{'librarian'}= $librarian->{'liblibrarian'}; 
	
		$i++;
	}
	$sth->finish;
	return @nivel1Comp;
}

sub detalleNivel1OPAC{
	my ($id1, $nivel1,$tipo)= @_;
	my $dbh = C4::Context->dbh;
	my @nivel1Comp;
	my $i=0;
	my $getLib;
	my $autor= $nivel1->{'autor'};
	
	$nivel1Comp[$i]->{'campo'}= "245";
	$nivel1Comp[$i]->{'subcampo'}= "a";
	$nivel1Comp[$i]->{'dato'}= $nivel1->{'titulo'};
	$getLib= &C4::AR::Busquedas::getLibrarian('245', 'a',$nivel1->{'titulo'}, 'ALL',$tipo,0);
	$nivel1Comp[$i]->{'librarian'}= $getLib->{'textPred'};
	$i++;

	$autor= &C4::AR::Busquedas::getautor($autor);
	$nivel1Comp[$i]->{'campo'}= "100"; #$autor->{'campo'}; se va a sacar de aca
	$nivel1Comp[$i]->{'subcampo'}= "a";
	$nivel1Comp[$i]->{'dato'}= $autor->{'completo'}; 
	$nivel1Comp[$i]->{'librarian'}= "Autor";
	$i++;

#trae nive1_repetibles
	my $query="SELECT * FROM cat_nivel1_repetible WHERE id1=?";
	my $sth=$dbh->prepare($query);
        $sth->execute($id1);
	while(my $data=$sth->fetchrow_hashref){
		$nivel1Comp[$i]->{'campo'}= $data->{'campo'};
		$nivel1Comp[$i]->{'subcampo'}= $data->{'subcampo'};
		$getLib= &C4::AR::Busquedas::getLibrarian($data->{'campo'}, $data->{'subcampo'},$data->{'dato'}, 'ALL',$tipo,0);
		$nivel1Comp[$i]->{'librarian'}= $getLib->{'textPred'};
		$nivel1Comp[$i]->{'dato'}= $getLib->{'dato'};
		$i++;
	}
	$sth->finish;
	return @nivel1Comp;
}

=item
detalleNivel1
Trae todo los datos del nivel 1 para poder verlos en el template.
=cut
sub detalleNivel1{
	my ($id1, $nivel1,$tipo)= @_;
	my $dbh = C4::Context->dbh;
	my @nivel1Comp;
	my %llaves;
	my $i=0;
	my $autor= $nivel1->{'autor'};
	my $getLib=&C4::AR::Busquedas::getLibrarian('245', 'a', "",'ALL',$tipo,0);
	$nivel1Comp[$i]->{'campo'}= "245";
	$nivel1Comp[$i]->{'subcampo'}= "a";
	$nivel1Comp[$i]->{'dato'}= $nivel1->{'titulo'};
	$nivel1Comp[$i]->{'librarian'}= $getLib->{'liblibrarian'};
	$i++;

	$autor= &C4::AR::Busquedas::getautor($autor);
	$nivel1Comp[$i]->{'campo'}= "100";
	$nivel1Comp[$i]->{'subcampo'}= "a";
	$nivel1Comp[$i]->{'dato'}= $autor->{'completo'}; 
	$nivel1Comp[$i]->{'librarian'}= "Autor";
	$i++;

#trae nive1_repetibles
	my $query="SELECT * FROM cat_nivel1_repetible WHERE id1=? ORDER BY campo,subcampo";
	my $sth=$dbh->prepare($query);
        $sth->execute($id1);
	my $llave;
	while(my $data=$sth->fetchrow_hashref){
		$llave=$data->{'campo'}.",".$data->{'subcampo'};
		my $getLib=&C4::AR::Busquedas::getLibrarian($data->{'campo'}, $data->{'subcampo'}, $data->{'dato'},'ALL',$tipo,0);
		if(not exists($llaves{$llave})){
			$llaves{$llave}=$i;
			$nivel1Comp[$i]->{'campo'}= $data->{'campo'};
			$nivel1Comp[$i]->{'subcampo'}= $data->{'subcampo'};
			$nivel1Comp[$i]->{'dato'}= $getLib->{'dato'};
			$nivel1Comp[$i]->{'librarian'}=$getLib->{'liblibrarian'};
			$i++;
		}
		else{
			my $separador=" ".$getLib->{'separador'}." " ||", ";
			my $pos=$llaves{$llave};
			$nivel1Comp[$pos]->{'dato'}.=$separador.$getLib->{'dato'};
		}
	}
	$sth->finish;
	return @nivel1Comp;
}



sub t_deleteNivel1 {
	my($params)=@_;

#se realizan las verificaciones antes de eliminar el Nivel1, reservas sobre el grupo o items
#y realizar todos los logueos necesarios luego de borrar
# FALTA VER SI TIENE EJEMPLARES RESERVADOS O PRESTADOS EN ESE CASO NO SE TIENE QUE ELIMINAR
	
	my ($error,$codMsg,$paraMens);

	my $error= 0;
	if(!$error){
	#No hay error
		my $dbh = C4::Context->dbh;
		$dbh->{AutoCommit} = 0;  # enable transactions, if possible
		$dbh->{RaiseError} = 1;
		eval {
			deleteNivel1($params->{'id1'});	
			$dbh->commit;
	
			$codMsg= 'M903';
			$paraMens->[0]= $params->{'id1'};
	
		};

		if ($@){
			#Se loguea error de Base de Datos
			$codMsg= 'B414';
			&C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
			eval {$dbh->rollback};
			#Se setea error para el usuario
			$error= 1;
			$codMsg= 'U307';
			$paraMens->[0]= $params->{'id1'};
		}
		$dbh->{AutoCommit} = 1;
		
	}

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
	return ($error, $codMsg, $message);
}


=item
deleteNivel1
Elimina todo la informacion de un item para el nivel 1
FALTA VER SI TIENE EJEMPLARES RESERVADOS O PRESTADOS EN ESE CASO NO SE TIENE QUE ELIMINAR
=cut
sub deleteNivel1{
	my($id1)=@_;
	my $dbh = C4::Context->dbh;

	my $query="SELECT id1,id3 FROM cat_nivel3 WHERE id1 = ?";
	my $sth=$dbh->prepare($query);
        $sth->execute($id1);
	while(my $data= $sth->fetchrow_hashref){
		my $query="DELETE FROM cat_nivel3_repetible WHERE id3 = ?";
		my $sth=$dbh->prepare($query);
        	$sth->execute($data->{'id3'});
	}
	my $query="DELETE FROM cat_nivel3 WHERE id1 = ?";
	my $sth=$dbh->prepare($query);
        $sth->execute($id1);

		my $query="SELECT id1,id2 FROM cat_nivel2 WHERE id1 = ?";
	my $sth=$dbh->prepare($query);
        $sth->execute($id1);
	while(my $data= $sth->fetchrow_hashref){
		my $query="DELETE FROM cat_nivel2_repetible WHERE id2 = ?";
		my $sth=$dbh->prepare($query);
        	$sth->execute($data->{'id2'});
	}
	my $query="DELETE FROM cat_nivel2 WHERE id1 = ?";
	my $sth=$dbh->prepare($query);
        $sth->execute($id1);

	my $query="DELETE FROM cat_nivel1_repetible WHERE id1 = ?";
	my $sth=$dbh->prepare($query);
        $sth->execute($id1);

	my $query="DELETE FROM cat_nivel1 WHERE id1 = ?";
	my $sth=$dbh->prepare($query);
        $sth->execute($id1);

}


=item
saveNivel1
Guarda los campos del nivel 1 tanto los unicos como los repetibles.
Los parametros que reciben son: $ids es la referencia a un arreglo que tiene los ids de los inputs de la interface que es un string compuesto por el campo y subcampo; $valores es la referencia a un arreglo que tiene los valores de los inputs de la interface.
=cut
sub saveNivel1{
	my ($autor,$nivel1)=@_;
	my $query1="";
	my $query2="";
	my @bind1=();
	my @bind2=();
	my $query3="SELECT MAX(id1) FROM cat_nivel1";
	my $titulo="";
	foreach my $obj(@$nivel1){
		my $campo=$obj->{'campo'};
		my $subcampo=$obj->{'subcampo'};
		my $valor=$obj->{'valor'};
		if($campo eq '245' && $subcampo eq 'a'){
			$titulo=$valor;
		}
		else{
			if($valor ne ""){
				if($obj->{'simple'}){
					$query2.=",(?,?,*?*,?)";
					push (@bind2,$campo,$subcampo,$valor);
				}
				else{
					foreach my $val (@$valor){
						$query2.=",(?,?,*?*,?)";
						push (@bind2,$campo,$subcampo,$val);
					}
				}
			}
		}
	}
	$query1="INSERT INTO cat_nivel1 (titulo,autor) VALUES (?,?) ";
	push (@bind1,$titulo,$autor);
	if($query2 ne ""){
		$query2=substr($query2,1,length($query2));
		$query2="INSERT INTO cat_nivel1_repetible (campo,subcampo,id1,dato) VALUES ".$query2;
	}
	my($ident,$error,$codMsg)=C4::AR::Catalogacion::transaccion($query1,\@bind1,$query2,\@bind2,$query3);

	return($ident,$error,$codMsg);
}


#=======================================================================ABM Nivel 1=======================================================
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
            eval {$db->rollback};
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

## FIXME ver si falta verificar algo!!!!!!!!!!
    my $msg_object= C4::AR::Mensajes::create();
    my $id1;

    if(!$msg_object->{'error'}){
    #No hay error
        my  $catNivel1;
		$catNivel1= C4::Modelo::CatNivel1->new(id1 => $params->{'id1'});
		$catNivel1->load();

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
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U380', 'params' => [$catNivel1->getId1]} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B430',"INTRA");
            eval {$db->rollback};
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U383', 'params' => [$catNivel1->getId1]} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object, $id1);
}


sub t_eliminarNivel1{
   
   my($id1)=@_;
   
   my $msg_object= C4::AR::Mensajes::create();

# FIXME falta verificar si es posible eliminar el nivel 1

    if(!$msg_object->{'error'}){
    #No hay error
        my  $catNivel1= C4::Modelo::CatNivel1->new(id1 => $id1);
            $catNivel1->load;
		my $id1= $catNivel1->getId1;
        my $db= $catNivel1->dbh; #SI SE PONE ->db QUEDA EN LOCK, ES MUY RARO, ASI ANDA, Y LAS TRANSACCIONES ANDAN BIEN
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
            eval {$db->rollback};
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U377', 'params' => [$id1]} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object);
}
#===================================================================Fin====ABM Nivel 1====================================================