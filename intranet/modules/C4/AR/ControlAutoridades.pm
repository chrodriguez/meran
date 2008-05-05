package C4::AR::ControlAutoridades;

#Este modulo provee funcionalidades para el Control de Autoridades
#Escrito el 8/9/2006 por einar@info.unlp.edu.ar
#
#Copyright (C) 2003-2006  Linti, Facultad de Inform�tica, UNLP
#This file is part of Koha-UNLP
#
#This program is free software; you can redistribute it and/or
#modify it under the terms of the GNU General Public License
#as published by the Free Software Foundation; either version 2
#of the License, or (at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software
#Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

use strict;
require Exporter;
use C4::Context;
use Date::Manip;
use C4::Date;

#use C4::Date;
use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(	&traerAutores 
		&traerTemas 
		&traerEditoriales 
		&traerSinonimosAutor 
		&traerSinonimosTemas 
		&traerSinonimosEditoriales 
		&insertSinonimosAutor 
		&insertSinonimosTemas 
		&insertSinonimosEditoriales
		&eliminarSinonimosAutor 
		&eliminarSinonimosTema 
		&eliminarSinonimosEditorial 
		&traerSeudonimosAutor 
		&traerSeudonimosTemas 
		&traerSeudonimosEditoriales 
		&insertSeudonimosAutor 
		&eliminarSeudonimosAutor
		&insertSeudonimosTemas 
		&eliminarSeudonimosTema 
		&insertSeudonimosEditoriales 
		&eliminarSeudonimosEditorial
		&search_temas
		&search_autores
		&search_editoriales
		&updateSinonimosAutores
		&updateSinonimosEditoriales
		&updateSinonimosTemas
);



#*************************************Sinonimos*************************************************
#creo q no se usa mas
sub traerAutores(){
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("SELECT id, Completo
			       FROM `autores`
			       Order By Completo");
	$sth->execute();
	my %results;
	my $i = 0;
	while (my $data = $sth->fetchrow_hashref) {
		#push(@results, $data->{'Completo'}); 
		$results{$data->{'id'}}= $data->{'Completo'};
		$i++;
	}
	  
	$sth->finish;

	return %results;
}

#creo q no se usa mas
sub traerTemas(){
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("SELECT id, nombre
			       FROM `temas`
			       Order By nombre");
	$sth->execute();
	my %results;
	my $i = 0;
	while (my $data = $sth->fetchrow_hashref) {
		$results{$data->{'id'}}= $data->{'nombre'};
		$i++;
	}
	  
	$sth->finish;

	return %results;
}

sub search_temas(){
	my ($tema)=@_; 

	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("	SELECT id, nombre
			       	FROM `temas`
				WHERE nombre like ?
			       	Order By nombre");
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
			       	Order By nombre");
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
			       	Order By editorial");
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

#creo q no se usa mas
sub traerEditoriales(){
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("SELECT id, editorial
			       FROM `editoriales`
			       Order By editorial");
	$sth->execute();
	my %results;
	my $i = 0;
	while (my $data = $sth->fetchrow_hashref) {
		$results{$data->{'id'}}= $data->{'editorial'};
		$i++;
	}
	  
	$sth->finish;

	return %results;
}
#*************************************************************************************************
sub traerSinonimosAutor(){
	my ($autor)=@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT id as idSinonimo, autor as sinonimo
		   FROM `control_autores_sinonimos`
		   WHERE id= ?
		   Order By autor";
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
	my $query="SELECT id as idSinonimo, tema as sinonimo
		   FROM `control_temas_sinonimos`
		   WHERE id= ?
		   Order By tema";
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
	my $query="SELECT id as idSinonimo, editorial as sinonimo
		   FROM `control_editoriales_sinonimos`
		   WHERE id= ?
		   Order By editorial";
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

sub insertSinonimosAutor(){
#Inserto el $sinonimo de Autores pasados por parametro
	my ($sinonimos_arrayref, $idAutor)=@_;
	my $dbh = C4::Context->dbh;
	my $sth;
	my $cant= @$sinonimos_arrayref;	
	my $sinonimo;

	for(my $i=0;$i<$cant;$i++){
		$sinonimo= $sinonimos_arrayref->[$i]->{'text'};
		#verifico la existencia del registro
		my $queryExist="Select count(*) 
				From `control_autores_sinonimos` 
				Where(id = ?)and(autor = ?)";
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
# 		return $Existe;
	}
}

sub insertSinonimosTemas(){
#Inserto el $sinonimo de Temas pasados por parametro
	my ($sinonimos_arrayref, $idTema)=@_;
	my $dbh = C4::Context->dbh;
	my $sth;
	my $cant= @$sinonimos_arrayref;	
	my $sinonimo;

	for(my $i=0;$i<$cant;$i++){
		$sinonimo= $sinonimos_arrayref->[$i]->{'text'};
		#verifico la existencia del registro
		my $queryExist="Select count(*) 
				From `control_temas_sinonimos` 
				Where(id = ?)and(tema = ?)";
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

sub insertSinonimosEditoriales(){
#Inserto $sinonimo de Editorial pasados por parametro
	my ($sinonimos_arrayref, $idEditorial)=@_;
	my $dbh = C4::Context->dbh;
	my $sth;
	my $cant= @$sinonimos_arrayref;	
	my $sinonimo;
	
	for(my $i=0;$i<$cant;$i++){
		$sinonimo= $sinonimos_arrayref->[$i]->{'text'};
		#verifico la existencia del registro
		my $queryExist="Select count(*) 
				From `control_editoriales_sinonimos` 
				Where(id = ?)and(editorial = ?)";
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
# 	return $Existe;
}
#************************************************************************************************
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


sub eliminarSinonimosAutor(){
#Elimino el sinonimo del autor pasados por parametro
	my ($idAutor,$sinonimo)=@_;
	my $dbh = C4::Context->dbh;
	my $sth;
	#verifico la existencia del registro
	my $query=	"Delete From `control_autores_sinonimos` 
			Where(id = ?)and(autor = ?)";
	$sth=$dbh->prepare($query);
	$sth->execute($idAutor, $sinonimo);

	$sth->finish;
}

sub eliminarSinonimosTema(){
#Elimino el sinonimo del tema pasados por parametro
	my ($idTema,$sinonimo)=@_;
	my $dbh = C4::Context->dbh;
	my $sth;
	#verifico la existencia del registro
	my $query=	"Delete From `control_temas_sinonimos` 
			Where(id = ?)and(tema = ?)";
	$sth=$dbh->prepare($query);
	$sth->execute($idTema, $sinonimo);

	$sth->finish;
}

sub eliminarSinonimosEditorial(){
#Elimino el sinonimo del editorial pasados por parametro
	my ($idEditorial,$sinonimo)=@_;
	my $dbh = C4::Context->dbh;
	my $sth;
	#verifico la existencia del registro
	my $query=	"Delete From `control_editoriales_sinonimos` 
			Where(id = ?)and(editorial = ?)";
	$sth=$dbh->prepare($query);
	$sth->execute($idEditorial, $sinonimo);

	$sth->finish;
}

#*************************************Seudonimos*************************************************

sub traerSeudonimosAutor(){
	my ($idAutor)=@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT id, id2
		   FROM `control_autores_seudonimos` 
		   WHERE id= ? or id2= ?";
	my $sth=$dbh->prepare($query);
	$sth->execute($idAutor, $idAutor);

	$query="SELECT completo
		FROM `autores` 
		WHERE id= ?
		ORDER By completo";
	
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
	my $query="SELECT id, id2
		   FROM `control_temas_seudonimos` 
		   WHERE id= ? or id2= ?";
	my $sth=$dbh->prepare($query);
	$sth->execute($idTema, $idTema);

	$query="SELECT nombre 
		FROM `temas` 
		WHERE id= ?
		ORDER By nombre";
	
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
	my $query="SELECT id, id2
		   FROM `control_editoriales_seudonimos` 
		   WHERE id= ? or id2= ?";
	my $sth=$dbh->prepare($query);
	$sth->execute($idEditorial, $idEditorial);

	$query="SELECT editorial 
		FROM `editoriales` 
		WHERE id= ?
		ORDER By editorial";
	
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


sub insertSeudonimosAutor(){
#Inserto los seudonimos pasados $seudonimos_arrayref al autor pasado por parametro
	my ($seudonimos_arrayref, $idAutor)=@_;
	my $dbh = C4::Context->dbh;
	my $sth;
	my $cant= scalar(@$seudonimos_arrayref);
	my $seudonimo;

	for(my $i=0;$i<$cant;$i++){
		$seudonimo= $seudonimos_arrayref->[$i]->{'ID'};
		#verifico la existencia del registro
		my $queryExist="Select count(*) 
				From `control_autores_seudonimos` 
				Where((id = $seudonimo)and(id2 = $idAutor))
				or((id2 = $seudonimo)and(id = $idAutor))";
		$sth=$dbh->prepare($queryExist);
		$sth->execute();

		my $Existe = $sth->fetchrow;

		#si no existe el registro
		if($Existe eq 0){		
			my $query="INSERT INTO `control_autores_seudonimos`(id, id2)
				   VALUES(?,?)";
			$sth=$dbh->prepare($query);
			$sth->execute($idAutor, $seudonimo);
        	}
		$sth->finish;
	}
}


sub eliminarSeudonimosAutor(){
#Elimino el $seudonimo del autor pasado por parametro
	my ($idAutor,$seudonimo)=@_;
	my $dbh = C4::Context->dbh;
	my $sth;
	#verifico la existencia del registro
	my $queryExist="Delete From `control_autores_seudonimos` 
			Where((id = $idAutor)and(id2 = $seudonimo))
			or(id2 = $idAutor)and(id = $seudonimo";
	$sth=$dbh->prepare($queryExist);
	$sth->execute();

	$sth->finish;
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
		my $queryExist="Select count(*) 
				From `control_temas_seudonimos` 
				Where((id = $seudonimo)and(id2 = $idTema))
				or((id2 = $seudonimo)and(id = $idTema))";
		$sth=$dbh->prepare($queryExist);
		$sth->execute();

		my $Existe = $sth->fetchrow;

		#si no existe el registro
		if($Existe eq 0){		
			my $query="INSERT INTO `control_temas_seudonimos`(id, id2)
				   VALUES(?,?)";
			$sth=$dbh->prepare($query);
			$sth->execute($idTema, $seudonimo);
        	}
		$sth->finish;
	}
}

sub eliminarSeudonimosTema(){
#Elimino el $seudonimo del tema pasados por parametro
	my ($idTema,$seudonimo)=@_;
	my $dbh = C4::Context->dbh;
	my $sth;
	#verifico la existencia del registro
	my $queryExist="Delete From `control_temas_seudonimos` 
			Where((id = $idTema)and(id2 = $seudonimo))
			or((id2 = $idTema)and(id = $seudonimo))";
	$sth=$dbh->prepare($queryExist);
	$sth->execute();

	$sth->finish;
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
		my $queryExist="Select count(*) 
				From `control_editoriales_seudonimos` 
				Where((id = $seudonimo)and(id2 = $idEditorial))
				or((id2 = $seudonimo)and(id = $idEditorial))";
		$sth=$dbh->prepare($queryExist);
		$sth->execute();

		my $Existe = $sth->fetchrow;

		#si no existe el registro
		if($Existe eq 0){		
			my $query="INSERT INTO `control_editoriales_seudonimos`(id, id2)
				   VALUES(?,?)";
			$sth=$dbh->prepare($query);
			$sth->execute($idEditorial, $seudonimo);
        	}
		$sth->finish;
	}
}

sub eliminarSeudonimosEditorial(){
#Elimino el seudonimo de la editorial pasados por parametro
	my ($idEditorial,$seudonimo)=@_;
	my $dbh = C4::Context->dbh;
	my $sth;
	#verifico la existencia del registro
	my $queryExist="Delete From `control_editoriales_seudonimos` 
			Where((id = $idEditorial)and(id2 = $seudonimo))
			or((id2 = $idEditorial)and(id = $seudonimo))";
	$sth=$dbh->prepare($queryExist);
	$sth->execute();

	$sth->finish;
}

1;
