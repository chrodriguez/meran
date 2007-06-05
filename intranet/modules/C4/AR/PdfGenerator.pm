package C4::AR::PdfGenerator;

use strict;
require Exporter;
use C4::Context;
use PDF::Report;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
#
# don't forget MARCxxx subs are exported only for testing purposes. Should not be used
# as the old-style API and the NEW one are the only public functions.
#
@EXPORT = qw(
	&searchGenerator 
	&availPdfGenerator 
	&searchShelfGenerator 
	&shelfContentsGenerator
	&estadisticasPdfGenerator
	&hitoricoPrestamosPdfGenerator
);


sub newPdf{
	my $pdf = new PDF::Report(PageSize => "A4", PageOrientation => 'Portrait');
	return $pdf;		
}

sub searchGenerator {
	my ($from,@results)=@_;
	my $pdf=newPdf();
	my $pos;
	#my $pagewidth;
	#my $pageheight; 
	my $msg="Resultado de la busqueda: ";
	my $msg2="Biblioteca: ";
	my $text;
	my $line=36; 
	my $page=0;
	foreach my $res (@results){
=item	  if($line > 35){
			$line=0;
			$pos=800;
			$pdf->newpage(1);
			$page++;
	        	$pdf->openpage($page);
		        ($pagewidth, $pageheight) = $pdf->getPageDimensions();
		        $pdf->setFont("Verdana");
        		$pdf->setSize(22);
        		$pdf->addRawText("Biblioteca: " ,180,$pos);
        		$pdf->setSize(20);
        		$pos=$pos-20;
        		$pdf->addImg( C4::Context->config('opacdir').'/htdocs/opac-tmpl/'.C4::Context->preference('opacthemes').'/'.C4::Context->preference('opaclanguages').'/images/escudo-print.png', 500, $pageheight - 77);
		        $pdf->setFont("Verdana");
      			$pdf->setSize(10);
			 $pos=$pos-35;
		        $pdf->drawLine(25, $pos+12, 570 , $pos+12);
			}
=cut
		($pdf,$pos,$page,$line)=imprimirLinea($pdf,$pos,$msg,$msg2,$line,$page);# Se puso la parte de arriba en una funcion generica para que pueda ser usada por las otras funciones!!!! - Damian - 22/05/2007
# Si funciona sacar lo comentado que esta arriba!!!!!
		if ($from eq 'shelfs'){
			if ($res->{'nameparent'}){
				$text= $res->{'nameparent'}.' / '.$res->{'shelfname'};
			}
			else { 
				$text= $res->{'shelfname'};
			}
		}
		elsif ($res->{'analyticalnumber'}){
			my @anaut=C4::AR::AnalysisBiblio::getanalyticalautors($res->{'analyticalnumber'});
			$text='';
			foreach my $aut (@anaut){ 
				$text.= $aut->{'completo'};
			}
			my $autorppal=$res->{'completo'};
			$text.=' - '.$res->{'analyticaltitle'}.' EN: '.$autorppal.' - '. $res->{'title'}.' (Solicitar por '.$res->{'firstbulk'}.')';
		}
		else {
			my $autorppal=$res->{'completo'};

			$text= $autorppal.' - '.$res->{'title'}.' (Solicitar por '.$res->{'firstbulk'}.')';
		}
		($pdf,$line,$pos)=imprimirLinea2($pdf,$text,$line,$pos);# Funcion generica que reemplaza la parte que esta comentada abajo!!!
	#Se puede usar en todas la funciones que generan pdf!!!! - Damian 22/05/2007


=item	if (length($text) < 100){
		     $pdf->addParagragh($text, 25,$pos,550,20, 30);
		     $line++;
		     $pdf->drawLine(25, $pos-5, 570 , $pos-5);
		     $pos=$pos-19;
			}else
		       {my $blank=index($text,' ', 100);
			if ($blank<0){$blank=length($text)}
			my $index=0;	
		while (($blank < length($text))and($blank>0)){
			my $size=$blank-$index;
			my $substr= substr($text,$index ,$size);
			 $pdf->addParagragh($substr, 25,$pos,550,20, 30);
 
			$line++;
                     	 $pos=$pos-10;
			$index=$blank;
			if($blank+90 < length($text)) {$blank=index($text,' ',$blank+100);}else{$blank=length($text);}
		   				}
			  my $substr= substr($text,$index ,length($text)-$index);
                         $pdf->addParagragh($substr, 25,$pos,550,20, 30);
                         $line++;
		
			$pdf->drawLine(25, $pos-5, 570 , $pos-5);
                        $pos=$pos-20;
=cut			}

	}#for each
	my $tmpFileName= "search.pdf";
        imprimirFinal($pdf,$tmpFileName);
}


sub shelfContentsGenerator {
	
	my ($shelfname,@results)=@_;
	my $pdf=newPdf();
	my $pos;
	#my $pagewidth;
	#my $pageheight; 
	my $text;
	my $line=36; 
	my $page=0;
	my $msg2="Biblioteca: ";
	my $msg="Contenido del Estante Virtual : ".$shelfname;
	foreach my $res (@results) {
=item	  if($line > 35){
			$line=0;
			$pos=800;
			$pdf->newpage(1);
			$page++;
	        	$pdf->openpage($page);
		        ($pagewidth, $pageheight) = $pdf->getPageDimensions();
		        $pdf->setFont("Verdana");
        		$pdf->setSize(22);
        		$pdf->addRawText("Biblioteca: " ,180,$pos);
        		$pdf->setSize(20);
        		$pos=$pos-20;
        		$pdf->addImg( C4::Context->config('opacdir').'/htdocs/opac-tmpl/'.C4::Context->preference('opacthemes').'/'.C4::Context->preference('opaclanguages').'/images/escudo-print.png', 500, $pageheight - 77);
			
			$pdf->setFont("Verdana");
                        $pdf->setSize(12);
			$pdf->addRawText("Contenido del Estante Virtual : ".$shelfname ,70,$pos-15);
			
		        $pdf->setFont("Verdana");
      			$pdf->setSize(10);
			$pos=$pos-35;
		        $pdf->drawLine(25, $pos+12, 570 , $pos+12);
			}
=cut
		($pdf,$pos,$page,$line)=imprimirLinea($pdf,$pos,$msg,$msg2,$line,$page);# Se puso la parte de arriba en una funcion generica para que pueda ser usada por las otras funciones!!!! - Damian - 22/05/2007
	
		$text= $res->{'author'}.' - '.$res->{'title'}.' (Solicitar por '.$res->{'firstbulk'}.')';
		($pdf,$line,$pos)=imprimirLinea2($pdf,$text,$line,$pos);# Funcion generica que reemplaza la parte que esta comentada abajo!!!
	#Se puede usar en todas la funciones que generan pdf!!!! - Damian 22/05/2007

=item	if (length($text) < 100){
		     $pdf->addParagragh($text, 25,$pos,550,20, 30);
		     $line++;
		     $pdf->drawLine(25, $pos-5, 570 , $pos-5);
		     $pos=$pos-19;
			}else
		       {my $blank=index($text,' ', 100);
			if ($blank<0){$blank=length($text)}
			my $index=0;	
		while (($blank < length($text))and($blank>0)){
			my $size=$blank-$index;
			my $substr= substr($text,$index ,$size);
			 $pdf->addParagragh($substr, 25,$pos,550,20, 30);
 
			$line++;
                     	 $pos=$pos-10;
			$index=$blank;
			if($blank+90 < length($text)) {$blank=index($text,' ',$blank+100);}else{$blank=length($text);}
		   				}
			  my $substr= substr($text,$index ,length($text)-$index);
                         $pdf->addParagragh($substr, 25,$pos,550,20, 30);
                         $line++;
		
			$pdf->drawLine(25, $pos-5, 570 , $pos-5);
                        $pos=$pos-20;
=cut			}

	}#for each
	my $tmpFileName= "shelfContents.pdf";
        imprimirFinal($pdf,$tmpFileName);
}

sub searchShelfGenerator {
	my (@results)=@_;
	my $pdf=newPdf();
	my $pos;
	#my $pagewidth;
	#my $pageheight; 
	my $msg="Estantes virtules";
	my $msg2="Biblioteca: ";
	my $text;
	my $line=36; 
	my $page=0;
	foreach my $res (@results) {
		($pdf,$pos,$page,$line)=imprimirLinea($pdf,$pos,$msg,$msg2,$line,$page);# Se puso la parte de arriba en una funcion generica para que pueda ser usada por las otras funciones!!!! - Damian - 22/05/2007
=item	  if($line > 35){
			$line=0;
			$pos=800;
			$pdf->newpage(1);
			$page++;
	        	$pdf->openpage($page);
		        ($pagewidth, $pageheight) = $pdf->getPageDimensions();
		        $pdf->setFont("Verdana");
        		$pdf->setSize(22);
        		$pdf->addRawText("Biblioteca: " ,180,$pos);
        		$pdf->setSize(20);
        		$pos=$pos-20;
        		$pdf->addImg( C4::Context->config('opacdir').'/htdocs/opac-tmpl/'.C4::Context->preference('opacthemes').'/'.C4::Context->preference('opaclanguages').'/images/escudo-print.png', 500, $pageheight - 77);
		        $pdf->setFont("Verdana");
      			$pdf->setSize(10);
			 $pos=$pos-35;
		        $pdf->drawLine(25, $pos+12, 570 , $pos+12);
=cut			}

		if ($res->{'nameparent'}){
			$text= $res->{'nameparent'}.' / '.$res->{'shelfname'};
		}
		else{ 
			$text= $res->{'shelfname'};
		}
		($pdf,$line,$pos)=imprimirLinea2($pdf,$text,$line,$pos);# Funcion generica que reemplaza la parte que esta comentada abajo!!!
	#Se puede usar en todas la funciones que generan pdf!!!! - Damian 22/05/2007

=item	if (length($text) < 100){
		     $pdf->addParagragh($text, 25,$pos,550,20, 30);
		     $line++;
		     $pdf->drawLine(25, $pos-5, 570 , $pos-5);
		     $pos=$pos-19;
			}else
		       {my $blank=index($text,' ', 100);
			if ($blank<0){$blank=length($text)}
			my $index=0;	
		while (($blank < length($text))and($blank>0)){
			my $size=$blank-$index;
			my $substr= substr($text,$index ,$size);
			 $pdf->addParagragh($substr, 25,$pos,550,20, 30);
 
			$line++;
                     	 $pos=$pos-10;
			$index=$blank;
			if($blank+90 < length($text)) {$blank=index($text,' ',$blank+100);}else{$blank=length($text);}
		   				}
			  my $substr= substr($text,$index ,length($text)-$index);
                         $pdf->addParagragh($substr, 25,$pos,550,20, 30);
                         $line++;
		
			$pdf->drawLine(25, $pos-5, 570 , $pos-5);
                        $pos=$pos-20;
=cut			}

	}#for each
	my $tmpFileName= "searchShelf.pdf";
        imprimirFinal($pdf,$tmpFileName);
}


	
sub availPdfGenerator{
	my ($msg,@results)=@_;
	my $msg2="Biblioteca: ";
	my $pdf=newPdf();
	my $text;
	my $line=36; 
	my $pos;
	my $page=0;
=item
	my $pagewidth;
	my $pageheight; 


	
=cut
	foreach my $res (@results) {
=item	  if($line > 35){
			$line=0;
			$pos=810;
			$pdf->newpage(1);
			$page++;
	        	$pdf->openpage($page);
		        ($pagewidth, $pageheight) = $pdf->getPageDimensions();
		        $pdf->setFont("Verdana");
        		$pdf->setSize(16);
        		$pdf->addRawText("Biblioteca: " ,180,$pos);
        		$pdf->setSize(12);
        		$pos=$pos-15;
        		$pdf->addImg( C4::Context->config('opacdir').'/htdocs/opac-tmpl/'.C4::Context->preference('opacthemes').'/'.C4::Context->preference('opaclanguages').'/images/escudo-print.png', 500, $pageheight - 77);
		        $pdf->setFont("Verdana");
      			$pdf->setSize(10);
			 $pos=$pos-40;
			$pdf->addParagragh($msg, 25 ,$pos+20,550,20, 30);
		        $pdf->drawLine(25, $pos+12, 570 , $pos+12);
			}
=cut
		($pdf,$pos,$page,$line)=imprimirLinea($pdf,$pos,$msg,$msg2,$line,$page);# Se puso la parte de arriba en una funcion generica para que pueda ser usada por las otras funciones!!!! - Damian - 22/05/2007
	# Si funciona sacar lo comentado que esta arriba!!!!!
		$text= $res->{'author'}.' - '.$res->{'title'}.' - Signatura: '.$res->{'bulk'}.' Cod.: '.$res->{'barcode'}.' Fecha: '.$res->{'date'}; 

		($pdf,$line,$pos)=imprimirLinea2($pdf,$text,$line,$pos);# Funcion generica que reemplaza la parte que esta comentada abajo!!!
	#Se puede usar en todas la funciones que generan pdf!!!! - Damian 22/05/2007

=item	if (length($text) < 100){
		     $pdf->addParagragh($text, 25,$pos,550,20, 30);
		     $line++;
		     $pdf->drawLine(25, $pos-5, 570 , $pos-5);
		     $pos=$pos-19;
			}else
		       {my $blank=index($text,' ', 100);
			if ($blank<0){$blank=length($text)}
			my $index=0;	
		while (($blank < length($text))and($blank>0)){
			my $size=$blank-$index;
			my $substr= substr($text,$index ,$size);
			 $pdf->addParagragh($substr, 25,$pos,550,20, 30);
 
			$line++;
                     	 $pos=$pos-10;
			$index=$blank;
			if($blank+90 < length($text)) {$blank=index($text,' ',$blank+100);}else{$blank=length($text);}
		   				}
			  my $substr= substr($text,$index ,length($text)-$index);
                         $pdf->addParagragh($substr, 25,$pos,550,20, 30);
                         $line++;
		
			$pdf->drawLine(25, $pos-5, 570 , $pos-5);
                        $pos=$pos-20;
			}
=cut
	}#for each
	my $tmpFileName= "availsearch.pdf";
        imprimirFinal($pdf,$tmpFileName);
}

#Genera el PDF de las estadisticas que se generan en la pagina estadisticas.pl - Damian
sub estadisticasPdfGenerator(){
	my ($msg,@results)=@_;
	my $pdf=newPdf();
	my $pos;
	my $msg2="Biblioteca: ";
	my $blanco="				";
	my @text;
	my $line=36; 
	my $page=0;
	($pdf,$pos, $page,$line)=imprimirLinea($pdf,$pos,$msg,$msg2,$line,$page);
	$text[0]="Por Usuario: ";
	$text[1]=$blanco."Prestamos: ".$results[6]." Reservas: ".$results[8]." Renovados: ".$results[7];
	$text[2]="Por Domiciliarios: ";
	$text[3]=$blanco."Total: ".$results[0]." Renovados: ".$results[1]." Devueltos: ".$results[2];
	$text[4]="Por Sala: ".$results[3];
	$text[5]="Por Fotocopia: ".$results[4];
	$text[6]="Por Especial: ".$results[5];
	my $i;
	my $texto;
	for ($i=0; $i<=6; $i++){
		$texto=$text[$i];
		($pdf,$line,$pos)=imprimirLinea2($pdf,$texto,$line,$pos);
	}
	my $tmpFileName= "estadisticas.pdf";
	imprimirFinal($pdf,$tmpFileName);
}

#Miguel 31-05/07 - Genero el PDF de Historico de Prestamos
sub hitoricoPrestamosPdfGenerator(){
	my ($msg,@results)=@_;
	my $pdf=newPdf();
	my $pos;
	my $msg2="Biblioteca: ";
	my $text;
	my $line=36; 
	my $page=0;
	($pdf,$pos, $page,$line)=imprimirLinea($pdf,$pos,$msg,$msg2,$line,$page);

	#Se recorre el restultado y se arma el texto por linea para mostrar
	my $texto;
	foreach  my $res (@results) {
		$texto= $res->{'firstname'}.' - '.$res->{'surname'}.' - '.$res->{'DNI'}.' - '.$res->{'CatUsuario'}.' - '.$res->{'tipoPrestamo'}.' - '.$res->{'barcode'}.' - '.$res->{'fechaPrestamo'}.' - '.$res->{'fechaDevolucion'}.' - '.$res->{'tipoItem'};
		#Muestra la linea
		($pdf,$line,$pos)=imprimirLinea2($pdf,$texto,$line,$pos);
	}
	my $tmpFileName= "historicoPrestamos.pdf";
	#Se crea el archivo .PDF
	imprimirFinal($pdf,$tmpFileName);
}

#Damian - 22/05/2007
#Funcion generica que sirve para imprimir las lineas se usa en todos los generadores de pdf
#Ver si sirve!!!!!!!!!!!!
sub imprimirLinea(){
	my ($pdf,$pos,$msg,$msg2,$line,$page)=@_;
	my $pagewidth;
	my $pageheight; 
	if($line > 35){
		$line=0;
		$pos=810;
		$pdf->newpage(1);
		$page++;
	        $pdf->openpage($page);
		($pagewidth, $pageheight) = $pdf->getPageDimensions();
		$pdf->setFont("Verdana");
        	$pdf->setSize(16);
        	$pdf->addRawText($msg2 ,180,$pos);
        	$pdf->setSize(12);
        	$pos=$pos-15;
        	$pdf->addImg( C4::Context->config('opacdir').'/htdocs/opac-tmpl/'.C4::Context->preference('opacthemes').'/'.C4::Context->preference('opaclanguages').'/images/escudo-print.png', 500, $pageheight - 77);
		$pdf->setFont("Verdana");
      		$pdf->setSize(10);
		$pos=$pos-40;
		$pdf->addParagragh($msg, 25 ,$pos+20,550,20, 30);
		$pdf->drawLine(25, $pos+12, 570 , $pos+12);
	}
	return($pdf, $pos, $page, $line);
}

#Damian - 22/05/2007
#Funcion generica que sirve para imprimir las lineas se usa en todos los generadores de pdf
#Ver si sirve!!!!!!!!!!!!
sub imprimirLinea2(){
	my ($pdf, $text,$line,$pos)=@_;

	if (length($text) < 100){
		$pdf->addParagragh($text, 25,$pos,550,20, 30);
		$line++;
		$pdf->drawLine(25, $pos-5, 570 , $pos-5);
		$pos=$pos-19;
	}
	else{
		my $blank=index($text,' ', 100);
		if ($blank<0){
			$blank=length($text)
		}
		my $index=0;	
		while (($blank < length($text))and($blank>0)){
			my $size=$blank-$index;
			my $substr= substr($text,$index ,$size);
			$pdf->addParagragh($substr, 25,$pos,550,20, 30);
 			$line++;
                	$pos=$pos-10;
			$index=$blank;
			if($blank+90 < length($text)) {
				$blank=index($text,' ',$blank+100);
			}
			else{
				$blank=length($text);
			}
		}
		my $substr= substr($text,$index ,length($text)-$index);
                $pdf->addParagragh($substr, 25,$pos,550,20, 30);
                $line++;
		$pdf->drawLine(25, $pos-5, 570 , $pos-5);
                $pos=$pos-20;
	}
	return($pdf,$line,$pos);
}

#Para imprimir el archivo con el nombre. Funcion generica que se puede usar en todos las funciones 
#que generan pdf - Damian - 23/05/2007
sub imprimirFinal(){
	my($pdf,$tmpFileName)=@_;
	print "Content-type: application/pdf\n";
        print "Content-Disposition: attachment; filename=\"$tmpFileName\"\n\n";
        print $pdf->Finish();
}










