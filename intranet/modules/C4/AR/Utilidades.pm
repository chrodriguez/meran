package C4::AR::Utilidades;

#Este modulo provee funcionalidades varias sobre las tablas de referencias en general
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
@EXPORT=qw(&obtenerTiposDeColaboradores &obtenerReferencia &obtenerTemas &obtenerEditores &noaccents &saveholidays &getholidays &savedatemanip &buscarTabladeReferencia &obtenerValores &actualizarCampos &buscarTablasdeReferencias &listadoTabla &obtenerCampos &valoresTabla &tablasRelacionadas &valoresSimilares &asignar &obtenerDefaults &guardarDefaults &mailDeUsuarios &verificarValor &cambiarLibreDeuda 
&quitarduplicados
);

#Obtiene los mail de todos los usuarios
sub mailDeUsuarios(){
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("SELECT emailaddress FROM  borrowers WHERE emailaddress IS NOT NULL AND emailaddress <> ''");
	$sth->execute();
	my @results;
	while (my $data = $sth->fetchrow_hashref) {
		push(@results, $data); 
	}
	  
	$sth->finish;

	return(@results);
}

sub in_array() {
        my $val = shift @_ || return 0;
        my @array = @_;
        foreach (@array)
                { return 1 if ($val eq $_); }
        return 0;
}

sub array_diff{
# A $array1 le resta $array2
	my ($array1_ref,@array2) = @_;
	my @array_res;
	foreach (@$array1_ref) {
		push(@array_res, $_) unless (&in_array($_,@array2));
	} 
	return(@array_res);
}

sub saveholidays{	
	my ($hol) = @_;
	if ($hol){ # FIXME falla si borro todos los feriados
		my @feriados = split(/,/, $hol);
		savedatemanip(@feriados);
		my ($cant,@feriados_anteriores)= &getholidays();
		my @feriados_nuevos= &array_diff(\@feriados,@feriados_anteriores);
		my @feriados_borrados= &array_diff(\@feriados_anteriores,@feriados);
		foreach (@feriados_nuevos) { updateForHoliday($_,"+"); }
		foreach (@feriados_borrados) { updateForHoliday($_,"-"); }
		my $dbh = C4::Context->dbh;
#Se borran todos los feriados de la tabla
		if (scalar(@feriados_borrados)) {
			my $sth=$dbh->prepare("delete from feriados where fecha in (".join(',',map {"('".$_."')"} @feriados_borrados).")");
			$sth->execute();
			$sth->finish;
		}
#Se dan de alta todos los feriados
		if (scalar(@feriados_nuevos)) {
			my $sth=$dbh->prepare("insert into feriados (fecha) values ".join(',',map {"('".$_."')"} @feriados_nuevos));
			$sth->execute();
			$sth->finish;
		}
	}
}
sub obtenerTiposDeColaboradores{
my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare("select codigo,descripcion from  referenciaColaboradores order by descripcion");
$sth->execute();
my %results;
while (my $data = $sth->fetchrow_hashref) {#push(@results, $data); 
  $results{$data->{'codigo'}}=$data->{'descripcion'};
}
	  # while
	$sth->finish;
	return(%results);#,@results);
}


sub getholidays{
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select * from  feriados");
        $sth->execute();
	my @results;
	while (my $data = $sth->fetchrow) {push(@results, $data); } # while
	$sth->finish;
	return(scalar(@results),@results);
}
#27/03/07 Miguel - Cuando agregaba un autor en Colaboradores
#obtenerReferencia devuelve los autores cuyos apellidos sean like el parametro
sub obtenerReferencia{
	my ($dato)=@_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select UPPER(concat_ws(', ',apellido,nombre)) from autores where apellido LIKE ? order by apellido limit 0,15");
        $sth->execute($dato.'%');
	my @results;
	while (my $data = $sth->fetchrow) {push(@results, $data); } # while
	$sth->finish;
	return(@results);
}

#obtenerTemas devuelve los temas que sean like el parametro
sub obtenerTemas{
	my ($dato)=@_;
	my $dbh = C4::Context->dbh;
# 	my $sth=$dbh->prepare("select catalogueentry from catalogueentry where catalogueentry LIKE ? order by catalogueentry limit 0,15");
	my $sth=$dbh->prepare("select nombre from temas where nombre LIKE ? order by nombre limit 0,15");
        $sth->execute($dato.'%');
	my @results;
	while (my $data = $sth->fetchrow) {push(@results, $data); } # while
	$sth->finish;
	return(@results);
}

#obtenerEditores devuelve los editores que sean like el parametro
sub obtenerEditores{
	my ($dato)=@_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select UPPER(concat_ws(', ',apellido,nombre)) from autores where apellido LIKE ? order by apellido limit 0,15");
        $sth->execute($dato.'%');
	my @results;
	while (my $data = $sth->fetchrow) {push(@results, $data); } # while
	$sth->finish;
	return(@results);
}
sub noaccents {
	my $word = @_[0];
	my @chars = split(//,$word);
	my $newstr = ""; 
	foreach my $ch (@chars) {
		if (ord($ch) == 225 || ord($ch) == 193) {$newstr.= 'a'} 
		elsif (ord($ch) == 233 || ord($ch) == 201) {$newstr.= 'e'}
		elsif (ord($ch) == 237 || ord($ch) == 205) {$newstr.= 'i'}
		elsif (ord($ch) == 243 || ord($ch) == 211) {$newstr.= 'o'}
		elsif (ord($ch) == 250 || ord($ch) == 218) {$newstr.= 'u'}
		else {$newstr.= $ch}
	} 
	return(uc($newstr));
}

sub savedatemanip {
my @feriados= @_;
#Actualizo el archivo de configuracion de DateManip
	open (F,'>/var/www/.DateManip.cnf'); #FIXME hay que sacar /var/www/ y poner algo asi como $ENV{HOME}
	printf F "*Holiday\n\n";
	foreach my $f (@feriados) {
		my @fecha = split('-',$f);
		my $fnue = $fecha[2].'/'.$fecha[1].'/'.$fecha[0];
		printf F $fnue."\t= Feriado\n\n";
	}
	close F;
}

#Se obtienen los campos de una tabla que es el parametro que se recibe
sub obtenerCampos{
my ($tabla)=@_;
my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare("show fields from $tabla");
$sth->execute();#$tabla);
my @results;
while (my @data=$sth->fetchrow_array){
        my $aux;
	$aux->{'campo'} = $data[0];
        push(@results,$aux);
        }
$sth->finish;
return @results;
}

sub listadoTabla{
my($tabla,$ind,$cant,$id,$orden,$search,$bloqueIni,$bloqueFin)=@_;
#$cant=$cant+$ind;
($id||($id=0));
open(A, ">>/tmp/debug.txt");
print A "listado Tabla \n";

$search=$search.'%';

print A "search $search \n";
close(A);
my $dbh = C4::Context->dbh;
# my $sth=$dbh->prepare("select count(*) from $tabla  where $orden like '$search'");
# $sth->execute();
my $sth;
my @cantidad;


if( ($bloqueIni ne "")&&($bloqueFin ne "") ){
	$sth=$dbh->prepare("	SELECT count(*)
				FROM $tabla
				WHERE $orden BETWEEN  '$bloqueIni%' AND '$bloqueFin%' ");

	$sth->execute();
	@cantidad=$sth->fetchrow_array;

	$sth=$dbh->prepare("	SELECT *
				FROM $tabla
				WHERE $orden BETWEEN  '$bloqueIni%' AND '$bloqueFin%' 
				ORDER BY $orden limit $ind,$cant ");
	$sth->execute();
}else{
	$sth=$dbh->prepare("select count(*) from $tabla  where $orden like '$search'");
	$sth->execute();

	@cantidad=$sth->fetchrow_array;
	$sth=$dbh->prepare("select * from $tabla where $orden like '$search' order by $orden limit $ind,$cant");
	$sth->execute();
}

my @results;
while (my @data=$sth->fetchrow_array){
        my @results2;
	my $i;
	
	for ($i=0;$i<@data;$i++) {
		my $aux;
		$aux->{'campo'} = $data[$i];
        	push(@results2,$aux);
	}

	my $aux2;
	$aux2->{'registro'}=\@results2;
	$aux2->{'id'}=$data[$id];
	push(@results,$aux2);
}
        
$sth->finish;
return ($cantidad[0],@results);
}


#devuelve los valores de un elemento en particular de la tabla de referencia que se esta editando
#recibe la tabla, el nombre del campo que es identificador y el valor que debe buscar 
#estos tres parametros se obtienen anteriorimente de la tabla tablasDeReferencias
sub valoresTabla{
my ($tabla,$indice,$valor)=@_;

my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare("show fields from $tabla");
$sth->execute();
my @results;
while (my @data=$sth->fetchrow_array){
        my $aux;
	$aux->{'campo'} = $data[0];
        push(@results,$aux);
        }

$sth=$dbh->prepare("select * from $tabla where $indice=?");
$sth->execute($valor);
my @results2;
while (my $data=$sth->fetchrow_hashref){
        my $i;
	foreach $i (@results){
		my $aux;
		$aux->{'campo'} = $i->{'campo'};
		$aux->{'valor'}=$data->{$i->{'campo'}};
        	push(@results2,$aux);
	}
	}
        
$sth->finish;
return @results2;
}

#devuelve todos los registros relacionados con un elemento de referencia, dependiendo de los valores en tablasDeReferencias, por ej: para el autor id 10 devolvera que tiene asignados 35 biblios

sub tablasRelacionadas{
my ($tabla,$indice,$valor)=@_;

my $dbh = C4::Context->dbh;
#Se verfica si tiene referencias
#Tabla referencias
#referencia nomcamporeferencia camporeferencia referente             camporeferente
#autores 	id 		0 		biblio 			author
#autores 	id 		0 		colaboradores 		idColaborador
#autores 	id 		0 		additionalauthors 	author
#autores 	id 		0 		analyticalauthors 	author
my $sth=$dbh->prepare("select * from tablasDeReferencias where referencia= ?");
$sth->execute($tabla);
my @results;
while (my $data=$sth->fetchrow_hashref){
        my $aux;
	my $sth2=$dbh->prepare("select $data->{'nomcamporeferencia'} from $data->{'referencia'} where
	$indice = ?");
	$sth2->execute($valor);
	my $identificador=$sth2->fetchrow_array;
	$sth2=$dbh->prepare("select count(*) from $data->{'referente'} where $data->{'camporeferente'}= ?");
	$sth2->execute($identificador);
	$aux->{'relacionadoTabla'} = $data->{'referente'};
        if (my $canti= $sth2->fetchrow_array){
	$aux->{'relacionadoTablaCantidad'}=$canti;
	push(@results,$aux);}
        }

return @results;
}



#devuelve los valores similares de un elemento en particular de la tabla de referencia que se esta editando basandose en la tablaDeReferenciaInfo 
#recibe la tabla, el nombre del campo que es identificador y el valor que debe buscar 
#estos tres parametros se obtienen anteriorimente de la tabla tablasDeReferencias
sub valoresSimilares{

my($tabla,$camporeferencia,$id)=@_;
($id||($id=0));
my $dbh = C4::Context->dbh;
#Obtengo que campo voy a utilizar para buscar similares, es en tablasDeReferenciasInfo
my $sth=$dbh->prepare("Select similares from tablasDeReferenciasInfo where referencia=? ");
$sth->execute($tabla);
my $similar=$sth->fetchrow_array;
#Busco el valor del campo similar que corresponde al registro para el cual estoy buscando similares 
$sth=$dbh->prepare("select $similar from $tabla where $camporeferencia = ? limit 0,1");
$sth->execute($id);
my $valorAbuscarSimil=$sth->fetchrow_array;
my $tamano=(length($valorAbuscarSimil))-1;
#Busco los valores similares, con una expresion regular que busca aquellas tuplas que coincidan en campo similar en todos los caracteres-1 del original
$sth=$dbh->prepare("select * from $tabla where $similar REGEXP '[$valorAbuscarSimil]{$tamano,}' and $camporeferencia  != ? order by $similar limit 0,15");
$sth->execute($id);
my $sth3=$dbh->prepare("Select camporeferencia from tablasDeReferencias where referencia=? limit 0,1");
$sth3->execute($tabla);
my $idnum=$sth3->fetchrow_array;


my @results;
while (my @data=$sth->fetchrow_array){
        my @results2;
	my $i;
	for ($i=0;$i<@data;$i++) {
		my $aux;
		$aux->{'campo'} = $data[$i];
        	push(@results2,$aux);
	}
	my $aux2;
	$aux2->{'registro'}=\@results2;
	$aux2->{'id'}=$data[$idnum];
	push(@results,$aux2);
	}
        
$sth->finish;
return (@results);
}

#Busca todas las tablas relacionadas con $tabla y actualiza la referencia a el nuevo valor que esta en valorNuevo. Ej: actualiza todos los libros para que hayan sido escritos por autor id=58 y le pone que fueron esvcritos por autor id=60 
sub asignar {
my ($tabla,$indice,$identificador,$valorNuevo,$borrar)=@_;
#ACa hay q hacer q sea una transaccion
my $dbh = C4::Context->dbh;
my $asignar;
my $sthT=$dbh->prepare("START TRANSACTION");
$sthT->execute();
my $sth=$dbh->prepare("select * from tablasDeReferencias where referencia= ?");
$sth->execute($tabla);
my @results;
my $asignar=0;
while (my $data=$sth->fetchrow_hashref){
	$asignar=1;
        my $aux;
	my $sth2=$dbh->prepare("select $data->{'nomcamporeferencia'} from $data->{'referencia'} where $indice = ?");
	$sth2->execute($identificador);
	my $identificador2=$sth2->fetchrow_array;
	$sth2=$dbh->prepare("update $data->{'referente'} set $data->{'camporeferente'}= ? where $data->{'camporeferente'}= ?");
	$sth2->execute($valorNuevo,$identificador2);
	}
if ($borrar){
	my $sth3=$dbh->prepare("delete from $tabla where $indice= ?");
	$sth3->execute($identificador);
	$borrar=1;
	}
$sthT=$dbh->prepare("COMMIT");
$sthT->execute();

return ($asignar,$borrar);	
        }







sub obtenerValores{
my ($tabla,$indice,$valor)=@_;
my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare("show fields from ?");
$sth->execute($tabla);
my @data=$sth->fetchrow_array;
$sth=$dbh->prepare("select * from ? where ?=?");
$sth->execute($tabla,$indice,$valor);
my $data2=$sth->fetchrow_hashref;
$sth->finish;
my %row;
foreach my $campo (@data) {
my %row = ($campo => $data2->{$campo});
          }
return \%row;
}
#Esta funcion recibe tres parametros, el nombre de la tabla que se esta editando, el campo identificador de la tabla y un hash de los campos y valores que se van a actualizar en esa tabla   
sub actualizarCampos{
my ($tabla,$id,%valores)=@_;
my $dbh = C4::Context->dbh;
my $sql='';
foreach my $key (keys(%valores)){
$sql.=', '.$key.'="'.$valores{$key}.'"';
}
$sql=substr($sql,2);
my $sth=$dbh->prepare("update $tabla set $sql where $id=?");
$sth->execute($valores{$id});
$sth->finish;
}
#Esta funcion retorna todas las tablas de referencia las sistema de acuerdo a las tablas que esten en la tabla tablasDeReferencias de la base de datos, no recibe parametros

sub buscarTablasdeReferencias{
my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare("select distinct(referencia) from tablasDeReferencias order by referencia");
$sth->execute();
my %results;
while (my $data = $sth->fetchrow_hashref) {#push(@results, $data); 
  $results{$data->{'referencia'}}=$data->{'referencia'};
}
$sth->finish;
return(%results);#,@results);
}

#Esta funcion devuelve la tabla de referencia que se esta buscando para modificar
sub buscarTabladeReferencia{
my ($ref)=@_;
my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare("Select * from tablasDeReferencias where referencia=? limit 0,1");
$sth->execute($ref);
my $results=$sth->fetchrow_hashref;
#se obtiene el orden de la tabla con la que se esta trabajando
$sth=$dbh->prepare("Select orden from tablasDeReferenciasInfo where referencia=? limit 0,1");
$sth->execute($ref);
$results->{'orden'}=$sth->fetchrow_array;
$sth->finish;
return($results);#,@results);
}

#obtenerTemas devuelve los temas que sean like el parametro
sub obtenerDefaults{

my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare("select * from defaultbiblioitem");
$sth->execute();
my @results;
while (my $data = $sth->fetchrow_hashref) {push(@results, $data); } # while
$sth->finish;
return(@results);
}

sub guardarDefaults 
{ my ($biblioitem)=@_;

my $dbh = C4::Context->dbh;

my $sth=$dbh->prepare("update defaultbiblioitem set valor = ? where campo=?");
$sth->execute($biblioitem->{'volume'},'volume');
$sth->execute($biblioitem->{'number'},'number');
$sth->execute($biblioitem->{'classification'},'selectlevel');
$sth->execute($biblioitem->{'itemtype'},'selectitem');
$sth->execute($biblioitem->{'isbncode'},'isbn');
$sth->execute($biblioitem->{'issn'},'issn');
$sth->execute($biblioitem->{'lccn'},'lccn');
$sth->execute($biblioitem->{'publishercode'},'publishercode');
$sth->execute($biblioitem->{'publicationyear'},'publicationyear');
$sth->execute($biblioitem->{'dewey'},'dewey');
$sth->execute($biblioitem->{'url'},'url');
$sth->execute($biblioitem->{'volumeddesc'},'volumeddesc');
$sth->execute($biblioitem->{'illus'},'illus');
$sth->execute($biblioitem->{'pages'},'pages');
$sth->execute($biblioitem->{'bnotes'},'notes');
$sth->execute($biblioitem->{'size'},'size');
$sth->execute($biblioitem->{'place'},'place');
$sth->execute($biblioitem->{'language'},'selectlang');
$sth->execute($biblioitem->{'support'},'selectsuport');
$sth->execute($biblioitem->{'country'},'selectcountry');
$sth->execute($biblioitem->{'serie'},'serie');

}


=item
verificarValor
Verifica que el valor que ingresado no tenga sentencias peligrosas, se filtran.
=cut

sub verificarValor(){
	my ($valor)=@_;
	my @array=split(/;/,$valor);
	if(scalar(@array) > 1){
		#por si viene un ; saco las palabras peligrosas, que son las de sql.
		$valor=~ s/\b(SELECT|WHERE|INSERT|SHUTDOWN|DROP|DELETE|UPDATE|FROM|AND|OR|BETWEEN)\b/ /gi;
	}
	
	#$valor=~ s/'/\\'/g; 
	#$valor=~ s/-/\\-/g;
	$valor=~ s/%|"|=|\*|-(<,>)//g;	
	$valor=~ s/%3b|%3d|%27|%25//g;#Por aca no entra llegan los caracteres ya traducidos
	$valor=~ s/\<SCRIPT>|\<\/SCRIPT>//gi;
	return $valor;
}

=item
cambiarLibreDeuda
guarda el nuevo valor de la variable libreDeuda de la tabla de las preferencias
NOTA: cambiar de PM a uno donde esten todo lo referido a las preferencias de sistema, esta funcion se utiliza en los archivos adminLibreDeuda.pl y libreDeuda.pl
=cut
sub cambiarLibreDeuda(){
	my ($valor)=@_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("update systempreferences set value=? where variable='libreDeuda'");
	$sth->execute($valor);
}


=item
quitarduplicados
simplemente devuelve el arreglo que recibe sin elementos duplicados
=cut
sub quitarduplicados (){
my  (@arreglo)=@_;
my @arreglosin=();
for(my $i=0;$i<scalar(@arreglo);$i++){
	my $ok=1;
	for(my $j=0;$j<scalar(@arreglosin);$j++){
	if ($arreglo[$i] == $arreglosin[$j] ){$ok=0;}
	}
	if ($ok eq 1) {push(@arreglosin, $arreglo[$i] );}
}
return (@arreglosin);
}

1;
