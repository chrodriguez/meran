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
   my ($params_obj)=@_;

   my $dateformat = C4::Date::get_date_format();
   my @filtros;
    
   if ($params_obj->{'fechaIni'} ne ""){
      push(@filtros, ( 'busqueda.fecha' => {       eq=> format_date_in_iso($params_obj->{'fechaIni'},$dateformat), 
                                                   gt => format_date_in_iso($params_obj->{'fechaIni'},$dateformat), 
                                 }
                      ) );
   }
   if ($params_obj->{'fechaFin'} ne ""){
      push(@filtros, ( 'busqueda.fecha' => {       eq=> format_date_in_iso($params_obj->{'fechaFin'},$dateformat), 
                                                   lt => format_date_in_iso($params_obj->{'fechaFin'},$dateformat), 
                                }
                     ) );
   }
   if($params_obj->{'catUsuarios'} ne "SIN SELECCIONAR"){
      push(@filtros, ( 'busqueda.socio.cod_categoria' => { eq=> $params_obj->{'catUsuarios'}, }) );
   }
   use C4::Modelo::RepHistorialBusqueda::Manager;

   my $busquedas_count = C4::Modelo::RepHistorialBusqueda::Manager->get_rep_historial_busqueda_count(
                                                                                          query => \@filtros,
                                                                                          select => ['*','usr_socio.*'],
                                                                                          with_objects => ['busqueda','busqueda.socio'],
                                                                                           );
   my $busquedas = C4::Modelo::RepHistorialBusqueda::Manager->get_rep_historial_busqueda(
                                                                                          query => \@filtros,
                                                                                          sorty_by => $params_obj->{'orden'},
                                                                                          select => ['*','usr_socio.*'],
                                                                                          with_objects => ['busqueda','busqueda.socio'],
                                                                                        );
   return($busquedas_count,$busquedas);

}

sub historicoPrestamos{
   #Se realiza un Historial de Prestamos, con los siguientes datos:
   #Apellido y Nombre, DNI,Categoria del Usuario, Tipo de Prestamo, Codigo de Barras, 
   #Fecha de Prestamo, Fecha de Devolucion, Tipo de Item
   
   my ($params_obj)=@_;

   my $dateformat = C4::Date::get_date_format();

   my @filtros;

  
   my $prestamos_count = C4::Modelo::CircPrestamo::Manager->get_circ_prestamo_count(
                                                                        query => \@filtros,
                                                                        require_objects => ['nivel3','socio','ui','ui_prestamo'],
                                                                        ); 

   my $prestamos = C4::Modelo::CircPrestamo::Manager->get_circ_prestamo(
                                                                        query => \@filtros,
                                                                        require_objects => ['nivel3','socio','ui','ui_prestamo'],
                                                                        ); 

   return($prestamos_count,$prestamos);
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
##Ejemplares perdidos del branch que le paso por parametro
sub disponibilidad{
   my ($params_obj)=@_;
   use C4::Modelo::CatHistoricoDisponibilidad::Manager;
   my $dateformat = C4::Date::get_date_format();
   my $dates='';
   my @filtros;

   if (($params_obj->{'fechaInicio'} ne '') && ($params_obj->{'fechaInicio'} ne '')){
      push(@filtros, ( fecha => {      eq=> format_date_in_iso($params_obj->{'fechaInicio'},$dateformat), 
                                       gt => format_date_in_iso($params_obj->{'fechaInicio'},$dateformat), 
                                 }
                      ) );
      
      push(@filtros, ( fecha => {      eq=> format_date_in_iso($params_obj->{'fechaFin'},$dateformat), 
                                       lt => format_date_in_iso($params_obj->{'fechaFin'},$dateformat), 
                                }
                     ) );
   }

   push(@filtros, ( id_ui => { eq => $params_obj->{'ui'} } ) );

   push(@filtros, ( tipo_prestamo => { eq => $params_obj->{'disponibilidad'} } ) );

   my $det_disponibilidad = C4::Modelo::CatHistoricoDisponibilidad::Manager->get_cat_historico_disponibilidad(
                                                                                                          query => \@filtros,
                                                                                                          distinct => 1,
                                                                                                          require_objects => ['nivel3'],
                                                                                                          limit => $params_obj->{'cantR'},
                                                                                                          offset => $params_obj->{'ini'},
                                                                                                          sorty_by => $params_obj->{'orden'},
                                                                                                         );




   return (scalar(@$det_disponibilidad),$det_disponibilidad);
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


sub registroEntreFechas{
   my ($params_obj)=@_;

   my @filtros;

   use C4::Modelo::RepRegistroModificacion::Manager;

   if ($params_obj->{'chkfecha'} ne "false"){
      push(@filtros, ( fecha => {      eq=> $params_obj->{'fechaInicio'}, 
                                       gt => $params_obj->{'fechaInicio'}, 
                                 }
                      ) );
      
      push(@filtros, ( fecha => {      eq=> $params_obj->{'fechaFin'},
                                       lt => $params_obj->{'fechaFin'}  
                                }
                     ) );
   }

   C4::AR::Debug::debug($params_obj->{'tipo'});
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
                                 } ) );

      push(@filtros, ( numero => {
                                    eq=> $params_obj->{'numHasta'},
                                    lt => $params_obj->{'numHasta'}, 
                                 }
                     ) );
   }

   my $registros = C4::Modelo::RepRegistroModificacion::Manager->get_rep_registro_modificacion(
                                                                        query => \@filtros,
                                                                        sorty_by => $params_obj->{'orden'},
                                                                        limit => $params_obj->{'cantR'},
                                                                        offset => $params_obj->{'fin'},
                                                                        require_objects => ['socio_responsable'],
                                                                        );

   return (scalar(@$registros),$registros);
}

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
         my ($params_obj)=@_;
         my @results;
      
         my $dateformat = C4::Date::get_date_format();
         my @filtros;

         if ($params_obj->{'fechaIni'} ne ""){
            push(@filtros, ( 'fecha_prestamo' => {       eq=> format_date_in_iso($params_obj->{'fechaIni'},$dateformat), 
                                                         gt => format_date_in_iso($params_obj->{'fechaIni'},$dateformat), 
                                       }
                           ) );
         }
      
         if ($params_obj->{'fechaIni'} ne ""){
            push(@filtros, ( 'fecha_prestamo' => {       eq=> format_date_in_iso($params_obj->{'fechaFin'},$dateformat), 
                                                         lt => format_date_in_iso($params_obj->{'fechaFin'},$dateformat), 
                                    }
                           ) );
         }
      
         if($params_obj->{'id_ui'} ne "SIN SELECCIONAR"){
            push(@filtros, ( id_ui_origen => { eq=> $params_obj->{'id_ui'}, }) );
         }


         my $prestamos = C4::Modelo::CircPrestamo::Manager->get_circ_prestamo(
                                                                             query => \@filtros,
                                                                             require_objects => ['socio','nivel3'],
                                                                             );

         my @datearr = localtime(time);
         my $hoy =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
         my @results;
         foreach my $prestamo (@$prestamos){
            my $dateformat = C4::Date::get_date_format();
            $prestamo->{'vencimiento'}=C4::Date::format_date(C4::AR::Prestamos::vencimiento($prestamo),$dateformat);
            #Se filtra por Fechas de Vencimiento 
            if ( estaEnteFechas(($params_obj->{'fechaIni'},($params_obj->{'fechaFin'},$prestamo->getFecha_vencimiento_formateada))) ) {
              #Se filtra por Fechas de Vencimiento 
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

            if ( $params_obj->{'estado'} eq "TO" ){
                  push (@results,$prestamo);
            }
            elsif ( $params_obj->{'estado'} eq "VE" ){ 
                  if (C4::AR::Prestamos::estaVencido($prestamo->getId3,$prestamo->tipo->getId_tipo_prestamo)){
                        push (@results,$prestamo);
                  }
            } else{
                     if (!C4::AR::Prestamos::estaVencido($prestamo->getId3,$prestamo->tipo->getId_tipo_prestamo)){
                        push (@results,$prestamo);
                  }
            }
         }
      }#foreach
      
#       # Da el ORDEN al arreglo
#        if (($orden ne "vencimiento") and ($orden ne "date_due")) {
#        #ordeno alfabeticamente
#           my @sorted = sort { $a->{$orden} cmp $b->{$orden} } @results;
#           @results=@sorted;
#        }
#        else
#        {#ordeno Fechas
#           my @sorted = sort { Date::Manip::Date_Cmp($a->{$orden},$b->{$orden}) } @results;
#           @results=@sorted;
#        }
      #  
         my $cantReg=scalar(@results);
      #Se chequean si se quieren devolver todos
         if(($cantReg > $params_obj->{'fin'})&&($params_obj->{'fin'} ne "todos")){
            my $cantFila=($params_obj->{'cantR'}-1+($params_obj->{'ini'}) );
            my @results2;
            if($cantReg < $cantFila ){
               @results2=@results[($params_obj->{'ini'})..($params_obj->{'cantR'}) ];
            }
            else{
               @results2=@results[$params_obj->{'ini'}..$params_obj->{'cantR'}-1+$params_obj->{'ini'}];
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

   my $reservas_count = C4::Modelo::CircReserva::Manager->get_circ_reserva_count(   query => \@filtros,
                                                                               );

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
      return ($reservas_count,@results);
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


sub tiposDeItem_reporte{
      my ($id_ui)=@_;
      my @filtros;
      push (@filtros, ( id_ui_poseedora => { eq => $id_ui}) );

      my $tipos_item = C4::Modelo::CatNivel3::Manager->get_cat_nivel3(
                                                                        query => \@filtros,  
                                                                        select => ['nivel2.*','COUNT(tipo_documento) AS agregacion_temp'],
                                                                        group_by => ['tipo_documento'],
                                                                        with_objects => ['nivel2'],

                                                                     );
      my $tipos_item_count = C4::Modelo::CatNivel3::Manager->get_cat_nivel3_count(
                                                                        query => \@filtros,  
                                                                        with_objects => ['nivel2'],

                                                                     );

      return ($tipos_item_count,$tipos_item);
}

sub reporteNiveles{
      my ($id_ui)=@_;
        

#       my $query="SELECT ref_nivel_bibliografico.description, COUNT( ref_nivel_bibliografico.description ) AS cant
# 		FROM ref_nivel_bibliografico
# 		LEFT JOIN cat_nivel2 n2 ON bibliolevel.code = n2.nivel_bibliografico
# 		INNER JOIN cat_nivel3 n3 ON n2.id2 = n3.id2
# 		WHERE holdingbranch = ?
# 		GROUP BY ref_nivel_bibliografico.description";

      my @filtros;

      push (@filtros, ( id_ui_poseedora => { eq => $id_ui}) );

      my $niveles = C4::Modelo::CatNivel3::Manager->get_cat_nivel3(
                                                                     query => \@filtros,
                                                                     select => ['*','COUNT(nivel_bibliografico) AS agregacion_temp'],
                                                                     group_by => ['nivel_bibliografico'],
                                                                     sort_by => ['ref_nivel_bibliografico.description'],
                                                                     with_objects => ['nivel2.ref_nivel_bibliografico'],
                                                                  );

      return (scalar(@$niveles),$niveles);
}

sub disponibilidadAnio {

    my ($id_ui,$ini,$fin)=@_;
    my @filtros;
    my $dateformat = C4::Date::get_date_format();
    use C4::Modelo::CatHistoricoDisponibilidad::Manager;
#       my $query="SELECT month( date )  AS mes, year( date )  AS year, avail, count( avail )  AS cantidad
#       FROM cat_detalle_disponibilidad
#       WHERE branch =  ?  AND date BETWEEN ? AND  ?
#       GROUP  BY year( date ) , month( date )  ORDER  BY month( date ) , year( date )";

   push (@filtros, ( id_ui => { eq => $id_ui}) );

   if ($ini ne ""){
      push(@filtros, ( 'fecha' => {       eq=> format_date_in_iso($ini,$dateformat), 
                                          gt => format_date_in_iso($ini,$dateformat), 
                                  }
                      ) );
   }
   if ($fin ne ""){
      push(@filtros, ( 'fecha' => {       eq=> format_date_in_iso($fin,$dateformat), 
                                          lt => format_date_in_iso($fin,$dateformat), 
                                  }
                     ) );
   }

   my $detalle_disponibilidad =
                     C4::Modelo::CatHistoricoDisponibilidad::Manager->get_cat_historico_disponibilidad(
                                                                                                query => \@filtros,
                                                                                                select => [ 'estado',
                                                                                                            'YEAR(fecha) AS anio_agregacion',  
                                                                                                            'MONTH(fecha) AS mes_agregacion',
                                                                                                            'COUNT(estado) AS agregacion_temp'],
                                                                                                group_by => ['YEAR(fecha), MONTH(fecha)'],
                                                                                                sort_by => ['MONTH(fecha), YEAR(fecha)'],
                                                                                                  );
   return (scalar(@$detalle_disponibilidad),$detalle_disponibilidad);
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
   my ($params_obj)=@_;
   my @filtros;
   
   if ($params_obj->{'chkfecha'} ne "false"){
      push(@filtros, ( fecha => {      eq => $params_obj->{'fechaInicio'}, 
                                       gt => $params_obj->{'fechaInicio'}, 
                                 }
                        ) );
      
      push(@filtros, ( fecha => {      eq => $params_obj->{'fechaFin'},
                                       lt => $params_obj->{'fechaFin'},
                                 }
                     ) );
   }
   my @filtros_temp;
   my $loop=scalar($params_obj->{'chck_array'});
   my @loop_array = $params_obj->{'chck_array'};
   if ($loop>0){
      my @filtros_temp;
      for (my $i=0; $i<$loop-1; $i++){
          push (@filtros_temp, (tipo_prestamo => { eq=>@loop_array[$i] }));
      }
      push (@filtros,@filtros_temp);
   }
   my $prestamos = C4::Modelo::CircPrestamo::Manager->get_circ_prestamo(
                                                                     query => \@filtros,
                                                                     select => ['*','SUM(renovaciones) AS agregacion_temp'],
                                                                     group_by => ['tipo_prestamo',],

                                                                    );
   my $domiTotal=0;
   #my $noRenovados;
   my $devueltos;
   my $renovados;
   my $sala;
   my $foto;
   my $especial;


#FIXME que es esto????????????????????????????????????????????????????????????
=item
   while (my $data=$sth->fetchrow_hashref){
      if($data->{'issuecode'} eq 'DO'){
         if($data->{'renewals'}!=0){
            $renovados=$data->{'cant'};
         }
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
=cut
if ($prestamos->[0]){
   $domiTotal = $especial = $prestamos->[0]->agregacion_temp; #ARREGLO TEMPORAL POR EL FIXME DE ARRIBA
}
#******Para saber cuantos libros se devolvieron***********
   if($domiTotal){
      if ($params_obj->{'chkfecha'} ne "false"){

         push(@filtros, ( fecha => {      eq => $params_obj->{'fechaInicio'}, 
                                          gt => $params_obj->{'fechaInicio'}, 
                                    }
                           ) );

         push(@filtros, ( fecha => {      eq => $params_obj->{'fechaFin'},
                                          lt => $params_obj->{'fechaFin'},
                                    }
                        ) );
      }
      push(@filtros, ( tipo_prestamo => { eq => 'DO'},));
      my $prestamos_domiciliarios = C4::Modelo::CircPrestamo::Manager->get_circ_prestamo(
                                                                                          query => \@filtros,
                                                                                          group_by => ['tipo_prestamo',],
                                                                                       );
#       $devueltos=$data->{'devueltos'};
   }else {
            $domiTotal="";
         } # Si no es una busqueda por domiciliario para que no muestre 0 en el tmpl


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

  my $querySelect =" SELECT h.id, a.completo,a.id as idAutor,h.id1, n1.titulo, ";
  $querySelect .= "  h.id2,h.id3,h.branchcode as branchcode, ";
  $querySelect .= "  it.description,h.date as fechaReserva,h.end_date as fechaVto,h.type ";

  my $queryFrom .= " 	FROM rep_historial_circulacion h LEFT JOIN circ_ref_tipo_prestamo it ";
  $queryFrom .= " 	ON(it.id_tipo_prestamo = h.issuetype) ";
  $queryFrom .= " 	LEFT JOIN cat_nivel1 n1 ";
  $queryFrom .= " 	ON (n1.id1 = h.id1) ";
  $queryFrom .= " 	LEFT JOIN cat_autor a ";
  $queryFrom .= " 	ON (a.id = n1.autor) ";
  $queryFrom .= " 	LEFT ";

# FIXME que paso aca???????????
}

sub historicoCirculacion{
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

sub historicoSanciones{
	my ($params_obj)=@_;
   use C4::Modelo::RepHistorialSancion::Manager;
   my @filtros;
   my @results;

   push (@filtros, ( fecha => {  eq => format_date_in_iso($params_obj->{'fechaIni'}),
                                 gt => format_date_in_iso($params_obj->{'fechaIni'}) }) );

   push (@filtros, ( fecha => {  eq => format_date_in_iso($params_obj->{'fechaFin'}),
                                 lt => format_date_in_iso($params_obj->{'fechaFin'}) }) );


   if ( ($params_obj->{'user'}) && ($params_obj->{'user'} ne '-1') ){
      push (@filtros, ( responsable => { eq => $params_obj->{'user'} },) );
   }

   if( ($params_obj->{'tipoOperacion'}) && ($params_obj->{'tipoOperacion'} ne '-1') ){
      push (@filtros, ( tipo_operacion => { eq => $params_obj->{'tipoOperacion'} },) );
   }
   if ( ($params_obj->{'tipoPrestamo'}) && ($params_obj->{'tipoPrestamo'} ne '-1') ){
      push (@filtros, ( 'circ_tipo_sancion.tipo_operacion' => { eq => $params_obj->{'tipoPrestamo'} },) );
   }

   my $sanciones = C4::Modelo::RepHistorialSancion::Manager->get_rep_historial_sancion(
                                                                              query => \@filtros,
                                                                              sorty_by => $params_obj->{'orden'},
                                                                              limit => $params_obj->{'cantR'},
                                                                              offset => $params_obj->{'ini'},
                                                                              #FIXME falta circ_tipo_sancion
                                                                              with_objects => ['usr_responsable','usr_nro_socio'],
                                                                           );
   return (scalar(@$sanciones),$sanciones);
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
	my ($id_ui)=@_;
#         my $query=" SELECT categorycode, count( categorycode ) as cant FROM borrowers WHERE branchcode = ? GROUP BY categorycode  ";
   my @filtros;
   use C4::Modelo::UsrSocio::Manager;
   push (@filtros, ( id_ui => { eq => $id_ui },) );
   my $socios = C4::Modelo::UsrSocio::Manager->get_usr_socio(
                                                               query => \@filtros,
                                                               select => ['*','COUNT(cod_categoria) AS agregacion_temp'],
                                                               group_by => ['cod_categoria'],
                                                               require_objects => ['categoria','ui'],
                                                            );
#  	my $clase='par';
# 	my $catcode;
# 	my $i=0;
# 	my %indices;
#         while (my $data=$sth->fetchrow_hashref){
# 	        if ($clase eq 'par') {$clase='impar'} else {$clase='par'};
# 		      $catcode=$data->{'categorycode'};
# 		      $indices{$catcode}=$i;
# 		      $results[$i]->{'reales'}=$data->{'cant'};
# 		      $results[$i]->{'categoria'}=C4::AR::Busquedas::getborrowercategory($data->{'categorycode'});
# 		      $results[$i]->{'clase'}=$clase;
# 		      $i++;
#         }
# 
# 	my $query=" SELECT categorycode, count( categorycode ) as cant FROM persons WHERE branchcode = ? AND borrowernumber IS NULL GROUP BY categorycode  ";
# 	$sth=$dbh->prepare($query);
#         $sth->execute($branch);
# 	while (my $data=$sth->fetchrow_hashref){
# 		$catcode=$data->{'categorycode'};
# 		if (not exists($indices{$catcode})){
# 			if ($clase eq 'par') {$clase='impar'} else {$clase='par'};
# 			$results[$i]->{'reales'}=0;
# 			$results[$i]->{'potenciales'}=$data->{'cant'};
# 			$results[$i]->{'categoria'}=C4::AR::Busquedas::getborrowercategory($data->{'categorycode'});
# 			$results[$i]->{'clase'}=$clase;
# 			$i++;
# 		}
# 		else{
# 			$results[$indices{$catcode}]->{'potenciales'}=$data->{'cant'};
# 		}
# 	}
         return (scalar(@$socios),$socios);
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

1;
