package C4::AR::Estadisticas;

#
#Este modulo sera el encargado del manejo de estadisticas sobre los prestamos
#,reservas, devoluciones y todo tipo de consulta sobre el uso de la biblioteca
#
#

use strict;
require Exporter;
use C4::Date;
use C4::AR::Busquedas;

use vars qw(@EXPORT @ISA);

@ISA=qw(Exporter);

@EXPORT=qw(
	&usuarios
	&historicoPrestamos
	&cantidadRetrasados
	&renovacionesDiarias
	&prestamos
	&reservas
	&cantUsuarios
	&registroActividadesDiarias
	&registroEntreFechas
	&insertarNota
	&armarPaginas
	&armarPaginasPorRenglones
	&cantidadRenglones
	&prestamosAnual
	&cantRegDiarias
	&cantRegFechas
	&cantidadAnaliticas
	&disponibilidad
	&itemtypesReport
	&levelsReport
	&availYear
	&getuser
	&estadisticasGenerales
	&cantidadUsuariosPrestamos
	&cantidadUsuariosReservas
	&cantidadUsuariosRenovados
	&historicoDeBusqueda
	&historicoCirculacion
	&insertarNotaHistCirc
	&userCategReport
	&historicoSanciones
	&historialReservas
	&signaturamax
	&signaturamin
	&listaDeEjemplares
);


sub historicoDeBusqueda{
        my ($ini,$cantR,$fechaIni,$fechaFin,$catUsuarios,$orden)=@_;

        my $dbh = C4::Context->dbh;
	my $dateformat = C4::Date::get_date_format();
	my $olddate;
	my $newdate;	
	my $query2;
	my $filtro1;
	my $filtro2;
	my $filtro3;

	$query2 = " SELECT count(*) as cant
			FROM rep_busqueda b INNER JOIN rep_historial_busqueda hb 
			ON (b.idBusqueda = hb.idBusqueda) LEFT JOIN borrowers bor
			ON (b.borrower = bor.borrowernumber) LEFT JOIN usr_ref_categoria_socio c
			ON (c.categorycode = bor.categorycode) ";
	
        my $query ="	SELECT bor.borrowernumber,bor.surname, bor.firstname, bor.cardnumber, 
			b.fecha, hb.campo, hb.valor, c.description, hb.tipo
			FROM rep_busqueda b INNER JOIN rep_historial_busqueda hb 
			ON (b.idBusqueda = hb.idBusqueda) LEFT JOIN borrowers bor
			ON (b.borrower = bor.borrowernumber) LEFT JOIN usr_ref_categoria_socio c
			ON (c.categorycode = bor.categorycode) ";

	if(($fechaIni ne "")&&($fechaFin ne "")&&($catUsuarios ne "SIN SELECCIONAR")){

		$fechaIni=format_date_in_iso($fechaIni,$dateformat)." 00:00:00";
		$fechaFin=format_date_in_iso($fechaFin,$dateformat)." 23:59:59";

		$filtro1 = " WHERE fecha BETWEEN  '".$fechaIni."' AND '".$fechaFin."'";
		$filtro1 .= " AND bor.categorycode = '".$catUsuarios."'";
		$query2 .= $filtro1;
		$query .= $filtro1;

	}else{
		if(($fechaIni ne "")&&($fechaFin ne "")){

			$fechaIni=format_date_in_iso($fechaIni,$dateformat)." 00:00:00";
			$fechaFin=format_date_in_iso($fechaFin,$dateformat)." 23:59:59";

			$filtro2 = " WHERE fecha BETWEEN  '".$fechaIni."' AND '".$fechaFin."'";
			$query2 .= $filtro2;
			$query .= $filtro2;
		}else{
			if($catUsuarios ne "SIN SELECCIONAR"){
				$filtro3 = " WHERE bor.categorycode = '".$catUsuarios."'";
				$query2 .= $filtro3;
				$query .= $filtro3;
			}
		}
	}	

	$query .= " ORDER BY $orden limit ?,?";

        my $sth=$dbh->prepare($query);
        $sth->execute($ini,$cantR);

	my $sth2=$dbh->prepare($query2);
	$sth2->execute();
	my $cantidad=$sth2->fetchrow_hashref;

	my @results;
	my $olddate;
	my $newdate;

	while (my $data=$sth->fetchrow_hashref){
 		
		$olddate= $data->{'fecha'};
		
		C4::Date::Date_Init("DateFormat=US");
		$olddate = C4::Date::ParseDate($olddate);
		$newdate = C4::Date::UnixDate($olddate,'%m/%d/%Y %H:%M');

		$data->{'fecha'}= $newdate;

		if($data->{'borrowernumber'} eq ""){
			$data->{'surname'}= "USUARIO NO LOGUEADO";
		}

		push(@results,$data);
        };
	
	return($cantidad->{'cant'},@results);      	

}   


sub historicoPrestamos{
	#Se realiza un Historial de Prestamos, con los siguientes datos:
	#Apellido y Nombre, DNI,Categoria del Usuario, Tipo de Prestamo, Codigo de Barras, 
	#Fecha de Prestamo, Fecha de Devolucion, Tipo de Item
	
	my ($orden,$ini,$fin,$f_ini,$f_fin,$tipoItem,$tipoPrestamo,$catUsuario)=@_;
	my $dbh = C4::Context->dbh;
	my $dateformat = C4::Date::get_date_format();

	my $datesSQL='';
	if (($f_ini ne '') and ($f_fin ne '')){
		$datesSQL=' AND I.date_due BETWEEN "'.format_date_in_iso($f_ini,$dateformat).'" AND "'.format_date_in_iso($f_fin,$dateformat).'" ';
	}

	my $tipoDePrestamoSQL;
	if ($tipoPrestamo ne "-1"){
		$tipoDePrestamoSQL= 'and ISST.issuecode = "'.$tipoPrestamo.'"';
	}	

	my $tipoDeItemSQL = '';
	if ($tipoItem ne "-1"){
		$tipoDeItemSQL= 'and ITT.itemtype = "'.$tipoItem.'"';
	}

	my $catUsuarioSQL = '';
	if ($catUsuario ne "-1"){
		$catUsuarioSQL= 'and C.categorycode = "'.$catUsuario.'"';
	}

	my $querySelect=" Select B.firstname, B.surname, B.documentnumber as DNI, C.description as CatUsuario, ISST.description as tipoPrestamo, n3.barcode, I.date_due as fechaPrestamo, I.returndate as fechaDevolucion, ITT.description as tipoItem ";

	my $queryFrom= " 	From  circ_prestamo I, borrowers B, usr_ref_categoria_socio C, cat_nivel3 n3, cat_nivel2 n2, 
				cat_ref_tipo_nivel3 ITT, circ_ref_tipo_prestamo ISST ";

	my $queryWhere= " where (B.borrowernumber = I.borrowernumber)and(C.categorycode = B.categorycode)
	and(n3.id3 = I.id3)and(ISST.id_tipo_prestamo = I.issuecode)
	and(n2.id2 = n3.id2)and(ITT.itemtype = n2.tipo_documento)
	and not(I.returndate is null) ";

	my $queryCount= " 	Select count(*) as cant 
				$queryFrom
				$queryWhere
				$datesSQL
				$tipoDeItemSQL
				$tipoDePrestamoSQL
				$catUsuarioSQL ";

	my $sth=$dbh->prepare($queryCount);
        $sth->execute();
	my $dataResult= $sth->fetchrow_hashref;
	my $cant= $dataResult->{'cant'};

        my $query ="	$querySelect
			$queryFrom
			$queryWhere
			$datesSQL
			$tipoDeItemSQL
			$tipoDePrestamoSQL
			$catUsuarioSQL
			Order By ".$orden;

	$query .= " limit ".$ini.",".$fin;

	my $sth=$dbh->prepare($query);
        $sth->execute();

	my @results;
	while (my $data=$sth->fetchrow_hashref){
		$data->{'fechaPrestamo'}=format_date($data->{'fechaPrestamo'},$dateformat);
		$data->{'fechaDevolucion'}=format_date($data->{'fechaDevolucion'},$dateformat);
		push(@results,$data);

        };
	return($cant,@results);
}


#
#Cuenta la cantidad de prestamos realizados durante el año que ingresa por parametro
sub prestamosAnual{
        my ($branch,$year)=@_;
        my $dbh = C4::Context->dbh;
	my @results;
	my $query ="SELECT month( date_due ) AS mes, count( * ) AS cantidad,SUM( renewals ) AS 
			   renovaciones, issuecode
		    FROM  circ_prestamo 
		    WHERE year( date_due ) = ? 
		    GROUP BY month( date_due ), issuecode";

	my $sth=$dbh->prepare($query);
        $sth->execute($year);
	while (my $data=$sth->fetchrow_hashref){
		$data->{'mes'}=&mesString($data->{'mes'});
		push(@results,$data);
        	};
	$query ="SELECT count( * ) AS devoluciones
                 FROM  circ_prestamo 
                 WHERE year( date_due ) = ? and returndate is not null
                 GROUP BY month( date_due ), issuecode";
	my $sth=$dbh->prepare($query);
        $sth->execute($year);
	my $i=0;
	while (my $data=$sth->fetchrow_hashref){
		@results[$i]->{'devoluciones'}=$data->{'devoluciones'};
		$i++;
		};

	return(@results);
}

#
#Ejemplares perdidos del branch que le paso por parametro
sub disponibilidad{
        my ($branch,$orden,$avail,$fechaIni,$fechaFin,$ini,$cantR)=@_;
        my $dbh = C4::Context->dbh;
	my $dateformat = C4::Date::get_date_format();
	my @results;
	my $dates='';
	my @bind;
	push(@bind,$avail);
	push(@bind,$branch);
	if (($fechaIni ne '') && ($fechaFin ne '')){
		$dates=" AND av.date between ? AND ? ";
		push(@bind,format_date_in_iso($fechaIni,$dateformat));
		push(@bind,format_date_in_iso($fechaFin,$dateformat));
	}
	my $query= "SELECT COUNT(*)";
	my $query2 = "SELECT DISTINCT n3.*, anio_publicacion, titulo, autor AS id,MAX(av.date) AS date, a.completo AS autor";
	my $resto= " FROM cat_nivel3 n3 INNER JOIN cat_nivel2 n2 ON (n3.id2 = n2.id2) 
		     INNER JOIN cat_nivel1 n1 ON (n2.id1=n1.id1) 
		     INNER JOIN cat_detalle_disponibilidad av ON ( av.id3 = n3.id3  ) 
		     INNER JOIN cat_autor a ON (a.id = n1.autor)
		     WHERE n3.wthdrawn = ? AND homebranch=? ".$dates." GROUP BY av.id3";
	
	$query.=$resto;
        my $sth=$dbh->prepare($query);
        $sth->execute(@bind);
	my $cant=$sth->rows;

	$query2.=$resto." ORDER BY ".$orden;
	if($ini ne ""){
		$query2.=" limit ?,?";
		push(@bind,$ini);
		push(@bind,$cantR);
	}
	$sth=$dbh->prepare($query2);
	$sth->execute(@bind);
        while (my $data=$sth->fetchrow_hashref){
		$data->{'date'}=format_date($data->{'date'},$dateformat);
		$data->{'number'}=C4::AR::Nivel2::getEdicion($data->{'id2'});
		push(@results,$data);
        }
        return ($cant,@results);
}

#Cantidad de renglones seteado en los parametros del sistema para ver por cada pagina
sub cantidadRenglones{
        my $dbh = C4::Context->dbh;
        my $query="select value
		   from pref_preferencia_sistema
                   where variable='renglones'";
        my $sth=$dbh->prepare($query);
	$sth->execute();
	return($sth->fetchrow_array);
}

#
#Esta funcion recibe un numero que equivale a la cantidad de tuplas que devuelve cualquier consulta
# y en base a eso arma el array con la cantidad de paginas que tiene que quedar como respuesta
# Paginador
sub armarPaginas{
	my ($cant,$actual)=@_;
	my $renglones = cantidadRenglones();
	my $paginas = 0;
	if ($renglones != 0){
		$paginas= $cant % $renglones;}
	if  ($paginas == 0){
        	$paginas= $cant /$renglones;}
	else {$paginas= (($cant - $paginas)/$renglones) +1};
	my @numeros=();
	for (my $i=1; ($paginas >1 and $i <= $paginas) ; $i++ ) {
		 push @numeros, { number => $i, actual => ($i!=$actual)}
	};
	return(@numeros);
}

sub armarPaginasPorRenglones {
	my ($cant,$actual,$renglones)=@_;
	my $paginas = 0;
	if ($renglones != 0){
		$paginas= $cant % $renglones;}
	if  ($paginas == 0){
        	$paginas= $cant /$renglones;}
	else {$paginas= (($cant - $paginas)/$renglones) +1};
	my @numeros=();
	for (my $i=1; ($paginas >1 and $i <= $paginas) ; $i++ ) {
		 push @numeros, { number => $i, actual => ($i!=$actual)}
	};
	return(@numeros);
}

sub insertarNota{
	my ($id,$nota)=@_;
        my $dbh = C4::Context->dbh;
        my $query="update  rep_registro_modificacion set nota=?
		   where idModificacion=?";
        my $sth=$dbh->prepare($query);
        $sth->execute($nota,$id);
}

sub cantRegFechas{
	my ($chkfecha,$fechaInicio,$fechaFin,$tipo,$operacion,$chkuser,$chknum,$user,$numDesde,$numHasta)=@_;
        my $dbh = C4::Context->dbh;
	my @bind;
        my $query ="SELECT  count(*)
        	    FROM rep_registro_modificacion INNER JOIN borrowers ON
		   (rep_registro_modificacion.responsable=borrowers.cardnumber) ";
	my $where = "";
	
	if ($chkfecha ne "false"){
		$where = "WHERE";
		$query.= $where." (fecha>=?) AND (fecha<=?)";
		push(@bind,$fechaInicio);
		push(@bind,$fechaFin);
	}

	if ($operacion ne ''){
		if ($where eq ''){
			$where = "WHERE";
			$query.= $where." operacion=?";
		}
		else {$query.= " AND operacion=?";}
		push(@bind,$operacion);
	}

	if ($tipo ne ''){
		if ($where eq ''){
			$where = "WHERE";
			$query.= $where." tipo=?";
		}
		else {$query.= " AND tipo=?";}
		push(@bind,$tipo);
	}

	if ($chkuser ne "false"){
		if ($where eq ''){
			$where = "WHERE";
			$query.= $where." responsable=?";
		}
		else {$query.= " AND responsable=?";}
		push(@bind,$user);
	}
	
	if ($chknum ne "false"){
		if ($where eq ''){
			$where = "WHERE";
			$query.= $where." numero >= ? AND numero <= ?";
		}
		else {$query.= " AND numero >= ? AND numero <= ?";}
		push(@bind,$numDesde);
		push(@bind,$numHasta);
	}

	my $sth=$dbh->prepare($query);
        $sth->execute(@bind);
        return($sth->fetchrow_array);


}

# FIXME comentado hasta que se suba el pm C4/Modelo/RepRegistroModificacion/Manager.pm
=item
sub registroEntreFechas{
   my ($params_obj)=@_;

   my @filtros;

   use C4::Modelo::RepRegistroModificacion::Manager;

	if ($params_obj->{'chkfecha'} ne "false"){
      push(@filtros, ( fecha => {      eq=> $params_obj->{'fechaInicio'}, 
                                       gt => $params_obj->{'fechaInicio'}, 
                                       eq=> $params_obj->{'fechaFin'}, 
                                       lt => $params_obj->{'fechaFin'}  }
                     ) );
	}

	if ($params_obj->{'operacion'} ne ''){
      push(@filtros, ( operacion => { eq => $params_obj->{'operacion'} }) );
	}

	if ($params_obj->{'tipo'} ne ''){
      push(@filtros, ( tipo => { eq => $params_obj->{'tipo'} }) );
   }

	if ($params_obj->{'chkuser'} ne "false"){
		push(@filtros, ( responsable => { eq => $params_obj->{'user'} }) );
	}
	
	if ($params_obj->{'chknum'} ne "false"){
		push(@filtros, ( numero => {  eq=> $params_obj->{'numDesde'},
                                    gt => $params_obj->{'numDesde'},
                                    eq=> $params_obj->{'numHasta'},
                                    lt => $params_obj->{'numHasta'}  }
                     ) );
	}

   my $registros = C4::Modelo::RepRegistroModificacion::Manager->get_rep_registro_modificacion(
                                                                        query => \@filtros,
                                                                        sorty_by => $params_obj->{'orden'},
                                                                        #limit => [$params_obj->{'ini'},$params_obj->{'fin'}],
                                                                        require_objects => ['socio_responsable'],
                                                                        );

   return (scalar(@$registros),$registros);
}
=cut

=item
sub cantRegDiarias{
 	my ($today)=@_;
        my $dbh = C4::Context->dbh;
        my $query ="SELECT  count(*)
        	    FROM modificaciones INNER JOIN borrowers ON
		   (modificaciones.responsable=borrowers.cardnumber) 
                    WHERE fecha='$today'";
        my $sth=$dbh->prepare($query);
        $sth->execute();
        return($sth->fetchrow_array);
}

sub registroActividadesDiarias{
	my ($orden,$fecha,$ini,$cantR)=@_;
        my $dbh = C4::Context->dbh;
        my $query="SELECT operacion,fecha,responsable,numero,tipo,surname,firstname
		   FROM modificaciones INNER JOIN borrowers ON
		   (modificaciones.responsable=borrowers.cardnumber) 
                   WHERE (fecha=?)
		   ORDER BY (?)
		   limit $ini,$cantR";
        my $sth=$dbh->prepare($query);
        $sth->execute($fecha,$orden);
	my @results;
        while (my $data=$sth->fetchrow_hashref){
		$data->{'fecha'}=format_date($data->{'fecha'});
		$data->{'nomCompleto'}=$data->{'surname'}.", ".$data->{'firstname'};
                push(@results,$data);
        }
        return (@results);
}
=cut

#
#Prestamos sin devolucion al dia de hoy
#

sub cantidadRetrasados{
        my ($branch)=@_; 
	my $dbh = C4::Context->dbh;
	my @results;
	my $query ="Select * 
	              From  circ_prestamo inner join borrowers on ( circ_prestamo.borrowernumber=borrowers.borrowernumber)
        	      Where (returndate is NULL and  circ_prestamo.branchcode = ? ) ";
	my $sth=$dbh->prepare($query);
	$sth->execute($branch);
	while (my $data=$sth->fetchrow_hashref){
                push(@results,$data);
        }
        return (@results);

}

#
#Renovaciones realizadas por socios al dia de hoy
#
sub renovacionesDiarias{
        my ($branch)=@_; 
	my $dbh = C4::Context->dbh;
	my @results;
	my $query ="select *
  		    from  circ_prestamo inner join borrowers on ( circ_prestamo.borrowernumber=borrowers.borrowernumber)
		    where (returnDate is NULL and  circ_prestamo.branchcode=? and renewals >= 1 )";
	my $sth=$dbh->prepare($query);
	$sth->execute($branch);
	while (my $data=$sth->fetchrow_hashref){
                push(@results,$data);
        }
        return (@results);
}

#
#Prestamos realizados en una fecha dada
#
sub prestamosEnUnaFecha{
	my ($branch,$fecha)=@_;
        my $dbh = C4::Context->dbh;
        my @results;
	my $query ="select *
		    from  circ_prestamo inner join borrowers on ( circ_prestamo.borrowernumber=borrowers.borrowernumber)
		    where ( circ_prestamo.date_due=? and  circ_prestamo.branchcode = ?)";
        my $sth=$dbh->prepare($query);
        $sth->execute($fecha,$branch);
	while (my $data=$sth->fetchrow_hashref){
                push(@results,$data);
        }
        return (@results);
}

#
#Devoluciones que se tienen que hacer en una fecha dada
#

sub devolucionesParaFecha{
	my ($branch,$fecha)=@_;
        my $dbh = C4::Context->dbh;
	my @results;
        my $query ="select *
                    from  circ_prestamo inner join borrowers on ( circ_prestamo.borrowernumber=borrowers.borrowernumber)
		    where ( circ_prestamo.returndate=? and  circ_prestamo.branchcode=?) ";
        my $sth=$dbh->prepare($query);
        $sth->execute($fecha,$branch);
	while (my $data=$sth->fetchrow_hashref){
                push(@results,$data);
        }
        return (@results);
}

#Historial de prestamos realizados por un usuario 
                                                                                                                             
sub historialUsuario{
        my ($id,$branch)=@_;
        my $dbh = C4::Context->dbh;
        my $query ="select  *
                    from  circ_prestamo inner join borrowers on ( circ_prestamo.borrowernumber=borrowers.borrowernumber)
		    where borrowers.borrowernumber=? and  circ_prestamo.branchcode=?";
        my $sth=$dbh->prepare($query);
        $sth->execute($id,$branch);
	return($sth->fechtrow_hashref);
}


#Usuarios de un branch dado 
#Damian - 31/05/2007 - Se agrego para difereciar usuarios que usan y no usan la biblioteca
sub usuarios{
        my ($branch,$orden,$ini,$fin,$anio,$usos,$categ,@chck)=@_;
	my $dbh = C4::Context->dbh;
	my $dateformat = C4::Date::get_date_format();
  	my @results;
	my @bind;
	my @bind2;
	my $queryCant ="SELECT count( * ) AS cantidad
                    FROM borrowers b
                    WHERE branchcode=? ";

        my $query ="SELECT  b.phone,b.emailaddress,b.dateenrolled,c.description as categoria ,
		    b.firstname,b.surname,b.streetaddress,b.cardnumber,b.city,b.borrowernumber
                    FROM borrowers b inner join usr_ref_categoria_socio c on (b.categorycode = c.categorycode)
 		    WHERE b.branchcode=? ";
	my $where="";
	push(@bind,$branch);

	my $query2 = "SELECT * FROM  circ_prestamo i WHERE b.borrowernumber = i.borrowernumber ";
	my $exists = "";
	for (my $i=0; $i < scalar(@chck); $i++){
		if($chck[$i] eq "CAT"){
			$where.=" AND b.categorycode= ?";
			if($exists eq ""){$exists = " AND EXISTS (";}
			push(@bind,$categ);
		}
		elsif($chck[$i] eq "AN"){
			$query2 = $query2 ." AND year( date_due )= ?";
			$exists = " AND EXISTS (";
			push(@bind2,$anio);
		}
		elsif($chck[$i] eq "USO"){
			if($usos eq "NI"){$exists = " AND NOT EXISTS (";}
			else{$exists = " AND EXISTS (";}
		}
	}
	my $finCons= " ORDER BY ($orden) LIMIT $ini,$fin";
	if ( $exists eq ""){
		$query.=$finCons;
	}
	else{
		$queryCant.=$where.$exists.$query2.")";
		$query.=$where.$exists.$query2.") GROUP BY b.borrowernumber ".$finCons;
	}

        my $sth=$dbh->prepare($queryCant);
        $sth->execute(@bind,@bind2);
	my $cantidad=$sth->fetchrow;
	
	$sth=$dbh->prepare($query);
        $sth->execute(@bind,@bind2);
	while (my $data=$sth->fetchrow_hashref){
		if ($data->{'phone'} eq "" ){$data->{'phone'}='-' };
		if ($data->{'emailaddress'} eq "" ){
					$data->{'emailaddress'}='-';
					$data->{'ok'}=1;
				};
		$data->{'dateenrolled'}=format_date($data->{'dateenrolled'},$dateformat);
		$data->{'city'}=C4::AR::Busquedas::getNombreLocalidad($data->{'city'});
                push(@results,$data);
        }
        return ($cantidad,@results);
}


# Verifica que una fecha este entre otras 2 
sub estaEnteFechas {
   my ($begindate,$enddate,$vencimiento)=@_;

  if (($begindate eq '')or($enddate eq '')or($vencimiento eq '')){ return 1;} # Si alguna de las fechas viene vacia se devuelve 1
  else {
		# Se hacen las comapraciones
		my $flag1=Date::Manip::Date_Cmp($begindate,$vencimiento);
		my $flag2=Date::Manip::Date_Cmp($vencimiento,$enddate);	
		if (($flag1 le 0) and ($flag2 le 0)) {return 1;}
		#
	}
  return 0;
}

sub prestamos{
         my ($id_ui,$orden,$ini,$fin,$estado,$fecha_inicio,$fecha_fin)=@_;
         my @results;
      
         my @filtros;

         if ((length($fecha_inicio) > 5)){
             push(@filtros, ( fecha_prestamo => { gt => $fecha_inicio, eq => $fecha_inicio }) );
         }

         if (($fecha_fin > 5)){
             push(@filtros, ( fecha_prestamo => { lt => $fecha_fin, eq => $fecha_fin }) );
         }
         push(@filtros, ( id_ui_origen => { eq => $id_ui }  ) );

         my $prestamos = C4::Modelo::CircPrestamo::Manager->get_circ_prestamo(
                                                                             query => \@filtros,
                                                                             require_objects => ['socio','nivel3'],
                                                                             );

	      my @datearr = localtime(time);
	      my $hoy =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
      
	      foreach my $prestamo (@$prestamos){
            my $dateformat = C4::Date::get_date_format();
		      $prestamo->{'vencimiento'}=C4::Date::format_date(C4::AR::Prestamos::vencimiento($prestamo),$dateformat);
		      #Se filtra por Fechas de Vencimiento 
		      if ( estaEnteFechas($fecha_inicio,$fecha_fin,$prestamo->{'vencimiento'}) ) {
      
               if ($prestamo->socio->persona->getTelefono eq "" ){
                  $prestamo->socio->persona->setTelefono('-');
               }
		

		         if (!($prestamo->socio->persona->getEmail)){
					         $prestamo->socio->persona->setEmail('-');
					         $prestamo->{'ok'}=1;
				   }

		         if (!($prestamo->getFecha_devolucion)){
                  $prestamo->setFecha_devolucion('-');
               }
		         else{
                  $prestamo->setFecha_devolucion(C4::Date::format_date($prestamo->getFecha_devolucion,$dateformat));
               }

               $prestamo->setFecha_prestamo(C4::Date::format_date($prestamo->getFecha_prestamo,$dateformat));;

		         my $flag=Date::Manip::Date_Cmp($prestamo->{'vencimiento'},$hoy);
		         #Se marcan los prestamos vencidos
		         if ($flag lt 0){
                  $prestamo->{'vencido'}='1';
               }

		         if ($estado eq "VE"){
				         if ($flag lt 0){
				           push(@results,$prestamo);
			         }
		         }
		         elsif ($estado eq "NV"){
			         if($flag gt 0 || $flag == 0){
				         push(@results,$prestamo);
			         }
		         }
		         else{
			         push(@results,$prestamo);
		         }
           }
       } # foreach
      
#       # Da el ORDEN al arreglo
# 	      if (($orden ne "vencimiento") and ($orden ne "date_due")) {
# 	      #ordeno alfabeticamente
# 	         my @sorted = sort { $a->{$orden} cmp $b->{$orden} } @results;
# 	         @results=@sorted;
# 	      }
# 	      else
# 	      {#ordeno Fechas
# 	         my @sorted = sort { Date::Manip::Date_Cmp($a->{$orden},$b->{$orden}) } @results;
# 	         @results=@sorted;
# 	      }
      #  
	      my $cantReg=scalar(@results);
      #Se chequean si se quieren devolver todos
	      if(($cantReg > $fin)&&($fin ne "todos")){
		      my $cantFila=$fin-1+$ini;
		      my @results2;
		      if($cantReg < $cantFila ){
			      @results2=@results[$ini..$cantReg];
		      }
		      else{
			      @results2=@results[$ini..$fin-1+$ini];
		      }
      
		      return($cantReg,@results2);
	      }
            else{
		        return ($cantReg,@results);
	      }
}

sub reservas{
   my ($id_ui,$orden,$ini,$cantR,$tipo)=@_;
	my $dateformat = C4::Date::get_date_format();
   my @filtros;
   my @results;

   push (@filtros, ( id_ui => { eq => $id_ui}) );

	if($tipo eq "GR"){
		 push (@filtros, ( estado => { eq => 'G'}) );

	}
	elsif($tipo eq "EJ"){
		 push (@filtros, ( estado => { eq => 'E'}) );
	}
	else {
	    push (@filtros, ( estado => { eq => 'E', eq => 'G'}) );
	}

   my $reservas = C4::Modelo::CircReserva::Manager->get_circ_reserva(   query => \@filtros,
                                                                        sorty_by => [$orden],
                                                                        limit => $cantR,
                                                                        offset => $ini,
                                                                        require_objects => ['socio','nivel3'],
                                                                      );

   foreach my $reserva (@$reservas){
		$reserva->setFecha_recordatorio(format_date($reserva->getFecha_recordatorio,$dateformat));
		$reserva->setFecha_reserva(format_date($reserva->getFecha_reserva,$dateformat));
		if ($reserva->getId3 eq "" ){
         $reserva->setId3("\-") 
      }
      if ($reserva->socio->persona->getEmail eq "" ){
			$reserva->socio->persona->setEmail("\-");
			$reserva->{'mail'}=1;
      }
      push(@results,$reserva);
      return (scalar(@results),@results);
   }

}

sub cantidadAnaliticas{
        my $dbh = C4::Context->dbh;
        my @results;
        my $query ="SELECT count( * ) AS cantidad
                    FROM cat_analitica";
        my $sth=$dbh->prepare($query);
        $sth->execute();
        while (my $data=$sth->fetchrow_hashref){
                push(@results,$data);
        }
        return (@results);
}


sub itemtypesReport{
        my ($branch)=@_;
        my $dbh = C4::Context->dbh;
        my $query=" SELECT cat_ref_tipo_nivel3.description, COUNT( cat_ref_tipo_nivel3.description ) AS cant
		FROM cat_ref_tipo_nivel3
		LEFT JOIN cat_nivel2 n2 ON itemtypes.itemtype = n2.tipo_documento
		INNER JOIN cat_nivel3 n3 ON n2.id2 = n3.id2
		WHERE holdingbranch = ?
		GROUP BY cat_ref_tipo_nivel3.description  ";
        my $sth=$dbh->prepare($query);
        $sth->execute($branch);
        my @results;
        while (my $data=$sth->fetchrow_hashref){
                push(@results,$data);
        }
        return (scalar(@results),@results);
}

sub levelsReport{
        my ($branch)=@_;
        my $dbh = C4::Context->dbh;
        my $query="SELECT ref_nivel_bibliografico.description, COUNT( ref_nivel_bibliografico.description ) AS cant
		FROM ref_nivel_bibliografico
		LEFT JOIN cat_nivel2 n2 ON bibliolevel.code = n2.nivel_bibliografico
		INNER JOIN cat_nivel3 n3 ON n2.id2 = n3.id2
		WHERE holdingbranch = ?
		GROUP BY ref_nivel_bibliografico.description";
        my $sth=$dbh->prepare($query);
        $sth->execute($branch);
        my @results;
        while (my $data=$sth->fetchrow_hashref){
                push(@results,$data);
        }
        return (scalar(@results),@results);
}

sub availYear {
        my ($branch,$ini,$fin)=@_;
        my $dbh = C4::Context->dbh;
	my $dateformat = C4::Date::get_date_format();
        my $query="SELECT month( date )  AS mes, year( date )  AS year, avail, count( avail )  AS cantidad
			FROM cat_detalle_disponibilidad
			WHERE branch =  ?  AND date BETWEEN ? AND  ?
			GROUP  BY year( date ) , month( date )  ORDER  BY month( date ) , year( date )";
        my $sth=$dbh->prepare($query);
        $sth->execute($branch,format_date_in_iso($ini,$dateformat),format_date_in_iso($fin,$dateformat));
        my @results;
        while (my $data=$sth->fetchrow_hashref){
                push(@results,$data);
        }
        return (scalar(@results),@results);
	}

#Damian - 11/04/2007 - Para buscar a los usuarios que administran el sistema.
sub getuser{
	#my ($branch)=@_;
	my $dbh = C4::Context->dbh;
        my $query="SELECT surname, firstname,borrowernumber,cardnumber FROM borrowers ";
	   $query.="WHERE flags IS NOT NULL AND flags <> 0 ";
	my $sth=$dbh->prepare($query);
        $sth->execute();
	my %results;
	while (my $data=$sth->fetchrow_hashref){
		$data->{'nomCompleto'}=$data->{'surname'}.','.$data->{'firstname'};
		$results{$data->{'cardnumber'}}= $data;
	}
	return(\%results);
}

#Damian - 04/05/2007 - Para buscar la cantidad de prestamos de cada tipo (estadisticas generales).
sub estadisticasGenerales{
	my ($fechaInicio, $fechaFin, $chkfecha, @chck)=@_;
	my $dbh = C4::Context->dbh;
	my @bind;
        my $query="SELECT count(*) as cant, issuecode, renewals FROM  circ_prestamo WHERE (renewals >0 OR renewals=0)";
	
	if ($chkfecha ne "false"){
		$query.=" AND (date_due>=?) AND (date_due<=?)";
		push(@bind,$fechaInicio);
		push(@bind,$fechaFin);
	}

	my $loop=scalar(@chck);
	my $subquery="";
	if ($loop>0){
		my $i;
		for ($i=0; $i<$loop-1; $i++){
			$subquery.=" issuecode = ? OR";
			push(@bind,$chck[$i]);
		}
		$subquery =" AND (".$subquery." issuecode = ?)";
		push(@bind,$chck[$loop-1]);
	}
	$query .= $subquery." GROUP BY issuecode, renewals";

	my $sth=$dbh->prepare($query);
        $sth->execute(@bind);

	my $domiTotal=0;
	#my $noRenovados;
	my $devueltos;
	my $renovados;
	my $sala;
	my $foto;
	my $especial;

	while (my $data=$sth->fetchrow_hashref){
	if($data->{'issuecode'} eq 'DO'){
		if($data->{'renewals'}!=0){
			$renovados=$data->{'cant'};
		}
		#else{
		#	$noRenovados=$data->{'cant'};
		#}
		$domiTotal=$domiTotal + $data->{'cant'};
	}
	elsif($data->{'issuecode'} eq 'SA'){
		$sala=$data->{'cant'};
	}
	elsif($data->{'issuecode'} eq 'FO'){
		$foto=$data->{'cant'};
	}
	else{
		$especial=$data->{'cant'};
	}
	}

#******Para saber cuantos libros se devolvieron***********
	if($domiTotal){
		my @bind2;
		my $query="SELECT count(*) as devueltos, issuecode FROM  circ_prestamo WHERE returndate IS NOT NULL AND issuecode = 'DO'";
		if ($chkfecha ne "false"){
			$query.=" AND (date_due>=?) AND (date_due<=?)";
			push(@bind2,$fechaInicio);
			push(@bind2,$fechaFin);
		}
		$query.=" GROUP BY issuecode";
		
		my $sth=$dbh->prepare($query);
        	$sth->execute(@bind2);
		my $data=$sth->fetchrow_hashref;
		$devueltos=$data->{'devueltos'};
	}
	else {$domiTotal="";} # Si no es una busqueda por domiciliario para que no muestre 0 en el tmpl


return ($domiTotal,$renovados,$devueltos,$sala,$foto,$especial); 
}


sub cantidadUsuariosPrestamos{
	my ($fechaInicio, $fechaFin, $chkfecha)=@_;
	my $dbh = C4::Context->dbh;
        my $query="SELECT borrowernumber FROM  circ_prestamo ";
	my @bind;
	if ($chkfecha ne "false"){
		$query.=" WHERE (date_due>=?) AND (date_due<=?)";
		push(@bind,$fechaInicio);
		push(@bind,$fechaFin);
	}
	$query .=" GROUP BY borrowernumber";

	my $sth=$dbh->prepare($query);
        $sth->execute(@bind);
	my $cant;
	if($sth->rows()!=0){
		$cant=$sth->rows();
	}

return ($cant);
}

sub cantidadUsuariosRenovados{
	my ($fechaInicio, $fechaFin, $chkfecha)=@_;
	my $dbh = C4::Context->dbh;
        my $query="SELECT borrowernumber FROM  circ_prestamo WHERE renewals <> 0 ";
	my @bind;
	if ($chkfecha ne "false"){
		$query.=" AND (date_due>=?) AND (date_due<=?)";
		push(@bind,$fechaInicio);
		push(@bind,$fechaFin);
	}
	$query .=" GROUP BY borrowernumber";

	my $sth=$dbh->prepare($query);
        $sth->execute(@bind);
	my $cant;
	if($sth->rows()!=0){
		$cant=$sth->rows();
	}

return ($cant);
}

sub cantidadUsuariosReservas{
	my ($fechaInicio, $fechaFin, $chkfecha)=@_;
	my $dbh = C4::Context->dbh;
        my $query="SELECT borrowernumber FROM circ_reserva ";
	my @bind;
	if ($chkfecha ne "false"){
		$query.=" WHERE (reservedate>=?) AND (reservedate<=?)";
		push(@bind,$fechaInicio);
		push(@bind,$fechaFin);
	}
	$query .=" GROUP BY borrowernumber";

	my $sth=$dbh->prepare($query);
        $sth->execute(@bind);
	my $cant;
	if($sth->rows()!=0){
		$cant=$sth->rows();
	}

return ($cant);
}

sub historialReservas {
  my ($bornum,$ini,$cantR)=@_;
 
  my $dbh = C4::Context->dbh;
  my $dateformat = C4::Date::get_date_format();

  my $querySelectCount="SELECT count(*) as cant ";

  my $querySelect =" 	SELECT h.id, a.completo,a.id as idAutor,h.id1, n1.titulo, ";
  $querySelect .= " 	h.id2,h.id3,h.branchcode as branchcode, ";
  $querySelect .= " 	it.description,h.date as fechaReserva,h.end_date as fechaVto,h.type ";

  my $queryFrom .= " 	FROM rep_historial_circulacion h LEFT JOIN circ_ref_tipo_prestamo it ";
  $queryFrom .= " 	ON(it.id_tipo_prestamo = h.issuetype) ";
  $queryFrom .= " 	LEFT JOIN cat_nivel1 n1 ";
  $queryFrom .= " 	ON (n1.id1 = h.id1) ";
  $queryFrom .= " 	LEFT JOIN cat_autor a ";
  $queryFrom .= " 	ON (a.id = n1.autor) ";
  $queryFrom .= " 	LEFT JOIN cat_nivel3 n3 ";
  $queryFrom .= " 	ON (n3.id3 = h.id3) "; 

  my $queryWhere .= " 	WHERE h.borrowernumber = ? and h.type in ('reserve','cancel','notification') ";

  my $queryFinal .= " 	ORDER BY h.timestamp desc ";	
  $queryFinal .= " 	limit $ini,$cantR ";

  my $consulta= $querySelectCount.$queryFrom.$queryWhere;

  #obtengo la cantidad total para el paginador
  my $sth=$dbh->prepare($consulta);
  $sth->execute($bornum);
  my $data= $sth->fetchrow_hashref;
  my $count= $data->{'cant'};
  #se realiza la consulta
  $consulta= $querySelect.$queryFrom.$queryWhere.$queryFinal;
  my $sth=$dbh->prepare($consulta);
  $sth->execute($bornum);

  #proceso los datos
  my @result;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
	if (( $data->{'type'} eq 'reserve' )||( $data->{'type'} eq 'notification' )) {
		$data->{'estado'}= 'Otorgada';
		$data->{'fechaVto'}= format_date($data->{'fechaVto'},$dateformat);
	}else{
		if (( $data->{'type'} eq 'cancel' )&&($data->{'fechaVto'} eq '0000-00-00')) {
			$data->{'estado'}= 'Anulada';
			$data->{'fechaVto'}= '-';
		}else{
			$data->{'estado'}= 'Vencida';
			$data->{'fechaVto'}= format_date($data->{'fechaVto'},$dateformat);
		}
	}

	$data->{'fechaReserva'}= format_date($data->{'fechaReserva'},$dateformat);

    	$result[$i]=$data;
    	$i++;
  }
  $sth->finish;
  return($count,\@result);
}

sub historicoCirculacion(){
	my ($chkfecha,$fechaIni,$fechaFin,$user,$id3,$ini,$cantR,$orden,
	$tipoPrestamo,$tipoOperacion)=@_;
	
        my $dbh = C4::Context->dbh;
	my $dateformat = C4::Date::get_date_format();
	my @bind;
	my $query="";
	my $cant=0;
	my $select= " 	SELECT h.id, nota, a.completo,a.id as idAutor,h.id1, titulo,
			h.id2,h.id3,h.branchcode as branchcode, it.description,date,h.borrowernumber,responsable,type,b.surname,b.firstname, n3.barcode, n3.signatura_topografica, u.firstname as userFirstname, u.surname as userSurname";

	my $from= "	FROM rep_historial_circulacion h LEFT JOIN borrowers b 
			ON (h.responsable=b.borrowernumber)
			LEFT JOIN borrowers u
			ON (h.borrowernumber = u.borrowernumber)
			LEFT JOIN circ_ref_tipo_prestamo it
			ON(it.id_tipo_prestamo = h.issuetype)
			LEFT JOIN cat_nivel1 n1
			ON (n1.id1 = h.id1)
			LEFT JOIN cat_autor a
			ON (a.id = n1.autor) 
			LEFT JOIN cat_nivel3 n3
			ON (n3.id3 = h.id3) ";

	my $where = "";
	if ($chkfecha ne 'false'){
		$where = " WHERE (date>=?) AND (date<=?) ";
		push(@bind,$fechaIni);
		push(@bind,$fechaFin);
	}
	if (($user)&&($user ne '-1')){	
		if ($where eq ''){$where = " WHERE responsable=? ";}
		else {$where.= " AND responsable=? ";}
		push(@bind,$user);
	}
	if(($tipoOperacion)&&($tipoOperacion ne '-1')){
		if ($where eq ''){$where = " WHERE h.type = ? ";}
		else{$where .= " AND h.type = ? ";}
		push(@bind, $tipoOperacion);
	}

	if(($tipoPrestamo)&&($tipoPrestamo ne '-1')){
		if ($where eq ''){ $where = " WHERE h.issuetype = ? ";}
		else{$where .= " AND h.issuetype = ? ";}
		push(@bind, $tipoPrestamo);
	}

# 	my $finCons=" ORDER BY ".$orden." limit $ini,$cantR ";
#Miguel solo para testear, despues sacar
	my $finCons=" ORDER BY h.timestamp desc limit $ini,$cantR ";

#para buscar las operaciones sobre un item, viene desde el pl detalleItemResult.pl
	if($id3 ne ''){
		$where.=" AND n3.id3 = ?";
		push(@bind,$id3);
	}
	
	$query="SELECT count(*) as cant ".$from.$where;
        my $sth=$dbh->prepare($query);
        $sth->execute(@bind);
	$cant=$sth->fetchrow_array;
	
	$query=$select.$from.$where.$finCons;
	$sth=$dbh->prepare($query);
        $sth->execute(@bind);
	my @results;
        while (my $data=$sth->fetchrow_hashref){
		$data->{'fecha'}=format_date($data->{'date'},$dateformat);
		$data->{'operacion'}=tipoDeOperacion($data->{'type'});
		$data->{'nomCompleto'}=$data->{'surname'}.", ".$data->{'firstname'};
		$data->{'userCompleto'}=$data->{'userSurname'}.", ".$data->{'userFirstname'};
		$data->{'unititle'}=C4::AR::Nivel1::getUnititle($data->{'id1'});
                push(@results,$data);
        }
        return ($cant,@results);
}

sub historicoSanciones(){
	my ($fechaIni,$fechaFin,$user,$id3,$ini,$cantR,$orden,
	$tipoPrestamo,$tipoOperacion)=@_;
	
        my $dbh = C4::Context->dbh;
	my @bind;
	my $query="";
	my $cant=0;


	my $select= " 	SELECT hs.borrowernumber, hs.responsable,hs.type, b.firstname AS firstnameBor, 
			b.surname AS surnameBor,resp.firstname AS firstnameResp, resp.surname AS surnameResp,
			hs.end_date, hs.date, st.issuecode, hs.timestamp, hs.sanctiontypecode, 
			it.description AS tipoPrestamo";

	my $from= "	FROM rep_historial_sancion hs INNER JOIN borrowers b
			ON (hs.borrowernumber = b.borrowernumber)
			LEFT JOIN borrowers resp
			ON (hs.responsable = resp.borrowernumber)
			LEFT JOIN circ_tipo_sancion st
			ON (st.sanctiontypecode = hs.sanctiontypecode) 
			LEFT JOIN circ_ref_tipo_prestamo it
			ON (it.id_tipo_prestamo = st.issuecode) ";

	my $where = "";

	$where = " WHERE (date>=?) AND (date<=?) ";
	push(@bind,$fechaIni);
	push(@bind,$fechaFin);


	if (($user)&&($user ne '-1')){	
		if ($where eq ''){$where = " WHERE responsable=? ";}
		else {$where.= " AND responsable=? ";}
		push(@bind,$user);
	}

	if(($tipoOperacion)&&($tipoOperacion ne '-1')){
		if ($where eq ''){$where = " WHERE hs.type = ? ";}
		else{$where .= " AND hs.type = ? ";}
		push(@bind, $tipoOperacion);
	}

	if(($tipoPrestamo)&&($tipoPrestamo ne '-1')){
		if ($where eq ''){ $where = " WHERE st.issuecode = ? ";}
		else{$where .= " AND st.issuecode = ? ";}
		push(@bind, $tipoPrestamo);
	}

	my $finCons=" ORDER BY $orden DESC LIMIT $ini,$cantR ";

	$query="SELECT count(*) as cant ".$from.$where;
        my $sth=$dbh->prepare($query);
        $sth->execute(@bind);
	$cant=$sth->fetchrow_array;
	
	$query=$select.$from.$where.$finCons;
	$sth=$dbh->prepare($query);
        $sth->execute(@bind);
	my @results;
	my $dateformat = C4::Date::get_date_format();
        while (my $data=$sth->fetchrow_hashref){
		$data->{'operacion'}=tipoDeOperacion($data->{'type'});
		$data->{'respCompleto'}=$data->{'surnameResp'}.", ".$data->{'firstnameResp'};
		$data->{'userCompleto'}=$data->{'surnameBor'}.", ".$data->{'firstnameBor'};
		$data->{'date'}=format_date($data->{'date'},$dateformat);
		$data->{'end_date'}=format_date($data->{'end_date'},$dateformat);
                push(@results,$data);
        }
        return ($cant,@results);
}


sub tipoDeOperacion(){
	my ($tipo)=@_;
	if($tipo eq "issue"){$tipo="Prestamo";}
	elsif($tipo eq "return"){$tipo="Devoluci&oacute;n";}
	elsif($tipo eq "cancel"){$tipo="Cancelaci&oacute;n";}
	elsif($tipo eq "notification"){$tipo="Notificaci&oacute;n (Vto. Reserva)";}
	elsif($tipo eq "queue"){$tipo="R. en Espera";}
	elsif($tipo eq "reserve"){$tipo="Reservado";}
	elsif($tipo eq "renew"){$tipo="Renovado";}
	elsif($tipo eq "reminder"){$tipo="Notificaci&oacute;n (Vto. Pr&eacute;stamo)";}
	elsif($tipo eq "Insert"){$tipo="Agregado";}	
	elsif($tipo eq "Delete"){$tipo="Borrado";}
	return $tipo;
}

sub insertarNotaHistCirc(){
	my ($id,$nota)=@_;
        my $dbh = C4::Context->dbh;
        my $query="update  rep_historial_circulacion set nota=?
		   where id=?";
        my $sth=$dbh->prepare($query);
        $sth->execute($nota,$id);
}

sub userCategReport{
	my ($branch)=@_;
	my $dbh = C4::Context->dbh;
        my $query=" SELECT categorycode, count( categorycode ) as cant FROM borrowers WHERE branchcode = ? GROUP BY categorycode  ";
        my $sth=$dbh->prepare($query);
        $sth->execute($branch);
        my @results;
 	my $clase='par';
	my $catcode;
	my $i=0;
	my %indices;
        while (my $data=$sth->fetchrow_hashref){
	        if ($clase eq 'par') {$clase='impar'} else {$clase='par'};
		$catcode=$data->{'categorycode'};
		$indices{$catcode}=$i;
		$results[$i]->{'reales'}=$data->{'cant'};
		$results[$i]->{'categoria'}=C4::AR::Busquedas::getborrowercategory($data->{'categorycode'});
		$results[$i]->{'clase'}=$clase;
		$i++;
        }

	my $query=" SELECT categorycode, count( categorycode ) as cant FROM persons WHERE branchcode = ? AND borrowernumber IS NULL GROUP BY categorycode  ";
	$sth=$dbh->prepare($query);
        $sth->execute($branch);
	while (my $data=$sth->fetchrow_hashref){
		$catcode=$data->{'categorycode'};
		if (not exists($indices{$catcode})){
			if ($clase eq 'par') {$clase='impar'} else {$clase='par'};
			$results[$i]->{'reales'}=0;
			$results[$i]->{'potenciales'}=$data->{'cant'};
			$results[$i]->{'categoria'}=C4::AR::Busquedas::getborrowercategory($data->{'categorycode'});
			$results[$i]->{'clase'}=$clase;
			$i++;
		}
		else{
			$results[$indices{$catcode}]->{'potenciales'}=$data->{'cant'};
		}
	}
         return (scalar(@results),@results);
}

=item
SE USA EN EL REPORTE Generar Etiquetas
=cut
sub signaturamax {
 my ($branch) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT MAX(signatura_topografica) AS max FROM cat_nivel3 WHERE signatura_topografica IS NOT NULL AND signatura_topografica <> '' AND homebranch = ?");
	$sth->execute($branch);
	my $res= ($sth->fetchrow_hashref)->{'max'};
	return $res;
}

=item
SE USA EN EL REPORTE Generar Etiquetas
=cut
sub signaturamin {
 my ($branch) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT MIN(signatura_topografica) AS min FROM cat_nivel3 WHERE signatura_topografica IS NOT NULL AND signatura_topografica <> '' AND homebranch = ?");
	$sth->execute($branch);
	my $res= ($sth->fetchrow_hashref)->{'min'};
	return $res;
	}


=item
SE USA EN EL REPORTE Generar Etiquetas
=cut

sub listaDeEjemplares {
	my ($minbarcode,$maxbarcode,$minlocation,$maxlocation,$beginlocation,$branch,$ini,$fin,$orden) = @_;
	my @bind;
	my $branchcode=  $branch || C4::AR::Preferencias->getValorPreferencia('defaultbranch');
	my $dbh = C4::Context->dbh;
	my $query="SELECT id3, barcode, signatura_topografica, titulo, autor, anio_publicacion, n3.id2, n2.id2, homebranch
	FROM ((cat_nivel3 n3 INNER JOIN cat_nivel2 n2 ON n3.id2 = n2.id2)
	INNER JOIN cat_nivel1 n1 ON n1.id1 = n2.id1)
	WHERE ";
	
	if ($beginlocation ne '') {
		$query.=" (signatura_topografica LIKE '".$beginlocation."%') ";
	}
	else {
	
		if (($minbarcode ne '') and ($maxbarcode ne '')) {
			$query.=" (barcode BETWEEN ? AND ?) ";
			push(@bind,$minbarcode);
			push(@bind,$maxbarcode);
		}
		if (($minlocation ne '') and ($maxlocation ne '')) {
			if (($minbarcode ne '') and ($maxbarcode ne '')) {$query.=" AND ";} #Se van a hacer las 2 consultas
		
			$query.=" (signatura_topografica BETWEEN ? AND ?) ";
			push(@bind,$minlocation);
			push(@bind,$maxlocation);
		}
	}
	my @results;
	if (($beginlocation ne '') or (($minbarcode ne '') and ($maxbarcode ne '')) or (($minlocation ne '') and ($maxlocation ne ''))) {
	#Se va a hacer la consulta

		$query.=" AND (homebranch= ?) ;";
		push(@bind,$branchcode);	
		my $sth = $dbh->prepare($query);
		$sth->execute(@bind);
	
		while (my $row = $sth->fetchrow_hashref) {
# 			$row->{'publisher'}=C4::Circulation::Circ2::getpublishers($row->{'biblioitemnumber'});
			$row->{'number'}=C4::AR::Nivel2::getEdicion($row->{'id2'});
			$row->{'autor'}=C4::AR::Busquedas::getautor($row->{'autor'});
			$row->{'unititle'}=C4::AR::Nivel1::getUnititle($row->{'id1'});
			$row->{'completo'}=($row->{'autor'})->{'completo'}; #para dar el orden
			push @results,$row;
		}

		if ($orden){
		# Da el ORDEN al arreglo
			my @sorted = sort { $a->{$orden} cmp $b->{$orden} } @results;
			@results=@sorted;
		}

		my $cantReg=scalar(@results);

		#Se chequean si se quieren devolver todos
		if(($cantReg > $fin)&&($fin ne "todos")){
			my $cantFila=$fin-1+$ini;
			my @results2;
			if($cantReg < $cantFila ){
				@results2=@results[$ini..$cantReg];
			}
			else{
				@results2=@results[$ini..$fin-1+$ini];
			}

			return($cantReg,@results2);
		}
        	else{
			return ($cantReg,@results);
		}

	}
	else {# NO se hace la consulta
		return (0,@results);
	}	
}

