#!/usr/bin/perl

# script to generate cards for the borrowers
# written 03/2005
# by Luciano Iglesias - li@info.unlp.edu.ar - LINTI, Facultad de Inform�tica, UNLP Argentina

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

require Exporter;

use strict;
use CGI;
use C4::Context;
use PDF::Report;

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
	while ($i < 11)	{
		$str= "0".$str;
		$i++;
	}
	return($str);
}

sub cardGenerator {
	my ($bornum) = @_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("SELECT borrowernumber, documenttype, documentnumber, studentnumber, firstname, surname,  categories.description FROM borrowers, categories WHERE (borrowernumber=$bornum)  and (borrowers.categorycode=categories.categorycode)");
	$sth->execute;
	my ($borrowernumber, $documenttype, $documentnumber, $studentnumber, $firstname, $surname, $categorydes) = $sth->fetchrow_array;
	$sth->finish;
	my $tmpFileName= $bornum.".pdf";
	my $pdf = new PDF::Report(PageSize => "A6", 
                                  PageOrientation => "Landscape");
	
	$pdf->newpage(1);
	$pdf->openpage(1);
	my ($pagewidth, $pageheight) = $pdf->getPageDimensions();
	$pdf->setSize(7);
	#Insert a picture of the borrower if exist
	my $picturesDir= C4::Context->config("picturesdir");
	my $foto= undef;
	if (opendir(DIR, $picturesDir)) {
        	my $pattern= $bornum.".*";
	        my @file = grep { /$pattern/ } readdir(DIR);
        	$foto= join("",@file) if scalar(@file);
	        closedir DIR;
	}
	if ($foto){
		$pdf->addImg($picturesDir.'/'.$foto, 168, $pageheight - 89);
	} else {
		$pdf->drawRect(168, $pageheight - 4, 253, $pageheight - 89);
		$pdf->addRawText("3 x 3 cm.",190,$pageheight - 50);
	}
	####

	#Insert a rectangle to delimite the card
	$pdf->drawRect(2, $pageheight - 2, 255, $pageheight - 156); # 9x5,5 cm = 3.51x2.145 inches = 253x154 pdf-units

	#Insert a barcode to the card
	$pdf->drawBarcode(33,$pageheight - 160,undef,1,"3of9",completeBorrowerNumber($borrowernumber),undef, 10, 10, 30, 10);

	#Write the borrower data into the pdf file
	$pdf->setSize(7);
	
	$pdf->setFont("Arial-Bold");
	$pdf->addRawText("UNIVERSIDAD NACIONAL DE LA PLATA",14,$pageheight - 18);
	$pdf->addRawText("FACULTAD DE INFORMATICA - BIBLIOTECA",14,$pageheight - 25);
	$pdf->setFont("Arial");
	$pdf->setSize(6);
	$pdf->addRawText("Calle 49 no. 479 - B1900APS La Plata",14,$pageheight - 32);
	$pdf->addRawText("Tel/Fax 0221 421-6564 biblioteca@\linfo.unlp.edu.ar",14,$pageheight - 37);
	$pdf->setSize(8);
	$pdf->addRawText("Apellido: $surname",18,$pageheight - 55);
	$pdf->addRawText("Nombre: $firstname",18,$pageheight - 67);
	$pdf->addRawText("Tipo de Lector: $categorydes",18,$pageheight - 79);
	$pdf->addRawText("$documenttype: $documentnumber",18,$pageheight - 91);
	#$pdf->addRawText("Legajo: $studentnumber",10,$pageheight - 90);
	print "Content-type: application/pdf\n";
	print "Content-Disposition: attachment; filename=\"$tmpFileName\"\n\n";
        print $pdf->Finish();
}

my $cgi= new CGI;
my $bornum = $cgi->param('bornum');
cardGenerator($bornum);
