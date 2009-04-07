package C4::AR::Utilidades;

#Este modulo provee funcionalidades varias sobre las tablas de referencias en general
#Escrito el 8/9/2006 por einar@info.unlp.edu.ar
#
#Copyright (C) 2003-2006  Linti, Facultad de Informática, UNLP
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
use C4::AR::Estadisticas;
use C4::AR::Referencias;
use CGI;
use Encode;
use JSON;
use POSIX qw(ceil floor); #para redondear cuando divido un numero

#use C4::Date;
use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(
    &aplicarParches 
    &obtenerParches 
    &obtenerTiposDeColaboradores 
    &obtenerReferencia 
    &obtenerTemas 
    &obtenerEditores 
    &noaccents 
    &saveholidays 
    &getholidays 
    &savedatemanip 
    &obtenerValores 
    &actualizarCampos 
    &buscarTablasdeReferencias 
    &listadoTabla 
    &obtenerCampos 
    &valoresTabla 
    &tablasRelacionadas 
    &valoresSimilares 
    &asignar 
    &obtenerDefaults 
    &guardarDefaults 
    &mailDeUsuarios 
    &obtenerAutores 
    &obtenerPaises 
    &crearComponentes 
    &obtenerTemas2 
    &obtenerBiblios 
    &verificarValor 
    &cantidadRenglones 
    &armarPaginas 
    &crearPaginador 
    &InitPaginador
    &from_json_ISO 
    &UTF8toISO 
    &obtenerIdentTablaRef 
    &obtenerValoresTablaRef 
    &obtenerValoresAutorizados 
    &obtenerDatosValorAutorizado
    &cambiarLibreDeuda 
    &checkdigit 
    &checkvalidisbn 
    &quitarduplicados
    &buscarCiudades
    &trim
    &validateString
    &joinArrayOfString
    &buscarLenguajes
    &buscarSoportes
    &buscarNivelesBibliograficos
    &generarComboTipoPrestamo
    &generarComboDeSocios
    &generarComboTipoDeOperacion
    

);

=item
crearComponentes
Crea los componentes que van a ir al tmpl.
$tipoInput es el tipo de componente que se va a crear en el tmpl.
$id el id del componente para poder recuperarlo.
$values los valores o que puede devolver el componente (combo, radiobotton y checkbox)
$labels lo que va a mostrar el componente (combo, radiobotton y checkbox).
$valor es el valor por defecto que tiene el componente, si es que tiene.
=cut
sub crearComponentes(){
    my ($tipoInput,$id,$values,$labels,$valor)=@_;
    my $inputCampos;
    if ($tipoInput eq 'combo'){
        $inputCampos=CGI::scrolling_list(  
            -name      => $id,
            -id    => $id,
            -values    => $values,
            -labels    => $labels,
            -default   => $valor,
            -size      => 1,
                );
    }
    elsif($tipoInput eq 'radio'){
        $inputCampos=CGI::radio_group(
            -name      =>$id,
            -id    =>$id,
            -values    => $values,
            -labels    => $labels,
            -default   => $valor,
        );
    }
    elsif($tipoInput eq 'check'){
        $inputCampos=CGI::checkbox_group(
            -name   =>$id,
            -id =>$id,
            -values    => $values,
            -labels    => $labels,
            -default   => $valor,
        );
    }
    elsif($tipoInput eq 'text'){
        $inputCampos=CGI::textfield(
            -name   =>$id,
            -id =>$id,
            -value  =>$valor,
            -size   =>$values,
                );
    }
    elsif($tipoInput eq 'texta'){
        $inputCampos=CGI::textarea(
            -name    =>$id,
            -id  =>$id,
            -value   =>$valor,
            -rows    =>$labels,
            -cols    =>$values,
                );
    }
    else{
        $inputCampos= CGI::hidden(-id=>$id,);
    }
    return($inputCampos);
}


#Obtiene los mail de todos los usuarios
sub mailDeUsuarios(){
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare(" SELECT emailaddress 
                FROM  borrowers 
                WHERE (emailaddress IS NOT NULL) AND (emailaddress <> '')");
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
            my $sth=$dbh->prepare(" DELETE FROM pref_feriado 
                        WHERE fecha IN (".join(',',map {"('".$_."')"} @feriados_borrados).")");
            $sth->execute();
            $sth->finish;
        }
#Se dan de alta todos los feriados
        if (scalar(@feriados_nuevos)) {
            my $sth=$dbh->prepare(" INSERT INTO pref_feriado (fecha) 
                        VALUES ".join(',',map {"('".$_."')"} @feriados_nuevos));
            $sth->execute();
            $sth->finish;
        }
    }
}

sub obtenerTiposDeColaboradores{
my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare(" SELECT codigo,descripcion 
            FROM cat_ref_colaborador 
            ORDER BY (descripcion)");
$sth->execute();
my %results;
while (my $data = $sth->fetchrow_hashref) {#push(@results, $data); 
  $results{$data->{'codigo'}}=$data->{'descripcion'};
}
      # while
    $sth->finish;
    return(%results);#,@results);
}

=item obtenerParches
la funcion obtenerParches devuelve toda la informacion sobre los parches de actualizacion que hay que aplpicar, con esto se logra cambiar de la version 2 a las versiones futuras sin problemas, via web
=cut
sub obtenerParches{
my ($version)=@_;
my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare(" SELECT * 
            FROM parches 
            WHERE (corresponde > ?) 
            ORDER BY (id)");
$sth->execute($version);
my @results;
while (my $data = $sth->fetchrow_hashref) {#push(@results, $data); 
  push(@results,$data);
}
# while
$sth->finish;
return(@results);
}

=item aplicarParches
la funcion aplicarParches aplica el parche que le llega por parametro.
Para hacer esto lo que hace es leer la base de datos y aplicar las instrucciones mysql que corresponden con ese parche 
=cut
sub aplicarParches{
my ($parche)=@_;
my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare(" SELECT * 
            FROM parches_scripts 
            WHERE (parche= ?) 
            ORDER BY (id)");
$sth->execute($parche);
my $sth2;
my $error='';
while (my $data = $sth->fetchrow_hashref) {#push(@results, $data); 
$sth2=$dbh->prepare($data->{'sql'});
$sth2->execute();  
if ($sth2 -> errstr){ $error=$sth2 -> errstr;
}
# while
$sth->finish;
if (not $error){
my $sth3=$dbh->prepare("UPDATE parches 
            SET aplicado='1' 
            WHERE id=?");
$sth3->execute($parche);
}
    }

$sth2->finish;

return($error);
}



sub getholidays{
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare(" SELECT * 
                FROM pref_feriado");
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
    my $sth=$dbh->prepare(" SELECT UPPER(concat_ws(', ',apellido,nombre)) 
                FROM cat_autor 
                WHERE apellido LIKE ? 
                ORDER BY apellido 
                LIMIT 0,15");
        $sth->execute($dato.'%');
    my @results;
    while (my $data = $sth->fetchrow) {push(@results, $data); } # while
    $sth->finish;
    return(@results);
}

#obtenerReferencia devuelve los autores cuyos apellidos sean like el parametro
sub obtenerAutores{
    my ($dato)=@_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare(" SELECT completo, id 
                FROM cat_autor 
                WHERE apellido LIKE ? 
                ORDER BY (apellido)");
        $sth->execute($dato.'%');
    my @results;
    while (my $data = $sth->fetchrow_hashref) {
        push(@results, $data); 
    } # while
    $sth->finish;
    return(@results);
}

sub obtenerPaises{
    my ($dato)=@_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare(" SELECT nombre_largo, iso 
                FROM ref_pais 
                WHERE nombre_largo LIKE ? 
                ORDER BY (nombre_largo)");
        $sth->execute($dato.'%');
    my @results;
    while (my $data = $sth->fetchrow_hashref) {
        push(@results, $data);
    } # while
    $sth->finish;
    return(@results);
}

#obtenerTemas devuelve los temas que sean like el parametro
sub obtenerTemas{
    my ($dato)=@_;
    my $dbh = C4::Context->dbh;
#   my $sth=$dbh->prepare("select catalogueentry from catalogueentry where catalogueentry LIKE ? order by catalogueentry limit 0,15");
    my $sth=$dbh->prepare(" SELECT nombre 
                FROM cat_tema 
                WHERE nombre LIKE ? 
                ORDER BY nombre 
                LIMIT 0,15");
        $sth->execute($dato.'%');
    my @results;
    while (my $data = $sth->fetchrow) {push(@results, $data); } # while
    $sth->finish;
    return(@results);
}

sub obtenerTemas2(){
    my ($dato)=@_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare(" SELECT nombre, id 
                FROM cat_tema 
                WHERE nombre LIKE ? 
                ORDER BY nombre");
        $sth->execute($dato.'%');
    my @results;
    while (my $data = $sth->fetchrow_hashref) {
        push(@results, $data);
    } # while
    $sth->finish;
    return(@results);
}

#obtenerEditores devuelve los editores que sean like el parametro
sub obtenerEditores{
    my ($dato)=@_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare(" SELECT UPPER(concat_ws(', ',apellido,nombre)) 
                FROM cat_autor 
                WHERE apellido LIKE ? 
                ORDER BY (apellido) 
                LIMIT 0,15");
        $sth->execute($dato.'%');
    my @results;
    while (my $data = $sth->fetchrow) {push(@results, $data); } # while
    $sth->finish;
    return(@results);
}

sub obtenerBiblios{
    my ($dato)=@_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare(" SELECT branchname, branchcode AS id 
                FROM pref_unidad_informacion 
                WHERE branchname LIKE ? 
                ORDER BY branchname");
        $sth->execute($dato.'%');
    my @results;
    while (my $data = $sth->fetchrow_hashref) {
        push(@results, $data);
    } # while
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
    $sth=$dbh->prepare("    SELECT count(*)
                FROM $tabla
                WHERE $orden BETWEEN  '$bloqueIni%' AND '$bloqueFin%' ");

    $sth->execute();
    @cantidad=$sth->fetchrow_array;

    $sth=$dbh->prepare("    SELECT *
                FROM $tabla
                WHERE $orden BETWEEN  '$bloqueIni%' AND '$bloqueFin%' 
                ORDER BY $orden limit $ind,$cant ");
    $sth->execute();
}else{
    $sth=$dbh->prepare("  SELECT COUNT(*) 
                FROM $tabla  
                WHERE $orden LIKE '$search'");
    $sth->execute();

    @cantidad=$sth->fetchrow_array;
    $sth=$dbh->prepare("    SELECT * 
                FROM $tabla 
                WHERE $orden LIKE '$search' 
                ORDER BY $orden LIMIT $ind,$cant");
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
my $sth=$dbh->prepare("SHOW FIELDS FROM $tabla");
$sth->execute();
my @results;
while (my @data=$sth->fetchrow_array){
        my $aux;
    $aux->{'campo'} = $data[0];
        push(@results,$aux);
        }

$sth=$dbh->prepare("    SELECT * 
            FROM $tabla 
            WHERE $indice=?");
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

=item
obtenerValoresTablaRef
Obtiene las tuplas con los campos requeridos de la tabla a la cual se esta haciendo referencia. Devuelve un string json y una hash.
=cut
sub obtenerValoresTablaRef{
    my ($tabla,$ident,$campos,$orden)=@_;

    my $dbh = C4::Context->dbh;
    my $query=" SELECT ".$ident." as id,".$campos." 
            FROM ".$tabla. " 
            ORDER BY ".$orden;
    my $sth=$dbh->prepare($query);
    $sth->execute();
    my $strjson="";
    my $labels;
    my @campos=split(/,/,$campos);
    my $long=scalar(@campos);
    my $data;
    my %result;

    while($data=$sth->fetchrow_hashref()){
        $result{$data->{'id'}}=$data->{$campos[0]};
        $strjson.=",{'clave':'".$data->{'id'}."','valor':";
        $labels="'".$data->{$campos[0]};
        for(my $i=1;$i<$long;$i++){
            $labels.="|".$data->{$campos[$i]};
            $result{$data->{'id'}}.=",".$data->{$campos[$i]};
        }
        $strjson.=$labels."'}";
    }
    $strjson=substr($strjson,1,length($strjson));
    $strjson="[".$strjson."]";

    return($strjson,\%result);
}

#devuelve todos los registros relacionados con un elemento de referencia, dependiendo de los valores en tablasDeReferencias, por ej: para el autor id 10 devolvera que tiene asignados 35 biblios

sub tablasRelacionadas{
my ($tabla,$indice,$valor)=@_;

my $dbh = C4::Context->dbh;
#Se verfica si tiene referencias
#Tabla referencias
#referencia nomcamporeferencia camporeferencia referente             camporeferente
#autores    id      0       biblio          author
#autores    id      0       colaboradores       idColaborador
#autores    id      0       additionalauthors   author
#autores    id      0       analyticalauthors   author
my $sth=$dbh->prepare(" SELECT * 
            FROM pref_tabla_referencia 
            WHERE referencia= ?");
$sth->execute($tabla);
my @results;
while (my $data=$sth->fetchrow_hashref){
        my $aux;
    my $sth2=$dbh->prepare("SELECT $data->{'nomcamporeferencia'} 
                FROM $data->{'referencia'} 
                WHERE $indice = ?");
    $sth2->execute($valor);
    my $identificador=$sth2->fetchrow_array;
    $sth2=$dbh->prepare("   SELECT COUNT(*) 
                FROM $data->{'referente'} 
                WHERE $data->{'camporeferente'}= ?");
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
my $sth=$dbh->prepare(" SELECT similares 
            FROM pref_tabla_referencia_info 
            WHERE referencia=? ");
$sth->execute($tabla);
my $similar=$sth->fetchrow_array;
#Busco el valor del campo similar que corresponde al registro para el cual estoy buscando similares 
$sth=$dbh->prepare("    SELECT $similar 
            FROM $tabla 
            WHERE $camporeferencia = ? 
            LIMIT 0,1");
$sth->execute($id);
my $valorAbuscarSimil=$sth->fetchrow_array;
my $tamano=(length($valorAbuscarSimil))-1;
#Busco los valores similares, con una expresion regular que busca aquellas tuplas que coincidan en campo similar en todos los caracteres-1 del original
$sth=$dbh->prepare("    SELECT * 
            FROM $tabla 
            WHERE $similar REGEXP '[$valorAbuscarSimil]{$tamano,}' AND $camporeferencia  != ? 
            ORDER BY $similar 
            LIMIT 0,15");
$sth->execute($id);
my $sth3=$dbh->prepare("SELECT camporeferencia 
            FROM pref_tabla_referencia 
            WHERE referencia=? 
            LIMIT 0,1");
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
my $sth=$dbh->prepare(" SELECT * 
            FROM pref_tabla_referencia 
            WHERE referencia= ?");
$sth->execute($tabla);
my @results;
my $asignar=0;
while (my $data=$sth->fetchrow_hashref){
    $asignar=1;
        my $aux;
    my $sth2=$dbh->prepare("SELECT $data->{'nomcamporeferencia'} 
                FROM $data->{'referencia'} 
                WHERE $indice = ?");
    $sth2->execute($identificador);
    my $identificador2=$sth2->fetchrow_array;
    $sth2=$dbh->prepare("   UPDATE $data->{'referente'} 
                SET $data->{'camporeferente'}= ? 
                WHERE $data->{'camporeferente'}= ?");
    $sth2->execute($valorNuevo,$identificador2);
    }
if ($borrar){
    my $sth3=$dbh->prepare("DELETE FROM $tabla 
                WHERE $indice= ?");
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
my $sth=$dbh->prepare("SHOW FIELDS FROM ?");
$sth->execute($tabla);
my @data=$sth->fetchrow_array;
$sth=$dbh->prepare("    SELECT * 
            FROM ? 
            WHERE ?=?");
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
my $sth=$dbh->prepare(" UPDATE $tabla 
            SET $sql 
            WHERE $id=?");
$sth->execute($valores{$id});
$sth->finish;
}

# #Esta funcion retorna todas las tablas de referencia las sistema de acuerdo a las tablas que esten en la tabla tablasDeReferencias de la base de datos, no recibe parametros
# sub buscarTablasdeReferencias{
# my $dbh = C4::Context->dbh;
# my $sth=$dbh->prepare(" SELECT DISTINCT(referencia) 
#             FROM pref_tabla_referencia 
#             ORDER BY (referencia)");
# $sth->execute();
# my %results;
# while (my $data = $sth->fetchrow_hashref) {#push(@results, $data); 
#   $results{$data->{'referencia'}}=$data->{'referencia'};
# }
# $sth->finish;
# return(%results);#,@results);
# }
# 
# #Esta funcion devuelve la tabla de referencia que se esta buscando para modificar
# sub {
# my ($ref)=@_;
# my $dbh = C4::Context->dbh;
# my $sth=$dbh->prepare(" SELECT * 
#             FROM pref_tabla_referencia 
#             WHERE referencia=? 
#             LIMIT 0,1");
# $sth->execute($ref);
# my $results=$sth->fetchrow_hashref;
# #se obtiene el orden de la tabla con la que se esta trabajando
# $sth=$dbh->prepare("    SELECT orden 
#             FROM pref_tabla_referencia_info 
#             WHERE referencia=? 
#             LIMIT 0,1");
# $sth->execute($ref);
# $results->{'orden'}=$sth->fetchrow_array;
# $sth->finish;
# return($results);
# }
# 
# =item
# obtenerIdentTablaRef
# Obtiene el campo clave de la tabla a la cual se esta asi referencia
# =cut
# sub obtenerIdentTablaRef{
#     my ($tabla)=@_;
#     my $dbh = C4::Context->dbh;
# 
#     my $query=" SELECT nomcamporeferencia 
#             FROM pref_tabla_referencia 
#             WHERE referencia=?";
#     my $sth=$dbh->prepare($query);
#     $sth->execute($tabla);
#     return($sth->fetchrow);
# }

#obtenerTemas devuelve los temas que sean like el parametro
sub obtenerDefaults{

my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare(" SELECT * 
            FROM defaultbiblioitem");
$sth->execute();
my @results;
while (my $data = $sth->fetchrow_hashref) {push(@results, $data); } # while
$sth->finish;
return(@results);
}

sub guardarDefaults 
{ my ($biblioitem)=@_;

my $dbh = C4::Context->dbh;

my $sth=$dbh->prepare(" UDPATE defaultbiblioitem 
            SET valor = ? 
            WHERE campo=?");
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
    
#   $valor=~ s/'/\\'/g; 
    #$valor=~ s/-/\\-/g;
    $valor=~ s/%|"|'|=|\*|-(<,>)//g;    
    $valor=~ s/%3b|%3d|%27|%25//g;#Por aca no entra llegan los caracteres ya traducidos
    $valor=~ s/\<SCRIPT>|\<\/SCRIPT>//gi;
    return $valor;
}

#*****************************************Paginador*********************************
#Funciones para paginar en el Servidor
#

sub InitPaginador{
    my ($iniParam)=@_;
    my $pageNumber;
    my $ini;
    my $cantR=cantidadRenglones();
    
    if (($iniParam eq "")){
            $ini=0;
        $pageNumber=1;
    } else {
        $ini= ($iniParam-1)* $cantR;
        $pageNumber= $iniParam;
    };

    return ($ini,$pageNumber,$cantR);
}

sub crearPaginador{

    my ($cantResult, $cantRenglones, $pagActual, $funcion,$t_params)=@_;

    my ($paginador, $cantPaginas)=armarPaginas($pagActual, $cantResult, $cantRenglones,$funcion,$t_params);

#         $t_params->{'paginador'} = $paginador;
    return $paginador;

}

sub armarPaginas{
#@actual, es la pagina seleccionada por el usuario
#@cantRegistros, cant de registros que se van a paginar
#@$cantRenglones, cantidad de renglones maximo a mostrar
#@$t_params, para obtener el path para las imagenes


    my ($actual, $cantRegistros, $cantRenglones,$funcion, $t_params)=@_;

    my $pagAMostrar=C4::AR::Preferencias->getValorPreferencia("paginas")||10;
    my $numBloq=floor($actual / $pagAMostrar);
    my $limInf=($numBloq * $pagAMostrar);
    my $limSup=$limInf + $pagAMostrar;
    if($limInf == 0){
        $limInf= 1;
        $limSup=$limInf + $pagAMostrar -1;
    }
    my $totalPaginas = ceil($cantRegistros/$cantRenglones);

    my $themelang= $t_params->{'themelang'};

    my $paginador= "<div id=paginador>";
    my $class="paginaNormal";

    if($actual > 1){
        #a la primer pagina
        $paginador .= "<span class='click' onClick='".$funcion."(1)' title='Inicio'>
        <img src='".$themelang."/images/numbers/pag_primera.png' border=0></span>";

        $paginador .= "<span> </span>";

        my $ant= $actual-1;
        $paginador .= "<span class='click' onClick='".$funcion."(".$ant.")' title='Anterior'>
        <img src='".$themelang."/images/numbers/pag_anterior.png' border=0></span>";
    }
    for (my $i=$limInf; ($totalPaginas >1 and $i <= $totalPaginas and $i <= $limSup) ; $i++ ) {
        if($actual == $i){$class="paginaActual"}
            else{$class="paginaNormal"}
        $paginador .= "<span class='".$class."' onClick='".$funcion."(".$i.")'> ".$i." </span>";
    }

    if($actual >= 1 && $actual < $totalPaginas){
        my $sig= $actual+1;
        $paginador .= "<span class='click' onClick='".$funcion."(".$sig.")' title='Siguiente'>
        <img src='".$themelang."/images/numbers/pag_siguiente.png' border=0></span>";

        $paginador .= "<span> </span>";
        #a la primer pagina
        $paginador .= "<span class='click' onClick='".$funcion."(".$totalPaginas.")' title='Fin'>
        <img src='".$themelang."/images/numbers/pag_ultima.png' border=0></span>";
    }
    $paginador .= "</div>"; 

    return($paginador, $totalPaginas);
}

#
#Cantidad de renglones seteado en las preferencias del sistema para ver por cada pagina
sub cantidadRenglones{

        my $dbh = C4::Context->dbh;
        my $query="	SELECT value
		   	FROM pref_preferencia_sistema
                   	WHERE variable='renglones'";
        my $sth=$dbh->prepare($query);
        $sth->execute();

    return($sth->fetchrow_array);
}

#**************************************Fins***Paginador*********************************

=item
cambiarLibreDeuda
guarda el nuevo valor de la variable libreDeuda de la tabla de las preferencias
NOTA: cambiar de PM a uno donde esten todo lo referido a las preferencias de sistema, esta funcion se utiliza en los archivos adminLibreDeuda.pl y libreDeuda.pl
=cut
sub cambiarLibreDeuda(){
	my ($valor)=@_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("	UPDATE pref_preferencia_sistema 
				SET value=? 
				WHERE variable='libreDeuda'");
	$sth->execute($valor);
}

=item 
checkdigit
  $valid = &checkdigit($env, $cardnumber $nounique);
Takes a card number, computes its check digit, and compares it to the
checkdigit at the end of C<$cardnumber>. Returns a true value iff
C<$cardnumber> has a valid check digit.
C<$env> is ignored.
VIENE DEL PM INPUT QUE FUE ELIMINADO
=cut
sub checkdigit {
    my ($env,$infl, $nounique) =  @_;
    $infl = uc $infl;
    #Check to make sure the cardnumber is unique
    #FIXME: We should make the error for a nonunique cardnumber
    #different from the one where the checkdigit on the number is
    #not correct
    unless ( $nounique ){
        my $dbh=C4::Context->dbh;
        my $query=qq{   SELECT * 
                FROM borrowers 
                WHERE cardnumber=?};
        my $sth=$dbh->prepare($query);
        $sth->execute($infl);
        my %results = $sth->fetchrow_hashref();
        if ( $sth->rows != 0 ){return 0;}
    }
    if (C4::AR::Preferencias->getValorPreferencia("checkdigit") eq "none") {return 1;}
    my @weightings = (8,4,6,3,5,2,1);
    my $sum;
    my $i = 1;
    my $valid = 0;
    foreach $i (1..7) {
        my $temp1 = $weightings[$i-1];
        my $temp2 = substr($infl,$i,1);
        $sum += $temp1 * $temp2;
    }
    my $rem = ($sum%11);
    if ($rem == 10) {$rem = "X";}
    if ($rem eq substr($infl,8,1)) {$valid = 1;}
    return $valid;
} # sub checkdigit

=item
checkvalidisbn
  $valid = &checkvalidisbn($isbn);
Returns a true value iff C<$isbn> is a valid ISBN: it must be ten
digits long (counting "X" as a digit), and must have a valid check
digit at the end.
VIENE DEL PM INPUT QUE FUE ELIMINADO
=cut
#--------------------------------------
# Determine if a number is a valid ISBN number, according to length
#   of 10 digits and valid checksum
# VIENE DEL PM INPUT QUE FUE ELIMINADO
sub checkvalidisbn {
        my ($q)=@_ ;    # Input: ISBN number
        my $isbngood = 0; # Return: true or false
        $q=~s/x$/X/g;           # upshift lower case X
        $q=~s/[^X\d]//g;
        $q=~s/X.//g;
    #return 0 if $q is not ten digits long
    if (length($q)!=10) {return 0;}
    #If we get to here, length($q) must be 10
        my $checksum=substr($q,9,1);
        my $isbn=substr($q,0,9);
        my $i;
        my $c=0;
        for ($i=0; $i<9; $i++) {
            my $digit=substr($q,$i,1);
            $c+=$digit*(10-$i);
        }
    $c %= 11;
        ($c==10) && ($c='X');
        $isbngood = $c eq $checksum;
        return $isbngood;
} # sub checkvalidisbn

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

#pasa de codificacion UTF8 a ISO-8859-1,
sub UTF8toISO{
    my ($data)=@_;
    return $data= Encode::decode('utf8', $data);
}


sub from_json_ISO{

    eval {
        my ($data)=@_;
        $data= UTF8toISO($data);
        return from_json($data, {ascii => 0});
    }
    or do {
        return "0";
   }
        
}
=item
obtenerValoresAutorizados
Obtiene todas las categorias, sin repetición de la tabla authorised_values.
=cut
sub obtenerValoresAutorizados(){

	use C4::Modelo::PrefValorAutorizado;
	use C4::Modelo::PrefValorAutorizado::Manager;

    my $valAuto_array_ref;
    my @filtros;
    my $valTemp = C4::Modelo::PrefValorAutorizado->new();
  
    $valAuto_array_ref = C4::Modelo::PrefValorAutorizado::Manager->get_pref_valor_autorizado( 
										select => ['category'],
										group_by => ['category'],
     							); 

    return ($valAuto_array_ref);

}

=item
obtenerDatosValorAutorizado
Obtiene todos los valores de una categoria.
=cut
sub obtenerDatosValorAutorizado(){
    my ($categoria)= @_;

    use C4::Modelo::PrefValorAutorizado;
    my $valAuto_array_ref = C4::Modelo::PrefValorAutorizado::Manager->get_pref_valor_autorizado( query => [ category => { eq => $categoria} ]);

    my %autoValueHash;
    foreach my $av (@$valAuto_array_ref){
       $autoValueHash{trim($av->getAuthorisedValue)}= trim($av->getLib);
        }
    return (%autoValueHash);
}

=item
buscarCiudades
Busca las ciudades con todas la relaciones. Se usa para el autocomplete en la parte de agregar usuario.
=cut
sub buscarCiudades{
        my ($ciudad) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "   SELECT  ref_pais.nombre AS pais, ref_provincia.nombre AS provincia, 
                ref_dpto_partido.nombre AS partido, ref_localidad.localidad AS localidad,
                ref_localidad.nombre AS nombre 
            
            FROM ref_localidad LEFT JOIN ref_dpto_partido ON 
                        (ref_localidad.DPTO_PARTIDO = ref_dpto_partido.DPTO_PARTIDO) 
                         LEFT JOIN ref_provincia ON 
                                (ref_dpto_partido.provincia = ref_provincia.provincia) LEFT JOIN ref_pais ON 
                                (ref_pais.codigo = ref_provincia.pais) 
            WHERE (ref_localidad.nombre LIKE ?) OR (ref_localidad.nombre LIKE ?)
            ORDER BY (ref_localidad.nombre)";
    my $sth = $dbh->prepare($query);
        $sth->execute($ciudad.'%', '% '.$ciudad.'%');
        my @results;
    my $cant;
        while (my $data=$sth->fetchrow_hashref){ 
        push(@results,$data); 
        $cant++;
    }
    $sth->finish;
    return ($cant, \@results);
}


=item
buscarLenguajes
=cut
sub buscarLenguajes{
      my ($lenguaje) = @_;
      
      my $lenguajes = C4::Modelo::RefIdioma::Manager->get_ref_idioma(query => [ description => { like => '%'.$lenguaje.'%' } ]);
      
      return (scalar(@$lenguajes), $lenguajes);
}

=item
buscarSoportes
=cut
sub buscarSoportes{
      my ($soporte) = @_;
      
      my $soportes = C4::Modelo::RefSoporte::Manager->get_ref_soporte(query => [ description => { like => '%'.$soporte.'%' } ]);
      
      return (scalar(@$soportes), $soportes);
}

=item
buscarSoportes
=cut
sub buscarNivelesBibliograficos{
      my ($nivelBibliografico) = @_;
      
      my $nivelesBibliograficos = C4::Modelo::RefNivelBibliografico::Manager->get_ref_nivel_bibliografico(
                                                                          query => [ description => { like => '%'.$nivelBibliografico.'%' } ]
                                                                                );
      
      return (scalar(@$nivelesBibliograficos), $nivelesBibliograficos);
}

# Esta funcioin remueve los blancos del principio y el final del string
sub trim($)
{
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;

    return $string;
}


#FUNCION QUE VALIDA QUE UN STRING NO SEA SOLAMENTE UNA SECUENCIA DE BLANCOS (USA Trim())
sub validateString{

    my ($string)=@_;
    $string = trim($string);
    if (length($string) == 0){
        return 0; #EL STRING ERA SOLO BLANCOS, FALSE
    }
    return 1; # TODO OK, TRUE
}


#********************************************************Generacion de Combos****************************************************

sub generarComboDeDisponibilidad{

    my ($params) = @_;
    
    my @select_disponibilidades_array;
    my %select_disponibilidades_hash;

    my ($disponibilidades_array_ref)= &C4::AR::Referencias::obtenerDisponibilidades();
    foreach my $disponibilidad (@$disponibilidades_array_ref) {
        push(@select_disponibilidades_array, $disponibilidad->getCodigo);
        $select_disponibilidades_hash{$disponibilidad->getCodigo}= $disponibilidad->nombre;
    }

    my %options_hash; 
   
    if ( $params->{'onChange'} ){$options_hash{'onChange'}= $params->{'onChange'};}
    if ( $params->{'onFocus'} ){$options_hash{'onFocus'}= $params->{'onFocus'};}
    if ( $params->{'onBlur'} ){$options_hash{'onBlur'}= $params->{'onBlur'};}

    $options_hash{'name'}= $params->{'name'}||'disponibilidad_name';
    $options_hash{'id'}= $params->{'id'}||'disponibilidad_id';
    $options_hash{'size'}=  $params->{'size'}||1;
    $options_hash{'multiple'}= $params->{'multiple'}||0;
    $options_hash{'defaults'}= $params->{'default'} || C4::AR::Preferencias->getValorPreferencia("defaultDisponibilidad");

    push (@select_disponibilidades_array, 'SIN SELECCIONAR');
    $options_hash{'values'}= \@select_disponibilidades_array;
    $options_hash{'labels'}= \%select_disponibilidades_hash;

    my $comboDeDisponibilidades= CGI::scrolling_list(\%options_hash);

    return $comboDeDisponibilidades;
}

#GENERA EL COMBO CON LAS CATEGORIAS, Y SETEA COMO DEFAULT EL PARAMETRO (QUE DEBE SER EL VALUE), SINO HAY PARAMETRO, SE TOMA LA PRIMERA
sub generarComboCategoriasDeSocio{

    my ($params) = @_;
    
    my @select_categorias_array;
    my %select_categorias_hash;

    my ($categorias_array_ref)= &C4::AR::Referencias::obtenerCategoriaDeSocio();
    foreach my $categoria (@$categorias_array_ref) {
        push(@select_categorias_array, $categoria->getCategory_code);
        $select_categorias_hash{$categoria->getCategory_code}= $categoria->description;
    }

    my %options_hash; 
   
    if ( $params->{'onChange'} ){$options_hash{'onChange'}= $params->{'onChange'};}
    if ( $params->{'onFocus'} ){$options_hash{'onFocus'}= $params->{'onFocus'};}
    if ( $params->{'onBlur'} ){$options_hash{'onBlur'}= $params->{'onBlur'};}

    $options_hash{'name'}= $params->{'name'}||'categoria_socio_name';
    $options_hash{'id'}= $params->{'id'}||'categoria_socio_id';
    $options_hash{'size'}=  $params->{'size'}||1;
    $options_hash{'multiple'}= $params->{'multiple'}||0;
    $options_hash{'defaults'}= $params->{'default'} || C4::AR::Preferencias->getValorPreferencia("defaultCategoriaSocio");

    push (@select_categorias_array, 'SIN SELECCIONAR');
    $options_hash{'values'}= \@select_categorias_array;
    $options_hash{'labels'}= \%select_categorias_hash;

    my $comboDeCategorias= CGI::scrolling_list(\%options_hash);

    return $comboDeCategorias;
}

#GENERA EL COMBO CON LOS DOCUMENTOS, Y SETEA COMO DEFAULT EL PARAMETRO (QUE DEBE SER EL VALUE), SINO HAY PARAMETRO, SE TOMA LA PRIMERA
sub generarComboTipoDeDoc {

    my ($params)=@_;

    my @select_docs_array;
    my %select_docs;
    my $docs=&C4::AR::Referencias::obtenerTiposDeDocumentos();
    
    foreach my $doc (@$docs) {
        push(@select_docs_array, $doc->nombre);
        $select_docs{$doc->nombre}= $doc->descripcion;
    }

    my %options_hash; 
   
    if ( $params->{'onChange'} ){$options_hash{'onChange'}= $params->{'onChange'};}
    if ( $params->{'onFocus'} ){$options_hash{'onFocus'}= $params->{'onFocus'};}
    if ( $params->{'onBlur'} ){$options_hash{'onBlur'}= $params->{'onBlur'};}

    $options_hash{'name'}= $params->{'name'}||'tipo_documento_name';
    $options_hash{'id'}= $params->{'id'}||'tipo_documento_id';
    $options_hash{'size'}=  $params->{'size'}||1;
    $options_hash{'multiple'}= $params->{'multiple'}||0;
    $options_hash{'defaults'}= $params->{'default'} || C4::AR::Preferencias->getValorPreferencia("defaultTipoDoc");

    push (@select_docs_array, 'SIN SELECCIONAR');
    $options_hash{'values'}= \@select_docs_array;
    $options_hash{'labels'}= \%select_docs;

    my $combo_tipo_documento= CGI::scrolling_list(\%options_hash);

    return $combo_tipo_documento; 
}

sub generarComboTipoNivel3{

    my ($params) = @_;

    my @select_tipo_nivel3_array;
    my %select_tipo_nivel3_hash;

    my ($tipoNivel3_array_ref)= &C4::AR::Referencias::obtenerTiposNivel3();

    foreach my $tipoNivel3 (@$tipoNivel3_array_ref) {
        push(@select_tipo_nivel3_array, $tipoNivel3->id_tipo_doc);
        $select_tipo_nivel3_hash{$tipoNivel3->id_tipo_doc}= $tipoNivel3->nombre;
    }

    my %options_hash; 

    if ( $params->{'onChange'} ){
         $options_hash{'onChange'}= $params->{'onChange'};
    }

    if ( $params->{'onFocus'} ){
      $options_hash{'onFocus'}= $params->{'onFocus'};
    }

    if ( $params->{'onBlur'} ){
      $options_hash{'onBlur'}= $params->{'onBlur'};
    }

    $options_hash{'name'}= $params->{'name'}||'tipo_nivel3_name';
    $options_hash{'id'}= $params->{'id'}||'tipo_nivel3_id';
    $options_hash{'size'}=  $params->{'size'}||1;
    $options_hash{'multiple'}= $params->{'multiple'}||0;
    $options_hash{'defaults'}= $params->{'default'} || C4::AR::Preferencias->getValorPreferencia("defaultTipoNivel3");

    push (@select_tipo_nivel3_array, 'ALL');
    $select_tipo_nivel3_hash{'ALL'}= 'TODOS';

    push (@select_tipo_nivel3_array, 'SIN SELECCIONAR');
    $options_hash{'values'}= \@select_tipo_nivel3_array;
    $options_hash{'labels'}= \%select_tipo_nivel3_hash;

    my $comboTipoNivel3= CGI::scrolling_list(\%options_hash);

    return $comboTipoNivel3;
}

sub generarComboTipoPrestamo{

    my ($params) = @_;

    my @select_tipo_nivel3_array;
    my %select_tipo_prestamo_hash;
    use C4::Modelo::CircRefTipoPrestamo::Manager;
    my ($tipoPrestamo_array)= C4::Modelo::CircRefTipoPrestamo::Manager->get_circ_ref_tipo_prestamo();

    foreach my $tipoPrestamo (@$tipoPrestamo_array) {
        push(@select_tipo_nivel3_array, $tipoPrestamo->id_tipo_prestamo);
        $select_tipo_prestamo_hash{$tipoPrestamo->id_tipo_prestamo}= $tipoPrestamo->descripcion;
    }

    my %options_hash; 

    if ( $params->{'onChange'} ){
         $options_hash{'onChange'}= $params->{'onChange'};
    }

    if ( $params->{'onFocus'} ){
      $options_hash{'onFocus'}= $params->{'onFocus'};
    }

    if ( $params->{'onBlur'} ){
      $options_hash{'onBlur'}= $params->{'onBlur'};
    }

    $options_hash{'name'}= $params->{'name'}||'tipo_nivel3_name';
    $options_hash{'id'}= $params->{'id'}||'tipo_nivel3_id';
    $options_hash{'size'}=  $params->{'size'}||1;
    $options_hash{'multiple'}= $params->{'multiple'}||0;

#FIXME falta un default no?
#     $options_hash{'defaults'}= $params->{'default'} || C4::AR::Preferencias->getValorPreferencia("defaultTipoNivel3");


    push (@select_tipo_nivel3_array, 'SIN SELECCIONAR');
    $options_hash{'values'}= \@select_tipo_nivel3_array;
    $options_hash{'labels'}= \%select_tipo_prestamo_hash;

    my $comboTipoNivel3= CGI::scrolling_list(\%options_hash);

    return $comboTipoNivel3;
}

#GENERA EL COMBO CON LOS BRANCHES, Y SETEA COMO DEFAULT EL PARAMETRO (QUE DEBE SER EL VALUE), SINO HAY PARAMETRO, SE TOMA LA PRIMERA
sub generarComboUI {
    my ($params) = @_;

    my @select_ui;
    my %select_ui;

    my $unidades_de_informacion= C4::AR::Referencias::obtenerUnidadesDeInformacion();

    foreach my $ui (@$unidades_de_informacion) {
        push(@select_ui, $ui->id_ui);
        $select_ui{$ui->id_ui}= $ui->nombre;
    }

    my %options_hash; 
   
    if ( $params->{'onChange'} ){$options_hash{'onChange'}= $params->{'onChange'};}
    if ( $params->{'onFocus'} ){$options_hash{'onFocus'}= $params->{'onFocus'};}
    if ( $params->{'onBlur'} ){$options_hash{'onBlur'}= $params->{'onBlur'};}

    $options_hash{'name'}= $params->{'name'}||'id_ui';
    $options_hash{'id'}= $params->{'id'}||'id_ui';
    $options_hash{'size'}=  $params->{'size'}||1;
    $options_hash{'multiple'}= $params->{'multiple'}||0;
    $options_hash{'defaults'}= $params->{'default'} || C4::AR::Preferencias->getValorPreferencia("defaultUI");

    push (@select_ui, 'SIN SELECCIONAR');
    $options_hash{'values'}= \@select_ui;
    $options_hash{'labels'}= \%select_ui;

    my $CGIunidadDeInformacion= CGI::scrolling_list(\%options_hash);

    return $CGIunidadDeInformacion; 
}

sub generarComboDeSocios {
    my ($params) = @_;

    my @select_socios;
    my %select_socios;

    my $socios= C4::Modelo::UsrSocio::Manager->get_usr_socio( query => [ 
                                                                          activo => {eq => 1},
                                                                       ],);

    foreach my $socio (@$socios) {
        push(@select_socios, $socio->getId_socio);
        $select_socios{$socio->getId_socio}= $socio->persona->getApellido.", ".$socio->persona->getNombre." (".$socio->getNro_socio.")" ;
    }

    my %options_hash; 
   
    if ( $params->{'onChange'} ){$options_hash{'onChange'}= $params->{'onChange'};}
    if ( $params->{'onFocus'} ){$options_hash{'onFocus'}= $params->{'onFocus'};}
    if ( $params->{'onBlur'} ){$options_hash{'onBlur'}= $params->{'onBlur'};}

    $options_hash{'name'}= $params->{'name'}||'ui_name';
    $options_hash{'id'}= $params->{'id'}||'ui_id';
    $options_hash{'size'}=  $params->{'size'}||1;
    $options_hash{'multiple'}= $params->{'multiple'}||0;
    $options_hash{'defaults'}= $params->{'default'} || '-1';

    push (@select_socios, 'SIN SELECCIONAR');
    $select_socios{'-1'}='SIN SELECCIONAR';
    $options_hash{'values'}= \@select_socios;
    $options_hash{'labels'}= \%select_socios;

    my $CGIsocios= CGI::scrolling_list(\%options_hash);

    return $CGIsocios; 
}


sub generarComboCampoX{


    my $onReadyFunction = shift;
    my $defaultCampoX = shift;
    #Filtro de numero de campo
    my %camposX;
    my @values;
    push (@values, -1);
    $camposX{-1}="Elegir";

    my $option;
    for (my $i =0 ; $i <= 9; $i++){
        push (@values, $i);
        $option= $i."xx";
        $camposX{$i}=$option;
    }
    my $defaulCX= $defaultCampoX || 'Elegir';

    my $selectCampoX=CGI::scrolling_list(  -name      => 'campoX',
                    -id    => 'campoX',
                    -values    => \@values,
                    -labels    => \%camposX,
                    -defaults  => $defaulCX,
                    -size      => 1,
                    -onChange  => $onReadyFunction,
    );

    return ($selectCampoX);
}

sub generarComboTipoDeOperacion {
   
   my ($params) = @_;
   use C4::Modelo::RefTipoOperacion::Manager;
   my @select_tipoOperacion_Values;
   my %select_tipoOperacion_Labels;
   my $result = C4::Modelo::RefTipoOperacion::Manager->get_ref_tipo_operacion();

   foreach my $tipoOperacion (@$result) {
      push (@select_tipoOperacion_Values, $tipoOperacion->id);
      $select_tipoOperacion_Labels{$tipoOperacion->id} = $tipoOperacion->descripcion;
   }

   my $CGISelectTipoOperacion=CGI::scrolling_list(    -name      => 'tipoOperacion',
                                                      -id        => 'tipoOperacion',
                                                      -values    => \@select_tipoOperacion_Values,
                                                      -labels    => \%select_tipoOperacion_Labels,
                                                      -size      => 1,
                                                      -defaults  => 'SIN SELECCIONAR'
                                                 );
}

sub generarComboNiveles {

    my ($params) = @_;

    my @nivel;
    my $cantNivel=3;
    push(@nivel, "Niveles");
    for (my $i=1; $i<=$cantNivel; $i++){
        push(@nivel, $i);
    }

    my @select_niveles;
    my %select_niveles;

    foreach my $nivel (@nivel) {
        push(@select_niveles, $nivel);
        $select_niveles{$nivel}= $nivel;
    }

    my %options_hash; 
   
    if ( $params->{'onChange'} ){$options_hash{'onChange'}= $params->{'onChange'};}
    if ( $params->{'onFocus'} ){$options_hash{'onFocus'}= $params->{'onFocus'};}
    if ( $params->{'onBlur'} ){$options_hash{'onBlur'}= $params->{'onBlur'};}

    $options_hash{'name'}= 'niveles_name';
    $options_hash{'id'}= 'niveles_id';
    $options_hash{'size'}=  $params->{'size'}||1;
    $options_hash{'multiple'}= $params->{'multiple'}||0;
    $options_hash{'defaults'}= $params->{'default'} || 'Niveles';

    push (@select_niveles, 'SIN SELECCIONAR');
    $options_hash{'values'}= \@select_niveles;
    $options_hash{'labels'}= \%select_niveles;

    my $CGINiveles= CGI::scrolling_list(\%options_hash);

    return $CGINiveles; 
}

#****************************************************Fin****Generacion de Combos**************************************************


sub printHASH {
    my ($hash_ref) = @_;
    open(Z, ">>/tmp/debug.txt");
    print Z "\n";
    print Z "PRINT HASH: \n";
    
    if($hash_ref){
        while ( my ($key, $value) = each(%$hash_ref) ) {
                print Z "key: $key => value: $value\n";
            }
    }
    print Z "\n";
    close(Z);
}

sub joinArrayOfString{

    my (@columns) = @_;
    my ($fieldsString) = "";
    foreach my $campo (@columns){

        $fieldsString.= $campo." ";
    }
    return ($fieldsString);
}

=item
Esta funcion convierte el arreglo de objetos (Rose::DB) a JSON
=cut
sub arrayObjectsToJSONString {
    my ($objects_array) = @_;
    my @objects_array_JSON;

    for(my $i=0; $i<scalar(@$objects_array); $i++ ){
        push (@objects_array_JSON, $objects_array->[$i]->as_json);
    }

    my $infoJSON= '[' . join(',' ,@objects_array_JSON) . ']';

    return $infoJSON;
}

=item
Esta funcion convierte el arreglo de valores a JSON {campo->campo}
=cut
sub arrayToJSONString {
    my ($array) = @_;
	my @array_JSON;

    for(my $i=0; $i<scalar(@$array); $i++ ){
        push (@array_JSON,"{'campo':'".$array->[$i]->{'campo'}."'}");
    }

    my $infoJSON= '[' . join(',' ,@array_JSON) . ']';

    return $infoJSON;
}

=item
Esta funcion convierte el arreglo de los pares clave/valor a JSON {clave->clave,valor->valor}
=cut
sub arrayClaveValorToJSONString {
    my ($array) = @_;
	my @array_JSON;

    for(my $i=0; $i<scalar(@$array); $i++ ){
        push (@array_JSON,"{'clave':'".$array->[$i]->{'clave'}."',valor':'".$array->[$i]->{'valor'}."'}");
    }

    my $infoJSON= '[' . join(',' ,@array_JSON) . ']';

    return $infoJSON;
}

1;
