package C4::AR::ControlAutoridades;

use strict;
require Exporter;
use C4::Context;
use Date::Manip;
use C4::Date;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(	

		&t_insertSinonimosAutor
		&t_insertSinonimosTemas 
		&t_insertSinonimosEditoriales

		&t_insertSeudonimosAutor 
		&t_insertSeudonimosTemas
		&t_insertSeudonimosEditoriales 

		&t_eliminarSinonimosAutor 
		&t_eliminarSinonimosTema 
		&t_eliminarSinonimosEditorial 

		&t_eliminarSeudonimosAutor
		&t_eliminarSeudonimosTema 
		&t_eliminarSeudonimosEditorial

		&t_updateSinonimosAutores
		&t_updateSinonimosEditoriales
		&t_updateSinonimosTemas

		&traerSeudonimosAutor 
		&traerSeudonimosTemas 
		&traerSeudonimosEditoriales 
		&traerSinonimosAutor 
		&traerSinonimosTemas 
		&traerSinonimosEditoriales 
		
		&search_temas
		&search_autores
		&search_editoriales

);


# FIXME los search son para los auto_complete, PASAR A ROSE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#*************************************Sinonimos*************************************************

sub search_temas(){
	my ($tema)=@_; 

	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("	SELECT id, nombre
			       	FROM cat_tema
				WHERE nombre like ?
			       	ORDER BY nombre");

	$sth->execute('%'.$tema.'%');

	my @results;
	my $cant= 0;
	while (my $data=$sth->fetchrow_hashref){
		push (@results, $data);
		$cant++;
	}
	$sth->finish;
	return ($cant, @results);

}

sub search_autores(){
	my ($autor)=@_; 

	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("	SELECT id, nombre
			       	FROM cat_autor
				WHERE nombre like ?
			       	ORDER BY nombre");

	$sth->execute('%'.$autor.'%');

	my @results;
	my $cant= 0;
	while (my $data=$sth->fetchrow_hashref){
		push (@results, $data);
		$cant++;
	}
	$sth->finish;
	return ($cant, @results);
}

sub search_editoriales(){
	my ($editorial)=@_; 

	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("	SELECT id, editorial
			       	FROM cat_editorial
				WHERE editorial like ?
			       	ORDER BY editorial");

	$sth->execute('%'.$editorial.'%');

	my @results;
	my $cant= 0;
	while (my $data=$sth->fetchrow_hashref){
		push (@results, $data);
		$cant++;
	}
	$sth->finish;
	return ($cant, @results);
}

#*************************************************************************************************
sub traerSinonimosAutor{
    my ($autor)=@_;
    use C4::Modelo::CatControlSinonimoAutor::Manager;
    my @filtros;

    push(@filtros, ( id => { eq => $autor}) );
    
    my $sinonimos_autor = C4::Modelo::CatControlSinonimoAutor::Manager->get_cat_control_sinonimo_autor(

                                                                                    query => \@filtros,

                                                                                    );

    return (scalar(@$sinonimos_autor), $sinonimos_autor);
}

sub traerSinonimosTemas{
    my ($autor)=@_;
    use C4::Modelo::CatControlSinonimoTema::Manager;
    my @filtros;

    push(@filtros, ( id => { eq => $autor}) );
    
    my $sinonimos_tema = C4::Modelo::CatControlSinonimoTema::Manager->get_cat_control_sinonimo_tema(

                                                                                    query => \@filtros,
                                                                                    sort_by => 'tema ASC',

                                                                                    );

    return (scalar(@$sinonimos_tema), $sinonimos_tema);
}


sub traerSinonimosEditoriales{
    my ($editorial)=@_;
    use C4::Modelo::CatControlSinonimoEditorial::Manager;
    my @filtros;

    push(@filtros, ( id => { eq => $editorial}) );
    
    my $sinonimos_editorial = C4::Modelo::CatControlSinonimoEditorial::Manager->get_cat_control_sinonimo_editorial(

                                                                                    query => \@filtros,
                                                                                    sort_by => 'editorial ASC',

                                                                                    );

    return (scalar(@$sinonimos_editorial), $sinonimos_editorial);
}

#*************************************************************************************************


sub t_insertSinonimosAutor {
	
	my($sinonimos_arrayref, $idAutor)=@_;

	my ($error, $codMsg,$paraMens);
	
    my $sinonimo_dbo = C4::Modelo::CatControlSinonimoAutor->new();
    my $db = $sinonimo_dbo->db;
	
	eval{
        foreach my $sinonimo (@$sinonimos_arrayref){
            $sinonimo_dbo->agregar($sinonimo->{'text'},$idAutor);
            $sinonimo_dbo = C4::Modelo::CatControlSinonimoAutor->new();
		}
        $db->commit;
	};

	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B400';
		&C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
		eval {
                $db->rollback
        };
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'CA601';
	}
		

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
	return ($error, $codMsg, $message);
}


sub t_insertSinonimosTemas {

    my($sinonimos_arrayref, $idTema)=@_;

    my ($error, $codMsg,$paraMens);

    my $sinonimo_dbo = C4::Modelo::CatControlSinonimoTema->new();
    my $db = $sinonimo_dbo->db;

    eval{
        foreach my $sinonimo (@$sinonimos_arrayref){
            $sinonimo_dbo->agregar($sinonimo->{'text'},$idTema);
            $sinonimo_dbo = C4::Modelo::CatControlSinonimoTema->new();
        }
        $db->commit;
    };

    if ($@){
        #Se loguea error de Base de Datos
        $codMsg= 'B400';
        &C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
        eval {
                $db->rollback
        };
        #Se setea error para el usuario
        $error= 1;
        $codMsg= 'CA601';
    }

    my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
    return ($error, $codMsg, $message);
}

sub t_insertSinonimosEditoriales {

    my($sinonimos_arrayref, $idEditorial)=@_;

    use C4::Modelo::CatControlSinonimoEditorial;

    my ($error, $codMsg,$paraMens);

    my $sinonimo_dbo = C4::Modelo::CatControlSinonimoEditorial->new();
    my $db = $sinonimo_dbo->db;

    eval{
        foreach my $sinonimo (@$sinonimos_arrayref){
            $sinonimo_dbo->agregar($sinonimo->{'text'},$idEditorial);
            $sinonimo_dbo = C4::Modelo::CatControlSinonimoEditorial->new();
        }
        $db->commit;
    };

    if ($@){
        #Se loguea error de Base de Datos
        $codMsg= 'B400';
        &C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
        eval {
                $db->rollback
        };
        #Se setea error para el usuario
        $error= 1;
        $codMsg= 'CA601';
    }


    my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
    return ($error, $codMsg, $message);
}

#************************************************************************************************

sub t_updateSinonimosAutores {
	
	my($idSinonimo, $nombre, $nombreViejo)=@_;

    use C4::Modelo::CatControlSinonimoAutor;

	my ($error, $codMsg,$paraMens);
	
	eval {
            my $sinonimo_autor = C4::Modelo::CatControlSinonimoAutor->new(id => $idSinonimo, autor => $nombreViejo);
               $sinonimo_autor->load();
               $sinonimo_autor->agregar($nombre,$idSinonimo);

	};
	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B400';
		&C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'CA605';
	}

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
	return ($error, $codMsg, $message);
}


sub t_updateSinonimosTemas {
    
    my($idSinonimo, $nombre, $nombreViejo)=@_;

    use C4::Modelo::CatControlSinonimoTema;

    my ($error, $codMsg,$paraMens);
    
    eval {
            my $sinonimo_tema = C4::Modelo::CatControlSinonimoTema->new(id => $idSinonimo, tema => $nombreViejo);
               $sinonimo_tema->load();
               $sinonimo_tema->agregar($nombre,$idSinonimo);

    };
    if ($@){
        #Se loguea error de Base de Datos
        $codMsg= 'B400';
        &C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
        #Se setea error para el usuario
        $error= 1;
        $codMsg= 'CA605';
    }

    my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
    return ($error, $codMsg, $message);
}

sub t_updateSinonimosEditoriales {
    
    my($idSinonimo, $nombre, $nombreViejo)=@_;

    use C4::Modelo::CatControlSinonimoEditorial;

    my ($error, $codMsg,$paraMens);
    
    eval {
            my $sinonimo_editorial = C4::Modelo::CatControlSinonimoEditorial->new(id => $idSinonimo, editorial => $nombreViejo);
               $sinonimo_editorial->load();
               $sinonimo_editorial->agregar($nombre,$idSinonimo);

    };
    if ($@){
        #Se loguea error de Base de Datos
        $codMsg= 'B400';
        &C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
        #Se setea error para el usuario
        $error= 1;
        $codMsg= 'CA605';
    }

    my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
    return ($error, $codMsg, $message);
}


sub t_eliminarSinonimosAutor {
	
# FIXME la clave son los 2, o sea, un string, habria que poner un serial no???? (@Gaspar)


	my($idAutor,$sinonimo)=@_;

	my ($error, $codMsg,$paraMens);
	
	eval {
        use C4::Modelo::CatControlSinonimoAutor::Manager;
        my @filtros;
        push(@filtros, ( id => { eq => $idAutor}) );
        push(@filtros, ( autor => { eq => $sinonimo}) );
		C4::Modelo::CatControlSinonimoAutor::Manager->delete_cat_control_sinonimo_autor( where => \@filtros);
		$codMsg= 'U310';

	};

	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B419';
		&C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'CA604';
	}
		
	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
	return ($error, $codMsg, $message);
}
# 
# =item
# Esta funcion elimina el sinonimo del autor pasados por parametro
# =cut


sub t_eliminarSinonimosTema {
    
# FIXME la clave son los 2, o sea, un string, habria que poner un serial no???? (@Gaspar)


    my($idTema,$sinonimo)=@_;

    my ($error, $codMsg,$paraMens);
    
    eval {
        use C4::Modelo::CatControlSinonimoTema::Manager;
        my @filtros;
        push(@filtros, ( id => { eq => $idTema}) );
        push(@filtros, ( tema => { eq => $sinonimo}) );
        C4::Modelo::CatControlSinonimoTema::Manager->delete_cat_control_sinonimo_tema( where => \@filtros);
        $codMsg= 'U310';

    };

    if ($@){
        #Se loguea error de Base de Datos
        $codMsg= 'B419';
        &C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
        #Se setea error para el usuario
        $error= 1;
        $codMsg= 'CA604';
    }

    my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
    return ($error, $codMsg, $message);
}


sub t_eliminarSinonimosEditorial {
	
    
# FIXME la clave son los 2, o sea, un string, habria que poner un serial no???? (@Gaspar)

    my($idEditorial,$sinonimo)=@_;

    my ($error, $codMsg,$paraMens);
    
    eval {
        use C4::Modelo::CatControlSinonimoEditorial::Manager;
        my @filtros;
        push(@filtros, ( id => { eq => $idEditorial}) );
        push(@filtros, ( editorial => { eq => $sinonimo}) );
        C4::Modelo::CatControlSinonimoEditorial::Manager->delete_cat_control_sinonimo_editorial( where => \@filtros);
        $codMsg= 'U310';

    };

    if ($@){
        #Se loguea error de Base de Datos
        $codMsg= 'B419';
        &C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
        #Se setea error para el usuario
        $error= 1;
        $codMsg= 'CA604';
    }

    my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
    return ($error, $codMsg, $message);
}

#*************************************Seudonimos*************************************************

sub traerSeudonimosAutor(){
	my ($idAutor)=@_;
	my $dbh = C4::Context->dbh;

	my $query="	SELECT id, id2
		   	FROM cat_control_seudonimo_autor 
		   	WHERE id= ? or id2= ?";

	my $sth=$dbh->prepare($query);
	$sth->execute($idAutor, $idAutor);

	$query="	SELECT completo
			FROM cat_autor 
			WHERE id= ?
			ORDER BY completo";
	
	my $sth2=$dbh->prepare($query);

	my $Autor;
	my @results;

	while (my $data = $sth->fetchrow_hashref) {
		if($idAutor ne $data->{'id2'}){
			$sth2->execute($data->{'id2'});
			$Autor = $sth2->fetchrow_hashref;
			$data->{'seudonimo'}= $Autor->{'completo'};
			push @results, $data; 
		}	
		if($idAutor ne $data->{'id'}){
			$sth2->execute($data->{'id'});
			$Autor = $sth2->fetchrow_hashref;
			$data->{'seudonimo'}= $Autor->{'completo'};
			push @results, $data;
 		}
	}

	$sth->finish;
	return @results;
}

sub traerSeudonimosTemas(){
	my ($idTema)=@_;
	my $dbh = C4::Context->dbh;

	my $query="	SELECT id, id2
		   	FROM cat_control_seudonimo_tema 
		   	WHERE id= ? or id2= ?";

	my $sth=$dbh->prepare($query);
	$sth->execute($idTema, $idTema);

	$query="	SELECT nombre 
			FROM cat_tema 
			WHERE id= ?
			ORDER BY nombre";
	
	my $sth2=$dbh->prepare($query);

	my $Tema;
	my @results;

	while (my $data = $sth->fetchrow_hashref) {
		if($idTema ne $data->{'id2'}){
			$sth2->execute($data->{'id2'});
			$Tema = $sth2->fetchrow_hashref;
			$data->{'seudonimo'}= $Tema->{'nombre'};
			push @results, $data;
		}	
		if($idTema ne $data->{'id'}){
			$sth2->execute($data->{'id'});
			$Tema = $sth2->fetchrow_hashref;
			$data->{'seudonimo'}= $Tema->{'nombre'};
			push @results, $data;
 		}
	}

	$sth->finish;
	return @results;
}

sub traerSeudonimosEditoriales(){
	my ($idEditorial)=@_;
	my $dbh = C4::Context->dbh;

	my $query="	SELECT id, id2
		   	FROM cat_control_seudonimo_editorial 
		   	WHERE id= ? OR id2= ?";

	my $sth=$dbh->prepare($query);
	$sth->execute($idEditorial, $idEditorial);

	$query="	SELECT editorial 
			FROM `editoriales` 
			WHERE id= ?
			ORDER BY editorial";
	
	my $sth2=$dbh->prepare($query);

	my $Editorial;
	my @results;

	while (my $data = $sth->fetchrow_hashref) {
		if($idEditorial ne $data->{'id2'}){
			$sth2->execute($data->{'id2'});
			$Editorial = $sth2->fetchrow_hashref;
			$data->{'seudonimo'}= $Editorial->{'editorial'};
			push @results, $data;
		}	
		if($idEditorial ne $data->{'id'}){
			$sth2->execute($data->{'id'});
			$Editorial = $sth2->fetchrow_hashref;
			$data->{'seudonimo'}= $Editorial->{'editorial'};
			push @results, $data;			
 		}
	}

	$sth->finish;
	return @results;
}


sub t_insertSeudonimosAutor {
	
	my($seudonimos_arrayref, $idAutor)=@_;

	my ($error, $codMsg,$paraMens);
	
	my $dbh = C4::Context->dbh;
	my ($paramsReserva);
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	eval {
		insertSeudonimosAutor($seudonimos_arrayref, $idAutor);	
		$dbh->commit;

	};

	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B400';
		&C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'CA602';
	}
	$dbh->{AutoCommit} = 1;
		

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
	return ($error, $codMsg, $message);
}

=item
Esta funcion inserta los seudonimos pasados $seudonimos_arrayref al autor pasado por parametro
=cut
sub insertSeudonimosAutor(){

	my ($seudonimos_arrayref, $idAutor)=@_;
	my $dbh = C4::Context->dbh;
	my $sth;
	my $cant= scalar(@$seudonimos_arrayref);
	my $seudonimo;

	for(my $i=0;$i<$cant;$i++){
		$seudonimo= $seudonimos_arrayref->[$i]->{'ID'};
		#verifico la existencia del registro
		my $queryExist="	SELECT count(*) 
					FROM cat_control_seudonimo_autor 
					WHERE((id = ?)AND(id2 = ?))
					OR((id2 = ?)AND(id = ?))";

		$sth=$dbh->prepare($queryExist);
		$sth->execute(
				$seudonimo,
				$idAutor,
				$seudonimo,
				$idAutor
		);

		my $Existe = $sth->fetchrow;

		#si no existe el registro
		if($Existe eq 0){		
			my $query="	INSERT INTO cat_control_seudonimo_autor(id, id2)
				   	VALUES(?,?)";
			$sth=$dbh->prepare($query);
			$sth->execute($idAutor, $seudonimo);
        	}
		$sth->finish;
	}
}


sub t_eliminarSeudonimosAutor {
	
	my($idAutor,$seudonimo)=@_;

	my ($error, $codMsg,$paraMens);
	
	my $dbh = C4::Context->dbh;
	my ($paramsReserva);
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	eval {
		eliminarSeudonimosAutor($idAutor,$seudonimo);	
		$dbh->commit;
		$codMsg= 'U309';

	};

	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B417';
		&C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'CA603';
	}
	$dbh->{AutoCommit} = 1;
		

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
	return ($error, $codMsg, $message);
}

=item
Esta fucion elimina el $seudonimo del autor pasado por parametro
=cut
sub eliminarSeudonimosAutor(){

	my ($idAutor,$seudonimo)=@_;
	my $dbh = C4::Context->dbh;
	my $sth;
	
	my $queryExist="	DELETE FROM cat_control_seudonimo_autor 
				WHERE((id = ?)AND(id2 = ?))
				OR(id2 = ?)AND(id = ?)";

	$sth=$dbh->prepare($queryExist);
	$sth->execute(
			$idAutor,
			$seudonimo,
			$idAutor,
			$seudonimo
	);

	$sth->finish;
}


sub t_insertSeudonimosTemas {
	
	my($seudonimos_arrayref, $idTema)=@_;

	my ($error, $codMsg,$paraMens);
	
	my $dbh = C4::Context->dbh;
	my ($paramsReserva);
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	eval {
		insertSeudonimosTemas($seudonimos_arrayref, $idTema);	
		$dbh->commit;

	};

	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B400';
		&C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'CA602';
	}
	$dbh->{AutoCommit} = 1;
		

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
	return ($error, $codMsg, $message);
}

sub insertSeudonimosTemas(){
#Inserto los seudonimos pasados $seudonimos_arrayref al tema pasado por parametro
	my ($seudonimos_arrayref, $idTema)=@_;
	my $dbh = C4::Context->dbh;
	my $sth;
	my $cant= scalar(@$seudonimos_arrayref);
	my $seudonimo;

	for(my $i=0;$i<$cant;$i++){
		$seudonimo= $seudonimos_arrayref->[$i]->{'ID'};
		#verifico la existencia del registro
		my $queryExist="	SELECT count(*) 
					FROM cat_control_seudonimo_tema 
					WHERE((id = ?)AND(id2 = ?))
					OR((id2 = ?)AND(id = ?))";

		$sth=$dbh->prepare($queryExist);
		$sth->execute(
				$seudonimo,
				$idTema,
				$seudonimo,
				$idTema
		);

		my $Existe = $sth->fetchrow;

		#si no existe el registro
		if($Existe eq 0){		
			my $query="	INSERT INTO cat_control_seudonimo_tema (id, id2)
				   	VALUES(?,?)";

			$sth=$dbh->prepare($query);
			$sth->execute($idTema, $seudonimo);
        	}
		$sth->finish;
	}
}

sub t_eliminarSeudonimosTema {
	
	my($idTema,$seudonimo)=@_;

	my ($error, $codMsg,$paraMens);
	
	my $dbh = C4::Context->dbh;
	my ($paramsReserva);
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	eval {
		eliminarSeudonimosTema($idTema,$seudonimo);	
		$dbh->commit;
		$codMsg= 'U309';

	};

	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B418';
		&C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'CA603';
	}
	$dbh->{AutoCommit} = 1;
		

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
	return ($error, $codMsg, $message);
}


sub eliminarSeudonimosTema(){
#Elimino el $seudonimo del tema pasados por parametro
	my ($idTema,$seudonimo)=@_;
	my $dbh = C4::Context->dbh;
	my $sth;
	
	my $queryExist="	DELETE FROM cat_control_seudonimo_tema 
				WHERE((id = ?)AND(id2 = ?))
				OR((id2 = ?)AND(id = ?))";

	$sth=$dbh->prepare($queryExist);
	$sth->execute(
			$idTema,
			$seudonimo,
			$idTema,
			$seudonimo
	);

	$sth->finish;
}

sub t_insertSeudonimosEditoriales {
	
	my($seudonimos_arrayref, $idEditorial)=@_;

	my ($error, $codMsg,$paraMens);
	
	my $dbh = C4::Context->dbh;
	my ($paramsReserva);
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	eval {
		insertSeudonimosEditoriales($seudonimos_arrayref, $idEditorial);	
		$dbh->commit;

	};

	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B400';
		&C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'CA602';
	}
	$dbh->{AutoCommit} = 1;
		

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
	return ($error, $codMsg, $message);
}

sub insertSeudonimosEditoriales(){
#Inserto los seudonimos pasados $seudonimos_arrayref a la editorial pasado por parametro
	my ($seudonimos_arrayref, $idEditorial)=@_;
	my $dbh = C4::Context->dbh;
	my $sth;
	my $cant= scalar(@$seudonimos_arrayref);
	my $seudonimo;

	for(my $i=0;$i<$cant;$i++){
		$seudonimo= $seudonimos_arrayref->[$i]->{'ID'};
		#verifico la existencia del registro
		my $queryExist="	SELECt count(*) 
					FROM cat_control_seudonimo_editorial 
					WHERE((id = ?)AND(id2 = ?))
					OR((id2 = ?)AND(id = ?))";

		$sth=$dbh->prepare($queryExist);
		$sth->execute(
				$seudonimo,
				$idEditorial,
				$seudonimo,
				$idEditorial
		);

		my $Existe = $sth->fetchrow;

		#si no existe el registro
		if($Existe eq 0){		
			my $query="	INSERT INTO cat_control_seudonimo_editorial (id, id2)
				   	VALUES(?,?)";

			$sth=$dbh->prepare($query);
			$sth->execute($idEditorial, $seudonimo);
        	}
		$sth->finish;
	}
}

sub t_eliminarSeudonimosEditorial {
	
	my($idEditorial,$seudonimo)=@_;

	my ($error, $codMsg,$paraMens);
	
	my $dbh = C4::Context->dbh;
	my ($paramsReserva);
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	eval {
		eliminarSeudonimosEditorial($idEditorial,$seudonimo);	
		$dbh->commit;

	};

	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B400';
		&C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'CA603';
	}
	$dbh->{AutoCommit} = 1;
		

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
	return ($error, $codMsg, $message);
}

sub eliminarSeudonimosEditorial(){
#Elimino el seudonimo de la editorial pasados por parametro
	my ($idEditorial,$seudonimo)=@_;
	my $dbh = C4::Context->dbh;
	my $sth;

	my $query="	DELETE FROM cat_control_seudonimo_editorial 
				WHERE((id = ?)AND(id2 = ?))
				OR((id2 = ?)AND(id = ?))";

	$sth=$dbh->prepare($query);
	$sth->execute(
			$idEditorial,
			$seudonimo,
			$idEditorial,
			$seudonimo
	);

	$sth->finish;
}

1;
