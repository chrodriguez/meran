package C4::AR::Estadisticas;

#
#Este modulo sera el encargado del manejo de estadisticas sobre los prestamos
#,reservas, devoluciones y todo tipo de consulta sobre el uso de la biblioteca
#
#

use strict;
require Exporter;
use C4::Search;
use C4::Context;
use C4::Date;
use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(&usuarios
	   &historicoPrestamos
           &cantidadPrestamos
	   &cantidadRetrasados
	   &renovacionesDiarias
	   &prestamos
	   &reservas
	   &cantUsuarios
	   &cantidadReservas
	   &registroActividadesDiarias
	   &registroEntreFechas
	   &insertarNota
	   &armarPaginas
	   &cantidadRenglones
	   &prestamosAnual
	   &cantidadUsuarios
	   &cantidadReservas
	   &cantRegDiarias
	   &cantRegFechas
	   &biblioitems
	   &cantidadBiblio
	   &biblio
	   &cantBiblio
	   &items
	   &cantidadItem
	   &cantidadTipos
	   &cantidadAnaliticas
	   &disponibilidad
	   &disponibilidadCantidad
	   &itemtypesReport
	   &levelsReport
	   &availYear
	   &getuser
	   &estadisticasGenerales
	   &cantidadUsuariosPrestamos
	   &cantidadUsuariosReservas
	   &cantidadUsuariosRenovados
);


sub historicoPrestamos{
	#Se realiza un Historial de Prestamos, con los siguientes datos:
	#Apellido y Nombre, DNI,Categoria del Usuario, Tipo de Prestamo, Codigo de Barras, 
	#Fecha de Prestamo, Fecha de Devolucion, Tipo de Item
	
	my ($orden,$ini,$fin,$tipoItem,$tipoPrestamo,$catUsuario)=@_;
	my $dbh = C4::Context->dbh;

	my $datesSQL='';
	if (($ini ne '') and ($fin ne '')){
		$datesSQL=' AND I.date_due BETWEEN "'.format_date_in_iso($ini).'" AND "'.format_date_in_iso($fin).'" ';
	}

	my $tipoDePrestamoSQL;
	if ($tipoPrestamo ne "SIN SELECCIONAR"){
		$tipoDePrestamoSQL= 'and ISST.issuecode = "'.$tipoPrestamo.'"';
	}	

	my $tipoDeItemSQL = '';;
	if ($tipoItem ne "SIN SELECCIONAR"){
		$tipoDeItemSQL= 'and ITT.itemtype = "'.$tipoItem.'"';
	}

	my $catUsuarioSQL = '';
	if ($catUsuario ne "SIN SELECCIONAR"){
		$catUsuarioSQL= 'and C.categorycode = "'.$catUsuario.'"';
	}
	

        my $query ="Select B.firstname, B.surname, B.documentnumber as DNI, C.description as CatUsuario, ISST.description as tipoPrestamo, IT.barcode, I.date_due as fechaPrestamo, I.returndate as fechaDevolucion, ITT.description as tipoItem
	From issues I, borrowers B, categories C, items IT, biblioitems BBI, itemtypes ITT, issuetypes ISST
	where (B.borrowernumber = I.borrowernumber)and(C.categorycode = B.categorycode)
	and(IT.itemnumber = I.itemnumber)and(ISST.issuecode = I.issuecode)
	and(BBI.biblioitemnumber = IT.biblioitemnumber)and(ITT.itemtype = BBI.itemtype)
	and not(I.returndate is null)
	$datesSQL
	$tipoDeItemSQL
	$tipoDePrestamoSQL
	$catUsuarioSQL
	Order By ".$orden;

	my $sth=$dbh->prepare($query);
        $sth->execute();

	my @results;
	my $clase;
	while (my $data=$sth->fetchrow_hashref){
		if ($clase eq 'par') {$clase='impar';}else{$clase='par'};
		$data->{'fechaPrestamo'}=format_date($data->{'fechaPrestamo'});
		$data->{'fechaDevolucion'}=format_date($data->{'fechaDevolucion'});
		push(@results,$data);
        };
	return(scalar(@results),@results);      
}


#
#Cuenta la cantidad de prestamos realizados durante el año que ingresa por parametro
sub prestamosAnual{
        my ($branch,$year)=@_;
 	my $clase='par';
        my $dbh = C4::Context->dbh;
	my @results;
	my $query ="SELECT month( date_due ) AS mes, count( * ) AS cantidad,SUM( renewals ) AS 
			   renovaciones, issuecode
		    FROM issues 
		    WHERE year( date_due ) = ? 
		    GROUP BY month( date_due ), issuecode";

	my $sth=$dbh->prepare($query);
        $sth->execute($year);
	while (my $data=$sth->fetchrow_hashref){
		if ($clase eq 'par') {$clase='impar';}else{$clase='par'};
		if ($data->{'mes'} eq "1") {$data->{'mes'}='Enero'};
		if ($data->{'mes'} eq "2") {$data->{'mes'}='Febrero'};
		if ($data->{'mes'} eq "3") {$data->{'mes'}='Marzo'};
		if ($data->{'mes'} eq "4") {$data->{'mes'}='Abril'};
		if ($data->{'mes'} eq "5") {$data->{'mes'}='Mayo'};
		if ($data->{'mes'} eq "6") {$data->{'mes'}='Junio'};
		if ($data->{'mes'} eq "7") {$data->{'mes'}='Julio'};
		if ($data->{'mes'} eq "8") {$data->{'mes'}='Agosto'};
		if ($data->{'mes'} eq "9") {$data->{'mes'}='Septiembre'};
		if ($data->{'mes'} eq "10") {$data->{'mes'}='Octubre'};
		if ($data->{'mes'} eq "11") {$data->{'mes'}='Noviembre'};
		if ($data->{'mes'} eq "12") {$data->{'mes'}='Diciembre'};
		$data->{'clase'}=$clase;
		push(@results,$data);
        	};
	$query ="SELECT count( * ) AS devoluciones
                 FROM issues 
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
        my ($branch,$orden,$avail,$ini,$fin)=@_;
        my $dbh = C4::Context->dbh;
	my @results;
	my $dates='';
	if (($ini ne '') and ($fin ne '')){
		$dates=' AND av.date between "'.format_date_in_iso($ini).'" AND "'.format_date_in_iso($fin).'" ';
	}

	my $query = "SELECT DISTINCT i.*,bi.number,bi.publicationyear,b.title,b.author,
		     MAX(av.date) AS date, a.completo
	  	     FROM items i INNER JOIN biblioitems bi ON (i.biblioitemnumber = bi.biblioitemnumber) 
		     INNER JOIN biblio b ON (bi.biblionumber=b.biblionumber) 
		     INNER JOIN availability av ON ( av.item = i.itemnumber  ) 
		     INNER JOIN autores a ON (a.id = b.author)
		     WHERE i.wthdrawn = ? AND homebranch=? ".$dates. " GROUP BY av.item
		     ORDER BY ".$orden;
	


        my $sth=$dbh->prepare($query);

        $sth->execute($avail,$branch);
        my $clase='par';
        while (my $data=$sth->fetchrow_hashref){
		if ($clase eq 'par'){$clase='impar'}else{$clase='par'};
		$data->{'clase'}=$clase;
		$data->{'date'}=format_date($data->{'date'});
		my $autorPPAL= &getautor($data->{'author'});
                $data->{'author'}=$autorPPAL->{'completo'};
		push(@results,$data);
        }
        return (scalar(@results),@results);
}

sub disponibilidadCantidad{
        my ($branch,$avail)=@_;
        my $dbh = C4::Context->dbh;
        my @results;
        my $query ="select count(itemnumber)
                    from items i
                    where i.wthdrawn = ? and homebranch=? ";
        my $sth=$dbh->prepare($query);
        $sth->execute($avail,$branch);
        my $res=$sth->fetchrow_hashref;
        return ($res);
}   

#
#Cantidad de renglones seteado en los parametros del sistema para ver por cada pagina
sub cantidadRenglones{
        my $dbh = C4::Context->dbh;
        my $query="select value
		   from systempreferences
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

sub insertarNota{
	my ($id,$nota)=@_;
        my $dbh = C4::Context->dbh;
        my $query="update  modificaciones set nota=?
		   where idModificacion=?";
        my $sth=$dbh->prepare($query);
        $sth->execute($nota,$id);
}

sub cantRegFechas{
	my ($chkfecha,$fechaInicio,$fechaFin,$tipo,$operacion,$chkuser,$chknum,$user,$numDesde,$numHasta)=@_;
        my $dbh = C4::Context->dbh;
        my $query ="SELECT  count(*)
        	    FROM modificaciones INNER JOIN borrowers ON
		   (modificaciones.responsable=borrowers.cardnumber) ";
	my $where = "";
	
	if ($chkfecha ne ''){
		$where = "WHERE";
		$query.= $where." (fecha>='$fechaInicio') AND (fecha<='$fechaFin')";	
	}

	if ($operacion ne ''){
		if ($where eq ''){
			$where = "WHERE";
			$query.= $where." operacion='$operacion'";
		}
		else {$query.= " AND operacion='$operacion'";}
	}

	if ($tipo ne ''){
		if ($where eq ''){
			$where = "WHERE";
			$query.= $where." tipo='$tipo'";
		}
		else {$query.= " AND tipo='$tipo'";}
	}

	if ($chkuser ne ''){
		if ($where eq ''){
			$where = "WHERE";
			$query.= $where." responsable='$user'";
		}
		else {$query.= " AND responsable='$user'";}
	}
	
	if ($chknum ne ''){
		if ($where eq ''){
			$where = "WHERE";
			$query.= $where." numero >= '$numDesde' AND numero <= '$numHasta'";
		}
		else {$query.= " AND numero >= '$numDesde' AND numero <= '$numHasta'";}
	}

	my $sth=$dbh->prepare($query);
        $sth->execute();
        return($sth->fetchrow_array);


}


sub registroEntreFechas{
        my ($orden,$chkfecha,$fechaInicio,$fechaFin,$tipo,$operacion,$ini,$fin,$chkuser,$chknum,$user,$numDesde,$numHasta)=@_;
        my $dbh = C4::Context->dbh;
        my $clase='par';
        my $query="SELECT operacion,fecha,responsable,numero,tipo,surname,firstname
		   FROM modificaciones INNER JOIN borrowers ON
		   (modificaciones.responsable=borrowers.cardnumber) "; 
	my $where = "";
	
	if ($chkfecha ne ''){
		$where = "WHERE";
		$query.= $where." (fecha>='$fechaInicio') AND (fecha<='$fechaFin')";	
	}

	if ($operacion ne ''){
		if ($where eq ''){
			$where = "WHERE";
			$query.= $where." operacion='$operacion'";
		}
		else {$query.= " AND operacion='$operacion'";}
	}

	if ($tipo ne ''){
		if ($where eq ''){
			$where = "WHERE";
			$query.= $where." tipo='$tipo'";
		}
		else {$query.= " AND tipo='$tipo'";}
	}

	if ($chkuser ne ''){
		if ($where eq ''){
			$where = "WHERE";
			$query.= $where." responsable='$user'";
		}
		else {$query.= " AND responsable='$user'";}
	}
	
	if ($chknum ne ''){
		if ($where eq ''){
			$where = "WHERE";
			$query.= $where." numero >= '$numDesde' AND numero <= '$numHasta'";
		}
		else {$query.= " AND numero >= '$numDesde' AND numero <= '$numHasta'";}
	}

	$query.=" ORDER BY ? limit $ini,$fin";
        my $sth=$dbh->prepare($query);
        $sth->execute($orden);
        my @results;

	my $IdModificacion;

        while (my $data=$sth->fetchrow_hashref){
                if ($clase eq 'par') {$clase='impar';} else {$clase='par'};
		$data->{'fecha'}=format_date($data->{'fecha'});
 	        $data->{'clase'}=$clase;
		$data->{'nomCompleto'}=$data->{'surname'}.", ".$data->{'firstname'};

		#ES RE TRUCHO PERO FUNCIONA, VER

		#$IdModificacion = $data->{'idModificacion'};
		#tengo que recuperar el numero del IdModificacion anterior
		#$IdModificacion = $IdModificacion - 1;

		#my $dbh = C4::Context->dbh;
	        #my $query="Select numero  
		#	   from modificaciones
                #	   where (idmodificacion = ?) ";
	        #my $sth2=$dbh->prepare($query);
        	#$sth2->execute($IdModificacion);

		#while (my $data2=$sth2->fetchrow_hashref){

		#$data->{'bib'} = $data2->{'numero'};
		#}	

                push(@results,$data);
        }
        return (@results);
}


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
 	my $clase='par';
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
		if ($clase eq 'par') {$clase='impar';}else {$clase='par'};
		$data->{'fecha'}=format_date($data->{'fecha'});
		$data->{'clase'}=$clase;
		$data->{'nomCompleto'}=$data->{'surname'}.", ".$data->{'firstname'};
                push(@results,$data);
        }
        return (@results);
}

#
#Prestamos sin devolucion al dia de hoy
#

sub cantidadRetrasados{
        my ($branch)=@_; 
	my $dbh = C4::Context->dbh;
	my @results;
	my $query ="Select * 
	              From issues inner join borrowers on (issues.borrowernumber=borrowers.borrowernumber)
        	      Where (returndate is NULL and issues.branchcode = ? ) ";
	my $sth=$dbh->prepare($query);
	$sth->execute(&branch);
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
  		    from issues inner join borrowers on (issues.borrowernumber=borrowers.borrowernumber)
		    where (returnDate is NULL and issues.branchcode=? and renewals >= 1 )";
	my $sth=$dbh->prepare($query);
	$sth->execute(&branch);
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
		    from issues inner join borrowers on (issues.borrowernumber=borrowers.borrowernumber)
		    where (issues.date_due=? and issues.branchcode = ?)";
        my $sth=$dbh->prepare($query);
        $sth->execute(&fecha,&branch);
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
                    from issues inner join borrowers on (issues.borrowernumber=borrowers.borrowernumber)
		    where (issues.returndate=? and issues.branchcode=?) ";
        my $sth=$dbh->prepare($query);
        $sth->execute(&fecha,&branch);
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
                    from issues inner join borrowers on (issues.borrowernumber=borrowers.borrowernumber)
		    where borrowers.borrowernumber=? and issues.branchcode=?";
        my $sth=$dbh->prepare($query);
        $sth->execute(&id,&branch);
	return($sth->fechtrow_hashref);
}



sub cantidadUsuarios{
        my ($branch,$anio,$usos,@chck)=@_;
        my $dbh = C4::Context->dbh;
        my $query ="SELECT count( * ) AS cantidad
                    FROM borrowers b
                    WHERE branchcode='$branch'";

	my $query2 = "SELECT * FROM issues i WHERE b.borrowernumber = i.borrowernumber ";

	my $exists = "";
	for (my $i=0; $i < scalar(@chck); $i++){
		if($chck[$i] eq "AN"){
			$query2 = $query2 ." AND year( date_due )= $anio";
			$exists = " AND EXISTS (";
		}
		else{
			if($usos eq "NI"){
				$exists = " AND NOT EXISTS (";
			}
			else{
				$exists = " AND EXISTS (";
			}
		}
	}
	if ($exists ne ""){
		$query = $query.$exists.$query2.")";
	}
	my $sth=$dbh->prepare($query);
        $sth->execute();
	return($sth->fetchrow_array);
	
}

#Usuarios de un branch dado 
#Damian - 31/05/2007 - Se agrego para difereciar usuarios que usan y no usan la biblioteca
sub usuarios{
        my $clase='par';
        my ($branch,$orden,$ini,$fin,$anio,$usos,@chck)=@_;
	my $dbh = C4::Context->dbh;
  	my @results;

        my $query ="SELECT  b.phone,b.emailaddress,b.dateenrolled,c.description as categoria ,
		    b.firstname,b.surname,b.streetaddress,b.cardnumber,b.city
                    FROM borrowers b inner join categories c on (b.categorycode = c.categorycode)
 		    WHERE b.branchcode='$branch'";

	my $query2 = "SELECT * FROM issues i WHERE b.borrowernumber = i.borrowernumber ";

	my $exists = "";
	for (my $i=0; $i < scalar(@chck); $i++){
		if($chck[$i] eq "AN"){
			$query2 = $query2 ." AND year( date_due )= $anio";
			$exists = " AND EXISTS (";
		}
		else{
			if($usos eq "NI"){
				$exists = " AND NOT EXISTS (";
			}
			else{
				$exists = " AND EXISTS (";
			}
		}
	}
	if ( $exists eq ""){
		$query .= " order by ($orden) limit $ini,$fin";
	}
	else{
		$query= $query.$exists.$query2.") group by b.borrowernumber order by ($orden) limit $ini,$fin";
	}
        my $sth=$dbh->prepare($query);
        $sth->execute();
	while (my $data=$sth->fetchrow_hashref){
                if ($clase eq 'par'){$clase='impar';}else {$clase='par'};
		if ($data->{'phone'} eq "" ){$data->{'phone'}='-' };
		if ($data->{'emailaddress'} eq "" ){
					$data->{'emailaddress'}='-';
					$data->{'ok'}=1;
				};
                $data->{'clase'}=$clase;
		$data->{'dateenrolled'}=format_date($data->{'dateenrolled'});
		$data->{'city'}=getcitycategory($data->{'city'});
                push(@results,$data);
        }
        return (@results);
}

sub cantidadPrestamos{
	
	my ($branch,$estado)=@_;
        my $dbh = C4::Context->dbh;
        my $query ="select issues.itemnumber as itemnumber
                    from issues inner join borrowers on (issues.borrowernumber=borrowers.borrowernumber)
		    inner join issuetypes on (issues.issuecode = issuetypes.issuecode)
		    inner join items on (issues.itemnumber = items.itemnumber)
                    where issues.branchcode='$branch' and returndate is NULL";
        my $sth=$dbh->prepare($query);
        $sth->execute();
	my @datearr = localtime(time);
	my $hoy =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
	my $cantidad=0;
	while (my $data=$sth->fetchrow_hashref){
		$data->{'vencimiento'}=format_date(C4::AR::Issues::vencimiento($data->{'itemnumber'}));
		my $flag=Date::Manip::Date_Cmp($data->{'vencimiento'},$hoy);
		if ($estado eq "VE"){
			if ($flag lt 0){
				$cantidad++;
			}
		}
		elsif($estado eq "NV"){
			if($flag gt 0 || $flag == 0){
				$cantidad++;
			}
		}
		else{
			$cantidad++;
		}
        }

        return($cantidad);

}

sub prestamos{
        my ($branch,$orden,$ini,$fin,$estado)=@_;
        my $dbh = C4::Context->dbh;
        my @results;
        my $clase='par';
	my $query ="select borrowers.borrowernumber AS borrowernumber,
			   items.itemnumber AS itemnumber, items.biblionumber AS biblionumber,
			   issuetypes.issuecode AS issuecode,description,
			   date_due, issues.branchcode AS branchcode, returndate,
			   surname, firstname, cardnumber, emailaddress, barcode
                    from issues inner join borrowers on (issues.borrowernumber=borrowers.borrowernumber)
		    inner join issuetypes on (issues.issuecode = issuetypes.issuecode)
		    inner join items on (issues.itemnumber = items.itemnumber)
                    where issues.branchcode=? and returndate is NULL
		    order by (?)
		    limit  $ini,$fin";
        my $sth=$dbh->prepare($query);
        $sth->execute($branch,$orden);
	my @datearr = localtime(time);
	my $hoy =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
	while (my $data=$sth->fetchrow_hashref){
                if ($clase eq 'par'){$clase='impar';} else {$clase='par'};
		$data->{'clase'}=$clase;
                if ($data->{'phone'} eq "" ){$data->{'phone'}='-' };
		

		if ($data->{'emailaddress'} eq "" ){
					$data->{'emailaddress'}='-';
					$data->{'ok'}=1;
				 };
		if ($data->{'returndate'} eq "" ){$data->{'returndate'}='-' }
		else  { $data->{'returndate'} =  format_date($data->{'returndate'})};
		$data->{'date_due'}=format_date($data->{'date_due'});
		$data->{'vencimiento'}=format_date(C4::AR::Issues::vencimiento($data->{'itemnumber'}));
		my $flag=Date::Manip::Date_Cmp($data->{'vencimiento'},$hoy);
		if ($estado eq "VE"){
			if ($flag lt 0){
				push(@results,$data);
			}
		}
		elsif($estado eq "NV"){
			if($flag gt 0 || $flag == 0){
				 push(@results,$data);
			}
		}
		else{
			 push(@results,$data);
		}
        }
        return (@results);
}


sub cantidadReservas{
	my ($branch,$tipo)=@_;
        my $dbh = C4::Context->dbh;
        my $query ="select  count(*)
                   from reserves inner join borrowers on (reserves.borrowernumber=borrowers.borrowernumber) 
		   where constrainttype IS NULL";
	if($tipo eq "GR"){
		$query.=" AND itemnumber IS NULL";
	}
	elsif($tipo eq "EJ"){
# 		$query.=" AND reserves.branchcode='$branch' AND itemnumber IS NOT NULL"; 
# La linea anterior se comento porque cuando una reserva pasa grupo a ejemplar no se guarda el codigo de la biblioteca porque las reservas por grupo no lo hacen, por lo tanto al cambiar de estado la reserva, esto se mantiene.
		$query.=" AND itemnumber IS NOT NULL";
	}
        my $sth=$dbh->prepare($query);
        $sth->execute();
        return($sth->fetchrow_array);

}

sub reservas{
        my ($branch,$orden,$ini,$fin,$tipo)=@_;
        my $dbh = C4::Context->dbh;
        my $clase='par';
        my @results;
        my $query ="select surname, firstname, cardnumber, emailaddress, reminderdate,
		    barcode, reservedate, reserves.itemnumber as itemnumber, 
		    borrowers.borrowernumber AS borrowernumber,
		    reserves.branchcode as branchcode,
		    items.biblionumber AS biblionumber
                    from reserves inner join borrowers on (reserves.borrowernumber=borrowers.borrowernumber) 
		    left join items on (reserves.itemnumber = items.itemnumber )
		    where constrainttype IS NULL ";
	
	if($tipo eq "GR"){
		$query.=" AND biblionumber IS NULL";
	}
	elsif($tipo eq "EJ"){
# 		$query.=" AND reserves.branchcode='".$branch."' AND biblionumber IS NOT NULL";
# La linea anterior se comento porque cuando una reserva pasa grupo a ejemplar no se guarda el codigo de la biblioteca porque las reservas por grupo no lo hacen, por lo tanto al cambiar de estado la reserva, esto se mantiene.
		$query.=" AND biblionumber IS NOT NULL";
	}
	$query.=" order by(?) limit $ini , $fin";

        my $sth=$dbh->prepare($query);
	 $sth->execute($orden);
        while (my $data=$sth->fetchrow_hashref){
 		if ($clase eq 'par') {$clase ='impar';} else {$clase='par'};
		$data->{'reminderdate'}=format_date($data->{'reminderdate'});
		$data->{'reservedate'}=format_date($data->{'reservedate'});
		if ($data->{'itemnumber'} eq "" ){$data->{'itemnumber'}='-' };
                if ($data->{'emailaddress'} eq "" ){
					$data->{'emailaddress'}='-';
					$data->{'mail'}=1;
				 };
		$data->{'clase'}=$clase;
                push(@results,$data);
        }
        return (@results);
}

sub biblioitems{

  my ($orden,$ini,$fin)=@_;
	my $clase='par';
        my $dbh = C4::Context->dbh;
        my @results;
        my $query ="select  *
                    from biblioitems
                    order by($orden)
                    limit $ini , $fin";
        my $sth=$dbh->prepare($query);
        $sth->execute();
	while (my $data=$sth->fetchrow_hashref){
	 	if ($data->{'isbn'} eq "" ){
                        $data->{'isbn'}='-';}
		if ($data->{'seriesitle'} eq "" ){
                        $data->{'seriestitle'}='-';}
		if ($data->{'place'} eq "" ){
                        $data->{'place'}='-';}
		if ($clase eq 'par'){$clase='impar'} else {$clase='par'};
		if ($data->{'publicationyear'} eq "" ){
                        $data->{'publicationyear'}='-';}
                $data->{'clase'}=$clase;
                push(@results,$data);
	}
        return (@results);

}

sub cantidadBiblio{
	
        my $dbh = C4::Context->dbh;
        my $query ="select  count(*)
                    from biblioitems";
        my $sth=$dbh->prepare($query);
        $sth->execute();
        return($sth->fetchrow_array);

}

sub biblio{

  my ($orden,$ini,$fin)=@_;
        my $dbh = C4::Context->dbh;
        my @results;
        my $clase='par';
        my $query ="select  *
                    from biblio
                    order by($orden)
                    limit $ini , $fin";
        my $sth=$dbh->prepare($query);
        $sth->execute();
        while (my $data=$sth->fetchrow_hashref){
		if ($data->{'title'} eq "" ){
                        $data->{'title'}='-';}
		if ($data->{'seriestitle'} eq "" ){
                        $data->{'seriestitle'}='-';}
		if ($data->{'author'} eq "" ){
                        $data->{'author'}='-'}
			else
			{my $autorPPAL= &getautor($data->{'author'});
			 $data->{'author'}= $autorPPAL->{'apellido'};
		         $data->{'authorNombre'}= $autorPPAL->{'nombre'};
			}
		
		#para que muestre las filas intercalando el color	
                if ($clase eq 'par') {$clase='impar'} else {$clase='par'};
		$data->{'clase'}=$clase;
                push(@results,$data);
        }
        return (@results);

}

sub cantBiblio{
        
        my $dbh = C4::Context->dbh;
        my $query ="select  count(*)
                    from biblio";
        my $sth=$dbh->prepare($query);
        $sth->execute();
        return($sth->fetchrow_array);

}

sub items{
  my $clase='par';
  my ($orden,$ini,$fin)=@_;
        my $dbh = C4::Context->dbh;
        my @results;
        my $query ="select  *
                    from items
                    order by($orden)
                    limit $ini , $fin";
        my $sth=$dbh->prepare($query);
        $sth->execute();
        while (my $data=$sth->fetchrow_hashref){
		if ($data->{'barcode'} eq "" ){
                        $data->{'barcode'}='-';
		}
		#16/03/07 Miguel - No mostraba las filas con el color de  forma intercalada
		if ($clase eq 'par'){$clase='impar'} else {$clase='par'};
		$data->{'clase'}=$clase;
                push(@results,$data);
        }
        return (@results);

}

sub cantidadItem{

        my $dbh = C4::Context->dbh;
        my $query ="select  count(*)
                    from items";
        my $sth=$dbh->prepare($query);
        $sth->execute();
        return($sth->fetchrow_array);

}


sub cantidadTipos{
                                                                                                                   
        my $dbh = C4::Context->dbh;
        my @results;
        my $query ="SELECT count( * ) AS cantidad, itemtypes.description AS descripcion
		    FROM biblioitems
		    INNER JOIN itemtypes ON ( biblioitems.itemtype = itemtypes.itemtype )
		    GROUP BY itemtypes.itemtype";
        my $sth=$dbh->prepare($query);
        $sth->execute();
        my $clase='par';
        while (my $data=$sth->fetchrow_hashref){
		if ($clase eq 'par') {$clase='impar'} else {$clase='par'};
		$data->{'clase'}=$clase;
                push(@results,$data);
        }
        return (@results);
}                                                                                                                         

sub cantidadAnaliticas{
                                                                                                                             
        my $dbh = C4::Context->dbh;
        my @results;
	my $clase='par';
        my $query ="SELECT count( * ) AS cantidad
                    FROM biblioanalysis";
        my $sth=$dbh->prepare($query);
        $sth->execute();
        while (my $data=$sth->fetchrow_hashref){
		if ($clase eq 'par') {$clase='impar'} else {$clase='par'};
		$data->{'clase'}=$clase;
                push(@results,$data);
        }
        return (@results);
}


sub itemtypesReport{
        my ($branch)=@_;
        my $dbh = C4::Context->dbh;
        my $query=" SELECT itemtypes.description, count( itemtypes.description ) as cant
		FROM itemtypes
		LEFT JOIN biblioitems ON itemtypes.itemtype = biblioitems.itemtype
		INNER JOIN items ON biblioitems.biblioitemnumber = items.biblioitemnumber
		WHERE items.holdingbranch = ?
		GROUP BY itemtypes.description  ";
        my $sth=$dbh->prepare($query);
        $sth->execute($branch);
        my @results;
 	my $clase='par';
        while (my $data=$sth->fetchrow_hashref){
	        if ($clase eq 'par') {$clase='impar'} else {$clase='par'};
                $data->{'clase'}=$clase; 
                push(@results,$data);
        }
        return (scalar(@results),@results);
}

sub levelsReport{
        my ($branch)=@_;
        my $dbh = C4::Context->dbh;
        my $query="SELECT bibliolevel.description, count( bibliolevel.description ) AS cant
		FROM bibliolevel
		LEFT JOIN biblioitems ON bibliolevel.code = biblioitems.classification
		INNER JOIN items ON biblioitems.biblioitemnumber = items.biblioitemnumber
		WHERE items.holdingbranch = ?
		GROUP BY bibliolevel.description";
        my $sth=$dbh->prepare($query);
        $sth->execute($branch);
        my @results;
        my $clase='par';
        while (my $data=$sth->fetchrow_hashref){
    	        if ($clase eq 'par') {$clase='impar'} else {$clase='par'};
                $data->{'clase'}=$clase;
                push(@results,$data);
        }
        return (scalar(@results),@results);
}

sub availYear {
        my ($branch,$ini,$fin)=@_;
        my $dbh = C4::Context->dbh;
        my $query="SELECT month( date )  AS mes, year( date )  AS year, avail, count( avail )  AS cantidad
			FROM availability
			WHERE branch =  ?  AND date BETWEEN ? AND  ?
			GROUP  BY year( date ) , month( date )  ORDER  BY month( date ) , year( date )";
        my $sth=$dbh->prepare($query);
        $sth->execute($branch,format_date_in_iso($ini),format_date_in_iso($fin));
        my @results;
        my $clase='par';
        while (my $data=$sth->fetchrow_hashref){
		if ($clase eq 'par') {$clase='impar'} else {$clase='par'};
                $data->{'clase'}=$clase;

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

        my $query="SELECT count(*) as cant, issuecode, renewals FROM issues WHERE (renewals >0 OR renewals=0)";
	
	if ($chkfecha ne ''){
		$query.=" AND (date_due>='$fechaInicio') AND (date_due<='$fechaFin')";	
	}

	my $loop=scalar(@chck);
	my $subquery="";
	if ($loop>0){
		my $i;
		for ($i=0; $i<$loop-1; $i++){
			$subquery.=" issuecode = '$chck[$i]' OR";
			
		}
		$subquery =" AND (".$subquery." issuecode = '$chck[$loop-1]')";
	}
	$query .= $subquery." GROUP BY issuecode, renewals";

	my $sth=$dbh->prepare($query);
        $sth->execute();

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
		my $query="SELECT count(*) as devueltos, issuecode FROM issues WHERE returndate IS NOT NULL AND issuecode = 'DO'";
		if ($chkfecha ne ''){
			$query.=" AND (date_due>='$fechaInicio') AND (date_due<='$fechaFin')";	
		}
		$query.=" GROUP BY issuecode";
		
		my $sth=$dbh->prepare($query);
        	$sth->execute();
		my $data=$sth->fetchrow_hashref;
		$devueltos=$data->{'devueltos'};
	}
	else {$domiTotal="";} # Si no es una busqueda por domiciliario para que no muestre 0 en el tmpl


return ($domiTotal,$renovados,$devueltos,$sala,$foto,$especial); 
}


sub cantidadUsuariosPrestamos{
	my ($fechaInicio, $fechaFin, $chkfecha)=@_;
	my $dbh = C4::Context->dbh;
        my $query="SELECT borrowernumber FROM issues ";
	
	if ($chkfecha ne ''){
		$query.=" WHERE (date_due>='$fechaInicio') AND (date_due<='$fechaFin')";	
	}
	$query .=" GROUP BY borrowernumber";

	my $sth=$dbh->prepare($query);
        $sth->execute();
	my $cant;
	if($sth->rows()!=0){
		$cant=$sth->rows();
	}

return ($cant);
}

sub cantidadUsuariosRenovados{
	my ($fechaInicio, $fechaFin, $chkfecha)=@_;
	my $dbh = C4::Context->dbh;
        my $query="SELECT borrowernumber FROM issues WHERE renewals <> 0 ";
	
	if ($chkfecha ne ''){
		$query.=" AND (date_due>='$fechaInicio') AND (date_due<='$fechaFin')";	
	}
	$query .=" GROUP BY borrowernumber";

	my $sth=$dbh->prepare($query);
        $sth->execute();
	my $cant;
	if($sth->rows()!=0){
		$cant=$sth->rows();
	}

return ($cant);
}

sub cantidadUsuariosReservas{
	my ($fechaInicio, $fechaFin, $chkfecha)=@_;
	my $dbh = C4::Context->dbh;
        my $query="SELECT borrowernumber FROM reserves ";
	
	if ($chkfecha ne ''){
		$query.=" WHERE (reservedate>='$fechaInicio') AND (reservedate<='$fechaFin')";	
	}
	$query .=" GROUP BY borrowernumber";

	my $sth=$dbh->prepare($query);
        $sth->execute();
	my $cant;
	if($sth->rows()!=0){
		$cant=$sth->rows();
	}

return ($cant);
}




