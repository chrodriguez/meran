package ImportacionIso2;

#
#Este modulo sera el encargado de interactuar con la tabla ISO2709 donde estan los datos 
#para la importacion de codigos iso a marc y donde estan las descripciones de cada campo y sus
#subcampos se usa con el script iso2koha.pl
#

use strict;
require Exporter;
use C4::Biblio;
use C4::Context;
use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(&ui
           &campoIso
	   &subCampoIso
	   &datosCompletos
	   &insertDescripcion
	   &mostrarTablas
	   &mostrarCampos
	   &insertTablaKoha
	   &listadoDeCodigosDeCampo
	   &list
	   &listK
	   &insertNuevo
           &agregarBiblio
	   &agregarBibItem
	   &agregarItem

);

#
#Dado una Unid. de Informacion sus campos y subcampos ISO me devuelve la descripcion correspondiente
#
sub checkDescription{
	my $dbh = C4::Context->dbh;
	my $query ="Select descripcion 
	              From iso2709 
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
	my $query ="update  iso2709 set descripcion=?
	    	     Where (id=?)";
 	my $sth=$dbh->prepare($query);
	$sth->execute($descripcion,$id);
        $sth-> finish;                                                                                             
}


sub insertUnidadInformacion{
	my $dbh = C4::Context->dbh;
	my $query ="Insert into iso2709 (ui) values (?)";
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
	my $query ="Select * from iso2709 ";
	$query.= "where campoIso = ".$campoIso." and ui='".$branchcode."'"; #Comentar para lograr el listado completo
	my $sth=$dbh->prepare($query);
	$sth->execute();
        while (my $data=$sth->fetchrow_hashref){
		 #if ($data->{'ui'} eq "") {
		#	$data->{'ui'}="-" };
		 if ($data->{'subCampoIso'} eq "") {
                        $data->{'subCampoIso'}="-" };
             	push(@results,$data);
		} 
	return (@results);
}

#Muestro todas las tablas de la base de datos

sub mostrarTablas{
        my $dbh = C4::Context->dbh;
        my @results;
        my $query ="show tables";
        my $sth=$dbh->prepare($query);
        $sth->execute();
	push(@results,""); #Agrago un primer elemento vacio
        while (my $data=$sth->fetchrow_hashref){
	#	if (($data->{'Tables_in_Econo'} eq 'items') 
	#		|| ($data->{'Tables_in_Econo'} eq 'biblio')
	#		|| ($data->{'Tables_in_Econo'} eq 'biblioitems')
	#	) {
			my $nombre = $data->{'Tables_in_Econo'};
 			push(@results,$nombre);
	#	}
	}
	return (@results);
}

#Dado el nombre de una tabla me devuelve todos sus campos
#

sub mostrarCampos{
        my $dbh = C4::Context->dbh;
        my @results;
	my ($nombre)=@_;
        my $query ="show fields from ".$nombre;
        my $sth=$dbh->prepare($query);
        $sth->execute();
        while (my $data=$sth->fetchrow_hashref){
		my $campos = $data->{'Field'};
		push(@results,$campos);
	}
        return (@results);
}
#Dado un campo y subcampo inserto la tabla koha al cual pertenece 
                                                                                                                             
sub insertTablaKoha{
        my ($kohaTabla,$id)=@_;
        my $dbh = C4::Context->dbh;
        my $query ="update  iso2709 set kohaTabla=?
                     Where (id=?)";
        my $sth=$dbh->prepare($query);
        $sth->execute($kohaTabla,$id);
        $sth-> finish;
}


#Inserto una tupla completa nueva
#
sub insertNuevo{
        my ($descripcion,$kohaTabla,$campoIso,$subCampoIso,$campoKoha,$orden,$separador,$id)=@_;
	if ($descripcion eq "") {$descripcion= undef;}
	if ($kohaTabla eq "") {$kohaTabla= undef;}
	if ($campoKoha eq "") {$campoKoha= undef;}
        my $dbh = C4::Context->dbh;
        my $query ="update  iso2709 set descripcion=?,kohaTabla=?,kohaCampo=?,orden=?,separador=?
                     Where (id=?)";
        my $sth=$dbh->prepare($query);
        $sth->execute($descripcion,$kohaTabla,$campoKoha,$orden,$separador,$id);
        $sth-> finish;
}

sub listadoDeCodigosDeCampo{

	my $dbh = C4::Context->dbh;
        my @results;
        my $query ="select campoIso from iso2709 group by campoIso order by campoIso";
        my $sth=$dbh->prepare($query);
        $sth->execute();
        while (my $data=$sth->fetchrow_hashref){
                push(@results,$data);
        }
        return (@results);
}
sub list{
        #esta funcion sirve para devolver un arreglo asociativo que tiene como clave el campoIso y SubcampoIso y como valor el campo Koha y el subcampoKoha.
        my $dbh = C4::Context->dbh;
        my %results;
        my $query ="select campoIso,subCampoIso,kohaCampo,kohaTabla,separador,orden,interfazWeb from iso2709 order by campoIso;";
        my $sth=$dbh->prepare($query);
        $sth->execute();
        while (my $data=$sth->fetchrow_hashref){
		my %resp;
		$resp{'tabla'}= $data->{'kohaTabla'};
		$resp{'campo'}=$data->{'kohaCampo'};
		$resp{'orden'}=$data->{'orden'};
		$resp{'separador'}=$data->{'separador'};
		$resp{'k'}=$data->{'interfazWeb'};
		my $aux=$data->{'campoIso'};
		if ((length ($aux))==1){
				 $aux="00".$aux;
				}
		elsif(length($aux)==2){$aux="0".$aux;
					}
		$results{$aux,$data->{'subCampoIso'}}=\%resp; 
	        }
        return (%results);
}
sub listK{
        #esta funcion sirve para devolver un arreglo asociativo que tiene como clave el campoIso y SubcampoIso y como valor el campo K.
        my %results;
	my $dbh = C4::Context->dbh;
        my $query ="select campoIso,subCampoIso,interfazWeb from iso2709 order by interfazWeb;";
        my $sth=$dbh->prepare($query);
        $sth->execute();
        while (my $data=$sth->fetchrow_hashref){
		my $aux=$data->{'campoIso'};
		if ((length ($aux))==1){
				 $aux="00".$aux;
				}
		elsif(length($aux)==2){$aux="0".$aux;
					}
		$results{$data->{'interfazWeb'}}=[$aux,$data->{'subCampoIso'}]; 
	        }
        return (%results);
}

sub agregarBibItem
{
my ($responsable,$biblionumber,$relacion,%biblioitem)=@_;
my $biblioIT = {
    biblionumber      => $biblionumber,
    itemtype          => $biblioitem{'itemtype'}?$biblioitem{'itemtype'}:"",
    isbn              => $biblioitem{'isbn'}?$biblioitem{'isbn'}:"",
    isbn2             => $biblioitem{'isbnSec'}?$biblioitem{'isbnSec'}:"",#ISBN secundario para algunos casos especiales
    publishercode     => $biblioitem{'publishercode'}?$biblioitem{'publishercode'}:"",
    publicationyear   => $biblioitem{'publicationyear'}?$biblioitem{'publicationyear'}:"",
    place             => $biblioitem{'place'}?$biblioitem{'place'}:"",
    #Country, language, support y series fueron agregados por Einar.
    serie             => $biblioitem{'serie'}?$biblioitem{'serie'}:"",
    support             => $biblioitem{'support'}?$biblioitem{'support'}:"",
    country             => $biblioitem{'country'}?$biblioitem{'country'}:"",
    language             => $biblioitem{'language'}?$biblioitem{'language'}:"",
    illus             => $biblioitem{'illus'}?$biblioitem{'illus'}:"",
    url               => $biblioitem{'url'}?$biblioitem{'url'}:"",
    dewey             => $biblioitem{'dewey'}?$biblioitem{'dewey'}:"",
    subclass          => $biblioitem{'subclass'}?$biblioitem{'subclass'}:"",
    issn              => $biblioitem{'issn'}?$biblioitem{'issn'}:"",
    lccn              => $biblioitem{'lccn'}?$biblioitem{'lccn'}:"",
    volume            => $biblioitem{'volume'}?$biblioitem{'volume'}:"",
    number            => $biblioitem{'number'}?$biblioitem{'number'}:"",
    volumeddesc       => $biblioitem{'volumeddesc'}?$biblioitem{'volumeddesc'}:"",
    pages             => $biblioitem{'pages'}?$biblioitem{'pages'}:"",
    size              => $biblioitem{'size'}?$biblioitem{'size'}:"",
    bnotes            => $biblioitem{'notes'}?$biblioitem{'notes'}:"",
}; 
my $dbh = C4::Context->dbh;
my $bibitemnum=newbiblioitem($biblioIT,$responsable); 
my $query3="Insert into relationISO set number = ?, idBiblio = ?, relacion = ?";
my $sth3=$dbh->prepare ($query3);
$sth3->execute($bibitemnum,$relacion,"biblioitem");
$sth3->finish;
return ($bibitemnum);

}

sub agregarItem
{
my ($responsable,$biblionumber,$biblioitemnumber,$relacion,%item)=@_;
my $itemT = {
    biblionumber     => $biblionumber,
    biblioitemnumber => $biblioitemnumber?$biblioitemnumber:"",
    homebranch       => $item{'homebranch'},
    holdingbranch    => $item{'homebranch'}, #esta es la linea que agregue
    replacementprice => $item{'replacementprice'}?$item{'replacementprice'}:"",
    #Agregado el bulk por Einar, el bulk es la signatura topografica
    bulk        => $item{'bulk'}?$item{'bulk'}:"",
    #Corregido el notes por el itemsnotes porque las notas del item son el items note
    itemnotes        => $item{'itemnotes'}?$item{'itemnotes'}:"",
    #Agregado por Einar, para saber si es para sala o si esta perdido o si esta withdrawn
    notforloan        => $item{'notforloan'}?$item{'notforloan'}:"",
    withdrawn        => $item{'withdrawn'}?$item{'withdrawn'}:"",
    itemlost        => $item{'Lost'}?$item{'Lost'}:""
	};


my $dbh = C4::Context->dbh;
my @barcode=($item{'barcode'}?$item{'barcode'}:"");
my $itemnum=newitems($itemT,$responsable,(@barcode)) ; 
my $query3="Insert into relationISO set number = ?, idBiblio = ?, relacion = ?";
my $sth3=$dbh->prepare ($query3);
$sth3->execute($itemnum,$relacion,"item");
$sth3->finish;
return ($itemnum);

}



sub noaccents {
        my $word = @_[0];
        my @chars = split(//,$word); 
        my $newstr = "";
        foreach my $ch (@chars) {
                if (ord($ch) == 225) {$newstr.= 'a'}
                elsif (ord($ch) == 233) {$newstr.= 'e'}
                elsif (ord($ch) == 237) {$newstr.= 'i'}
                elsif (ord($ch) == 243) {$newstr.= 'o'}
                elsif (ord($ch) == 250) {$newstr.= 'u'}
                elsif (ord($ch) == 193) {$newstr.= 'A'}
                elsif (ord($ch) == 201) {$newstr.= 'E'}
                elsif (ord($ch) == 205) {$newstr.= 'I'}
                elsif (ord($ch) == 211) {$newstr.= 'O'}
                elsif (ord($ch) == 218) {$newstr.= 'U'}
                else {$newstr.= $ch}
        }
        return($newstr);
}



sub agregarBiblio
{
my ($responsable,$relacion,%biblio)=@_;
my $biblioT = {
    title       => $biblio{'title'},
    subtitle    =>$biblio{'subtitle'}?$biblio{'subtitle'}:"",
    author      => $biblio{'author'}?$biblio{'author'}:"",
    unititle   => $biblio{'unititle'}?$biblio{'unititle'}:"",
    abstract    => $biblio{'abstract'}?$biblio{'abstract'}:"",
    notes       => $biblio{'notes'}?$biblio{'notes'}:"",
    #Campos agregados seriestitle es CDU
    seriestitle => $biblio{'seriestitle'}?$biblio{'seriestitle'}:"",
    additionalauthors => $biblio{'additionalauthors'}?$biblio{'additionalauthors'}:"",
    subjectheadings   => $biblio{'subjectheadings'}?$biblio{'subjectheadings'}:""
}; # my $biblioT


my $dbh = C4::Context->dbh;
my $query="select * from biblio where (title = ? and unititle = ? and author = ?  and  seriestitle = ? and notes = ? and  abstract = ?)";
my $sth=$dbh->prepare($query);
#Porque esta el noaccents?
$sth->execute (&noaccents($biblioT->{'title'}), &noaccents($biblioT->{'unititle'}) ,&noaccents($biblioT->{'author'}),&noaccents($biblioT->{'seriestitle'}),&noaccents($biblioT->{'notes'}),&noaccents($biblioT->{'abstract'}));
my $bibnum;
if (my $data=$sth->fetchrow_hashref){
	$bibnum= $data->{'biblionumber'};
} else {
$bibnum=newbiblio($biblioT,$responsable); 
my $query3="Insert into relationISO set number = ?, idBiblio = ?, relacion = ?";
my $sth3=$dbh->prepare ($query3);
$sth3->execute($bibnum,$relacion,"biblio");
$sth3->finish;
}
$sth ->finish;
return ($bibnum);

}

