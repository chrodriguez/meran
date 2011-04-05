package C4::AR::PdfGenerator;

use strict;
require Exporter;
use C4::Context;
use PDF::Report;

# use PDF::API2;
use C4::AR::Usuarios;
use HTML::HTMLDoc;

use vars qw($VERSION @ISA @EXPORT_OK);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);

#
# don't forget MARCxxx subs are exported only for testing purposes. Should not be used
# as the old-style API and the NEW one are the only public functions.
#
@EXPORT_OK = qw(
  &searchGenerator
  &availPdfGenerator
  &searchShelfGenerator
  &shelfContentsGenerator
  &estadisticasPdfGenerator
  &hitoricoPrestamosPdfGenerator
  &cardGenerator
  &batchCardsGenerator
  &generateCard
  &libreDeuda
  &prestInterBiblio
  &generateBookLabel
  &batchBookLabelGenerator
  &pdfFromHTML
  &pdfHeader
  &printPDF
);

sub newPdf {
	my $pdf =
	  new PDF::Report( PageSize => "A4", PageOrientation => 'Portrait' );
	return $pdf;
}

sub searchGenerator {
	my ( $from, @results ) = @_;
	my $pdf = newPdf();
	my $pos;
	my $msg  = "Resultado de la búsqueda: ";
	my $msg2 = "Biblioteca: ";
	my $text;
	my $line = 36;
	my $page = 0;
	foreach my $res (@results) {
		( $pdf, $pos, $page, $line ) =
		  imprimirLinea( $pdf, $pos, $msg, $msg2, $line, $page )
		  ;    # Se puso la parte de
		if ( $from eq 'shelfs' ) {
			if ( $res->{'nameparent'} ) {
				$text = $res->{'nameparent'} . ' / ' . $res->{'shelfname'};
			}
			else {
				$text = $res->{'shelfname'};
			}
		}
		elsif ( $res->{'analyticalnumber'} ) {
			my @anaut = C4::AR::AnalysisBiblio::getanalyticalautors(
				$res->{'analyticalnumber'} );
			$text = '';
			foreach my $aut (@anaut) {
				$text .= $aut->{'completo'};
			}
			my $autorppal = $res->{'completo'};
			$text .= ' - '
			  . $res->{'analyticaltitle'} . ' EN: '
			  . $autorppal . ' - '
			  . $res->{'title'}
			  . ' (Solicitar por '
			  . $res->{'firstbulk'} . ')';
		}
		else {
			my $autorppal = $res->{'completo'};

			$text =
			    $autorppal . ' - '
			  . $res->{'title'}
			  . ' (Solicitar por '
			  . $res->{'firstbulk'} . ')';
		}
		( $pdf, $line, $pos ) = imprimirLinea2( $pdf, $text, $line, $pos );
	}    #for each
	my $tmpFileName = "search.pdf";
	imprimirFinal( $pdf, $tmpFileName );
}

sub shelfContentsGenerator {
	my ( $shelfname, @results ) = @_;
	my $pdf = newPdf();
	my $pos;
	my $text;
	my $line = 36;
	my $page = 0;
	my $msg2 = "Biblioteca: ";
	my $msg  = "Contenido del Estante Virtual : " . $shelfname;
	foreach my $res (@results) {
		( $pdf, $pos, $page, $line ) =
		  imprimirLinea( $pdf, $pos, $msg, $msg2, $line, $page );
		$text =
		    $res->{'author'} . ' - '
		  . $res->{'title'}
		  . ' (Solicitar por '
		  . $res->{'firstbulk'} . ')';
		( $pdf, $line, $pos ) = imprimirLinea2( $pdf, $text, $line, $pos );
	}    #for each
	my $tmpFileName = "shelfContents.pdf";
	imprimirFinal( $pdf, $tmpFileName );
}

sub searchShelfGenerator {
	my (@results) = @_;
	my $pdf = newPdf();
	my $pos;
	my $msg  = "Estantes virtules";
	my $msg2 = "Biblioteca: ";
	my $text;
	my $line = 36;
	my $page = 0;
	foreach my $res (@results) {
		( $pdf, $pos, $page, $line ) =
		  imprimirLinea( $pdf, $pos, $msg, $msg2, $line, $page );
		if ( $res->{'nameparent'} ) {
			$text = $res->{'nameparent'} . ' / ' . $res->{'shelfname'};
		}
		else {
			$text = $res->{'shelfname'};
		}
		( $pdf, $line, $pos ) = imprimirLinea2( $pdf, $text, $line, $pos );
	}    #for each
	my $tmpFileName = "searchShelf.pdf";
	imprimirFinal( $pdf, $tmpFileName );
}

sub availPdfGenerator {
	my ( $msg, @results ) = @_;
	my $msg2 = "Biblioteca: ";
	my $pdf  = newPdf();
	my $text;
	my $line = 36;
	my $pos;
	my $page = 0;

	foreach my $res (@results) {
		( $pdf, $pos, $page, $line ) =
		  imprimirLinea( $pdf, $pos, $msg, $msg2, $line, $page );
		$text =
		    $res->{'autor'} . ' - '
		  . $res->{'titulo'}
		  . ' - Signatura: '
		  . $res->{'signatura_topografica'}
		  . ' Cod.: '
		  . $res->{'barcode'}
		  . ' Fecha: '
		  . $res->{'date'};

		( $pdf, $line, $pos ) = imprimirLinea2( $pdf, $text, $line, $pos );
	}    #for each
	my $tmpFileName = "availsearch.pdf";
	imprimirFinal( $pdf, $tmpFileName );
}

#Genera el PDF de las estadisticas que se generan en la pagina estadisticas.pl - Damian
sub estadisticasPdfGenerator {
	my ( $msg, @results ) = @_;
	my $pdf = newPdf();
	my $pos;
	my $msg2   = "Biblioteca: ";
	my $blanco = "                ";
	my @text;
	my $line = 36;
	my $page = 0;
	( $pdf, $pos, $page, $line ) =
	  imprimirLinea( $pdf, $pos, $msg, $msg2, $line, $page );
	$text[0] = "Por Usuario: ";
	$text[1] =
	    $blanco
	  . "Prestamos: "
	  . $results[6]
	  . " Reservas: "
	  . $results[8]
	  . " Renovados: "
	  . $results[7];
	$text[2] = "Por Domiciliarios: ";
	$text[3] =
	    $blanco
	  . "Total: "
	  . $results[0]
	  . " Renovados: "
	  . $results[1]
	  . " Devueltos: "
	  . $results[2];
	$text[4] = "Por Sala: " . $results[3];
	$text[5] = "Por Fotocopia: " . $results[4];
	$text[6] = "Por Especial: " . $results[5];
	my $i;
	my $texto;

	for ( $i = 0 ; $i <= 6 ; $i++ ) {
		$texto = $text[$i];
		( $pdf, $line, $pos ) = imprimirLinea2( $pdf, $texto, $line, $pos );
	}
	my $tmpFileName = "estadisticas.pdf";
	imprimirFinal( $pdf, $tmpFileName );
}

#Miguel 31-05/07 - Genero el PDF de Historico de Prestamos
sub hitoricoPrestamosPdfGenerator {
	my ( $msg, @results ) = @_;
	my $pdf = newPdf();
	my $pos;
	my $msg2 = "Biblioteca: ";
	my $text;
	my $line = 36;
	my $page = 0;
	( $pdf, $pos, $page, $line ) =
	  imprimirLinea( $pdf, $pos, $msg, $msg2, $line, $page );

	#Se recorre el restultado y se arma el texto por linea para mostrar
	my $texto;
	foreach my $res (@results) {
		$texto =
		    $res->{'firstname'} . ' - '
		  . $res->{'surname'} . ' - '
		  . $res->{'DNI'} . ' - '
		  . $res->{'CatUsuario'} . ' - '
		  . $res->{'tipoPrestamo'} . ' - '
		  . $res->{'barcode'} . ' - '
		  . $res->{'fechaPrestamo'} . ' - '
		  . $res->{'fechaDevolucion'} . ' - '
		  . $res->{'tipoItem'};

		#Muestra la linea
		( $pdf, $line, $pos ) = imprimirLinea2( $pdf, $texto, $line, $pos );
	}
	my $tmpFileName = "historicoPrestamos.pdf";

	#Se crea el archivo .PDF
	imprimirFinal( $pdf, $tmpFileName );
}

#Damian - 22/05/2007
#Funcion generica que sirve para imprimir las lineas se usa en todos los generadores de pdf
sub imprimirLinea {
	my ( $pdf, $pos, $msg, $msg2, $line, $page ) = @_;
	my $pagewidth;
	my $pageheight;
	if ( $line > 35 ) {
		$line = 0;
		$pos  = 810;
		$pdf->newpage(1);
		$page++;
		$pdf->openpage($page);
		( $pagewidth, $pageheight ) = $pdf->getPageDimensions();
		$pdf->setFont("Verdana");
		$pdf->setSize(16);
		$pdf->addRawText( $msg2, 180, $pos );
		$pdf->setSize(12);
		$pos = $pos - 15;
## FIXME esta funcion es llamada dentro de un loop, de manera q consulta demasiado a la base a travez del ##context(), o sea q estos valores se deben recibir como parametro
		$pdf->addImg(
			C4::AR::Preferencias::getValorPreferencia('opacdir')
			  . '/htdocs/opac-tmpl/'
			  . C4::AR::Preferencias::getValorPreferencia('opacthemes') . '/'
			  . C4::AR::Preferencias::getValorPreferencia('opaclanguages')
			  . '/images/escudo-print.png',
			500,
			$pageheight - 77
		);
		$pdf->setFont("Verdana");
		$pdf->setSize(10);
		$pos = $pos - 40;
		$pdf->addParagragh( $msg, 25, $pos + 20, 550, 20, 30 );
		$pdf->drawLine( 25, $pos + 12, 570, $pos + 12 );
	}
	return ( $pdf, $pos, $page, $line );
}

#Damian - 22/05/2007
#Funcion generica que sirve para imprimir las lineas se usa en todos los generadores de pdf
sub imprimirLinea2 {
	my ( $pdf, $text, $line, $pos ) = @_;

	if ( length($text) < 100 ) {
		$pdf->addParagragh( $text, 25, $pos, 550, 20, 30 );
		$line++;
		$pdf->drawLine( 25, $pos - 5, 570, $pos - 5 );
		$pos = $pos - 19;
	}
	else {
		my $blank = index( $text, ' ', 100 );
		if ( $blank < 0 ) {
			$blank = length($text);
		}
		my $index = 0;
		while ( ( $blank < length($text) ) and ( $blank > 0 ) ) {
			my $size = $blank - $index;
			my $substr = substr( $text, $index, $size );
			$pdf->addParagragh( $substr, 25, $pos, 550, 20, 30 );
			$line++;
			$pos   = $pos - 10;
			$index = $blank;
			if ( $blank + 90 < length($text) ) {
				$blank = index( $text, ' ', $blank + 100 );
			}
			else {
				$blank = length($text);
			}
		}
		my $substr = substr( $text, $index, length($text) - $index );
		$pdf->addParagragh( $substr, 25, $pos, 550, 20, 30 );
		$line++;
		$pdf->drawLine( 25, $pos - 5, 570, $pos - 5 );
		$pos = $pos - 20;
	}
	return ( $pdf, $line, $pos );
}

#Para imprimir el archivo con el nombre. Funcion generica que se puede usar en todos las funciones
#que generan pdf - Damian - 23/05/2007
sub imprimirFinal {
	my ( $pdf, $tmpFileName ) = @_;

# OLD WAY
# 	print "Content-type: application/pdf\n";
# 	print "Content-Disposition: attachment; filename=\"$tmpFileName\"\n\n";
# 	print $pdf->Finish();

my $filename='/tmp/'.$tmpFileName;
 $pdf->saveAs($filename);
 print C4::AR::PdfGenerator::pdfHeader($filename);
 C4::AR::PdfGenerator::printPDF($filename);

}

################CARNETS############################################33

sub completeBorrowerNumber {
	my ($bornum) = @_;
	my $str      = "";
	my $i        = 0;
	my $aux;
	while ( $bornum > 0 ) {
		$aux    = $bornum % 10;
		$str    = $aux . $str;
		$bornum = ( $bornum - ( $bornum % 10 ) ) / 10;
		$i++;
	}

	while ( $i < 11 ) {
		$str = "0" . $str;
		$i++;
	}
	return ($str);
}

sub cardGenerator {
	my ($nro_socio) = @_;
	my $pdf = newPdf();
	$pdf->newpage(1);
	$pdf->openpage(1);

	#Hoja A4 :  X diferencia 254 - Y diferencia 160
	#     $nro_socio = C4::AR::Usuarios::getSocioInfo(id => $nro_socio);
	generateCard( $nro_socio, 14, 14, $pdf );
	return ($pdf);
}

#  Genera los carnets a partir de una busqueda

sub batchCardsGenerator {
	my ( $count, $socios ) = @_;

	#   my $cantidad=$count;
	#   my $hojas= $count / 8;
	my $i   = 0;
	my $pag = 1;
	my $pdf = newPdf;

	while ( $i < $count ) {
		$pdf->newpage($pag);
		$pdf->openpage($pag);

		#Hoja A4 :  X diferencia 254 - Y diferencia 160
		if ( $i < $count ) {
			generateCard( @$socios[$i]->getNro_socio, 14, 14, $pdf );
			$i++;
		}
		if ( $i < $count ) {
			generateCard( @$socios[$i]->getNro_socio, 14, 174, $pdf );
			$i++;
		}
		if ( $i < $count ) {
			generateCard( @$socios[$i]->getNro_socio, 14, 334, $pdf );
			$i++;
		}
		if ( $i < $count ) {
			generateCard( @$socios[$i]->getNro_socio, 14, 494, $pdf );
			$i++;
		}
		if ( $i < $count ) {
			generateCard( @$socios[$i]->getNro_socio, 14, 654, $pdf );
			$i++;
		}
		if ( $i < $count ) {
			generateCard( @$socios[$i]->getNro_socio, 270, 14, $pdf );
			$i++;
		}
		if ( $i < $count ) {
			generateCard( @$socios[$i]->getNro_socio, 270, 174, $pdf );
			$i++;
		}
		if ( $i < $count ) {
			generateCard( @$socios[$i]->getNro_socio, 270, 334, $pdf );
			$i++;
		}
		if ( $i < $count ) {
			generateCard( @$socios[$i]->getNro_socio, 270, 494, $pdf );
			$i++;
		}
		if ( $i < $count ) {
			generateCard( @$socios[$i]->getNro_socio, 270, 654, $pdf );
			$i++;
		}
		$pag++;
	}
	my $tmpFileName = "carnets.pdf";
	&imprimirFinal( $pdf, $tmpFileName );
}

#genera a partir de una coordenada
sub generateCard {
	my ( $nro_socio, $x, $y, $pdf ) = @_;
	my $phone;

	#Datos del usuario
	my $socio = &C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);

	#     open A,">>/tmp/debug.txt";
	#     print A "ID_SOCIO:   ".$socio->persona->getApellido;
	#     close A;

	my ( $pagewidth, $pageheight ) = $pdf->getPageDimensions();
	$pdf->setSize(7);
	my $picturesDir = C4::Context->config("picturesdir");
	my $foto        = undef;
	if ( opendir( DIR, $picturesDir ) ) {
		my $pattern = $nro_socio . ".*";
		my @file = grep { /$pattern/ } readdir(DIR);
		$foto = join( "", @file ) if scalar(@file);
		closedir DIR;
	}

  #    if ($foto){
  #         $pdf->addImg($picturesDir.'/'.$foto, $x+154, $pageheight - ($y+75));
  #    } else {
	$pdf->drawRect( $x + 154, $pageheight - ( $y - 10 ),
		$x + 239, $pageheight - ( $y + 75 ) );
	$pdf->addRawText( "3 x 3 cm.", $x + 176, $pageheight - ( $y + 36 ) );

	#   }

	####

	#Insert a rectangle to delimite the card
	$pdf->drawRect( $x - 12, $pageheight - ( $y - 12 ),
		$x + 241, $pageheight - ( $y + 142 ) )
	  ;    # 9x5,5 cm = 3.51x2.145 inches = 253x154 pdf-units

	#Insert a barcode to the card
	$pdf->drawBarcode( $x + 19, $pageheight - ( $y + 146 ),
		undef, 1, "3of9", $socio->getNro_socio, undef, 10, 10, 30, 10 );

	#Write the borrower data into the pdf file
	$pdf->setSize(7);
	$pdf->setFont("Arial-Bold");
	$pdf->addRawText( _unformat( uc( $socio->categoria->getDescription ) ),
		$x, $pageheight - ( $y + 4 ) );
	$pdf->addRawText( _unformat( uc( $socio->ui->getNombre ) ),
		$x, $pageheight - ( $y + 11 ) );
	$pdf->addRawText( "BIBLIOTECA", $x, $pageheight - ( $y + 18 ) );
	$pdf->setFont("Arial");
	$pdf->setSize(6);

	my $address = _unformat( $socio->ui->getDireccion );
	$pdf->addRawText( $address, $x, $pageheight - ( $y + 25 ) );
	use locale;

	#     FIXME falta FAX, blabla
	$phone = $socio->ui->getTelefono;
	$pdf->addRawText( $phone, $x, $pageheight - ( $y + 31 ) );
	$pdf->setSize(8);
	$pdf->addRawText( "Apellido: " . _unformat( $socio->persona->getApellido ),
		$x + 4, $pageheight - ( $y + 57 ) );
	$pdf->addRawText( "Nombre: " . _unformat( $socio->persona->getNombre ),
		$x + 4, $pageheight - ( $y + 65 ) );
	$pdf->addRawText(
		"Tipo de Lector: " . _unformat( $socio->categoria->getDescription ),
		$x + 4, $pageheight - ( $y + 73 ) );
	$pdf->addRawText(
		""
		  . _unformat( $socio->persona->documento->getNombre ) . ":"
		  . _unformat( $socio->persona->getNro_documento ),
		$x + 4,
		$pageheight - ( $y + 81 )
	);
}
#############FIN CARNET########################
sub _format {
	my ($string) = @_;

	$string = Encode::decode_utf8( Encode::encode_utf8($string) );
	return ($string);
}

sub _unformat {
    my ($string) = @_;

    $string = Encode::decode_utf8($string);
    return ($string);
}

sub _formatArrayOfStrings {
	my ($array) = @_;

	foreach my $string (@$array) {
		$string = _format($string);
	}

	return ($array);
}

=item
datosBiblio
Busca todos los datos de la biblioteca en que se encuentra asociado el usuario.
Nota: branchaddress3, se va usar para guardar la direccion web de la biblioteca.
=cut

sub datosBiblio {

	my ($branchcode) = @_;
	my $biblio = 0;

	eval {
		$biblio =
		  C4::Modelo::PrefUnidadInformacion->new( id_ui => $branchcode );
		$biblio->load();
	};

	return ($biblio);
}

=item
libreDeuda
Genera y muestar la ventana para imprimir el documento de libre deuda.
=cut

sub libreDeuda {
	my ($socio) = shift;
	my $tmpFileName = "libreDeuda_" . $socio->getNro_socio . ".pdf";

	my $nombre = $socio->persona->getApeYNom;
	my $dni    = $socio->persona->getNro_documento;

	my $categ = $socio->categoria->getDescription;

	my $branchname = $socio->ui->getNombrePDF;

	my ( $pdf, $pagewidth, $pageheight ) = &inicializarPDF();

	my $x = 50;
	my $y =
	  300;  #pos 'y' a partir de donde se van a escribir la parte del contenido.
	my %titulo;
	$titulo{'titulo'} = "CERTIFICADO DE LIBRE DEUDA";
	$titulo{'posx'}   = 170;
	my @parrafo;
	$parrafo[0] =
	  Encode::decode_utf8( "       Certificamos que " 
		  . $nombre
		  . ", de la "
		  . $branchname
		  . ", " );
	$parrafo[1] =
	  Encode::decode_utf8( " con numero de documento " 
		  . $dni
		  . ", no adeuda material bibliográfico en esta Biblioteca." );
	$parrafo[2] = Encode::decode_utf8(
"       Se extiende el presente certificado para ser presentado ante quién corresponda, con una"
	);
	$parrafo[3] = Encode::decode_utf8(
		" validez de 10 días corridos a partir de su fecha de emisión.");

	($pdf) =
	  &imprimirEncabezado( $pdf, $categ, $branchname, $x, $pagewidth,
		$pageheight, \%titulo, );
	( $pdf, $y ) =
	  &imprimirContenido( $pdf, $x, $y, $pageheight, 15, \@parrafo );
	( $pdf, $y ) = &imprimirFirma( $pdf, $y + 50, $pageheight );
	&imprimirFinal( $pdf, $tmpFileName );
}

=item
prestInterBiblio
Genera y muestra la ventana para imprimir el documento de prestamos interbibliotecarios.
=cut

sub prestInterBiblio {
	my ( $nro_socio, $socio, $biblioDestino, $director, $datos ) = @_;

	my $tmpFileName = "prestInterBiblio" . $nro_socio . ".pdf";
	my $nombre      = $socio->persona->getApeYNom;
	my $dni         = $socio->persona->getNro_documento;
	my $branchcode  = $socio->getId_ui;
	my $biblio      = &datosBiblio($branchcode);
	my $categ       = $biblio->{'categ'};
	my $branchname  = $biblio->{'branchname'};

	my ( $pdf, $pagewidth, $pageheight ) = &inicializarPDF();

	my $x = 50;
	my $y = 300;
	my %titulo;
	$titulo{'titulo'} = ("SOLICITUD DE PRESTAMO INTERBIBLIOTECARIO");
	$titulo{'posx'}   = 100;
	my @parrafo;
	$parrafo[0] = ("Sr. Director de la Biblioteca");
	$parrafo[1] = ( "de la " . Encode::decode_utf8($biblioDestino) );
	$parrafo[2] = (Encode::decode_utf8($director));
	$parrafo[3] = ("S/D");
	$parrafo[4] = (
"          Tengo el agrado de dirigirme a Ud. a fin de solicitarle en carácter de préstamo"
	);
	$parrafo[5] = "interbibliotecario los siguientes items:";

	($pdf) =
	  &imprimirEncabezado( $pdf, $categ, $branchname, $x, $pagewidth,
		$pageheight, \%titulo );
	( $pdf, $y ) =
	  &imprimirContenido( $pdf, $x, $y, $pageheight, 15, \@parrafo );
	my $cant = scalar(@$datos);
	( $pdf, $y ) = &imprimirTabla( $pdf, $y, $pageheight, $cant, $datos );

	$parrafo[0] = ("La(s) misma(s) sería(n) retirada(s) por:");
	$parrafo[1] = ("Nombre y apellido: ").$nombre;
	$parrafo[2] = ("DNI:") . $dni;
	$parrafo[3] =
	    ("Dirección:")
	  . $socio->persona->getCalle . ", "
	  . $socio->persona->ciudad_ref->getNombre;
	$parrafo[4] = ("Teléfono:") . $socio->persona->getTelefono;
	$parrafo[5] = ("Correo electrónico:") . $socio->persona->getEmail;
	$parrafo[6] = "";
	$parrafo[7] = (
"          Sin otro particular y agradeciendo desde ya su amabilidad, saludo a Ud. muy"
	);
	$parrafo[8] = ("atentamente.");
	
	
	_formatArrayOfStrings( \@parrafo );

	( $pdf, $y ) = &imprimirContenido( $pdf, $x, $y, $pageheight, 15, \@parrafo );
	( $pdf, $y ) = &imprimirFirma( $pdf, $y, $pageheight );
	$y = $y + 15;
	$pdf->drawLine( 50, $pageheight - $y, $pagewidth - 50, $pageheight - $y );
	$pdf = &imprimirPiePag( $pdf, $y, $pageheight, $biblio );
	&imprimirFinal( $pdf, $tmpFileName );
}

=item
inicializarPDF
Crea un objeto pdf, lo devuelve, junto con la longitud de ancho ($pagewidth) y largo ($pageheight) que va a tener el documento.
=cut

sub inicializarPDF {
	my $pdf = newPdf();
	$pdf->newpage(1);
	$pdf->openpage(1);
	my ( $pagewidth, $pageheight ) = $pdf->getPageDimensions();
	return ( $pdf, $pagewidth, $pageheight );
}

=item
imprimirEncabezado
Imprime el encabezado del documento, con el escudo del la universidad nacional de la plata.
@params:
    $pdf, objeto que representa al documeto, donde se guardan los datos a imprimir;
    $categ, categoria de la institucion en la que se va a imprimir el documento;
    $branchname, nombre de la biblioteca en la que esta asociado el usuario que pidio el documento;
    $x, tamao de la sangria. A partir de donde se va a escribir en el renglon;
    $pagewidth, ancho del documento;
    $pageheight, largo del documento;
    $titulo, Titulo del documento;
=cut

sub imprimirEncabezado {
	my ( $pdf, $categ, $branchname, $x, $pagewidth, $pageheight, $titulo ) = @_;

	#fecha
	my @datearr = localtime(time);
	my $anio    = 1900 + $datearr[5];
	my $mes     = &C4::Date::mesString( $datearr[4] + 1 );
	my $dia     = $datearr[3];

	#fin fecha
	C4::AR::Debug::debug( C4::Context->config('intrahtdocs') . '/'
		  . C4::AR::Preferencias::getValorPreferencia('template')
		  . '/images/escudo-uni.png' );

# FIXME si le dejo esto se rompe, como se va a cambiar el manejador de PDFs lo dejo asi
#         $pdf->addImg( C4::Context->config('intrahtdocs').'/'.C4::AR::Preferencias::getValorPreferencia('template').'/images/escudo-uni.png', $x, $pageheight - 160);
	$pdf->setFont("Arial-Bold");
	$pdf->setSize(10);
	$pdf->addRawText( uc($categ),      $x, $pageheight - 180 );
	$pdf->addRawText( uc($branchname), $x, $pageheight - 190 );
	$pdf->addRawText( "BIBLIOTECA",    $x, $pageheight - 200 );
	$pdf->setFont("Verdana-Bold");
	$pdf->setSize(14);
	#Se pone solamente Encode::decode_utf8 porque ya viene en UTF-8
	$pdf->addRawText( Encode::decode_utf8($titulo->{'titulo'}), Encode::decode_utf8($titulo->{'posx'}),
		$pageheight - 240 );
	$pdf->setFont("Verdana");
	$pdf->setSize(10);
	$pdf->addRawText(
		"La Plata, " . $dia . " de " . $mes . " de " . $anio,
		$pagewidth - 250,
		$pageheight - 270
	);
	return ($pdf);
}

=item
imprimirContenido
Imprime el contenido de del documento.
@params:
    $pdf, objeto que representa al documeto, donde se guardan los datos a imprimir;
    $x, tamao de la sangria. A partir de donde se va a escribir en el renglon;
    $y, cantidad de renglones que se escribieron hasta el momento. Sirve de puntero para saber en que fila
        imprimir;
    $pageheight, largo del documento;
    $tamRenglon, tamao que va a tener el renglon. Espacio entre texto por fila;
    $parrafo, referencia al arreglo que contiene los string a imprimir en el pdf;
=cut

sub imprimirContenido {
	my ( $pdf, $x, $y, $pageheight, $tamRenglon, $parrafo ) = @_;
	for ( my $i = 0 ; $i < scalar(@$parrafo) ; $i++ ) {
		$pdf->addRawText( _format($parrafo->[$i]), $x, $pageheight - $y );
		$y = $y + $tamRenglon;
	}
	return ( $pdf, $y );
}

=item
imprimirFirma
Imprime la parte donde se pide la firma y aclaracion.
@params:
    $pdf, objeto que representa al documeto, donde se guardan los datos a imprimir;
    $y, cantidad de renglones que se escribieron hasta el momento. Sirve de puntero para saber en que fila
        imprimir;
    $pageheight, largo del documento;
=cut

sub imprimirFirma {
	my ( $pdf, $y, $pageheight ) = @_;
	my $linea = "................................";
	$y = $y + 30;
	$pdf->addRawText( $linea, 130, $pageheight - $y );
	$pdf->addRawText( $linea, 330, $pageheight - $y );
	$y = $y + 10;
	$pdf->addRawText( "Firma",                160, $pageheight - $y );
	$pdf->addRawText( _format("Aclaración"), 360, $pageheight - $y );
	return ( $pdf, $y );
}

=item
imprimirTabla
Imprime una tabla de tres columnas y n filas, dependiendo del parametro que llega.
@params:
    $pdf, objeto que representa al documeto, donde se guardan los datos a imprimir;
    $y, cantidad de renglones que se escribieron hasta el momento. Sirve de puntero para saber en que fila
        imprimir;
    $pageheight, largo del documento;
    $cantFila: cantidad de filas a generar en la tabla;
=cut

sub imprimirTabla {
	my ( $pdf, $y, $pageheight, $cantFila, $datos ) = @_;
	$pdf->setFont("Verdana-Bold");
	$pdf->setSize(12);
	$pdf->drawRect( 50, $pageheight - $y, 200, $pageheight - ( $y + 20 ) );
	$pdf->addRawText( "Autor/es", 100, $pageheight - ( $y + 15 ) );
	$pdf->drawRect( 200, $pageheight - $y, 350, $pageheight - ( $y + 20 ) );
	$pdf->addRawText( _format("Ttulo"), 255, $pageheight - ( $y + 15 ) );
	$pdf->drawRect( 350, $pageheight - $y, 500, $pageheight - ( $y + 20 ) );
	$pdf->addRawText( "Otros datos", 395, $pageheight - ( $y + 15 ) );
	$y = $y + 20;
	$pdf->setFont("Verdana");
	$pdf->setSize(11);
#Se pone solamente Encode::decode_utf8 porque ya viene en UTF-8
	for ( my $i = 0 ; $i < $cantFila ; $i++ ) {
		$pdf->drawRect( 50, $pageheight - $y, 200, $pageheight - ( $y + 20 ) );
		$pdf->addRawText( Encode::decode_utf8($datos->[$i]->{'autor'}),
			60, $pageheight - ( $y + 15 ) );
		$pdf->drawRect( 200, $pageheight - $y, 350, $pageheight - ( $y + 20 ) );
		$pdf->addRawText( Encode::decode_utf8($datos->[$i]->{'titulo'}),
			210, $pageheight - ( $y + 15 ) );
		$pdf->drawRect( 350, $pageheight - $y, 500, $pageheight - ( $y + 20 ) );
		$pdf->addRawText( Encode::decode_utf8($datos->[$i]->{'otros'}),
			360, $pageheight - ( $y + 15 ) );
		$y = $y + 20;
	}
	$y = $y + 20;
	$pdf->setSize(10);
	return ( $pdf, $y );
}

=item
imprimirPiePag
Imprime el pie de pagina del documento con la info de la biblioteca.
@params:
    $pdf, objeto que representa al documeto, donde se guardan los datos a imprimir;
    $y, cantidad de renglones que se escribieron hasta el momento. Sirve de puntero para saber en que fila
        imprimir;
    $pageheight, largo del documento;
    $biblio, referencia a una hash con los datos de la biblioteca.
=cut

sub imprimirPiePag {
	my ( $pdf, $y, $pageheight, $biblio ) = @_;
	my @texto;
	$texto[0] = _format("Biblioteca: ") . $biblio->{'branchname'};
	$texto[1] = "Calle " . $biblio->{'branchaddress1'};
	$texto[2] =
	  "Tel/Fax: " . $biblio->{'branchphone'} . "/" . $biblio->{'branchfax'};
	$texto[3] =
	    _format("Atención: lunes a viernes, ")
	  . C4::AR::Preferencias::getValorPreferencia('open') . " a "
	  . C4::AR::Preferencias::getValorPreferencia('close');
	$texto[4] = "E-mail: " . $biblio->{'branchemail'};
	$texto[5] = "Sitios web: " . $biblio->{'branchaddress3'};
	$texto[6] = "";
	$y        = $y + 15;
	( $pdf, $y ) =
	  &imprimirContenido( $pdf, 200, $y, $pageheight, 10, \@texto );
	return ($pdf);
}

#### Generar Etiquetas para Libros

#  Genera los carnets a partir de una busqueda

sub batchBookLabelGenerator {
	my ( $count, $results ) = @_;
	my $i   = 0;
	my $pag = 1;
	my $pdf = new PDF::Report();
	$pdf->{PageWidth}  = '270';
	$pdf->{PageHeight} = '190';

	foreach my $nivel3 (@$results) {
		$pdf->newpage($pag);
		$pdf->openpage($pag);
		&generateBookLabel( $nivel3->getSignatura_topografica,
			$nivel3->getBarcode, $nivel3->getId_ui_origen, 0, 97, $pdf );
		&generateBookLabel( $nivel3->getSignatura_topografica,
			$nivel3->getBarcode, $nivel3->getId_ui_origen, 0, 97, $pdf );
		$pag++;
	}
	my $tmpFileName = "etiquetas.pdf";
	&imprimirFinal( $pdf, $tmpFileName );
}

#genera a partir de una coordenada
sub generateBookLabel {
	my ( $signatura, $codigo, $branchcode, $x, $y, $pdf ) = @_;

	my $dbh = C4::Context->dbh;

	#Datos de la biblioteca
	my $branch = &datosBiblio($branchcode);

	my ( $pagewidth, $pageheight ) = $pdf->getPageDimensions();    #(200x300)
	$pdf->setSize(7);

	#Insert a rectangle to delimite the card
	$pdf->drawRect( $pagewidth, $pageheight + ( $y - 97 ), 0, $y );
	$pdf->drawLine( 95, $pageheight + ( $y - 97 ), 95, $y );

	#Insert a barcode to the card
	$pdf->drawBarcode( $x + 150, $y, 50 / 100, 1, "3of9", $codigo, undef, 10,
		10, 25, 10 );

	my $posy = 105;
	my $escudo =
	    C4::Context->config('intrahtdocs') . '/'
	  . C4::AR::Preferencias::getValorPreferencia('template') . '/'
	  . C4::AR::Preferencias::getValorPreferencia('opaclanguages')
	  . '/images/escudo-'
	  . $branchcode . '.png';

	if ( !( ( -e $escudo ) && ( -r $escudo ) ) ) {
		$escudo =
		    C4::Context->config('intrahtdocs') . '/'
		  . C4::AR::Preferencias::getValorPreferencia('template') . '/'
		  . C4::AR::Preferencias::getValorPreferencia('opaclanguages')
		  . '/images/escudo-uni.png';
	}

#      $pdf->addImgScaled($escudo, $x + 96 , $pageheight + ($y-30-$posy) , 32/100);

	#Write the borrower data into the pdf file
	$pdf->setSize(7);
	$pdf->setFont("Arial-Bold");

	#      $pdf->addRawText($branch->{'categ'},$x+135,$pageheight + ($y-$posy));
	$posy = $posy + 7;
	$pdf->addRawText( $branch->getNombre, $x + 135,
		$pageheight + ( $y - $posy ) );
	$posy = $posy + 7;
	$pdf->setSize(6);
	$pdf->addRawText( "Biblioteca", $x + 135, $pageheight + ( $y - $posy ) );
	$posy = $posy + 7;
	$pdf->setFont("Arial");

	my $cantdir = 1;                       #Cuantas direcciones tiene?
	my $address = $branch->getDireccion;
	$address .= "\n" . $branch->getAlt_direccion;
	$pdf->addRawText( $address, $x + 135, $pageheight + ( $y - $posy ) );
	$posy = $posy + ( 7 * $cantdir );

	my $mail = $branch->getEmail;
	$pdf->addRawText( $mail, $x + 135, $pageheight + ( $y - $posy ) );
	$posy = $posy + 7;

	my $phone_fax = "";
	$phone_fax = " Tel " . $branch->getTelefono || 'No dispone';
	$phone_fax = " Fax " . $branch->getFax      || 'No dispone';

	$pdf->addRawText( $phone_fax, $x + 135, $pageheight + ( $y - $posy ) );

	#AHORA DIBUJAMOS LA SIGNATURA SEPARADA POR ' '
	$pdf->setSize(14);
	$pdf->setFont("Arial-Bold");
	my @sigs = split( / /, $signatura );
	my $posicion = 0;
	foreach my $sig (@sigs) {
		$pdf->addRawText( "$sig", $x + 15,
			$pageheight + ( $y - 120 ) - $posicion );
		$posicion += 15;
	}
	$pdf->setFont("Arial");
}
#############FIN Etiquetas########################

sub pdfFromHTML {

	my ($out) = @_;
	
	$out = _unformat($out);
	
	my $htmldoc = new HTML::HTMLDoc( 'mode' => 'file', 'tmpdir' => '/tmp' );

	$htmldoc->set_html_content($out);
	$htmldoc->landscape();
	$htmldoc->set_header( 't', '.', 'D' );
	$htmldoc->color_on();
	$htmldoc->no_links();
	$htmldoc->path(C4::Context->config('intrahtdocs'));

	my $pdf = $htmldoc->generate_pdf();

	my $file_name = '/tmp/export' . time() . '.pdf';

	$pdf->to_file($file_name);

	return ($file_name);

}

sub pdfHeader {

	my ($filename) = @_;

	$filename = $filename || "report_export.pdf";

	my $session = CGI::Session->load();
	my $header =
	  $session->header( -type => 'application/pdf', -attachment => $filename );

	return ($header);

}

sub printPDF {

	my ($filename) = @_;

	open INF, $filename or die "\nCan't open $filename for reading: $!\n";

	my $buffer;

	while ( read( INF, $buffer, 65536 ) and print $buffer ) { }

	close INF;
}

END { }    # module clean-up code here (global destructor)

1;
__END__
