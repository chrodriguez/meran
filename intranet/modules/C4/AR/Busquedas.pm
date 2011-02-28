package C4::AR::Busquedas;

#Copyright (C) 2003-2008  Linti, Facultad de Informática, UNLP
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
#Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

use strict;
require Exporter;
use C4::Context;
use Date::Manip;
use C4::Date;
use C4::AR::Catalogacion;
use C4::AR::Utilidades;
use C4::AR::Reservas;
use C4::AR::Nivel1;
use C4::AR::Nivel2;
use C4::AR::Nivel3;
use C4::AR::PortadasRegistros;
use Text::Aspell;
use C4::Modelo::RepHistorialBusqueda;
use Sphinx::Search  qw(SPH_MATCH_ANY SPH_MATCH_PHRASE SPH_MATCH_BOOLEAN SPH_MATCH_EXTENDED SPH_MATCH_ALL SPH_SORT_RELEVANCE);
use Sphinx::Manager qw(new);

use vars qw(@EXPORT_OK @ISA);
@ISA=qw(Exporter);
@EXPORT_OK=qw(
    &busquedaAvanzada
    &busquedaCombinada
    &armarBuscoPor
    &obtenerEdiciones
    &obtenerGrupos
    &busquedaCombinada_newTemp
    &obtenerDisponibilidadTotal
    &busquedaPorBarcode
    &buscarMapeo
    &buscarMapeoTotal
    &buscarMapeoCampoSubcampo
    &buscarCamposMARC
    &buscarSubCamposMARC
    &buscarAutorPorCond
    &buscarDatoDeCampoRepetible
    &buscarTema

    &filtrarPorAutor
    &MARCDetail

    &getLibrarian
    &getautor
    &getLevel
    &getLevels
    &getCountry
    &getCountryTypes
    &getSupport
    &getSupportTypes
    &getLanguage
    &getLanguages
    &getItemType
    &getItemTypes
    &getborrowercategory
    &getAvail
    &getAvails
    &getTema
    &getNombreLocalidad
    &getBranches
    &getBranch

    &t_loguearBusqueda
);


#==================================================================nerSPHINX====================================================================
# =head2
#     sub generar_indice
# =cut
# sub generar_indice {
#     my ($id1)   = @_;
# 
# #     my $err = system("perl ".C4::Context->config("intranetdir")."/scripts/generar_indice_v2.pl ".$id1);
#     my $command = "perl ".C4::Context->config("intranetdir")."/scripts/generar_indice_v2.pl";
#     my @args    = ($command, $id1);
# 
#     C4::AR::Debug::debug("Busquedas => generar_indice => ejecutando comando ". $command ." con parametro: ".$id1);
# 
#     my $err     = system(@args);
# 
#     if ($err == -1) {
#             C4::AR::Debug::debug("Busquedas => generar_indice => ERROR => $!");
#     }
# }

=head2
    sub reindexar
=cut
# sub reindexar{
#     C4::AR::Debug::debug("Busquedas => reindexar => run_indexer => ");
# 
#     my $mgr = Sphinx::Manager->new({ config_file => C4::Context->config("sphinx_conf") });
#     #verifica si sphinx esta levantado, sino lo está lo levanta, sino no hace nada    
#     sphinx_start($mgr);
# 
#     my @args;
#     push (@args, '--all');
#     push (@args, '--rotate');
#     push (@args, '--quiet');
# 
#     $mgr->indexer_args(\@args);
#     $mgr->run_indexer();
#     C4::AR::Debug::debug("Busquedas => reindexar => --all --rotate => ");
# }
# 
# =head2
#     sub sphinx_start
#     verifica si sphinx esta levantado, sino lo está lo levanta, sino no hace nada
# =cut
# sub sphinx_start{
#     my ($mgr)= @_;
#     if (exists $ENV{MOD_PERL}){
#         defined (my $kid = fork) or die "Cannot fork: $!\n";
#         if ($kid) {
#         # Parent runs this block
#       } else {
#           # Child runs this block
#           # some code comes here
#           $mgr = $mgr || Sphinx::Manager->new({ config_file => C4::Context->config("sphinx_conf") });
#           $mgr->debug(0);
#           my $pids = $mgr->get_searchd_pid;
#           if(scalar(@$pids) == 0){
#               C4::AR::Debug::debug("Utilidades => generar_indice => el sphinx esta caido!!!!!!! => ");
#               $mgr->start_searchd;
#               C4::AR::Debug::debug("Utilidades => generar_indice => levantó sphinx!!!!!!! => ");
#           }
#           CORE::exit(0);
#       }
#   }else{
#       $mgr = $mgr || Sphinx::Manager->new({ config_file => C4::Context->config("sphinx_conf") });
#       $mgr->debug(0);
#       my $pids = $mgr->get_searchd_pid;
#       if(scalar(@$pids) == 0){
#           C4::AR::Debug::debug("Utilidades => generar_indice => el sphinx esta caido!!!!!!! => ");
#           $mgr->start_searchd;
#           C4::AR::Debug::debug("Utilidades => generar_indice => levantó sphinx!!!!!!! => ");
#       }
#   }
# }
#================================================================FIN SPHINX=================================================================



=head2
    sub buscarTodosLosDatosFromNivel2ByCampoSubcampo

    speedy gonzalezzzz
=cut
sub buscarTodosLosDatosFromNivel2ByCampoSubcampo {
    my ($campo, $subcampo) = @_;

    my @filtros;
    my @datos_array;

    my $cat_registro_marc_n2_array_ref = C4::Modelo::CatRegistroMarcN2::Manager->get_cat_registro_marc_n2( query => \@filtros);

    foreach my $n2 (@$cat_registro_marc_n2_array_ref){
        my $marc_record = MARC::Record->new_from_usmarc($n2->getMarcRecord);

        foreach my $field ($marc_record->field($campo)) {
#             C4::AR::Debug::debug("field => ".$field->tag);
        
            foreach my $subfield ($field->subfields()) {
                if ($subfield->[0] eq $subcampo){
#                     C4::AR::Debug::debug("subfield => ".$subfield->[0]);
#                     C4::AR::Debug::debug("dato => ".$subfield->[1]);
                    push (@datos_array, $subfield->[1]);
                }
            }# END foreach my $subfield ($field->subfields())

        }# END foreach my $field ($marc_record->field($campo))
    }

    return (\@datos_array);
}

=item
getLibrarianEstCat
trae el texto para mostrar (librarian), segun campo y subcampo, sino exite, devuelve 0
=cut
sub getLibrarianEstCat{
	my ($campo, $subcampo,$dato, $itemtype)= @_;

	my $dbh = C4::Context->dbh;
	my $query = "SELECT ec.*,ir.idinforef, ir.referencia as tabla, campos, separador, orden";
	$query .= " FROM cat_estructura_catalogacion ec LEFT JOIN pref_informacion_referencia ir ";
	$query .= " ON (ec.id = ir.idestcat) ";
	$query .= " WHERE(ec.campo = ?)and(ec.subcampo = ?)and(ec.itemtype = ?) ";

	my $sth=$dbh->prepare($query);
   	$sth->execute($campo, $subcampo, $itemtype);
	my $nuevoDato;
	my $data=$sth->fetchrow_hashref();

	if($data && $data->{'visible'}){
		if($data->{'referencia'} && $dato ne ""){
		#DA ERROR FIXME	
		#$nuevoDato=&buscarDatoReferencia($dato,$data->{'tabla'},$data->{'campos'},$data->{'separador'});
			$data->{'dato'}=$nuevoDato;
		}
		else{
			$data->{'dato'}=$dato;
		}
	}
	else{
		$data->{'liblibrarian'}=0;
		$data->{'dato'}="";
		$data->{'visible'}=0;
		
	}
#0 si no trae nada
	return $data;
}

=item
getLibrarianEstCatOpac
trae el texto para mostrar (librarian), segun campo y subcampo, sino exite, devuelve 0
=cut
sub getLibrarianEstCatOpac{
	my ($campo, $subcampo, $dato, $itemtype)= @_;

	my $dbh = C4::Context->dbh;

# open(A, ">>/tmp/debug.txt");
# print A "\n";
# print A "entro a getLibrarianEstCatOpac \n";
# print A "*************************************************************************\n";
# print A "campo: $campo \n";
# print A "subcampo: $subcampo \n";
# print A "itemtype: $itemtype \n";
# print A "dato: $dato \n";

my $query = " SELECT * ";
$query .= " FROM cat_estructura_catalogacion_opac eco INNER JOIN";
$query .= " cat_encabezado_item_opac eio ";
$query .= " ON (eco.idencabezado = eio.idencabezado) ";
$query .= " WHERE(eco.campo = ?)and(eco.subcampo = ?) and (visible = 1) ";
$query .= " and (eio.itemtype = ?)";

	my $sth=$dbh->prepare($query);
	$sth->execute($campo, $subcampo, $itemtype);
    	my $data1=$sth->fetchrow_hashref;

	my $data;
	my $textPred;
	my $textSucc;

	if($data1){

		$textPred= $data1->{'textpred'};
		$textSucc= $data1->{'textsucc'};

		my $dbh = C4::Context->dbh;
		my $query = "SELECT ec.*, ir.idinforef, ir.referencia as tabla, campos, separador, orden";
		$query .= " FROM cat_estructura_catalogacion ec LEFT JOIN pref_informacion_referencia ir ";
		$query .= " ON (ec.id = ir.idestcat) ";
		$query .= " WHERE(ec.campo = ?)and(ec.subcampo = ?)and(ec.itemtype = ?) ";

		my $sth=$dbh->prepare($query);
   		$sth->execute($campo, $subcampo, $itemtype);
		my $nuevoDato;
		$data=$sth->fetchrow_hashref();

		if($data->{'referencia'} && $dato ne ""){
		  $nuevoDato=&buscarDatoReferencia($dato,$data->{'tabla'},$data->{'campos'},$data->{'separador'});
# print A "dato nuevo **************************************** $nuevoDato \n";
		  $data->{'dato'}= $nuevoDato;
		  $data->{'textPred'}= $textPred;
		  $data->{'textSucc'}= $textSucc;
#  		  return $textPred." ".$nuevoDato;
		  return $data;
# 		  return $nuevoDato;

		}
		else{
		  $data->{'dato'}= $dato;
		  $data->{'textPred'}= $textPred;
		  $data->{'textSucc'}= $textSucc;
# print A "dato **************************************** $dato \n";
# print A "textpred **************************************** $textPred \n";
# 		  return $textPred." ";
		  return $data;
		}
		
# 		return $textPred." ".$data->{'dato'}." ".$textSucc;
#  		return $textPred." ";

	}
	else {
		$data->{'dato'}= "";
		$data->{'textPred'}= "";
		$data->{'textSucc'}= "";
		return $data;
# 		return 0;
	}
# close(A);

#0 si no trae nada
#  	return $sth->fetchrow_hashref; 
}


=item
getLibrarianMARCSubField
trae el texto para mostrar (librarian), segun campo y subcampo, sino exite, devuelve 0
=cut
sub getLibrarianMARCSubField{
	my ($campo, $subcampo)= @_;
	my $dbh = C4::Context->dbh;

	my $query = " SELECT * ";
	$query .= " FROM pref_estructura_subcampo_marc ";
	$query .= " WHERE (campo = ? )and(subcampo = ?)";

	my $sth=$dbh->prepare($query);
   	$sth->execute($campo, $subcampo);

	return $sth->fetchrow_hashref;
}

=item
getLibrarianIntra
Busca para un campo y subcampo, dependiendo el itemtype, como esta catalogado para mostrar en el template. Busca en la tabla estructura_catalogacion y sino lo encuentra lo busca en marc_subfield_structure que si o si esta.
=cut
sub getLibrarianIntra{
	my ($campo, $subcampo,$dato, $itemtype,$detalleMARC) = @_;

#busca librarian segun campo, subcampo e itemtype
	my $librarian= &getLibrarianEstCat($campo, $subcampo, $dato,$itemtype);

#si no encuentra, busca para itemtype = 'ALL'
	if(!$librarian->{'liblibrarian'}){
		$librarian= &getLibrarianEstCat($campo, $subcampo, $dato,'ALL');
	}
	
	if($librarian->{'liblibrarian'} && !$librarian->{'visible'} && !$detalleMARC){
		#Si esta catalogado y pero no esta visible retorna 0 para que no se vea el dato
		$librarian->{'liblibrarian'}=0;
		$librarian->{'dato'}="";
		return $librarian;
	}
	elsif(!$librarian->{'liblibrarian'}){
		$librarian= &getLibrarianMARCSubField($campo, $subcampo);
		$librarian->{'dato'}=$dato;
	}
	return $librarian;
}

=item
getLibrarianOpac
Busca para un campo y subcampo, dependiendo el itemtype, como esta catalogado para mostrar en el template. Busca en la tabla estructura_catalogacion_opac y sino lo encuentra lo busca en marc_subfield_structure que si o si esta.
=cut
sub getLibrarianOpac{
	my ($campo, $subcampo,$dato, $itemtype,$detalleMARC) = @_;
	my $textPred;	
	my $textSucc;
#busca librarian segun campo, subcampo e itemtype
	my $librarian= &getLibrarianEstCatOpac($campo, $subcampo, $dato, $itemtype);
#si no encuentra, busca para itemtype = 'ALL'
 	if(!$librarian){
 		$librarian= &getLibrarianEstCatOpac($campo, $subcampo, $dato, 'ALL');
 	}
	elsif($detalleMARC){
		$librarian= &getLibrarianMARCSubField($campo, $subcampo);
		$librarian->{'dato'}=$dato;
	}


	return $librarian;
}

sub getLibrarian{
	my ($campo, $subcampo,$dato,$itemtype,$tipo,$detalleMARC)=@_;
	my $librarian;
	if($tipo eq "intra"){
		$librarian=&getLibrarianIntra($campo, $subcampo,$dato, $itemtype,$detalleMARC);
	}else{
		$librarian=&getLibrarianOpac($campo, $subcampo,$dato, $itemtype,$detalleMARC);
	} 
	return $librarian;
}

=item
buscarMapeo
Asocia los campos marc correspondientes con los campos de las tablas de los nivel 1, 2 y 3 (koha) correspondiente al parametro que llega.
=cut
sub buscarMapeo{
	my ($tabla)= @_;
	my $dbh = C4::Context->dbh;
	my %mapeo;
	my $llave;
	my $query = " SELECT * FROM cat_pref_mapeo_koha_marc WHERE tabla = ? ";
	
	my $sth=$dbh->prepare($query);
	$sth->execute($tabla);
	while(my $data=$sth->fetchrow_hashref){
		$llave=$data->{'campo'}.",".$data->{'subcampo'};
		$mapeo{$llave}->{'campo'}=$data->{'campo'};
		$mapeo{$llave}->{'subcampo'}=$data->{'subcampo'};
		$mapeo{$llave}->{'tabla'}=$data->{'tabla'};
		$mapeo{$llave}->{'campoTabla'}=$data->{'campoTabla'};
	}
	return (\%mapeo);
}

=item
buscarMapeoTotal
Busca el mapeo de los campos de todas las tablas de niveles y obtiene el nombre de los campos
=cut
sub buscarMapeoTotal{
	my $dbh = C4::Context->dbh;
	my %mapeo;
	my $llave;
	my $query = " SELECT * FROM cat_pref_mapeo_koha_marc WHERE tabla like 'cat_nivel%' ORDER BY tabla";
	
	my $sth=$dbh->prepare($query);
	$sth->execute();
	while(my $data=$sth->fetchrow_hashref){
		$llave=$data->{'campo'}.",".$data->{'subcampo'};
		$mapeo{$llave}->{'campo'}=$data->{'campo'};
		$mapeo{$llave}->{'subcampo'}=$data->{'subcampo'};
		$mapeo{$llave}->{'tabla'}=$data->{'tabla'};
		$mapeo{$llave}->{'campoTabla'}=$data->{'campoTabla'};
		$mapeo{$llave}->{'nombre'}=$data->{'nombre'};
	}
	return (\%mapeo);
}

sub buscarMapeoCampoSubcampo{
	my ($campo,$subcampo,$nivel)=@_;
	my $dbh = C4::Context->dbh;
	my $tabla="nivel".$nivel;
	my $campoTabla=0;
	my $query = " SELECT campoTabla FROM cat_pref_mapeo_koha_marc WHERE tabla =? AND campo=? AND subcampo=?";
	my $sth=$dbh->prepare($query);
	$sth->execute($tabla,$campo,$subcampo);
	if(my $data=$sth->fetchrow_hashref){
		$campoTabla=$data->{'campoTabla'};
	}
	return $campoTabla;
}

=item
buscarSubCamposMapeo
Busca el mapeo para el subcampo perteneciente al campo que se pasa por parametro.
=cut
sub buscarSubCamposMapeo{
	my ($campo)=@_;
	my $dbh = C4::Context->dbh;
	my %mapeo;
	my $llave;
	my $query = " SELECT * FROM cat_pref_mapeo_koha_marc WHERE tabla like 'cat_nivel%' AND campo = ?";
	
	my $sth=$dbh->prepare($query);
	$sth->execute($campo);
	while(my $data=$sth->fetchrow_hashref){
		$llave=$data->{'campo'}.",".$data->{'subcampo'};
		$mapeo{$llave}->{'subcampo'}=$data->{'subcampo'};
		$mapeo{$llave}->{'tabla'}=$data->{'tabla'};
	}
	return (\%mapeo);
}


=item
obtenerEdiciones
obtiene las ediciones que pose un id de nivel 1.
=cut
sub obtenerEdiciones{
	my ($id1,$itemtype)=@_;
	my @ediciones;
	my $dbh = C4::Context->dbh;
	my $query="SELECT * FROM cat_nivel2 WHERE id1=? ";

	if($itemtype != -1 && $itemtype ne "" && $itemtype ne "ALL"){
		$query .=" and tipo_documento = '".$itemtype."'";
	}

	my $sth=$dbh->prepare($query);
	$sth->execute($id1);
	my $i=0;
	while(my $data=$sth->fetchrow_hashref){
		$ediciones[$i]->{'anio_publicacion'}=$data->{'anio_publicacion'};
		$i++;
	}
	return(@ediciones);
}

=item
obtenerGrupos
Esta funcion devuelve los datos de los grupos a mostrar en una busaqueda dado un id1. Se puede filtrar por tipo de documento.
=cut
sub obtenerGrupos {
	my ($id1,$itemtype,$type)=@_;
	
	#Obtenemos los niveles 2
	my $niveles2 = C4::AR::Nivel2::getNivel2FromId1($id1);
	
	my @result;
	my $res=0;
	foreach my $nivel2 (@$niveles2){
	    $result[$res]->{'id2'}=$nivel2->getId2;
            $result[$res]->{'edicion'}= $nivel2->getEdicion;
	    $result[$res]->{'anio_publicacion'}=$nivel2->getAnio_publicacion;
	    $res++;
	}

	return (\@result);
}


sub obtenerDisponibilidadTotal{
	my ($id1, $itemtype, $only_available) = @_;

	my @disponibilidad;
	my $dbh = C4::Context->dbh;
=item
	my $query = " SELECT count(*) as cant, id_disponibilidad FROM cat_nivel3 WHERE id1=? ";
	my $sth;

	if ($itemtype == -1 || $itemtype eq "" || $itemtype eq "ALL") {
	    $query .=" GROUP BY id_disponibilidad";
    
	    $sth = $dbh->prepare($query);
	    $sth->execute($id1);
	} else {
        #Filtro tb por tipo de item
	    $query .= " AND id2 IN ( SELECT id2 FROM cat_nivel2 WHERE tipo_documento = ? )  GROUP BY id_disponibilidad";
    
	    $sth = $dbh->prepare($query);
	    $sth->execute($id1, $itemtype);
	}
=cut

    my ($cat_ref_tipo_nivel3_array_ref) = C4::AR::Nivel3::getNivel3FromId1($id1);

	
	my $cant_para_domicilio = 0;
    my $cant_para_sala = 0;
    my $i = 0;

    foreach my $n3 (@$cat_ref_tipo_nivel3_array_ref){

        if ($n3->getIdDisponibilidad == 0) {
        #DOMICILIO    
#         C4::AR::Debug::debug("Busquedas => obtenerDisponibilidadTotal => DOMICILIO");
            $cant_para_domicilio++;
        } else {
        #PARA SALA
#         C4::AR::Debug::debug("Busquedas => obtenerDisponibilidadTotal => PARA SALA");
            
            $cant_para_sala++;
        }
	}

    $disponibilidad[$i]->{'tipoPrestamo'}   = "Para Domicilio:";
    $disponibilidad[$i]->{'cantTotal'}      = $cant_para_domicilio;

    $i++;
    $disponibilidad[$i]->{'tipoPrestamo'}   = "Para Sala:";
    $disponibilidad[$i]->{'cantTotal'}      = $cant_para_sala;

    $i++;
    $disponibilidad[$i]->{'tipoPrestamo'}   = "Circulaci&oacute;n";
    $disponibilidad[$i]->{'cantTotal'}      = $cant_para_domicilio + $cant_para_sala;
    $disponibilidad[$i]->{'prestados'}      = "Prestados: ";
    $disponibilidad[$i]->{'prestados'}     .= C4::AR::Prestamos::getCountPrestamosDelRegistro($id1);
    $disponibilidad[$i]->{'reservados'}     = "Reservados: ".C4::AR::Reservas::cantReservasPorNivel1($id1);

	return(@disponibilidad);
}


#****************************************************MARC DETAIL**************************************************


=item
buscarCamposMARC
Busca los campos correspondiente a el parametro campoX, para ver en el tmpl de filtradoAvanzado.
=cut
# sub buscarCamposMARC{
# 	my ($campoX) =@_;
# 	my $dbh = C4::Context->dbh;
# 	my $query="SELECT DISTINCT nivel,campo FROM pref_estructura_subcampo_marc ";
# 	$query .=" WHERE nivel > 0 AND campo LIKE ? ORDER BY nivel";
# 	
# 	my $sth=$dbh->prepare($query);
#         $sth->execute($campoX."%");
# 	my @results;
# 	my $nivel;
# 	while(my $data=$sth->fetchrow_hashref){
# 		$nivel="n".$data->{'nivel'}."r";
# 		push (@results,$nivel."/".$data->{'campo'});
# 	}
# 	$sth->finish;
# 	return (@results);
# }

=item
buscarSubCamposMARC
Busca los subcampos correspondiente al parametro de campo y que no sean propios de una tabla de nivel, solo los que estan en tablas de nivel repetibles.
=cut
sub buscarSubCamposMARC{
	my ($campo) =@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT subcampo FROM pref_estructura_subcampo_marc ";
	$query .=" WHERE nivel > 0 AND campo = ? ";
	my $mapeo=&buscarSubCamposMapeo($campo);
	foreach my $llave (keys %$mapeo){
		$query.=" AND (subcampo <> '".$mapeo->{$llave}->{'subcampo'}."' ) ";
	}
	my $sth=$dbh->prepare($query);
        $sth->execute($campo);
	my @results;
	while(my $data=$sth->fetchrow_hashref){
		push (@results, $data->{'subcampo'});
	}

	$sth->finish;
	return (@results);
}



=item
buscarNivel2EnMARC
Busca los datos de la tabla nivel2 y nivel2_repetibles y los devuelve en formato MARC (campo,subcampo,dato).
=cut
sub buscarNivel2EnMARC{
	my ($id1)=@_;
# open(A, ">>/tmp/debug.txt");
# print A "\n";
# print A "desde buscarNivel2EnMARC \n";
	my $dbh = C4::Context->dbh;
	my @nivel2=&buscarNivel2PorId1($id1);
	my $mapeo=&buscarMapeo('cat_nivel2');
	my $id2;
	my $itemtype;
	my $llave;
	my $i=0;
	my $dato;
	my @nivel2Comp;
	foreach my $row(@nivel2){
		$id2=$row->{'id2'};
		$itemtype=$row->{'itemtype'};
		$nivel2Comp[$i]->{'id2'}=$id2;
# print A "			fila: ".$i."\n";
# print A "			id2: ".$id2."\n";
# print A "			itemtype: ".$itemtype."\n";
		$nivel2Comp[$i]->{'itemtype'}=$itemtype;
		foreach my $llave (keys %$mapeo){
			$dato= $row->{$mapeo->{$llave}->{'campoTabla'}};
			$nivel2Comp[$i]->{$llave}=$dato;
# print A "llave ".$llave."\n";
# print A "dato ".$dato."\n";
			$nivel2Comp[$i]->{'campo'}= $mapeo->{$llave}->{'campo'};
			$nivel2Comp[$i]->{'subcampo'}= $mapeo->{$llave}->{'subcampo'};
# 			$i++;
		}
		my $query="SELECT * FROM cat_nivel2_repetible WHERE id2=?";
		my $sth=$dbh->prepare($query);
        	$sth->execute($id2);
		while (my $data=$sth->fetchrow_hashref){
			$llave=$data->{'campo'}.",".$data->{'subcampo'};

			$nivel2Comp[$i]->{'campo'}= $data->{'campo'};
			$nivel2Comp[$i]->{'subcampo'}= $data->{'subcampo'};

			if(not exists($nivel2Comp[$i]->{$llave})){
				$nivel2Comp[$i]->{$llave}= $data->{'dato'};#FALTA BUSCAR REFERENCIA SI ES QUE TIENE!!!!
			}
			else{
				$nivel2Comp[$i]->{$llave}.= " *?* ".$data->{'dato'};
			}
# 			$i++;
# print A "llave ".$llave."\n";
# print A "dato ".$data->{'dato'}."\n";
		}
 		$i++;
# print A "*****************************************Otra HASH********************************************** \n"
	}
	return \@nivel2Comp;
}

sub buscarAutorPorCond{
	my ($cond)=@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT * FROM cat_autor WHERE completo".$cond." ORDER BY apellido";
	my $sth=$dbh->prepare($query);
	$sth->execute();
	my @autores;
	while(my $data=$sth->fetchrow_hashref){
		push(@autores,$data);
	}
	return @autores;
}


sub buscarDatoDeCampoRepetible {
	my ($id,$campo,$subcampo,$nivel)=@_;
	
	my $niveln;
	my $idn;
	if ($nivel eq "1") {$niveln='cat_nivel1_repetible';$idn='id1';} elsif ($nivel eq "2"){$niveln='cat_nivel2_repetible';$idn='id2';} else {$niveln='cat_nivel3_repetible';$idn='id3';}

	my $dbh = C4::Context->dbh;
	my $query="SELECT dato FROM ".$niveln." WHERE campo = ? and subcampo = ? and ".$idn." = ?;";
	my $sth=$dbh->prepare($query);
	$sth->execute($campo,$subcampo,$id);
	my $data=$sth->fetchrow_hashref;
	return $data->{'dato'};
}

# FIXME DEPRECATED
# sub getautor {
#     my ($idAutor) = @_;
#     my $dbh   = C4::Context->dbh;
#     my $sth   = $dbh->prepare("	SELECT id,apellido,nombre,completo 
# 				FROM cat_autor WHERE id = ?");
#     $sth->execute($idAutor);
#     my $data=$sth->fetchrow_hashref; 
#     $sth->finish();
#     return($data);
#  }

# sub getautor {
#     my ($idAutor) = @_;
#     my $dbh   = C4::Context->dbh;
#     my $sth   = $dbh->prepare(" SELECT id,apellido,nombre,completo 
#                 FROM cat_autor WHERE id = ?");
#     $sth->execute($idAutor);
#     my $data=$sth->fetchrow_hashref; 
#     $sth->finish();
# 
# #     $db = $db || C4::Modelo::PermCatalogo->new()->db;
#     my $nivel3_array_ref = C4::Modelo::CatAutor::Manager->get_cat_autor(   
# #                                                                     db => $db,
#                                                                     query   => [ id1 => { eq => $id1} ], 
#                                                                 );
# 
#     return($data);
# }

sub getLevel{
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * from ref_nivel_bibliografico where code = ? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($cod);
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}

#Nivel bibliografico
sub getLevels {
 	my $dbh   = C4::Context->dbh;
  	my $sth   = $dbh->prepare("select * from ref_nivel_bibliografico");
  	my %resultslabels;
  	$sth->execute;
  	while (my $data = $sth->fetchrow_hashref) {
   		$resultslabels{$data->{'code'}}= $data->{'description'};
  	}
  	$sth->finish;
  	return(%resultslabels);
} # sub getlevels

sub  getCountry{
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * FROM ref_pais WHERE iso = ? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($cod);
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}

sub getCountryTypes{
  	my $dbh   = C4::Context->dbh;
  	my $sth   = $dbh->prepare("SELECT * FROM ref_pais ");
 	 my %resultslabels;
  	$sth->execute;
  	while (my $data = $sth->fetchrow_hashref) {
  		$resultslabels{$data->{'iso'}}= $data->{'printable_name'};	
  	}
  	$sth->finish;
  	return(%resultslabels);
} # sub getcountrytypes

sub getSupport{
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * from ref_soporte where idSupport = ? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($cod);
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}


sub getSupportTypes{
  	my $dbh   = C4::Context->dbh;
  	my $sth   = $dbh->prepare("SELECT * FROM ref_soporte");
  	my %resultslabels;
  	$sth->execute;
  	while (my $data = $sth->fetchrow_hashref) {
    		$resultslabels{$data->{'idSupport'}}= $data->{'description'};	
  	}
  	$sth->finish;
  	return(%resultslabels);
} # sub getsupporttypes

sub getLanguage{
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * FROM ref_idioma WHERE idLanguage = ? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($cod);
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}

sub getLanguages{
 	 my $dbh   = C4::Context->dbh;
  	my $sth   = $dbh->prepare("SELECT * FROM ref_idioma");
  	my %resultslabels;
  	$sth->execute;
  	while (my $data = $sth->fetchrow_hashref) {
    		$resultslabels{$data->{'idLanguage'}}= $data->{'description'};	
  	}
  	$sth->finish;
  	return(%resultslabels);
} # sub getlanguages

sub getItemType {
 	my ($type)=@_;
  	my $dbh = C4::Context->dbh;
  	my $sth=$dbh->prepare("SELECT nombre FROM cat_ref_tipo_nivel3 WHERE id_tipo_doc=?");
  	$sth->execute($type);
  	my $dat=$sth->fetchrow_hashref;
  	$sth->finish;

  	return ($dat->{'nombre'});
}

## FIXME DEPRECATED
sub getItemTypes {
 	my $dbh   = C4::Context->dbh;
  	my $sth   = $dbh->prepare("SELECT * FROM cat_ref_tipo_nivel3 ORDER BY nombre");
  	my $count = 0;
  	my @results;

  	$sth->execute;
  	while (my $data = $sth->fetchrow_hashref) {
    		$results[$count] = $data;
    		$count++;
  	}

  	$sth->finish;
  	return($count, @results);
} # sub getitemtypes

=item getborrowercategory
  $description = &getborrowercategory($categorycode);
Given the borrower's category code, the function returns the corresponding
description for a comprehensive information display.
=cut
## FIXME DEPRECATEDDDDDDDDDDDDDDDDDD C4::AR::Busquedas::getborrowercategory
sub getborrowercategory{
	my ($catcode) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT description FROM usr_ref_categoria_socio WHERE categorycode = ?");
	$sth->execute($catcode);
	my $description = $sth->fetchrow();
	$sth->finish();
	return $description;
} # sub getborrowercategory

sub getAvail{
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * from ref_disponibilidad where codigo = ? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($cod);
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}

#Disponibilidad
sub getAvails {
  	my $dbh   = C4::Context->dbh;
  	my $sth   = $dbh->prepare("select * from ref_disponibilidad");
  	my %resultslabels;
  	$sth->execute;
  	while (my $data = $sth->fetchrow_hashref) {
    		$resultslabels{$data->{'codigo'}}= $data->{'nombre'};
  	}
  	$sth->finish;
  	return(%resultslabels);
} # sub getavails


#Temas, toma un id de tema y devuelve la descripcion del tema.
sub getTema{
	my ($idTema)=@_;
	my $dbh = C4::Context->dbh;
        my $query = "SELECT * from cat_tema where id = ? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($idTema);
        my $tema=$sth->fetchrow_hashref;
        $sth->finish();
	return($tema);
}


sub buscarTema{
	my ($search)=@_;

	my $dbh = C4::Context->dbh;
	my $query = '';
	my @bind = ();
	my @results;
	my @key=split(' ',$search->{'tema'});
	my $count=@key;
	my $i=1;

	$query="Select distinct cat_tema.id, cat_tema.nombre from cat_nivel1_repetible inner join 
			cat_tema on cat_tema.id= cat_nivel1_repetible.dato  where (campo='650' and subcampo='a') and
			((cat_tema.nombre like ? or cat_tema.nombre like ?)";
	@bind=("$key[0]%","% $key[0]%");
	while ($i < $count){
		$query .= " and (cat_tema.nombre like ? or cat_tema.nombre like ?)";
		push(@bind,"$key[$i]%","% $key[$i]%");
		$i++;
	}
	$query .= ")";

	my $sth=$dbh->prepare($query);
	$sth->execute(@bind);

	my $i=0;
  	while (my $data=$sth->fetchrow_hashref){
    		push @results, $data;
    		$i++;
  	}
	my $count=$i;
	$sth->finish;

	return($count,@results);
}


=item
getNombreLocalidad
Devuelve el nombre de la localidad que se pasa por parametro.
=cut
## FIXME DEPRECATEDDDDDDDDDDDDDDDDDD   C4::AR::Busquedas::getNombreLocalidad
sub getNombreLocalidad{
	my ($catcode) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT nombre FROM ref_localidad WHERE localidad = ?");
	$sth->execute($catcode);
	my $description = $sth->fetchrow();
	$sth->finish();
	if ($description) {return $description;}
	else{return "";}
}

=item
getBranches
Devuelve una hash con todas bibliotecas y sus relaciones.
=cut

sub getBranches {
# returns a reference to a hash of references to branches...
	my %branches;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("	SELECT pref_unidad_informacion.*,categorycode 
				FROM pref_unidad_informacion INNER JOIN pref_relacion_unidad_informacion 
				ON pref_unidad_informacion.id_ui=pref_relacion_unidad_informacion.branchcode");
	$sth->execute;
	while (my $branch=$sth->fetchrow_hashref) {
		$branches{$branch->{'id_ui'}}=$branch;
	}
	return (\%branches);
}

=item
getBranch
=cut
sub getBranch{
    my($branch) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "SELECT * FROM pref_unidad_informacion WHERE id_ui=?";
    my $sth   = $dbh->prepare($query);
    $sth->execute($branch);
    return $sth->fetchrow_hashref;
}


########################################################## NUEVOS!!!!!!!!!!!!!!!!!!!!!!!!!! #################################################


sub _getMatchMode{
  my ($tipo) = @_;
  #por defecto se setea este match_mode
  my $tipo_match = SPH_MATCH_ANY;

  if($tipo eq 'SPH_MATCH_ANY'){
    #Match any words
    $tipo_match = SPH_MATCH_ANY;
  }elsif($tipo eq 'SPH_MATCH_PHRASE'){
    #Exact phrase match
    $tipo_match = SPH_MATCH_PHRASE;
  }elsif($tipo eq 'SPH_MATCH_BOOLEAN'){
    #Boolean match, using AND (&), OR (|), NOT (!,-) and parenthetic grouping
    $tipo_match = SPH_MATCH_BOOLEAN;
  }elsif($tipo eq 'SPH_MATCH_EXTENDED'){
    #Extended match, which includes the Boolean syntax plus field, phrase and proximity operators
    $tipo_match = SPH_MATCH_EXTENDED;
  }elsif($tipo eq 'SPH_MATCH_ALL'){
    #Match all words
    $tipo_match = SPH_MATCH_ALL;
  }
}

sub index_update{
  system('indexer --rotate --all');
}

sub getSuggestion{
    my ($search,$cant_result_busqueda,$intra,$obj_for_log) = @_;
    my $speller = Text::Aspell->new;
    my $lang = C4::AR::Auth::getUserLocale();
    C4::AR::Debug::debug("******************* USER LANG DE SUGGESTIONS: ".$lang);

    $speller->set_option('lang',$lang);
    my $suggestion = "";
    my @words = split(/ /,$search);
    my $total_found = 0;
    my $cont = 0;
    while ( ($total_found <= 0) && ($cont < 50) ){
        $suggestion="";
        foreach my $word (@words){
            my @suggestions = $speller->suggest($word);
            $suggestion.= @suggestions[$cont]." ";
        }
        my %hash = {};
#         if (!$intra){
            $suggestion = Encode::encode_utf8($suggestion);
#         }
        ($total_found) = busquedaCombinada_newTemp($suggestion,\%hash,$obj_for_log,1);
        $cont++;
    }

    if ( ($suggestion ne $search) && (C4::AR::Utilidades::validateString($suggestion)) ){
        if ( ($cant_result_busqueda < 10) && ($total_found) ){
            return ($suggestion);
        }
    }
    return (0);
}

sub busquedaAvanzada_newTemp{
    my ($params,$session) = @_;

    use Sphinx::Search;
    
    my $sphinx = Sphinx::Search->new();
    my $query = '';
    my $tipo = 'SPH_MATCH_EXTENDED';
    
    if($params->{'titulo'} ne ""){
        $query .= ' @titulo "'.$params->{'titulo'};
	    if($params->{'tipo'} eq "normal"){
	        $query .= "*";
	    }
	    $query .='"';
    }

    if($params->{'autor'} ne ""){
        $query .= ' @autor "'.$params->{'autor'};

        if($params->{'tipo'} eq "normal"){
            $query .= "*";
        }
        $query .='"';
    }

    if($params->{'tipo_nivel3_name'} ne ""){
        $query .= ' @string "'."cat_ref_tipo_nivel3%".$params->{'tipo_nivel3_name'};

        $query .='"';
    }



    if ($params->{'only_available'}){
        $query .= ' @string "ref_disponibilidad%'.C4::Modelo::RefDisponibilidad::paraPrestamoValue.'"';
    }
    
    C4::AR::Debug::debug("tipo_nivel3_name tipo_nivel3_name tipo_nivel3_name =>=> ".$params->{'tipo_nivel3_name'});

    C4::AR::Debug::debug("Busquedas => query string => ".$query);

    my $tipo_match = C4::AR::Utilidades::getSphinxMatchMode($tipo);

    $sphinx->SetMatchMode($tipo_match);
    #$sphinx->SetSortMode(SPH_SORT_RELEVANCE);
    $sphinx->SetSortMode(SPH_SORT_ATTR_ASC,"titulo_local");
    $sphinx->SetEncoders(\&Encode::encode_utf8, \&Encode::decode_utf8);
    $sphinx->SetLimits($params->{'ini'}, $params->{'cantR'});

    # NOTA: sphinx necesita el string decode_utf8
    my $results = $sphinx->Query($query);

    my @id1_array;
    my $matches = $results->{'matches'};
    my $total_found = $results->{'total_found'};
    $params->{'total_found'} = $total_found;

    C4::AR::Debug::debug("total_found: ".$total_found);
    C4::AR::Debug::debug("Busquedas.pm => LAST ERROR: ".$sphinx->GetLastError());
    C4::AR::Debug::debug("MATCH_MODE => ".$tipo);
    
    foreach my $hash (@$matches){
      my %hash_temp = {};
      $hash_temp{'id1'} = $hash->{'doc'};
      $hash_temp{'hits'} = $hash->{'weight'};

      push (@id1_array, \%hash_temp);
    }

    my ($total_found_paginado, $resultsarray);
    #arma y ordena el arreglo para enviar al cliente
    ($total_found_paginado, $resultsarray) = C4::AR::Busquedas::armarInfoNivel1($params, @id1_array);
    #se loquea la busqueda
    C4::AR::Busquedas::logBusqueda($params, $session);

    return ($total_found, $resultsarray);
}

sub busquedaPorTema{
    
    my ($tema, $session, $obj_for_log) = @_;
    
    $obj_for_log->{'match_mode'} = 'SPH_MATCH_PHRASE';
    
    $tema = "tema@".$tema; #FIXME ES ASI????????????????????????
    
    my ($cantidad, $resultId1, $suggested) = C4::AR::Busquedas::busquedaCombinada_newTemp($tema, $session, $obj_for_log);


    return ($cantidad, $resultId1, $suggested); 
}

sub busquedaPorISBN{
	
	my ($isbn, $session, $obj_for_log) = @_;
	
	
	$obj_for_log->{'match_mode'} = 'SPH_MATCH_PHRASE';
	
	$isbn = "isbn@".$isbn;
	
	my ($cantidad, $resultId1, $suggested) = C4::AR::Busquedas::busquedaCombinada_newTemp($isbn, $session, $obj_for_log);
	

    return ($cantidad, $resultId1, $suggested);	
}

sub busquedaCombinada_newTemp{
	
	
################### FIXME hacer el filtro de disponible con ref_disponibilidad%	
	
	use Sphinx::Search;
	
    my ($string_utf8_encoded,$session,$obj_for_log,$only_sphinx) = @_;

    $string_utf8_encoded = Encode::decode_utf8($string_utf8_encoded);
    my $from_suggested = $obj_for_log->{'from_suggested'} || 0;
    my @searchstring_array = C4::AR::Utilidades::obtenerBusquedas($string_utf8_encoded);
    my $string_suggested;
    $only_sphinx = $only_sphinx || 0;
    my $sphinx = Sphinx::Search->new();
    my $query = "";

    my $tipo        = $obj_for_log->{'match_mode'}||'SPH_MATCH_ALL';
    my $tipo_match  = C4::AR::Utilidades::getSphinxMatchMode($tipo);

    C4::AR::Debug::debug("Busquedas => match_mode ".$tipo);

    #se arma el query string
    foreach my $string (@searchstring_array){

        if($tipo eq 'SPH_MATCH_PHRASE'){
            $query .=  " ".$string;
        } else {
            $query .=  " ".$string."*";
        }
    }

    C4::AR::Debug::debug("Busquedas => query string ".$query);


    $sphinx->SetMatchMode($tipo_match);

#    $sphinx->SetSortMode(SPH_SORT_RELEVANCE);
   $sphinx->SetSortMode(SPH_SORT_ATTR_ASC,"titulo_local");
    
    $sphinx->SetEncoders(\&Encode::encode_utf8, \&Encode::decode_utf8);

    #FIX porque cuando viene 1, se saltea el primer resultado
    if ($obj_for_log->{'ini'}==1){
      $obj_for_log->{'ini'} = 0;
    }


    if (!$only_sphinx){
        $sphinx->SetLimits($obj_for_log->{'ini'}, $obj_for_log->{'cantR'});
    }
    # NOTA: sphinx necesita el string decode_utf8
    my $results = $sphinx->Query($query);

    my ($total_found_paginado, $resultsarray);
    my @id1_array;
    my $matches = $results->{'matches'};
    my $total_found = $results->{'total_found'};

    if ($only_sphinx){
        return ($total_found);
    }
#arma y ordena el arreglo para enviar al cliente
    $obj_for_log->{'total_found'} = $total_found;
#     C4::AR::Utilidades::printHASH($results);
    C4::AR::Debug::debug("total_found: ".$total_found);
    C4::AR::Debug::debug("Busquedas.pm => LAST ERROR: ".$sphinx->GetLastError());
    foreach my $hash (@$matches){
        my %hash_temp = {};
        $hash_temp{'id1'} = $hash->{'doc'};
        $hash_temp{'hits'} = $hash->{'weight'};
        push (@id1_array, \%hash_temp);
    }

    ($total_found_paginado, $resultsarray) = C4::AR::Busquedas::armarInfoNivel1($obj_for_log, @id1_array);
    #se loquea la busqueda
    C4::AR::Busquedas::logBusqueda($obj_for_log, $session);

    if ( (!$from_suggested) && ($total_found<=3) && ($tipo ne 'SPH_MATCH_PHRASE') ){
        $string_suggested = getSuggestion($string_utf8_encoded,$total_found,1,$obj_for_log);
    }
    

    return ($total_found, $resultsarray,$string_suggested);
}




sub armarInfoNivel1{
    my ($params, @resultId1)    = @_;

    my $tipo_nivel3_name        = $params->{'tipo_nivel3_name'};
    my $only_available          = $params->{'only_available'};
    my @result_array_paginado   = @resultId1;
    my $cant_total              = scalar(@resultId1);
    my @result_array_paginado_temp;

    for(my $i=0;$i<scalar(@result_array_paginado);$i++ ) {

        my $nivel1 = C4::AR::Nivel1::getNivel1FromId1(@result_array_paginado[$i]->{'id1'});

        if($nivel1){
#                 C4::AR::Debug::debug("NIVEL 1 PARA FAVORITOS: ".@result_array_paginado[$i]->{'id1'});
#                 C4::AR::Debug::debug("NIVEL 1 PARA FAVORITOS: ".($nivel1->toMARC)->as_formatted);
        # TODO ver si esto se puede sacar del resultado del indice asi no tenemos q ir a buscarlo
            @result_array_paginado[$i]->{'titulo'}              = $nivel1->getTitulo();
            my $autor_object                                    = $nivel1->getAutorObject();
#             @result_array_paginado[$i]->{'nomCompleto'}         = $nivel1->getAutorObject->getCompleto();
#             @result_array_paginado[$i]->{'idAutor'}             = $nivel1->getAutorObject->getId();
            @result_array_paginado[$i]->{'nomCompleto'}         = $autor_object->getCompleto();
            @result_array_paginado[$i]->{'idAutor'}             = $autor_object->getId();
            @result_array_paginado[$i]->{'esta_en_favoritos'}   = C4::AR::Nivel1::estaEnFavoritos($nivel1->getId1());
            #aca se procesan solo los ids de nivel 1 que se van a mostrar
            #se generan los grupos para mostrar en el resultado de la consulta
            my $ediciones           = &C4::AR::Busquedas::obtenerGrupos(@result_array_paginado[$i]->{'id1'}, $tipo_nivel3_name, "INTRA");
            my $nivel2_array_ref    = &C4::AR::Nivel2::getNivel2FromId1($nivel1->getId1);

            @result_array_paginado[$i]->{'grupos'} = 0;
            if(scalar(@$ediciones) > 0){
                @result_array_paginado[$i]->{'grupos'}  = $ediciones;
            }

#             @result_array_paginado[$i]->{'portada_registro'}=  C4::AR::PortadasRegistros::getImageForId1(@result_array_paginado[$i]->{'id1'},'S');
#             @result_array_paginado[$i]->{'portada_registro_medium'}=  C4::AR::PortadasRegistros::getImageForId1(@result_array_paginado[$i]->{'id1'},'M');
#             @result_array_paginado[$i]->{'portada_registro_big'}=  C4::AR::PortadasRegistros::getImageForId1(@result_array_paginado[$i]->{'id1'},'L');
# FIXME para que se hace esto por nivel 1 ?????????????????????????????????????????????
            my $images_n1_hash_ref = C4::AR::PortadasRegistros::getAllImageForId1(@result_array_paginado[$i]->{'id1'});
# C4::AR::PortadasRegistros::getAllImageForId1(@result_array_paginado[$i]->{'id1'});

            @result_array_paginado[$i]->{'portada_registro'}        =  $images_n1_hash_ref->{'S'};
            @result_array_paginado[$i]->{'portada_registro_medium'} =  $images_n1_hash_ref->{'M'};
            @result_array_paginado[$i]->{'portada_registro_big'}    =  $images_n1_hash_ref->{'L'};

            
            my @nivel2_portadas;
            if (scalar(@$nivel2_array_ref)>1){
                for(my $i=0;$i<scalar(@$nivel2_array_ref);$i++){
                    my $hash_nivel2;
# TODO preguntar al mono pq se busca la imagen por nivel 1 y 2 ??????????????????????????????????????????
#                     my $images_n2_hash_ref = C4::AR::PortadasRegistros::getAllImageForId2($nivel2_array_ref->[$i]->getId2);
                    my $images_n2_hash_ref                      = $nivel2_array_ref->[$i]->getAllImage();
#                     $hash_nivel2->{'portada_registro'}=  C4::AR::PortadasRegistros::getImageForId2($nivel2_array_ref->[$i]->getId2,'S');
#                     $hash_nivel2->{'portada_registro_medium'}=  C4::AR::PortadasRegistros::getImageForId2($nivel2_array_ref->[$i]->getId2,'M');
#                     $hash_nivel2->{'portada_registro_big'}=  C4::AR::PortadasRegistros::getImageForId2($nivel2_array_ref->[$i]->getId2,'L');
                    $hash_nivel2->{'portada_registro'}          =  $images_n2_hash_ref->{'S'};
                    $hash_nivel2->{'portada_registro_medium'}   =  $images_n2_hash_ref->{'M'};
                    $hash_nivel2->{'portada_registro_big'}      =  $images_n2_hash_ref->{'L'};

                    push(@nivel2_portadas, $hash_nivel2);
                }

                @result_array_paginado[$i]->{'portadas_grupo'}  = \@nivel2_portadas;
            }
            #se obtine la disponibilidad total 
            @result_array_paginado[$i]->{'rating'}              =  C4::AR::Nivel2::getRatingPromedio($nivel2_array_ref);

            my @disponibilidad = &C4::AR::Busquedas::obtenerDisponibilidadTotal(@result_array_paginado[$i]->{'id1'}, $tipo_nivel3_name,$only_available);
        
            @result_array_paginado[$i]->{'disponibilidad'}= 0;
          
            if (scalar(@disponibilidad) > 0){
                @result_array_paginado[$i]->{'disponibilidad'}  = \@disponibilidad;
            }

            push (@result_array_paginado_temp, @result_array_paginado[$i]);
        }
    }

    $cant_total             = scalar(@result_array_paginado_temp);
    @result_array_paginado  = @result_array_paginado_temp;


    return ($cant_total, \@result_array_paginado);
}

sub filtrarPorAutor{
    my ($params,$session) = @_;

    my $sphinx = Sphinx::Search->new();
    my $query = '';

#     if($params->{'titulo'} ne ""){
#         $query .= '@titulo '.$params->{'titulo'};
#         if($params->{'tipo'} eq "normal"){
#             $query .= "*";
#         }
#     }
# 
#     if($params->{'autor'} ne ""){
#         $query .= ' @autor '.$params->{'autor'};
#         if($params->{'tipo'} eq "normal"){
#             $query .= "*";
#         }
#     }

    $query = '@autor '.$params->{'completo'};
    C4::AR::Debug::debug("Busquedas => query string => ".$query);
#     C4::AR::Debug::debug("query string ".$query);
    my $tipo = 'SPH_MATCH_EXTENDED';
    my $tipo_match = C4::AR::Utilidades::getSphinxMatchMode($tipo);

    $sphinx->SetMatchMode($tipo_match);
    $sphinx->SetSortMode(SPH_SORT_RELEVANCE);
    $sphinx->SetEncoders(\&Encode::encode_utf8, \&Encode::decode_utf8);
    $sphinx->SetLimits($params->{'ini'}, $params->{'cantR'});
    # NOTA: sphinx necesita el string decode_utf8
    my $results = $sphinx->Query($query);

    my @id1_array;
    my $matches = $results->{'matches'};
    my $total_found = $results->{'total_found'};
    $params->{'total_found'} = $total_found;
#     C4::AR::Utilidades::printHASH($results);
    C4::AR::Debug::debug("total_found: ".$total_found);
#     C4::AR::Debug::debug("Busquedas.pm => LAST ERROR: ".$sphinx->GetLastError());
    foreach my $hash (@$matches){
      my %hash_temp = {};
      $hash_temp{'id1'} = $hash->{'doc'};
      $hash_temp{'hits'} = $hash->{'weight'};

      push (@id1_array, \%hash_temp);
    }

    my ($total_found_paginado, $resultsarray);
    #arma y ordena el arreglo para enviar al cliente
    ($total_found_paginado, $resultsarray) = C4::AR::Busquedas::armarInfoNivel1($params, @id1_array);
    #se loquea la busqueda
    C4::AR::Busquedas::logBusqueda($params, $session);

    return ($total_found, $resultsarray);
}

sub busquedaPorBarcode{
    my ($string_utf8_encoded,$session,$obj_for_log) = @_;


    my @id1_array;
    my $nivel3 = C4::AR::Nivel3::getNivel3FromBarcode($string_utf8_encoded);

    if($nivel3){
        my %hash_temp = {};
        $hash_temp{'id1'} = $nivel3->getId1();
        $hash_temp{'hits'} = undef;

        push (@id1_array, \%hash_temp);
    }

    my ($total_found_paginado, $resultsarray);
    #arma y ordena el arreglo para enviar al cliente
    ($total_found_paginado, $resultsarray) = C4::AR::Busquedas::armarInfoNivel1($obj_for_log, @id1_array);
    #se loquea la busqueda
    C4::AR::Busquedas::logBusqueda($obj_for_log, $session);

    return ($total_found_paginado, $resultsarray);
}

=item
Realiza una busqueda simpel por autor sobre nivel 1
=cut
sub busquedaSimplePorAutor{
	my ($params,$session) = @_;

	$params->{'nomCompleto'}= $params->{'autor'};
	my @searchstring_array= C4::AR::Utilidades::obtenerBusquedas($params->{'autor'});	
	my @id1_array;

	my $dbh = C4::Context->dbh;
	my $sql_string_c1;
	
	$sql_string_c1 = "	SELECT DISTINCT(c1.id1), c1.titulo, c1.autor, a.completo \n";
	$sql_string_c1 .= " FROM cat_nivel1 c1 LEFT JOIN cat_autor a ON (c1.autor = a.id) \n";
	$sql_string_c1 .=" 	WHERE (a.completo LIKE ?) \n";
	my $sth = $dbh->prepare($sql_string_c1);

	$sth->execute("%".$params->{'autor'}."%");
			
	while(my $data = $sth->fetchrow_hashref){
 			push (@id1_array,$data);
	}

	#arma y ordena el arreglo para enviar al cliente
   	my ($cant_total, $resultsarray) = C4::AR::Busquedas::armarInfoNivel1($params, @id1_array);
	#se loquea la busqueda
   	C4::AR::Busquedas::logBusqueda($params, $session);

   	return ($cant_total, $resultsarray);
}

=item
Realiza una busqueda simple por titulo sobre nivel 1
=cut
sub busquedaSimplePorTitulo{
	my ($params,$session) = @_;

	my @searchstring_array= C4::AR::Utilidades::obtenerBusquedas($params->{'titulo'});	
	my @id1_array;

	my $dbh = C4::Context->dbh;
	my $sql_string_c1;
	
	$sql_string_c1 = "	SELECT DISTINCT(c1.id1), c1.titulo, c1.autor, a.completo \n";
	$sql_string_c1 .= "	FROM cat_nivel1 c1 LEFT JOIN cat_autor a ON (c1.autor = a.id) \n";
	$sql_string_c1 .= " WHERE (c1.titulo LIKE ?)\n ";

	my $sth = $dbh->prepare($sql_string_c1);
	$sth->execute("%".$params->{'titulo'}."%");
			
	while(my $data = $sth->fetchrow_hashref){
 			push (@id1_array,$data);
	}

	#arma y ordena el arreglo para enviar al cliente
   	my ($cant_total, $resultsarray) = C4::AR::Busquedas::armarInfoNivel1($params, @id1_array);
	#se loquea la busqueda
   	C4::AR::Busquedas::logBusqueda($params, $session);

   	return ($cant_total, $resultsarray);
}

sub t_loguearBusqueda {
#     require C4::Modelo::RepHistorialBusqueda;
    my($loggedinuser,$desde,$http_user_agent,$search_array)=@_;

    my $msg_object= C4::AR::Mensajes::create();
    $desde = $desde || 'SIN_TIPO';
    my $historial = C4::Modelo::RepHistorialBusqueda->new();
    my $db = $historial->db;
    my $msg_object= C4::AR::Mensajes::create();
    $db->{connect_options}->{AutoCommit} = 0;
    eval {
        $historial->agregar($loggedinuser,$desde,$http_user_agent,$search_array);
        $db->commit;
    };

    if ($@){
        #Se loguea error de Base de Datos
        #Se setea error para el usuario
        &C4::AR::Mensajes::printErrorDB($@, 'B407',"INTRA");
        $msg_object->{'error'}= 1;
        #no se debe informar nada al usuario, no debería saber de esto      
#         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'R011', 'params' => []} ) ;        
        $db->rollback;
    }
    $db->{connect_options}->{AutoCommit} = 1;
    return ($msg_object);
}


sub logBusqueda{
	my ($params,$session) = @_;
	#esta funcion loguea las busquedas relizadas desde la INTRA u OPAC si:
	#la preferencia del OPAC es 1 y estoy buscando desde OPAC  
	#la preferencia de la INTRA es 1 y estoy buscando desde la INTRA

	my @search_array;

   $params->{'loggedinuser'}= $session->param('nro_socio');
	my $valorOPAC= C4::AR::Preferencias::getValorPreferencia("logSearchOPAC");
	my $valorINTRA= C4::AR::Preferencias::getValorPreferencia("logSearchINTRA");
   C4::AR::Debug::debug($params->{'type'});
	if( (($valorOPAC == 1)&&($params->{'type'} eq 'OPAC')) || (($valorINTRA == 1)&&($params->{'type'} eq 'INTRA')) ){
		if($params->{'codBarra'} ne ""){
			my $search;
			$search->{'barcode'}= $params->{'codBarra'};
			push (@search_array, $search);
		}

		if($params->{'autor'} ne ""){
			my $search;
			$search->{'autor'}= $params->{'autor'};
			push (@search_array, $search);
		}
	
		if($params->{'titulo'} ne ""){
			my $search;
			$search->{'titulo'}= $params->{'titulo'};
			push(@search_array, $search);
		}
	
		if($params->{'tipo_nivel3_name'} != -1 && $params->{'tipo_nivel3_name'} ne ""){
			my $search;
			$search->{'tipo_documento'}= $params->{'tipo_nivel3_name'};
			push (@search_array, $search);
		}

      
		if($params->{'keyword'} != -1 && $params->{'keyword'} ne ""){
			my $search;
			$search->{'keyword'}= $params->{'keyword'};
			push (@search_array, $search);
		}

		if($params->{'filtrarPorAutor'} ne ""){
			my $search;
			$search->{'filtrarPorAutor'}= $params->{'filtrarPorAutor'};
			push(@search_array, $search);
		}
	}

	my ($error, $codMsg, $message)= C4::AR::Busquedas::t_loguearBusqueda(
																			$params->{'loggedinuser'},
																			$params->{'type'},
                                                         					$session->param('browser'),
																			\@search_array
														);
}


=item
Esta funcion arma el string para mostrar en el cliente lo que a buscado, 
ademas escapa para evitar XSS
=cut
sub armarBuscoPor{
	my ($params) = @_;
	
	my $buscoPor="";
    my $str;
	
	if(C4::AR::Utilidades::validateString($params->{'keyword'})){
        $str      = C4::AR::Utilidades::verificarValor($params->{'keyword'});
#         $buscoPor.= Encode::encode('UTF-8',(Encode::decode('UTF-8', C4::AR::Filtros::i18n("B&uacute;squeda combinada: ")))).$str."&";
        $buscoPor.= $str."&";
	}
	
	if( $params->{'tipo_nivel3_name'} != -1 &&  C4::AR::Utilidades::validateString($params->{'tipo_nivel3_name'})){
# 		$buscoPor.= C4::AR::Filtros::i18n("Tipo de documento: ").C4::AR::Utilidades::verificarValor($params->{'tipo_nivel3_name'})."&";
        if ($params->{'tipo_nivel3_name'} eq 'ALL'){
        	$buscoPor.= C4::AR::Utilidades::verificarValor(C4::AR::Filtros::i18n("TODOS"))."&";
        }else{
            $buscoPor.= C4::AR::Utilidades::verificarValor(C4::AR::Referencias::translateTipoNivel3($params->{'tipo_nivel3_name'}))."&";
        	
        }
	}

	if( C4::AR::Utilidades::validateString($params->{'titulo'})){
# 		$buscoPor.= Encode::decode_utf8("Título: ".C4::AR::Utilidades::verificarValor($params->{'titulo'}))."&";
        $buscoPor.= Encode::decode_utf8(C4::AR::Utilidades::verificarValor($params->{'titulo'}))."&";  
	}
	
	if( C4::AR::Utilidades::validateString($params->{'completo'})){
# 		$buscoPor.= "Autor: ".C4::AR::Utilidades::verificarValor($params->{'autor'})."&";
        $buscoPor.= C4::AR::Utilidades::verificarValor($params->{'completo'})."&";
	}

    if( C4::AR::Utilidades::validateString($params->{'autor'})){
#       $buscoPor.= "Autor: ".C4::AR::Utilidades::verificarValor($params->{'autor'})."&";
        $buscoPor.= C4::AR::Utilidades::verificarValor($params->{'autor'})."&";
    }

	if( C4::AR::Utilidades::validateString($params->{'signatura'})){
# 		$buscoPor.= "Signatura: ".C4::AR::Utilidades::verificarValor($params->{'signatura'})."&";
        $buscoPor.= C4::AR::Utilidades::verificarValor($params->{'signatura'})."&";
	}

    if( C4::AR::Utilidades::validateString($params->{'isbn'})){
#       $buscoPor.= "ISBN: ".C4::AR::Utilidades::verificarValor($params->{'isbn'})."&";
        $buscoPor.= "ISBN: ".C4::AR::Utilidades::verificarValor($params->{'isbn'})."&";
    }       

    if( C4::AR::Utilidades::validateString($params->{'tema'})){
#       $buscoPor.= "ISBN: ".C4::AR::Utilidades::verificarValor($params->{'isbn'})."&";
        $buscoPor.= "Tema: ".C4::AR::Utilidades::verificarValor($params->{'tema'})."&";
    }       

	if( C4::AR::Utilidades::validateString($params->{'codBarra'})){
# 		$buscoPor.= Encode::decode_utf8("Código de Barra: ".C4::AR::Utilidades::verificarValor($params->{'codBarra'}))."&";
        $buscoPor.= Encode::decode_utf8(C4::AR::Utilidades::verificarValor($params->{'codBarra'}))."&";
	}		

    if( C4::AR::Utilidades::validateString($params->{'date_begin'})){
        $buscoPor.= Encode::decode_utf8(C4::AR::Filtros::i18n("desde")." ".$params->{'date_begin'})."&";  
    }
    
    if( C4::AR::Utilidades::validateString($params->{'date_end'})){
        $buscoPor.= Encode::decode_utf8(C4::AR::Filtros::i18n("hasta")." ".$params->{'date_end'})."&";  
    }

    if( C4::AR::Utilidades::validateString($params->{'only_available'})){
        $buscoPor.= Encode::decode_utf8(C4::AR::Filtros::i18n("Solo disponibles"))."&";  
    }

	my @busqueda    = split(/&/,$buscoPor);
	$buscoPor       = " ";
	
	foreach my $str (@busqueda){
		$buscoPor.=", ".$str;
	}
	
	$buscoPor       = substr($buscoPor,2,length($buscoPor));

	return $buscoPor;
}


#*****************************************Soporte MARC************************************************************************
#devuelve toda la info en MARC de un item (id3 de nivel 3)
sub MARCDetail{
	my ($id3,$tipo)= @_;

	my @MARC_result;
	my $marc_array_nivel1;
	my $marc_array_nivel2;
	my $marc_array_nivel3;

	my ($nivel3_object)= C4::AR::Nivel3::getNivel3FromId3($id3);
	if($nivel3_object ne 0){
		C4::AR::Debug::debug('recupero el nivel3');
		($marc_array_nivel3)= $nivel3_object->nivel3CompletoToMARC;
	}

	my ($nivel2_object)= C4::AR::Nivel2::getNivel2FromId2($nivel3_object->getId2);
	
	if($nivel2_object ne 0){
		C4::AR::Debug::debug('recupero el nivel2');
		($marc_array_nivel2)= $nivel2_object->nivel2CompletoToMARC;
		C4::AR::Debug::debug('MARCDetail => cant '.scalar(@$marc_array_nivel2));
	}
	my ($nivel1_object)= C4::AR::Nivel1::getNivel1FromId1($nivel2_object->getId1);
	if($nivel1_object ne 0){
		C4::AR::Debug::debug('recupero el nivel1');
		($marc_array_nivel1)= $nivel1_object->nivel1CompletoToMARC;
	}

	my @result;
	push(@result, @$marc_array_nivel1);
	push(@result, @$marc_array_nivel2);
	push(@result, @$marc_array_nivel3);
	
	my @MARC_result_array;
# FIXME no es muy eficiente pero funciona, ver si se puede mejorar, orden cuadrado
	
	for(my $i=0; $i< scalar(@result); $i++){
		my %hash;	
		my $campo= @result[$i]->{'campo'};
		my @info_campo_array;
		C4::AR::Debug::debug("Proceso todos los subcampos del campo: ".$campo);
		if(!_existeEnArregloDeCampoMARC(\@MARC_result_array, $campo) ){
			#proceso todos los subcampos del campo
			for(my $j=$i;$j < scalar(@result);$j++){
				my %hash_temp;
				$hash_temp{'subcampo'}= @result[$j]->{'subcampo'};
				$hash_temp{'liblibrarian'}= @result[$j]->{'liblibrarian'};
				$hash_temp{'dato'}= @result[$j]->{'dato'};
	
				if(@result[$j]->{'campo'} eq $campo){
					push(@info_campo_array, \%hash_temp);
# 					C4::AR::Debug::debug("agrego el subcampo: ".@result[$j]->{'subcampo'});
				}

        C4::AR::Debug::debug("campo, subcampo, dato: ".@result[$j]->{'campo'}.", ".@result[$j]->{'subcampo'}." : ".@result[$j]->{'dato'});
			}
		
			$hash{'campo'}= $campo;
			$hash{'header'}= @result[$i]->{'header'};
			$hash{'info_campo_array'}= \@info_campo_array;
		
			push(@MARC_result_array, \%hash);
# 			C4::AR::Debug::debug("campo: ".$campo);
			C4::AR::Debug::debug("cant subcampos: ".scalar(@info_campo_array));
		}
	}

	return (\@MARC_result_array);
}


=item
Verifica si existe en el arreglo de campos el campo pasado por parametro
=cut
sub _existeEnArregloDeCampoMARC{
	my ($array, $campo)= @_;

	for(my $j=0;$j < scalar(@$array);$j++){

		if(@$array->[$j]->{'campo'} eq $campo){
			return 1;
		}
	}

	return 0;
}


=item sub getRegistrosFromRange

Retorna todos los registros que se encuentran dentro del rango [$biblio_ini, $biblio_fin]
=cut
sub getRegistrosFromRange {
    my ($params, $cgi ) = @_;

    my $resultsarray;
    my $sphinx  = Sphinx::Search->new();
    my $query   = '';

    if ($cgi->param('tipo_nivel3_name') ne "") {
        #filtro por tipo de ejemplar
        $query .= " cat_ref_tipo_nivel3@".$cgi->param('tipo_nivel3_name');
    } 

    if ($cgi->param('name_nivel_bibliografico') ne "") {
        #filtro por el nivel bibliográfico
        $query .= " ref_nivel_bibliografico@".$cgi->param('name_nivel_bibliografico');
    } 

    if ($cgi->param('name_ui') ne "") {
        #filtro por homebranch
        $query .= " pref_unidad_informacion@".$cgi->param('name_ui');
    } 

    my $tipo = 'SPH_MATCH_EXTENDED';
    my $tipo_match = C4::AR::Utilidades::getSphinxMatchMode($tipo);

    $sphinx->SetMatchMode($tipo_match);
    $sphinx->SetSortMode(SPH_SORT_RELEVANCE);
    $sphinx->SetEncoders(\&Encode::encode_utf8, \&Encode::decode_utf8);
#     $sphinx->SetLimits($params->{'ini'}, $params->{'cantR'});
    # NOTA: sphinx necesita el string decode_utf8
    C4::AR::Debug::debug("Busquedas.pm => query: ".$query);
    my $results = $sphinx->Query($query);

    my @id1_array;
    my @id1_array_aux;
    my $matches                 = $results->{'matches'};
    my $total_found             = $results->{'total_found'};
    $params->{'total_found'}    = $total_found;

    #C4::AR::Debug::debug("Busquedas.pm => total_found: ".$total_found);
    #C4::AR::Debug::debug("Busquedas.pm => LAST ERROR: ".$sphinx->GetLastError());
    foreach my $hash (@$matches) {
        push (@id1_array, $hash->{'doc'});
    }

    if ($cgi->param('limit') ne "") {
        #muesrto los primeros "limit" registros
        @id1_array = @id1_array[0..$cgi->param('limit') - 1];
    }   

    if ( ($cgi->param('biblio_ini') ne "") && ($cgi->param('biblio_fin') ne "") ){
        #filtro por rango de id1
        foreach my $id1 (@id1_array) {
            if( ($id1 >= $cgi->param('biblio_ini')) && ( $id1 <= $cgi->param('biblio_fin')) ){

                push (@id1_array_aux, $id1);
            }
        }

        @id1_array = @id1_array_aux;
    }
    

    C4::AR::Debug::debug("Busquedas.pm => TOTAL FINAL =============== : ".scalar(@id1_array));

    return (scalar(@id1_array), \@id1_array);
}

#***************************************Fin**Soporte MARC*********************************************************************


1;
