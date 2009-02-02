package C4::AR::ImportacionIsoMARC;

#
#para la importacion de codigos iso a marc y donde estan las descripciones de cada campo y sus
#subcampos
#

use strict;
require Exporter;

use C4::Context;
use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(&ui
           &campoIso
	   &subCampoIso
	   &datosCompletos
	   &insertDescripcion
	   &listadoDeCodigosDeCampo
	   &mostrarCamposMARC
	   &mostrarSubCamposMARC
	   &list
	   &insertNuevo
	   &update
);

#
#Dado una Unid. de Informacion sus campos y subcampos ISO me devuelve la descripcion correspondiente
#
sub checkDescription{
	my $dbh = C4::Context->dbh;
	my $query ="Select descripcion 
	              From isomarc 
        	      Where (campoIso=? and subCampoIso=?  and ui=?) ";
	my $sth=$dbh->prepare($query);
	$sth->execute(&ui,&campoIso,&subCampoIso);
 
	return ($sth->fetchrow_hashref);
}


#
#Dado una Unid. de Informacion  inserto la descripcion correspondiente

sub insertDescripcion{ 
        my ($descripcion,$id)=@_; 
        my $dbh = C4::Context->dbh;
	my $query ="update  isomarc set descripcion=?
	    	     Where (id=?)";
 	my $sth=$dbh->prepare($query);
	$sth->execute($descripcion,$id);
        $sth-> finish;                                                                                             
}


sub insertUnidadInformacion{
	my $dbh = C4::Context->dbh;
	my $query ="Insert into isomarc (ui) values (?)";
	my $sth=$dbh->prepare($query);
	$sth->execute(&ui);
	$sth->finish;
}

#Datos para mostrar que estan en la tabla iso2709, para que carguen las descripciones de los
#campos y subcampos asi despues se puede hacer la importacion
#
sub datosCompletos{
	my ($campoIso,$branchcode)=@_;
	my $dbh = C4::Context->dbh;
	my @results;
	my $query ="Select * from isomarc ";
	$query.= "where campoIso = ".$campoIso." and ui='".$branchcode."'"; #Comentar para lograr el listado completo
	my $sth=$dbh->prepare($query);
	$sth->execute();
        while (my $data=$sth->fetchrow_hashref){
		 #if ($data->{'ui'} eq "") {$data->{'ui'}="-" };
		 if ($data->{'subCampoIso'} eq "") {
                        $data->{'subCampoIso'}="-" };
             	push(@results,$data);
		} 
	return (@results);
}

#Muestro todas las tablas de la base de datos

#sub mostrarTablas{
#        my $dbh = C4::Context->dbh;
#        my @results;
#        my $query ="show tables";
#        my $sth=$dbh->prepare($query);
#        $sth->execute();
#	push(@results,""); #Agrago un primer elemento vacio
#        while (my $data=$sth->fetchrow_hashref){
#	#	if (($data->{'Tables_in_Econo'} eq 'items') 
#	#		|| ($data->{'Tables_in_Econo'} eq 'biblio')
#	#		|| ($data->{'Tables_in_Econo'} eq 'biblioitems')
#	#	) {
#			my $nombre = $data->{'Tables_in_Econo'};
# 			push(@results,$nombre);
#	#	}
#	}
#	return (@results);
#}

#Dado el nombre de una tabla me devuelve todos sus campos
#

sub mostrarCamposMARC{
       my $dbh = C4::Context->dbh;
	my @results;
       my $query ="select distinct (tagfield) from pref_estructura_subcampo_marc order by tagfield";
       my $sth=$dbh->prepare($query);
        $sth->execute();
	while (my $data=$sth->fetchrow_hashref){
	push(@results,$data->{'tagfield'});
	}
        $sth->finish;
        return (@results);
}
#Devuelve todos los campos y subcampos marc
#

sub mostrarSubCamposMARC{
       my $dbh = C4::Context->dbh;
	my @results;
       my $query ="select tagfield,tagsubfield,liblibrarian,repeatable from pref_estructura_subcampo_marc order by tagfield";
       my $sth=$dbh->prepare($query);
        $sth->execute();
       while (my $data=$sth->fetchrow_hashref){
	push(@results,$data);
	}
        $sth->finish;
        return (@results);
}
                                                                                                                             
#Inserto una tupla completa nueva
#
sub insertNuevo{
        my($campo5,$campo9,$campoIso, $subCampoIso,$descripcion,$ui,$orden,$separador,$MARCfield,$MARCsubfield)=@_;
	if ($descripcion eq "") {$descripcion= undef;}
        my $dbh = C4::Context->dbh;
        my $query ="insert into isomarc (campo5,campo9,campoIso, subCampoIso,descripcion,ui,orden,separador,MARCfield,MARCsubfield) values(?,?,?,?,?,?,?,?)"; 
        my $sth=$dbh->prepare($query);
        $sth->execute($campo5,$campo9,$campoIso, $subCampoIso,$descripcion,$ui,$orden,$separador,$MARCfield,$MARCsubfield);
        $sth->finish;
}
#Inserto una tupla completa nueva
#
sub update{
        my($campo5,$campo9,$campoIso, $subCampoIso,$descripcion,$ui,$orden,$separador,$MARCfield,$MARCsubfield,$id)=@_;
	if ($descripcion eq "") {$descripcion= undef;}
        my $dbh = C4::Context->dbh;
        my $query ="update  isomarc set campo5=?,campo9=?,campoIso=?, subCampoIso=?,descripcion=?,ui=?,orden=?,separador=?,MARCfield=?,MARCsubfield=? where (id=?)";
        my $sth=$dbh->prepare($query);
        $sth->execute($campo5,$campo9,$campoIso, $subCampoIso,$descripcion,$ui,$orden,$separador,$MARCfield,$MARCsubfield,$id);
        $sth-> finish;
}
#Inserto una tupla completa nueva
#
sub borrar{
        my($id)=@_;
        my $dbh = C4::Context->dbh;
        my $query ="delete  isomarc (id=?)";
        my $sth=$dbh->prepare($query);
        $sth->execute($id);
        $sth-> finish;
}


sub listadoDeCodigosDeCampo{
        my($ui)=@_;
        my $dbh = C4::Context->dbh;
        my @results;
        my $query ="select campoIso from isomarc where ui=? group by campoIso order by campoIso";
        my $sth=$dbh->prepare($query);
        $sth->execute($ui);
        while (my $data=$sth->fetchrow_hashref){
                push(@results,$data);
        }
        return (@results);
}
sub list{
        my $dbh = C4::Context->dbh;
        my %results;
        my $query ="select campoIso,subCampoIso,MARCfield as tagfield ,MARCsubfield as tagsubfield from isomarc order by campoIso;";
        my $sth=$dbh->prepare($query);
        $sth->execute();
        while (my $data=$sth->fetchrow_hashref){
		my @resp;
		@resp= ($data->{'tagfield'},$data->{'tagsubfield'});
		$results{$data->{'campoIso'},$data->{'subCampoIso'}}=@resp; 
	        }
        return (%results);
}
