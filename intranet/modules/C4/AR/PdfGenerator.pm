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
	&cardGenerator
	&batchCardsGenerator
	&generateCard
	&libreDeuda
	&prestInterBiblio
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












################CARNETS############################################33

sub completeBorrowerNumber {
        my ($bornum) = @_;
	my $str="";
	my $i=0;
	my $aux;
	while ($bornum > 0) {	
		$aux= $bornum % 10;
		$str= $aux.$str;
		$bornum= ($bornum - ($bornum % 10)) / 10;
		$i++;
		}
	
	while ($i < 11) {
		$str= "0".$str;
		$i++;									
		}
	return($str);
	}


sub cardGenerator {
        my ($bornum) = @_;
	my $pdf = newPdf();
        $pdf->newpage(1);
        $pdf->openpage(1);
	#Hoja A4 :  X diferencia 254 - Y diferencia 160 
	generateCard($bornum,14,14,$pdf);
	return ($pdf);
	}	

#  Genera los carnets a partir de una busqueda

sub batchCardsGenerator {
        my ($count,@results) = @_;
#	my $cantidad=$count;
#	my $hojas= $count / 8;
	my $i=0;
	my $pag=1;
	my $pdf = newPdf();
        
	while ($i<$count)
	{
	$pdf->newpage($pag);
        $pdf->openpage($pag);
	#Hoja A4 :  X diferencia 254 - Y diferencia 160 
	
	if ($i<$count){	generateCard($results[$i]->{'borrowernumber'},14,14,$pdf);$i++;}
	if ($i<$count){	generateCard($results[$i]->{'borrowernumber'},14,174,$pdf);$i++;}
	if ($i<$count){	generateCard($results[$i]->{'borrowernumber'},14,334,$pdf);$i++;}
	if ($i<$count){	generateCard($results[$i]->{'borrowernumber'},14,494,$pdf);$i++;}
	if ($i<$count){	generateCard($results[$i]->{'borrowernumber'},14,654,$pdf);$i++;}
	if ($i<$count){	generateCard($results[$i]->{'borrowernumber'},270,14,$pdf);$i++;}
	if ($i<$count){	generateCard($results[$i]->{'borrowernumber'},270,174,$pdf);$i++;}
	if ($i<$count){	generateCard($results[$i]->{'borrowernumber'},270,334,$pdf);$i++;}
	if ($i<$count){	generateCard($results[$i]->{'borrowernumber'},270,494,$pdf);$i++;}
	if ($i<$count){	generateCard($results[$i]->{'borrowernumber'},270,654,$pdf);$i++;}
	$pag++;
	}
	return ($pdf);
	}	


#genera a partir de una coordenada
sub generateCard {
	 my ($bornum,$x,$y,$pdf) = @_;

	my $dbh = C4::Context->dbh;
	#Datos del usuario
	my $sth=$dbh->prepare("SELECT cardnumber, borrowernumber, documenttype, documentnumber, studentnumber, firstname, surname, branchcode,  categories.description FROM borrowers left join categories on borrowers.categorycode=categories.categorycode 
				WHERE borrowernumber=?");
	$sth->execute($bornum);
	my ($cardnumber, $borrowernumber, $documenttype, $documentnumber, $studentnumber, $firstname, $surname,$branchcode, $categorydes) = $sth->fetchrow_array;
	$sth->finish;

	#Datos de la biblioteca
	my $sth2=$dbh->prepare("SELECT branchname,branchaddress1,branchaddress2,branchaddress3,branchphone,branchfax,branchemail, branchcategories.categoryname  
	FROM branches inner join branchrelations on branches.branchcode=branchrelations.branchcode inner join branchcategories on branchcategories.categorycode = branchrelations.categorycode WHERE branches.branchcode=?");
	   $sth2->execute($branchcode);
my ($branchname,$branchaddress1,$branchaddress2,$branchaddress3,$branchphone,$branchfax,$branchemail,$categoryname) = $sth2->fetchrow_array;
	$sth2->finish;


	my ($pagewidth, $pageheight) = $pdf->getPageDimensions();
	$pdf->setSize(7);
																          #Insert a picture of the borrower if 
        my $picturesDir= C4::Context->config("picturesdir");
        my $foto= undef;
	if (opendir(DIR, $picturesDir)) {
 		my $pattern= $bornum.".*";
		my @file = grep { /$pattern/ } readdir(DIR);
		$foto= join("",@file) if scalar(@file);
		closedir DIR;
	}
	 #if ($foto){
	#	$pdf->addImg($picturesDir.'/'.$foto, $x+154, $pageheight - ($y+75));
	#	} else {
		$pdf->drawRect($x+154, $pageheight - ($y-10), $x+239 , $pageheight - ($y+75));
		$pdf->addRawText("3 x 3 cm.",$x+176,$pageheight - ($y+36));
	#	}

	 ####
         
	 #Insert a rectangle to delimite the card
	 $pdf->drawRect($x-12, $pageheight - ($y-12) , $x+241 , $pageheight - ($y+142)); # 9x5,5 cm = 3.51x2.145 inches = 253x154 pdf-units
	 
	 #Insert a barcode to the card
	 $pdf->drawBarcode($x+19,$pageheight - ($y+146),undef,1,"3of9",$cardnumber,undef, 10, 10, 30, 10);
	
	 #Write the borrower data into the pdf file
	 $pdf->setSize(7);
	 $pdf->setFont("Arial-Bold");
         $pdf->addRawText(uc($categoryname),$x,$pageheight - ($y+4));
	 $pdf->addRawText(uc($branchname),$x,$pageheight - ($y+11));
	 $pdf->addRawText("BIBLIOTECA",$x,$pageheight - ($y+18));
	 $pdf->setFont("Arial");
	 $pdf->setSize(6);

	 my $address=$branchaddress1;
	 if($branchaddress2 ne ''){$address.="\n".$branchaddress2;}
	 if($branchaddress3 ne ''){$address.="\n".$branchaddress3;}
	 $pdf->addRawText($address,$x,$pageheight - ($y+25));

	 if (($branchphone ne '')||($branchfax ne '')){
	 my $aux="";

	 if ($branchphone eq $branchfax){$aux="Tel/Fax ".$branchphone;}
	 	else{
			if ($branchphone ne '') { $aux=" Tel ".$branchphone;}
			if ($branchfax ne '') { $aux=" Fax ".$branchfax;}
			}
	 $pdf->addRawText($aux,$x,$pageheight - ($y+31));
	 
	 }
	 
	 $pdf->setSize(8);
	 $pdf->addRawText("Apellido: $surname",$x+4,$pageheight - ($y+57));
	 $pdf->addRawText("Nombre: $firstname",$x+4,$pageheight - ($y+65));
	 $pdf->addRawText("Tipo de Lector: $categorydes",$x+4,$pageheight - ($y+73));
	 $pdf->addRawText("$documenttype: $documentnumber",$x+4,$pageheight - ($y+81));
}
#############FIN CARNET########################

=item
datosBiblio
Busca todos los datos de la biblioteca en que se encuentra asociado el usuario.
Nota: branchaddress3, se va usar para guardar la direccion web de la biblioteca.
=cut
sub datosBiblio(){
	my ($branchcode)=@_;
	my $dbh = C4::Context->dbh;
	my $biblio;
	my $sth=$dbh->prepare("SELECT branchname,branchaddress1,branchaddress2,branchaddress3,branchphone,branchfax,branchemail, branchcategories.categoryname as categ
	FROM branches inner join branchrelations on branches.branchcode=branchrelations.branchcode inner join branchcategories on branchcategories.categorycode = branchrelations.categorycode WHERE branches.branchcode=?");
	$sth->execute($branchcode);
	$biblio=$sth->fetchrow_hashref();
	$sth->finish;
	return($biblio);
}

=item
libreDeuda
Genera y muestar la ventana para imprimir el documento de libre deuda.
=cut
sub libreDeuda(){
	my ($bornum,$borrewer) = @_;
	my $tmpFileName= "libreDeuda".$bornum.".pdf";
	my $nombre = $borrewer->{'surname'}.", ".$borrewer->{'firstname'};
	my $dni= $borrewer->{'documentnumber'};
	my $branchcode=$borrewer->{'branchcode'};
	my $biblio=&datosBiblio($branchcode);
	my $categ=$biblio->{'categ'};
	my $branchname=$biblio->{'branchname'};

	my ($pdf,$pagewidth, $pageheight) = &inicializarPDF();

	my $x=50;
	my $y=300;#pos 'y' a partir de donde se van a escribir la parte del contenido.
	my %titulo;
	$titulo{'titulo'}="CERTIFICADO DE LIBRE DEUDA";
	$titulo{'posx'}=170;
	my @parrafo;
	$parrafo[0]="       Certificamos que ".$nombre.", de la ".$branchname.", ";
	$parrafo[1]=" con número de documento ".$dni.", no adeuda material bibliográfico en esta Biblioteca.";
	$parrafo[2]="       Se extiende el presente certificado para ser presentado ante quien corresponda, con una";
	$parrafo[3]=" validez de 10 días corridos a partir de su fecha de emisión.";

	($pdf)=&imprimirEncabezado($pdf,$categ,$branchname,$x,$pagewidth,$pageheight,\%titulo,);
	($pdf,$y)=&imprimirContenido($pdf,$x,$y,$pageheight,15,\@parrafo);
	($pdf,$y)=&imprimirFirma($pdf,$y+50,$pageheight);
	&imprimirFinal($pdf,$tmpFileName);
}

=item
prestInterBiblio
Genera y muestra la ventana para imprimir el documento de prestamos interbibliotecarios.
=cut
sub prestInterBiblio(){
	my ($bornum,$borrewer,$biblioDestino,$director,$datos)=@_;
	my $tmpFileName= "prestInterBiblio".$bornum.".pdf";
	my $nombre = $borrewer->{'surname'}.", ".$borrewer->{'firstname'};
	my $dni= $borrewer->{'documentnumber'};
	my $branchcode=$borrewer->{'branchcode'};
	my $biblio=&datosBiblio($branchcode);
	my $categ=$biblio->{'categ'};
	my $branchname=$biblio->{'branchname'};

	my ($pdf,$pagewidth, $pageheight) = &inicializarPDF();

	my $x=50;
	my $y=300;
	my %titulo;
	$titulo{'titulo'}="SOLICITUD DE PRESTAMO INTERBIBLIOTECARIO";
	$titulo{'posx'}=100;
	my @parrafo;
	$parrafo[0]="Sr. Director de la Biblioteca";
	$parrafo[1]="de la ".$biblioDestino;
	$parrafo[2]=$director;
	$parrafo[3]="S/D";
	$parrafo[4]="          Tengo el agrado de dirigirme a Ud. a fin de solicitarle en carácter de préstamo"; 
	$parrafo[5]="interbibliotecario los siguientes ítems:";

	($pdf)=&imprimirEncabezado($pdf,$categ,$branchname,$x,$pagewidth,$pageheight,\%titulo);
	($pdf,$y)=&imprimirContenido($pdf,$x,$y,$pageheight,15,\@parrafo);
	my $cant=scalar(@$datos);
	($pdf,$y)=&imprimirTabla($pdf,$y,$pageheight,$cant,$datos);

	$parrafo[0]="La(s) misma(s) será(n) retirada(s) por:";
	$parrafo[1]="Nombre y apellido:".$nombre;
	$parrafo[2]="DNI:".$dni;
	$parrafo[3]="Dirección:".$borrewer->{'streetaddress'}.", ".&C4::Search::darCiudad($borrewer->{'city'});
	$parrafo[4]="Teléfono:".$borrewer->{'phone'};
	$parrafo[5]="Correo electrónico:".$borrewer->{'emailaddress'};
	$parrafo[6]="";
	$parrafo[7]="          Sin otro particular y agradeciendo desde ya su amabilidad, saludo a Ud. muy";
	$parrafo[8]="atentamente.";

	($pdf,$y)=&imprimirContenido($pdf,$x,$y,$pageheight,15,\@parrafo);
	($pdf,$y)=&imprimirFirma($pdf,$y,$pageheight);
	$y=$y+15;
	$pdf->drawLine(50, $pageheight-$y, $pagewidth-50, $pageheight-$y);
	$pdf=&imprimirPiePag($pdf,$y,$pageheight,$biblio);
	&imprimirFinal($pdf,$tmpFileName);
}

=item
inicializarPDF
Crea un objeto pdf, lo devuelve, junto con la longitud de ancho ($pagewidth) y largo ($pageheight) que va a tener el documento.
=cut
sub inicializarPDF(){
	my $pdf=newPdf();
	$pdf->newpage(1);
	$pdf->openpage(1);
	my ($pagewidth, $pageheight) = $pdf->getPageDimensions();
	return($pdf,$pagewidth,$pageheight);
}

=item
imprimirEncabezado
Imprime el encabezado del documento, con el escudo del la universidad nacional de la plata.
@params:
	$pdf, objeto que representa al documeto, donde se guardan los datos a imprimir;
	$categ, categoria de la institucion en la que se va a imprimir el documento;
	$branchname, nombre de la biblioteca en la que esta asociado el usuario que pidio el documento;
	$x, tamaño de la sangria. A partir de donde se va a escribir en el renglon;
	$pagewidth, ancho del documento;
	$pageheight, largo del documento;
	$titulo, Titulo del documento;
=cut
sub imprimirEncabezado(){
	my ($pdf,$categ,$branchname,$x,$pagewidth,$pageheight,$titulo)=@_;
#fecha
	my @datearr = localtime(time);
	my $anio=1900+$datearr[5];
	my $mes=&C4::Date::mesString($datearr[4]+1);
	my $dia=$datearr[3];
#fin fecha
        $pdf->addImg( C4::Context->config('intrahtdocs').'/'.C4::Context->preference('template').'/'.C4::Context->preference('opaclanguages').'/images/escudo-uni.png', $x, $pageheight - 160);
	$pdf->setFont("Arial-Bold");
      	$pdf->setSize(10);
	$pdf->addRawText(uc($categ), $x,$pageheight - 180);
	$pdf->addRawText(uc($branchname), $x,$pageheight - 190);
	$pdf->addRawText("BIBLIOTECA", $x,$pageheight - 200);
	$pdf->setFont("Verdana-Bold");
	$pdf->setSize(14);
	$pdf->addRawText($titulo->{'titulo'}, $titulo->{'posx'},$pageheight - 240);
	$pdf->setFont("Verdana");
	$pdf->setSize(10);
	$pdf->addRawText("La Plata, ".$dia." de ".$mes. " de ".$anio, $pagewidth-250,$pageheight - 270);
	return($pdf);
}

=item
imprimirContenido
Imprime el contenido de del documento.
@params:
	$pdf, objeto que representa al documeto, donde se guardan los datos a imprimir;
	$x, tamaño de la sangria. A partir de donde se va a escribir en el renglon;
	$y, cantidad de renglones que se escribieron hasta el momento. Sirve de puntero para saber en que fila
	    imprimir;
	$pageheight, largo del documento;
	$tamRenglon, tamaño que va a tener el renglon. Espacio entre texto por fila;
	$parrafo, referencia al arreglo que contiene los string a imprimir en el pdf;
=cut
sub imprimirContenido(){
	my ($pdf,$x,$y,$pageheight,$tamRenglon,$parrafo)=@_;
	for(my $i=0; $i < scalar(@$parrafo); $i++){
		$pdf->addRawText($parrafo->[$i], $x,$pageheight - $y);
		$y=$y+$tamRenglon;
	}
	return($pdf,$y);
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
sub imprimirFirma(){
	my ($pdf,$y,$pageheight)=@_;
	my $linea="................................";
	$y=$y+30;
	$pdf->addRawText($linea, 130,$pageheight - $y);
	$pdf->addRawText($linea, 330,$pageheight - $y);
	$y=$y+10;
	$pdf->addRawText("Firma", 160,$pageheight - $y);
	$pdf->addRawText("Aclaración", 360,$pageheight - $y);
	return($pdf,$y);
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
sub imprimirTabla(){
	my ($pdf,$y,$pageheight,$cantFila,$datos)=@_;
	$pdf->setFont("Verdana-Bold");
	$pdf->setSize(12);
	$pdf->drawRect(50, $pageheight-$y, 200, $pageheight-($y+20));
	$pdf->addRawText("Autor/es", 100,$pageheight - ($y+15));
	$pdf->drawRect(200, $pageheight-$y, 350, $pageheight-($y+20));
	$pdf->addRawText("Título", 255,$pageheight - ($y+15));
	$pdf->drawRect(350, $pageheight-$y, 500, $pageheight-($y+20));
	$pdf->addRawText("Otros datos", 395,$pageheight - ($y+15));
	$y=$y+20;
	$pdf->setFont("Verdana");
	$pdf->setSize(11);
	for(my $i=0;$i<$cantFila;$i++){
		$pdf->drawRect(50, $pageheight-$y, 200, $pageheight-($y+20));
		$pdf->addRawText($datos->[$i]->{'autor'}, 60,$pageheight - ($y+15));
		$pdf->drawRect(200, $pageheight-$y, 350, $pageheight-($y+20));
		$pdf->addRawText($datos->[$i]->{'titulo'}, 210,$pageheight - ($y+15));
		$pdf->drawRect(350, $pageheight-$y, 500, $pageheight-($y+20));
		$pdf->addRawText($datos->[$i]->{'otros'}, 360,$pageheight - ($y+15));
		$y=$y+20;
	}
	$y=$y+20;
	$pdf->setSize(10);
	return($pdf,$y);
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
sub imprimirPiePag(){
	my ($pdf,$y,$pageheight,$biblio)=@_;
	my @texto;
	$texto[0]="Biblioteca: ".$biblio->{'branchname'};
	$texto[1]="Calle ".$biblio->{'branchaddress1'};
	$texto[2]="Tel/Fax: ".$biblio->{'branchphone'}."/".$biblio->{'branchfax'};
	$texto[3]="Atención: lunes a viernes, ".C4::Context->preference('open')." a ".C4::Context->preference('close');
	$texto[4]="E-mail: ".$biblio->{'branchemail'};
	$texto[5]="Sitios web: ".$biblio->{'branchaddress3'};
	$texto[6]="";
	$y=$y+15;
	($pdf,$y)=&imprimirContenido($pdf,200,$y,$pageheight,10,\@texto);
	return ($pdf);
}