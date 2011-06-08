package C4::AR::Generic_Report;

#Este modulo provee funcionalidades para Reportes Genericos
#Escrito el 26/9/2007 por matiasp@info.unlp.edu.ar
#
#Copyright (C) 2003-2007  Linti, Facultad de Inform�tica, UNLP
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
use ooolib;

#use C4::Date;
use vars qw(@EXPORT_OK @ISA);
@ISA=qw(Exporter);
@EXPORT_OK=qw(&getReportTables &insertReportTable &getAllTables &getFields 
	   &deleteReportTable &getReportJoinTables &insertReportJoinTable &getFieldsArray
	   &getSearchFields &getSearchJoins 
	   &reportSearch &generar_planilla);



#Busco las tablas que se encuentran ya agregadas en generic_report_tables
sub getReportTables {
	my $dbh = C4::Context->dbh;
	my $sth1=$dbh->prepare("Select * from generic_report_tables ;");
   	$sth1->execute;
	my @results;

	while (my $field = $sth1->fetchrow_hashref) {
	  push(@results, $field);
	}
	$sth1->finish;
	return(@results);
}

#Inserto un campo nuevo para utilizar en los reportes
sub insertReportTable {
	my ($table,$field,$name)=@_;
	my $result='';
	my $dbh = C4::Context->dbh;
	my $sth1=$dbh->prepare("Select * from generic_report_tables where tabla = ? and campo = ? ;");
   	$sth1->execute($table,$field);
	if ($sth1->fetchrow_hashref){#ya existe 
		$result='Ya existe ese campo!!!';
		}
	else{
	if (($table ne '')&&($field ne '')){
	#Agrego la tabla y el campo
	my $sth2=$dbh->prepare("Insert into generic_report_tables values (?,?,?) ;");
   	$sth2->execute($table,$field,$name);
	}
	}

	
	$sth1->finish;
	return $result;
}



#Busco TODAS tablas
sub getAllTables {
	my $dbh = C4::Context->dbh;
	my $sth1=$dbh->prepare("Show tables;");
   	$sth1->execute;
	my @results;
	while (my $field = $sth1->fetchrow) {
	  push(@results, $field);
	}

	$sth1->finish;
	return(@results);
}

#Busco los campos de una tabla
sub getFields {
	my ($table)=@_;
	my $dbh = C4::Context->dbh;
	my $sth1=$dbh->prepare("Show fields from $table ;");
   	$sth1->execute();
	my @results;
	while (my $field = $sth1->fetchrow_hashref) {
	  push(@results, $field->{'Field'});
	}
	$sth1->finish;
	return(@results);
}


#Elimino un campo  de los reportes
sub deleteReportTable {
	my ($table,$field)=@_;
	
	if (($table ne '')&&($field ne '')){
		my $dbh = C4::Context->dbh;
		my $sth1=$dbh->prepare("Delete from generic_report_tables where tabla = ? and campo = ? ;");
   		$sth1->execute($table,$field);
		$sth1->finish;
	}
	return(0);
}


#Busco los joins que se encuentran ya agregadas en generic_report_joins
sub getReportJoinTables {
	my $dbh = C4::Context->dbh;
	my $sth1=$dbh->prepare("Select * from generic_report_joins ;");
   	$sth1->execute;
	my @results;

	while (my $field = $sth1->fetchrow_hashref) {
	  push(@results, $field);
	}
	$sth1->finish;
	return(@results);
}

#Inserto un campo nuevo para utilizar en los reportes
sub insertReportJoinTable {
	my ($table1,$field1,$table2,$field2,$unionjoin)=@_;
	my $result='';
	my $dbh = C4::Context->dbh;
	my $sth1=$dbh->prepare("Select * from generic_report_joins where 
				((table1 = ? and table2 = ?) or (table1 = ? and table2 = ?))  ;");

   	$sth1->execute($table1,$table2,$table2,$table1);
	if ($sth1->fetchrow_hashref){#ya existe 
		$result='Ya existe ese campo!!!';
		}
	else{
	if (($table1 ne '')&&($field1 ne '')&&($table2 ne '')&&($field2 ne '')){
	#Agrego la tabla y el campo
	my $sth2=$dbh->prepare("Insert into generic_report_joins values (?,?,?,?,?) ;");
   	$sth2->execute($table1,$field1,$table2,$field2,$unionjoin);
	}
	}

	
	$sth1->finish;
	return $result;
}



#Elimino un join
sub deleteReportJoinTable {
	my ($table1,$field1,$table2,$field2)=@_;
	
	if (($table1 ne '')&&($field1 ne '')&&($table2 ne '')&&($field2 ne '')){
		my $dbh = C4::Context->dbh;
		my $sth1=$dbh->prepare("Delete from generic_report_joins where 
					table1 = ? and field1 = ? and table2 = ? and field2 = ?  ;");
   		$sth1->execute($table1,$field1,$table2,$field2);
		$sth1->finish;
	}
	return(0);
}

#Busco las campos por los cuales se puede buscar
sub getFieldsArray {
	my @results;
	my @tables=getReportTables();
	
	foreach my $row (@tables) {
	  my $aux;
	  $aux->{'value'}=$row->{'tabla'}.".".$row->{'campo'};
	  $aux->{'label'}=$row->{'nombre'};
	  push(@results, $aux);
	}
	return(\@results);
}

sub reportSearch {
        my ( $fieldlist, $value, $operator,  $excluding, $and_or, $startfrom , $nro_socio) = @_;

	  my $results;
	  my @tables = ();# Tablas involucrados
	  my $where='';# Armo el where de la consulta
	  my $dbh = C4::Context->dbh;
	  my $count;
	  my $filename=''; #Para la planilla

	  for(my $i = 0 ; $i <= $#{$value} ; $i++) # Se procesan los que poseen algun valor ingresado
	    { 
	    if(@$value[$i] ne ''){ #Debe tener algun valor ingresado
	    
	    if (@$value[$i] ne '*'){ #El * solo realiza el JOIN de esa tabla sin filtrar

	    my $real_operator= @$operator[$i];
	    my $real_value= @$value[$i];
	    
	    #Reemplazo contains  y start
	    if(@$operator[$i] eq "contains") { $real_operator= "like";
	    				       $real_value= "'%".$real_value."%'";}
	
	    elsif(@$operator[$i] eq "start") { $real_operator= "like";
	    				    $real_value= "'".$real_value."%'";}

	   elsif (@$operator[$i] eq "=") {$real_value= "'".$real_value."'";}

	
	
	    #Armo la sentencia
	    my $sentencia = " ( ".@$fieldlist[$i]." ".$real_operator." ".$real_value." ) ";

	    #Se niega si es necesario
	    if (@$excluding[$i]){ $sentencia= " not ".$sentencia;} 
	    
	    #Se agrega al where
	    if ((@$and_or[$i])&&($where ne ''))
	     #Si el where esta vacio no se puede agregar ningun operador logico
	     { $where .= " ".@$and_or[$i]." ".$sentencia;}
		else { $where .= " ".$sentencia; }	
	   
	   }#fin if *
	    #Agrego el tabla a la lista de campos involucrados para poder hacer los joins correspondientes
	    my $find=0;
	    my $table=substr(@$fieldlist[$i],0,index(@$fieldlist[$i],'.'));
	    foreach my $field (@tables){if($field eq $table){$find=1;}}
	    if($find eq 0){push (@tables,$table);}	     
	   
	   }
	   }
	    
	    #Se obtienen los campos
	    my ($campos,$nombres)=getSearchFields(\@tables);
	    #Se obtienen los joins
	    my ($joins,$no_joins)=getSearchJoins(\@tables); 
	    
	  if (!@$no_joins[0]){#Hay algun join que no se pudo realizar?
	   #ARMO LA CONSULTA
	   my $SQL="SELECT DISTINCT ".$campos." FROM ".$joins;
	   if ($where ne ''){ $SQL.=" WHERE ".$where." ";}
	   
	   #CUENTO EL TOTAL
	    my $sthcount=$dbh->prepare($SQL);
	       $sthcount->execute;
	    my $rescount=$sthcount->fetchall_arrayref;
	       
	       #Generar la planilla# 
	       
	       $filename=generar_planilla($rescount,$nombres,$nro_socio);

	       #
	      
	      $sthcount->finish;
	    $count=$#{$rescount};
	   #
	   
	   #PAGINADO
	   #
	   ($startfrom) || ($startfrom=0);#Si no tiene valor es 0 por defecto
	   my $num=C4::AR::Preferencias::getValorPreferencia("renglones");
	   $SQL.=" LIMIT ".$startfrom." , ".$num." ;"; #Se arma el limit
	   #
	   ##
	   
	   my $sth=$dbh->prepare($SQL);
	   $sth->execute;
	   $results=$sth->fetchall_arrayref;
	   $sth->finish;
	   }
	   
	   return ($results,$nombres,$count,$filename);
	   }


sub getSearchFields {
        my ($tables) = @_;
	my $campos='';
	my $nombres='';
	my $dbh = C4::Context->dbh;
	my $sql='';
   	for(my $i = 0 ; $i <= $#{$tables} ; $i++){
	if ($sql eq ''){$sql="Select * from generic_report_tables where  tabla = '".@$tables[$i]."'";}
		  else {$sql.=" or tabla = '".@$tables[$i]."'";}
	}

	my $sth1=$dbh->prepare($sql);
	$sth1->execute;
	
	while (my $field = $sth1->fetchrow_hashref) {
	$campos.=$field->{'tabla'}.".".$field->{'campo'}.",";
	
	if($field->{'nombre'}){$nombres.=$field->{'nombre'}.",";}
	else {$nombres.=$field->{'tabla'}.".".$field->{'campo'}.",";}	
	
	}
	$sth1->finish;
	chop($campos);
	chop($nombres);
	return($campos,$nombres);
	}	
	

sub getSearchJoins { #arma los joins de la busqueda
        my ( $tables) = @_;
	my $usedtables;
	my $joins='';
	#Marco las tablas como no utilizadas
	for(my $i = 0 ; $i <= $#{$tables} ; $i++){push(@$usedtables,0);}
 	#

	if ($#{$tables} eq 0){$joins=@$tables[0];
			      @$usedtables[0]=1;}
	   elsif ($#{$tables} gt 0)
	   {
	   for(my $i = 0 ; $i <= $#{$tables} ; $i++)
	   {
	   if (@$usedtables[$i] eq 0){ #Si no fue procesada esa tabla

	   	my($join,$index)=searchjoin(@$tables[$i],$tables);
	    	if($join ne 0){#Si es 0 no se pudo realizar el join
	        
		if ($joins eq ''){ #es el primer join
		$joins.=" ( ".$join->{'table1'}." ".$join->{'unionjoin'}." JOIN ".$join->{'table2'}."  ON"; 
		$joins.=" ".$join->{'table1'}.".".$join->{'field1'}." = ".$join->{'table2'}.".".$join->{'field2'}." ) "; 
		
		#Marco las tablas como visitadas
		@$usedtables[$i]=1;
		@$usedtables[$index]=1;
		#
		}
		else 
		{#NO es el primer join

		 #REVISAR TABLAS VISITADAS#
		if (  @$usedtables[$index] eq 1 ) {
		 #Se hace un join de la tabla $i
		my $tabla='';
		#Contra que tabla se hace el join
		if (@$tables[$i] eq $join->{'table1'})
		     {$tabla=$join->{'table1'};} 
		else { $tabla=$join->{'table2'};}

	 	$joins = " ( ".$joins;	
		$joins.=" ".$join->{'unionjoin'}." JOIN ".$tabla."  ON"; 
		$joins.=" ".$join->{'table1'}.".".$join->{'field1'}." = ".$join->{'table2'}.".".$join->{'field2'}." "; 
		$joins.=" ) ";

		#Marco las tabla como visitadas
		@$usedtables[$i]=1;
		 } else {
		 #Ninguna tabla forma parte del join 
		 #Se deja pasar para resolver mas adelante 
			
			
		}

		}#else	
	        }#Si no hay join
	    	} #if procesada
	    } #for
	  }#elsif
	
	#Quedaron tablas sin unir?
	 my @no_join=();
	 for(my $i = 0 ; $i <= $#{$tables} ; $i++)
	  { if (@$usedtables[$i] eq 0) { push(@no_join,@$tables[$i]);}}
	#
	
	return ($joins, \@no_join);
	}


sub searchjoin {
	my ( $table ,$tables) = @_;
	my $dbh = C4::Context->dbh;
	my $find=0;
	my $result=0;
	my $i=0;
	while (($i <= $#{$tables})&&($find eq 0))
	{
	if ((@$tables[$i] ne '')&&($table ne @$tables[$i])){
	
 	 my $sth1=$dbh->prepare("Select * from generic_report_joins where 
	 			((table1 = ? and table2 = ?) or (table1 = ? and table2 = ?))  ;");
	 
	 $sth1->execute($table,@$tables[$i],@$tables[$i],$table);
	 if ($result=$sth1->fetchrow_hashref){#ya existe 
	    $find=1;}
	  }
	 if($find eq 0) {$i++;}
	 }

  	return ($result,$i);
	}


sub generar_planilla {
	my ($results,$nombres,$nro_socio) = @_;
#Genero la hoja de calculo Openoffice
## - start sxc document
my $sheet=new ooolib("sxc");
$sheet->oooSet("builddir","./plantillas");
#
## - Set Meta.xml data
$sheet->oooSet("title","Resultado de b�squeda gen�rica");
$sheet->oooSet("author","KOHA");
# - Set name of first sheet
$sheet->oooSet("subject","Reporte");
# - Set some data
# columns can be in numbers or letters

my $pos=1;
my $count=1;
$sheet->oooSet("bold", "on");
#Titulos
my @campos=split(/,/,$nombres);

$sheet->oooSet("bold", "on");

foreach my $field (@campos){
$sheet->oooSet("cell-loc", $count, $pos);
$sheet->oooData("cell-text", $field);
#$sheet->set_colwidth ($count, 1000);

$count++;
}
$sheet->oooSet("bold", "off");

$pos++;
##

#Datos
for(my $i = 0 ; $i <= $#{$results} ; $i++)
{
my $j=0;
foreach my $field (@campos){

$sheet->oooSet("cell-loc", $j+1, $pos);
$sheet->oooData("cell-text", @$results->[$i][$j]);
$j++;
}
$pos++;
}
##
my $name="reporte-generico-".$nro_socio;
	 $sheet->oooGenerate($name);
	return($name);
	}



END { }       # module clean-up code here (global destructor)

1;
__END__
