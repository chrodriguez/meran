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



#*************************************Sinonimos*************************************************

sub search_temas(){
	my ($tema)=@_; 

	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("	SELECT id, nombre
			       	FROM `temas`
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
			       	FROM `autores`
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
			       	FROM `editoriales`
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
sub traerSinonimosAutor(){
	my ($autor)=@_;
	my $dbh = C4::Context->dbh;

	my $query="	SELECT id as idSinonimo, autor as sinonimo
			FROM `control_autores_sinonimos`
			WHERE id= ?
			ORDER BY autor";

	my $sth=$dbh->prepare($query);
	$sth->execute($autor);

	my $cant= 0;
	my @results;
	while(my $data=$sth->fetchrow_hashref){
		$data->{'nroSinonimo'}= $cant;
		push (@results, $data);
		$cant++;
	}

	$sth->finish;
	return ($cant, @results);	
}

sub traerSinonimosTemas(){
	my ($tema)=@_;
	my $dbh = C4::Context->dbh;
	my $query="	SELECT id as idSinonimo, tema as sinonimo
			FROM `control_temas_sinonimos`
			WHERE id= ?
			ORDER BY tema";

	my $sth=$dbh->prepare($query);
	$sth->execute($tema);

	my $cant= 0;
	my @results;
	while(my $data=$sth->fetchrow_hashref){
		$data->{'nroSinonimo'}= $cant;
		push (@results, $data);
		$cant++;
	}

	$sth->finish;
	return ($cant, @results);	
}


sub traerSinonimosEditoriales(){
	my ($autor)=@_;
	my $dbh = C4::Context->dbh;
	my $query="	SELECT id as idSinonimo, editorial as sinonimo
			FROM `control_editoriales_sinonimos`
			WHERE id= ?
			ORDER BY editorial";

	my $sth=$dbh->prepare($query);
	$sth->execute($autor);
	
	my $cant= 0;
	my @results;
	while(my $data=$sth->fetchrow_hashref){
		$data->{'nroSinonimo'}= $cant;
		push (@results, $data);
		$cant++;
	}

	$sth->finish;
	return ($cant, @results);	
}

#*************************************************************************************************


sub t_insertSinonimosAutor {
	
	my($sinonimos_arrayref, $idAutor)=@_;

	my ($error, $codMsg,$paraMens);
	
	my $dbh = C4::Context->dbh;
	my ($paramsReserva);
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	eval {
		insertSinonimosAutor($sinonimos_arrayref, $idAutor);	
		$dbh->commit;

	};

	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B400';
		&C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'CA601';
	}
	$dbh->{AutoCommit} = 1;
		

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
	return ($error, $codMsg, $message);
}


=item
Esta funcion inserta el $sinonimo de Autores pasados por parametro
=cut
sub insertSinonimosAutor(){
	my ($sinonimos_arrayref, $idAutor)=@_;
	my $dbh = C4::Context->dbh;
	my $sth;
	my $cant= @$sinonimos_arrayref;	
	my $sinonimo;

	for(my $i=0;$i<$cant;$i++){
		$sinonimo= $sinonimos_arrayref->[$i]->{'text'};
		#verifico la existencia del registro
		my $queryExist="SELECT count(*) 
				FROM `control_autores_sinonimos` 
				WHERE(id = ?)AND(autor = ?)";
		$sth=$dbh->prepare($queryExist);
		$sth->execute($idAutor, $sinonimo);

		my $Existe = $sth->fetchrow;

		#si no existe el registro
		if($Existe eq 0){		
			my $query="INSERT INTO `control_autores_sinonimos`(id, autor)
				   VALUES(?,?)";
			$sth=$dbh->prepare($query);
			$sth->execute($idAutor, $sinonimo);
        	}
		$sth->finish;
	}
}

sub t_insertSinonimosTemas {
	
	my($sinonimos_arrayref, $idTema)=@_;

	my ($error, $codMsg,$paraMens);
	
	my $dbh = C4::Context->dbh;
	my ($paramsReserva);
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	eval {
		insertSinonimosTemas($sinonimos_arrayref, $idTema);	
		$dbh->commit;

	};

	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B400';
		&C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'CA601';
	}
	$dbh->{AutoCommit} = 1;
		

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
	return ($error, $codMsg, $message);
}


=item
Esta funcion inserta el $sinonimo de Temas pasados por parametro
=cut
sub insertSinonimosTemas(){
	my ($sinonimos_arrayref, $idTema)=@_;
	my $dbh = C4::Context->dbh;
	my $sth;
	my $cant= @$sinonimos_arrayref;	
	my $sinonimo;

	for(my $i=0;$i<$cant;$i++){
		$sinonimo= $sinonimos_arrayref->[$i]->{'text'};
		#verifico la existencia del registro
		my $queryExist="SELECT count(*) 
				FROM `control_temas_sinonimos` 
				WHERE(id = ?)AND(tema = ?)";

		$sth=$dbh->prepare($queryExist);
		$sth->execute($idTema, $sinonimo);

		my $Existe = $sth->fetchrow;

		#si no existe el registro
		if($Existe eq 0){
			my $query="INSERT INTO `control_temas_sinonimos`(id, tema)
				   VALUES(?,?)";
			$sth=$dbh->prepare($query);
			$sth->execute($idTema, $sinonimo);
		}
		$sth->finish;
# 		return $Existe;
	}
}

sub t_insertSinonimosEditoriales {
	
	my($sinonimos_arrayref, $idEditorial)=@_;

	my ($error, $codMsg,$paraMens);
	
	my $dbh = C4::Context->dbh;
	my ($paramsReserva);
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	eval {
		insertSinonimosEditoriales($sinonimos_arrayref, $idEditorial);	
		$dbh->commit;

	};

	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B400';
		&C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'CA601';
	}
	$dbh->{AutoCommit} = 1;
		

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
	return ($error, $codMsg, $message);
}

=item
Esta funcion inserta $sinonimo de Editorial pasados por parametro
=cut
sub insertSinonimosEditoriales(){

	my ($sinonimos_arrayref, $idEditorial)=@_;
	my $dbh = C4::Context->dbh;
	my $sth;
	my $cant= @$sinonimos_arrayref;	
	my $sinonimo;
	
	for(my $i=0;$i<$cant;$i++){
		$sinonimo= $sinonimos_arrayref->[$i]->{'text'};
		#verifico la existencia del registro
		my $queryExist="SELECT count(*) 
				FROM `control_editoriales_sinonimos` 
				WHERE(id = ?)AND(editorial = ?)";

		$sth=$dbh->prepare($queryExist);
		$sth->execute($idEditorial, $sinonimo);

		my $Existe = $sth->fetchrow;

		#si no existe el registro
		if($Existe eq 0){
			my $query="INSERT INTO `control_editoriales_sinonimos`(id, editorial)
				   VALUES(?,?)";
			$sth=$dbh->prepare($query);
			$sth->execute($idEditorial, $sinonimo);
		}
		$sth->finish;
	}
}
#************************************************************************************************

sub t_updateSinonimosAutores {
	
	my($idSinonimo, $nombre, $nombreViejo)=@_;

	my ($error, $codMsg,$paraMens);
	
	my $dbh = C4::Context->dbh;
	my ($paramsReserva);
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	eval {
		updateSinonimosAutores($idSinonimo, $nombre, $nombreViejo);	
		$dbh->commit;

	};

	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B400';
		&C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'CA605';
	}
	$dbh->{AutoCommit} = 1;
		

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
	return ($error, $codMsg, $message);
}

sub updateSinonimosAutores{
	my ($idSinonimo, $nombre, $nombreViejo)=@_;
	
	my $dbh = C4::Context->dbh;
	my $sth;

	my $queryExist= " 	SELECT count(*) 
				FROM `control_autores_sinonimos`
				WHERE(id = ?)AND(autor = ?) ";

	$sth=$dbh->prepare($queryExist);
	$sth->execute($idSinonimo, $nombre);

	my $Existe = $sth->fetchrow;

	#si no existe el registro
	if($Existe eq 0){

		my $query=	"UPDATE `control_autores_sinonimos` 
				SET autor = ?
				WHERE(id = ?)AND(autor = ?)";

		$sth=$dbh->prepare($query);
		$sth->execute($nombre, $idSinonimo, $nombreViejo);
		$sth->finish;
	}
}

sub t_updateSinonimosTemas {
	
	my($idSinonimo, $nombre, $nombreViejo)=@_;

	my ($error, $codMsg,$paraMens);
	
	my $dbh = C4::Context->dbh;
	my ($paramsReserva);
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	eval {
		updateSinonimosTemas($idSinonimo, $nombre, $nombreViejo);	
		$dbh->commit;

	};

	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B400';
		&C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'CA605';
	}
	$dbh->{AutoCommit} = 1;
		

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
	return ($error, $codMsg, $message);
}

sub updateSinonimosTemas{
	my ($idSinonimo, $nombre, $nombreViejo)=@_;
	
	my $dbh = C4::Context->dbh;
	my $sth;
	my $queryExist= " 	SELECT count(*) 
				FROM `control_temas_sinonimos`
				WHERE(id = ?)AND(tema = ?) ";

	$sth=$dbh->prepare($queryExist);
	$sth->execute($idSinonimo, $nombre);

	my $Existe = $sth->fetchrow;

	#si no existe el registro
	if($Existe eq 0){

		my $query=	"UPDATE `control_temas_sinonimos` 
				SET tema = ?
				WHERE(id = ?)AND(tema = ?)";

		$sth=$dbh->prepare($query);
		$sth->execute($nombre, $idSinonimo, $nombreViejo);
		$sth->finish;
	}
}

sub t_updateSinonimosEditoriales {
	
	my($idSinonimo, $nombre, $nombreViejo)=@_;

	my ($error, $codMsg,$paraMens);
	
	my $dbh = C4::Context->dbh;
	my ($paramsReserva);
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	eval {
		updateSinonimosEditoriales($idSinonimo, $nombre, $nombreViejo);	
		$dbh->commit;

	};

	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B400';
		&C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'CA605';
	}
	$dbh->{AutoCommit} = 1;
		

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
	return ($error, $codMsg, $message);
}

sub updateSinonimosEditoriales{
	my ($idSinonimo, $nombre, $nombreViejo)=@_;
	
	my $dbh = C4::Context->dbh;
	my $sth;

	my $queryExist= " 	SELECT count(*) 
				FROM `control_editoriales_sinonimos`
				WHERE(id = ?)AND(editorial = ?) ";

	$sth=$dbh->prepare($queryExist);
	$sth->execute($idSinonimo, $nombre);

	my $Existe = $sth->fetchrow;

	#si no existe el registro
	if($Existe eq 0){

		my $query=	"UPDATE `control_temas_sinonimos` 
				SET editorial = ?
				WHERE(id = ?)AND(editorial = ?)";

		$sth=$dbh->prepare($query);
		$sth->execute($nombre, $idSinonimo, $nombreViejo);
		$sth->finish;
	}
}


sub t_eliminarSinonimosAutor {
	
	my($idAutor,$sinonimo)=@_;

	my ($error, $codMsg,$paraMens);
	
	my $dbh = C4::Context->dbh;
	my ($paramsReserva);
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	eval {
		eliminarSinonimosAutor($idAutor,$sinonimo);	
		$dbh->commit;
		$codMsg= 'U310';

	};

	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B419';
		&C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'CA604';
	}
	$dbh->{AutoCommit} = 1;
		

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
	return ($error, $codMsg, $message);
}

=item
Esta funcion elimina el sinonimo del autor pasados por parametro
=cut
sub eliminarSinonimosAutor(){
	my ($idAutor,$sinonimo)=@_;
	my $dbh = C4::Context->dbh;
	my $sth;
	
	my $query="	DELETE FROM `control_autores_sinonimos` 
			WHERE(id = ?)AND(autor = ?)";
	$sth=$dbh->prepare($query);
	$sth->execute($idAutor, $sinonimo);

	$sth->finish;
}

sub t_eliminarSinonimosTema {
	
	my($idTema,$sinonimo)=@_;

	my ($error, $codMsg,$paraMens);
	
	my $dbh = C4::Context->dbh;
	my ($paramsReserva);
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	eval {
		eliminarSinonimosTema($idTema,$sinonimo);	
		$dbh->commit;
		$codMsg= 'U310';

	};

	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B400';
		&C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'CA604';
	}
	$dbh->{AutoCommit} = 1;
		

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
	return ($error, $codMsg, $message);
}

=item
Esta funcion elimina el sinonimo del tema pasados por parametro
=cut
sub eliminarSinonimosTema(){
	my ($idTema,$sinonimo)=@_;
	my $dbh = C4::Context->dbh;
	my $sth;
	
	my $query="	DELETE FROM `control_temas_sinonimos` 
			WHERE(id = ?)AND(tema = ?)";

	$sth=$dbh->prepare($query);
	$sth->execute($idTema, $sinonimo);

	$sth->finish;
}

sub t_eliminarSinonimosEditorial {
	
	my($idEditorial,$sinonimo)=@_;

	my ($error, $codMsg,$paraMens);
	
	my $dbh = C4::Context->dbh;
	my ($paramsReserva);
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	eval {
		eliminarSinonimosEditorial($idEditorial,$sinonimo);	
		$dbh->commit;
		$codMsg= 'U310';

	};

	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B400';
		&C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'CA604';
	}
	$dbh->{AutoCommit} = 1;
		

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
	return ($error, $codMsg, $message);
}

=item
Esta funcion elimina el sinonimo del editorial pasados por parametro
=cut
sub eliminarSinonimosEditorial(){

	my ($idEditorial,$sinonimo)=@_;
	my $dbh = C4::Context->dbh;
	my $sth;
	
	my $query="	DELETE FROM `control_editoriales_sinonimos` 
			WHERE(id = ?)AND(editorial = ?)";

	$sth=$dbh->prepare($query);
	$sth->execute($idEditorial, $sinonimo);

	$sth->finish;
}

#*************************************Seudonimos*************************************************

sub traerSeudonimosAutor(){
	my ($idAutor)=@_;
	my $dbh = C4::Context->dbh;

	my $query="	SELECT id, id2
		   	FROM `control_autores_seudonimos` 
		   	WHERE id= ? or id2= ?";

	my $sth=$dbh->prepare($query);
	$sth->execute($idAutor, $idAutor);

	$query="	SELECT completo
			FROM `autores` 
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
		   	FROM `control_temas_seudonimos` 
		   	WHERE id= ? or id2= ?";

	my $sth=$dbh->prepare($query);
	$sth->execute($idTema, $idTema);

	$query="	SELECT nombre 
			FROM `temas` 
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
		   	FROM `control_editoriales_seudonimos` 
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
					FROM `control_autores_seudonimos` 
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
			my $query="	INSERT INTO `control_autores_seudonimos`(id, id2)
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
	
	my $queryExist="	DELETE FROM `control_autores_seudonimos` 
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
					FROM `control_temas_seudonimos` 
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
			my $query="	INSERT INTO `control_temas_seudonimos`(id, id2)
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
	
	my $queryExist="	DELETE FROM `control_temas_seudonimos` 
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
					FROM `control_editoriales_seudonimos` 
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
			my $query="	INSERT INTO `control_editoriales_seudonimos`(id, id2)
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

	my $query="	DELETE FROM `control_editoriales_seudonimos` 
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
