package C4::AR::SxcGenerator;

use strict;
require Exporter;
use C4::Context;
use ooolib;

use vars qw($VERSION @ISA @EXPORT);

$VERSION = 0.01;

@ISA = qw(Exporter);
#
# Generador de  Planillas Sxc de OpenOffice
#
@EXPORT = qw(
	generar_planilla_prestamos
	generar_planilla_inventario
	generar_planilla_estantes
	generar_planilla_usuario
	generar_planilla_inventario_sig_top
);


#Genera la planilla del reporte  "Pr�stamos sin devolver"

sub generar_planilla_prestamos {
	my ($results,$nro_socio) = @_;
#Genero la hoja de calculo Openoffice
## - start sxc document
my $sheet=new ooolib("sxc");
$sheet->oooSet("builddir","./plantillas");
#
## - Set Meta.xml data
$sheet->oooSet("title","Reporte de Prestamos");
$sheet->oooSet("author","KOHA");
# - Set name of first sheet
$sheet->oooSet("subject","Reporte");
# - Set some data
# columns can be in numbers or letters

my $pos=1;
my $count=1;
$sheet->oooSet("bold", "on");
#Titulos
my @campos=(C4::AR::Filtros::i18n("Apellido"),
            C4::AR::Filtros::i18n("Nombre"),
            C4::AR::Filtros::i18n("Número de socio"),
            C4::AR::Filtros::i18n("E-mail"),
            C4::AR::Filtros::i18n("Fecha de prestamo"),
            C4::AR::Filtros::i18n("Fecha de vencimiento"),
            C4::AR::Filtros::i18n("Código de barra"),
            C4::AR::Filtros::i18n("Signatura Topográfica"),
            C4::AR::Filtros::i18n("Tipo de préstamo")
           );

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
foreach my $prestamo (@$results){
   $sheet->oooSet("cell-loc", 1, $pos);
   $sheet->oooData("cell-text", $prestamo->socio->persona->getApellido);
   $sheet->oooSet("cell-loc", 2, $pos);
   $sheet->oooData("cell-text", $prestamo->socio->persona->getNombre);
   $sheet->oooSet("cell-loc", 3, $pos);
   $sheet->oooData("cell-text", $prestamo->socio->getNro_socio);
   $sheet->oooSet("cell-loc", 4, $pos);
   $sheet->oooData("cell-text", $prestamo->socio->persona->getEmail);
   $sheet->oooSet("cell-loc", 5, $pos);
   $sheet->oooData("cell-text", $prestamo->getFecha_prestamo);
   $sheet->oooSet("cell-loc", 6, $pos);
   $sheet->oooData("cell-text", C4::AR::Prestamos::fechaDeVencimiento($prestamo->getId3,$prestamo->getFecha_prestamo) );
   $sheet->oooSet("cell-loc", 7, $pos);
   $sheet->oooData("cell-text", $prestamo->nivel3->getBarcode);
   $sheet->oooSet("cell-loc", 8, $pos);
   $sheet->oooData("cell-text", $prestamo->nivel3->nivel2->getSignatura_topografica);
   $sheet->oooSet("cell-loc", 9, $pos);
   $sheet->oooData("cell-text", $prestamo->tipo->getDescripcion);
   
   $pos++;
}
##
my $name="prestamos-vencidos-".$nro_socio;
	 $sheet->oooGenerate($name);
	return($name);

}

#Genera la planilla del reporte  "Inventario"

sub generar_planilla_inventario {
my ($results,$nro_socio) = @_;
#Genero la hoja de calculo Openoffice
## - start sxc document

my $sheet=new ooolib("sxc");
$sheet->oooSet("builddir","./plantillas");
$sheet->oooSet("title","Reporte de Inventario (C&oacute;digo de barras)");
$sheet->oooSet("author","KOHA");
$sheet->oooSet("subject","Reporte");
$sheet->oooSet("bold", "on");
my $pos=1;
$sheet->oooSet("text-size", 11);
$sheet->oooSet("cell-loc", 1, $pos);
$sheet->oooData("cell-text", "Ministerio de Educaci�n
Universidad Nacional de La Plata
");
$sheet->oooSet("text-size", 10);
$pos++;
#$sheet->set_colwidth (1, 2000);
$sheet->oooSet("cell-loc", 1, $pos);
$sheet->oooData("cell-text", "Nro. Inventario");
#$sheet->set_colwidth (2, 1000);
$sheet->oooSet("cell-loc", 2, $pos);
$sheet->oooData("cell-text", "Autor");
#$sheet->set_colwidth (4, 4000);
$sheet->oooSet("cell-loc", 3, $pos);
$sheet->oooData("cell-text", "T�tulo");
#$sheet->set_colwidth (5, 10000);
$sheet->oooSet("cell-loc", 4, $pos);
$sheet->oooData("cell-text", "Edic.");
$sheet->oooSet("cell-loc", 5, $pos);
$sheet->oooData("cell-text", "Editor");
$sheet->oooSet("cell-loc", 6, $pos);
$sheet->oooData("cell-text", "A�o");
$sheet->oooSet("cell-loc", 7, $pos);
$sheet->oooData("cell-text", "Signatura Topogr�fica");
#$sheet->set_colwidth (9, 1000);
$sheet->oooSet("bold", "off");

$pos++;
##@$results[$i]->



#Datos
for(my $i = 0 ; $i <= $#{$results} ; $i++)
{
if ( @$results[$i]) {

	##Lleno los datos
	$sheet->oooSet("cell-loc", 1, $pos);
	$sheet->oooData("cell-text", @$results[$i]->{'barcode'});

	$sheet->oooSet("cell-loc", 7, $pos);
	$sheet->oooData("cell-text", @$results[$i]->{'bulk'});
	
	$sheet->oooSet("cell-loc", 2, $pos);
	$sheet->oooData("cell-text", @$results[$i]->{'author'}->{'completo'});
	
	$sheet->oooSet("cell-loc", 3, $pos);
	if(@$results[$i]->{'unititle'} eq ""){$sheet->oooData("cell-text", @$results[$i]->{'title'});}
	else{	my $titulo=@$results[$i]->{'title'}.": ".@$results[$i]->{'unititle'};
		$sheet->oooData("cell-text", $titulo);}

	$sheet->oooSet("cell-loc", 4, $pos);
	$sheet->oooData("cell-text", @$results[$i]->{'number'});
	
	$sheet->oooSet("cell-loc", 5, $pos);
	$sheet->oooData("cell-text", @$results[$i]->{'publisher'});
	
	$sheet->oooSet("cell-loc", 6, $pos);
	$sheet->oooData("cell-text", @$results[$i]->{'publicationyear'});


}
$pos++;
}
##
my $name="inventario-".$nro_socio;
 $sheet->oooGenerate($name);
return($name);

}


#Genera la planilla del reporte  "Estantes"

sub generar_planilla_estantes {
my ($results,$nro_socio,$shelfname) = @_;

my $titulostot=0;
my $ejemplarestot=0;
my $unavailabletot=0;
my $forloantot=0;
my $notforloantot=0;


## - start sxc document
#Genero la hoja de calculo Openoffice
my $sheet=new ooolib("sxc");

$sheet->oooSet("builddir","./plantillas");
$sheet->oooSet("title","Reporte de Estantes");
$sheet->oooSet("author","KOHA");
$sheet->oooSet("subject","Reporte");
$sheet->oooSet("bold", "on");
my $pos=1;
$sheet->oooSet("text-size", 12);
$sheet->oooSet("cell-loc", 1, $pos);
$sheet->oooData("cell-text", $shelfname );
$sheet->oooSet("text-size", 10);
$pos++;

$sheet->oooSet("cell-loc", 1, $pos);
$sheet->oooData("cell-text", "Estantes");
$sheet->oooSet("cell-loc", 2, $pos);
$sheet->oooData("cell-text", "T�tulos");
$sheet->oooSet("cell-loc", 3, $pos);
$sheet->oooData("cell-text", "Ejemplares");
$sheet->oooSet("cell-loc", 4, $pos);
$sheet->oooData("cell-text", "No Disponibles");
$sheet->oooSet("cell-loc", 5, $pos);
$sheet->oooData("cell-text", "Para Prestar");
$sheet->oooSet("cell-loc", 6, $pos);
$sheet->oooData("cell-text", "Para Sala");
$sheet->oooSet("bold", "off");
$pos++;
##


#Datos
for(my $i = 0 ; $i <= $#{$results} ; $i++)
{
if ( @$results[$i]) {
	##Lleno los datos
	 $sheet->oooSet("cell-loc", 1, $pos);
	 $sheet->oooData("cell-text", @$results[$i]->{'shelfname'});
	 $sheet->oooSet("cell-loc", 2, $pos);
         $sheet->oooData("cell-float", @$results[$i]->{'titulos'});
	 $sheet->oooSet("cell-loc", 3, $pos);
	 $sheet->oooData("cell-float", @$results[$i]->{'ejemplares'});
	 $sheet->oooSet("cell-loc", 4, $pos);
         $sheet->oooData("cell-float", @$results[$i]->{'unavailable'});
	 $sheet->oooSet("cell-loc", 5, $pos);
         $sheet->oooData("cell-float", @$results[$i]->{'forloan'});
	 $sheet->oooSet("cell-loc", 6, $pos);
	 $sheet->oooData("cell-float", @$results[$i]->{'notforloan'});
	##

	#Sumas totales
	$titulostot+=@$results[$i]->{'titulos'};
	$ejemplarestot+=@$results[$i]->{'ejemplares'};
	$unavailabletot+=@$results[$i]->{'unavailable'};
	$forloantot+=@$results[$i]->{'forloan'};
	$notforloantot+=@$results[$i]->{'notforloan'};

}
$pos++;
}

#TOTALES
	
	$sheet->oooSet("bold", "on");
	$sheet->oooSet("cell-loc", 1, $pos);
	$sheet->oooData("cell-text", "Totales");
	$sheet->oooSet("cell-loc", 2, $pos);
	$sheet->oooData("cell-float", $titulostot);
	$sheet->oooSet("cell-loc", 3, $pos);
	$sheet->oooData("cell-float", $ejemplarestot);
	$sheet->oooSet("cell-loc", 4, $pos);
	$sheet->oooData("cell-float", $unavailabletot);
	$sheet->oooSet("cell-loc", 5, $pos);
	$sheet->oooData("cell-float", $forloantot);
	$sheet->oooSet("cell-loc", 6, $pos);
	$sheet->oooData("cell-float", $notforloantot);
        $sheet->oooSet("bold", "off");
	$pos++;

#


my $name="estantes-".$nro_socio;
 $sheet->oooGenerate($name);
return($name);
}



#Genera la planilla del reporte  "Usuarios por Categor�a"

sub generar_planilla_usuario {
	my ($results,$nro_socio) = @_;
#Genero la hoja de calculo Openoffice
## - start sxc document
#Genero la hoja de calculo Openoffice
my $sheet=new ooolib("sxc");
$sheet->oooSet("builddir","./plantillas");
$sheet->oooSet("title",C4::AR::Filtros::i18n("Estadadística Usuarios por categoría"));
$sheet->oooSet("author","KOHA");
$sheet->oooSet("subject",C4::AR::Filtros::i18n("Estadistica"));
$sheet->oooSet("bold", "on");
my $pos=1;
$sheet->oooSet("text-size", 11);
$sheet->oooSet("cell-loc", 1, $pos);
$sheet->oooData("cell-text", C4::AR::Filtros::i18n("Ministerio de Educación
Universidad Nacional de La Plata
"));
$sheet->oooSet("text-size", 10);
$pos++;
$sheet->oooSet("cell-loc", 1, $pos);
$sheet->oooData("cell-text", "Categoría");
$sheet->oooSet("cell-loc", 2, $pos);
$sheet->oooData("cell-text", C4::AR::Filtros::i18n("Cantidad de Usuarios Reales"));
$sheet->oooSet("cell-loc", 3, $pos);
$sheet->oooData("cell-text", C4::AR::Filtros::i18n("Cantidad de Usuarios Potenciales"));
$sheet->oooSet("bold", "off");
$pos++;
##

#Datos
foreach my $prestamo (@$results){
	$sheet->oooSet("cell-loc", 1, $pos);
	$sheet->oooData("cell-text", $prestamo->categoria->description);
	$sheet->oooSet("cell-loc", 2, $pos);
	$sheet->oooData("cell-text", $prestamo->agregacion_temp);
# FIXME falta calcular potenciales en userEst.pl
# 	$sheet->oooSet("cell-loc", 3, $pos);
# 	$sheet->oooData("cell-text", @$results[$i]->{'potenciales'});
   $pos++;
}

my $name='usuarioEstadistica-'.$nro_socio;
$sheet->oooGenerate($name);
return($name);
}

#Genera la planilla del reporte  "Inventario Signatura Topograficca"

sub generar_planilla_inventario_sig_top {
my ($results,$nro_socio) = @_;
#Genero la hoja de calculo Openoffice
## - start sxc document

#Genero la hoja de calculo Openoffice
my $sheet=new ooolib("sxc");
$sheet->oooSet("builddir","./plantillas");
$sheet->oooSet("title","Reporte de Inventario (Signatura topogr�fica)");
$sheet->oooSet("author","KOHA");
$sheet->oooSet("subject","Reporte");
$sheet->oooSet("bold", "on");
my $pos=1;
$sheet->oooSet("text-size", 11);
$sheet->oooSet("cell-loc", 1, $pos);
$sheet->oooData("cell-text", "Ministerio de Educaci�n
Universidad Nacional de La Plata
");
$sheet->oooSet("text-size", 10);
$pos++;
#$sheet->set_colwidth (1, 2000);
$sheet->oooSet("cell-loc", 1, $pos);
$sheet->oooData("cell-text", "Nro. Inventario");
#$sheet->set_colwidth (2, 1000);
$sheet->oooSet("cell-loc", 2, $pos);
$sheet->oooData("cell-text", "Autor");
#$sheet->set_colwidth (4, 4000);
$sheet->oooSet("cell-loc", 3, $pos);
$sheet->oooData("cell-text", "T�tulo");
#$sheet->set_colwidth (5, 10000);
$sheet->oooSet("cell-loc", 4, $pos);
$sheet->oooData("cell-text", "Edic.");
$sheet->oooSet("cell-loc", 5, $pos);
$sheet->oooData("cell-text", "Editor");
$sheet->oooSet("cell-loc", 6, $pos);
$sheet->oooData("cell-text", "A�o");
$sheet->oooSet("cell-loc", 7, $pos);
$sheet->oooData("cell-text", "Signatura Topogr�fica");
#$sheet->set_colwidth (9, 1000);
$sheet->oooSet("bold", "off");

$pos++;
##



#Datos
for(my $i = 0 ; $i <= $#{$results} ; $i++)
{
if ( @$results[$i]) {
##Lleno los datos
	$sheet->oooSet("cell-loc", 1, $pos);
	$sheet->oooData("cell-text", @$results[$i]->{'barcode'});

	$sheet->oooSet("cell-loc", 7, $pos);
	$sheet->oooData("cell-text", @$results[$i]->{'bulk'});
	
	$sheet->oooSet("cell-loc", 2, $pos);
	$sheet->oooData("cell-text", @$results[$i]->{'author'}->{'completo'});
	
	$sheet->oooSet("cell-loc", 3, $pos);
	if(@$results[$i]->{'unititle'} eq ""){$sheet->oooData("cell-text", @$results[$i]->{'title'});}
	else{	my $titulo=@$results[$i]->{'title'}.": ".@$results[$i]->{'unititle'};
		$sheet->oooData("cell-text", $titulo);}

	$sheet->oooSet("cell-loc", 4, $pos);
	$sheet->oooData("cell-text", @$results[$i]->{'number'});
	
	$sheet->oooSet("cell-loc", 5, $pos);
	$sheet->oooData("cell-text", @$results[$i]->{'publisher'});
	
	$sheet->oooSet("cell-loc", 6, $pos);
	$sheet->oooData("cell-text", @$results[$i]->{'publicationyear'});

}
$pos++;
}
##
my $name="inventario-sig-top-".$nro_socio;
 $sheet->oooGenerate($name);
return($name);

}

END { }       # module clean-up code here (global destructor)

1;
__END__