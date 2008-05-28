#!/usr/bin/perl
#written 11/3/2002 by Finlay
#script to execute returns of books

# Copyright 2000-2002 Katipo Communications
#
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

use strict;
use CGI;
use C4::Circulation::Circ2;
use C4::Search;
use C4::Output;
use C4::AR::Issues;
use C4::AR::Reserves;
use C4::AR::Sanctions;
use C4::Auth;
use C4::Interface::CGI::Output;
use HTML::Template;
use C4::Koha;
use Date::Manip;
use C4::Date;

my %env;
my $linecolor1='par';
my $linecolor2='impar';
my $query=new CGI;
#getting the template
my ($template, $loggedinuser, $cookie)
	= get_template_and_user({template_name => "circ/returns.tmpl",
			query => $query,
			type => "intranet",
			authnotrequired => 0,
			flagsrequired => {circulate => 1},
			});

my $okMensaje="";
my $hasdebts=0;
my $sanction=0;
my $enddate;
my $badbarcode=0;
my %env;
my $iteminfo;
my $message;
my $borrowerslist;
my $barcode = $query->param('barcode');
my $itemnumber = $query->param('itemnumber');
my $bornum=$query->param('borrnumber');

#DAMIAN - Para devolver varios items.
my @chkbox=$query->param('chkbox1');
my @infoTotal;
my $strItemNumbers=$query->param('strItemNumbers')||"";
my $loop=scalar(@chkbox);
my $chkall=$query->param('selectAll');
my $acc=$query->param('action');
my $ticket_string="";
my @tickets;

if($loop != 0 || $barcode){#Damian - Para devolver muchos libros a la vez
# si viene el barcode entonces esta intentando hacer la devolucion o renovacion => se le pregunta por una confirmacion
	if(! $barcode){#SE SELECCIONARON MUCHOS ITEMS
		for(my $i=0;$i<$loop;$i++){
		my $barcode2=$chkbox[$i];
		$iteminfo= getiteminformation( \%env, undef, $barcode2);
		if ($iteminfo) {
	#Si existe el codigo de barras
			if ($iteminfo->{'date_due'}) { #FIXME ver la pregunta
		#Si el libro esta prestado
				$query->param('borrnumber', $iteminfo->{'borrowernumber'});
				$iteminfo->{'action'}= $acc;
				$iteminfo->{'barcode'}=$barcode2;
				$iteminfo->{'return'}= ($acc eq 'return');
				$iteminfo->{'renew'}= ($acc eq 'renew');
				$infoTotal[$i]->{'iteminfo'}=$iteminfo;
				$infoTotal[$i]->{'barcode'}=$barcode2;
				$infoTotal[$i]->{'author'}=$iteminfo->{'author'};
				$infoTotal[$i]->{'title'}=$iteminfo->{'title'};
				$infoTotal[$i]->{'unititle'}=$iteminfo->{'unititle'};
				$infoTotal[$i]->{'edition'}=$iteminfo->{'number'};
				$strItemNumbers.=$iteminfo->{'itemnumber'}.",";
			} 
			else{
		#Si el libro no esta prestado
			$okMensaje.= "El libro con c&oacute;digo de barras $barcode no est&aacute; prestado";
			}
		} 
		else{
	#Si no existe el codigo de barras
			$okMensaje.= "El c&oacute;digo de barras $barcode no existe";
		}
		$infoTotal[$i]->{'okMensaje'}=$okMensaje;
		}
	}
	else{#Viene un solo barcode, es el ingresado a mano o desde la pagina del member.
		$iteminfo= getiteminformation( \%env, undef, $barcode);
		if ($iteminfo) {
	#Si existe el codigo de barras
			if ($iteminfo->{'date_due'}) { #FIXME ver la pregunta
		#Si el libro esta prestado
				$query->param('borrnumber', $iteminfo->{'borrowernumber'});
				$iteminfo->{'action'}= $query->param('action');
				$iteminfo->{'barcode'}=$barcode;
				$iteminfo->{'return'}= ($acc eq 'return');
				$iteminfo->{'renew'}= ($acc eq 'renew');
				$infoTotal[0]->{'iteminfo'}=$iteminfo;
				$infoTotal[0]->{'barcode'}=$barcode;
				$infoTotal[0]->{'author'}=$iteminfo->{'author'};
				$infoTotal[0]->{'title'}=$iteminfo->{'title'};
				$infoTotal[0]->{'edition'}=$iteminfo->{'number'};
				$strItemNumbers.=$iteminfo->{'itemnumber'}.",";
			} 
			else{
		#Si el libro no esta prestado
			$okMensaje.= "El libro con c&oacute;digo de barras $barcode no est&aacute; prestado";
			}
		} 
		else{
	#Si no existe el codigo de barras
			$okMensaje.= "El c&oacute;digo de barras $barcode no existe";
		}
	}
}
elsif($strItemNumbers ne "") {
	my @arrayItemNumbers=split(/,/,$strItemNumbers);
# si viene el itemnumber entonces esta aceptando la confirmacion => hay que hacer la devolucion o la renovacion
	my $cant=scalar(@arrayItemNumbers);
	for(my $i=0;$i<$cant;$i++){
		my $itemnumber= $arrayItemNumbers[$i];
		$iteminfo= getiteminformation( \%env, $itemnumber);
		my $action= $query->param('action');
		$barcode= $iteminfo->{'barcode'};
		$query->param('borrnumber', $iteminfo->{'borrowernumber'});

		if ($action eq 'return') {
			my ($returned) = devolver($iteminfo->{'itemnumber'},$iteminfo->{'borrowernumber'},$loggedinuser);
			$okMensaje.=($returned)?'El ejemplar con c&oacute;digo de barras '.$barcode.' fue devuelto<br>':'El ejemplar con c&oacute;digo de barras '.$barcode.' no pudo ser devuelto<br>';
		} 
		elsif($action eq 'renew') {
			my ($renewed) = renovar($iteminfo->{'borrowernumber'},$iteminfo->{'itemnumber'},$loggedinuser);
			$okMensaje.=($renewed)?'El ejemplar con c&oacute;digo de barras '.$barcode.' fue renovado<br>':'El ejemplar con c&oacute;digo de barras '.$barcode.' no pudo ser renovado<br>';
			if(C4::Context->preference("print_renew") && $renewed){#IF PARA LA CONDICION SI SE QUIERE O NO IMPRIMIR EL TICKET
				$ticket_string=&crearTicket($iteminfo,$loggedinuser);
				$tickets[$i]->{'ticket_string'}=$ticket_string;
				$tickets[$i]->{'number'}=$i;
			}
		}
	}
}
else {

	# if there is a list of find borrowers....
	my $findborrower = $query->param('findborrower');
	if ($findborrower) {
		my ($count,$borrowers)=BornameSearch(\%env,$findborrower,'web');
		my @borrowers=@$borrowers;
		if ($#borrowers == -1) {
			$query->param('findborrower', '');
			$message =  "No se encontr&oacute; ning&uacute;n usuario '$findborrower'";
		} elsif ($#borrowers == 0) {
			$query->param('borrnumber', $borrowers[0]->{'borrowernumber'});
		} else {
			$borrowerslist = \@borrowers;
		}
	}
}

my $bornum = $query->param('borrnumber');
my $CGIselectborrower;
my $borrower;
my $flags;
my $hash;
my @datearr = localtime(time());
my $todaysdate = (1900+$datearr[5]).sprintf ("%0.2d", ($datearr[4]+1)).sprintf ("%0.2d", ($datearr[3]));
my @issues;

if ($bornum) {
	($borrower, $flags, $hash) = getpatroninformation(\%env,$bornum,0);
	if ($borrower) {
		my $pcolor = 'par';
		my $issueslist = getissues($borrower); # FIXME trae libros que no corresponden
		my $dateformat = C4::Date::get_date_format();
		foreach my $it (keys %$issueslist) {
			my $book= $issueslist->{$it};
			$book->{'date_due'} = format_date($book->{'date_due'},$dateformat);
			my $err= "Error con la fecha";
			my $hoy=C4::Date::format_date_in_iso(ParseDate("today"),$dateformat);
			my  $close = ParseDate(C4::Context->preference("close"));
			if (Date::Manip::Date_Cmp($close,ParseDate("today"))<0){#Se paso la hora de cierre
				$hoy=C4::Date::format_date_in_iso(DateCalc($hoy,"+ 1 day",\$err),$dateformat);
			}

			my ($vencido,$df)= &C4::AR::Issues::estaVencido($book->{'itemnumber'},$book->{'issuecode'});

			$book->{'date_fin'} = format_date($df,$dateformat);
			if ($vencido){$book->{'color'} ='red';}
			($pcolor eq $linecolor1) ? ($pcolor=$linecolor2) : ($pcolor=$linecolor1);
			$book->{'renew'} = &sepuederenovar($bornum, $book->{'itemnumber'});
			$book->{'clase'}=$pcolor;
			$book->{'issuetype'}=$book->{'issuetype'};
			if ($book->{'author'} eq ''){$book->{'author'}=' ';}
			push @issues,$book
		}
	}

####Tiene sanciones el usuario?###
my $sanctions = hasSanctions($bornum);
$template->param(sanctions       => $sanctions);
####
####Es regular el Usuario?####
my $regular =  C4::AR::Usuarios::esRegular($bornum);
$template->param(regular       => $regular);
####

} else { # else -- if ($bornum)
	my @values;
	my %labels;
	if ($borrowerslist) {
		foreach (sort {$a->{'surname'}.$a->{'firstname'} cmp $b->{'surname'}.$b->{'firstname'}} @$borrowerslist){
			push @values,$_->{'borrowernumber'};
			$labels{$_->{'borrowernumber'}} ="$_->{'surname'}, $_->{'firstname'} ($_->{'cardnumber'})";
		}
		$CGIselectborrower=CGI::scrolling_list( -name     => 'borrnumber',
				-values   => \@values,
				-labels   => \%labels,
				-size     => 7,
				-multiple => 0 );
	}

}#end -- if ($bornum)

$template->param(       
		okMensaje => $okMensaje,
		hasdebts => $hasdebts,
		sanction => $sanction,
		enddate => $enddate,
		badbarcode => $badbarcode,
		barcode => $barcode,
		CGIselectborrower => $CGIselectborrower,
                issues => \@issues,
		borrowernumber => $bornum,
                firstname => $borrower->{'firstname'},
                surname => $borrower->{'surname'},
                zipcode => $borrower->{'zipcode'},
                categorycode => &C4::AR::Busquedas::getborrowercategory($borrower->{'categorycode'}),
                documenttype => $borrower->{'documenttype'},
                documentnumber => $borrower->{'documentnumber'},
                emailaddress => $borrower->{'emailaddress'},
                streetaddress => $borrower->{'streetaddress'},
                city => $borrower->{'city'},
                phone => $borrower->{'phone'},
                cardnumber => $borrower->{'cardnumber'},
                itemnumber => $iteminfo->{'itemnumber'},
#                 edition => $iteminfo->{'number'},
                biblioitemnumber => $iteminfo->{'biblioitemnumber'},
                notforloan => $iteminfo->{'notforloan'},
                author => $iteminfo->{'author'}, #devolvia el codigo del autor, se modifico para que de el nombre completo, en la funcion getiteminformation del paquete Circ2.pm
                title => $iteminfo->{'title'},
		unititle => $iteminfo->{'unititle'},
                action => $iteminfo->{'action'},
		return => $infoTotal[0]->{'iteminfo'}->{'return'},#se modifico para que se pueda devolver varios libros a la vez.
                renew => $iteminfo->{'renew'},
		message => $message,
	#se modifico para que se pueda devolver varios libros a la vez.
		infoTotal=>\@infoTotal,
		strItemNumbers =>$strItemNumbers,
		chkbox     =>join(",",@chkbox),
		chkall  =>$chkall,
		ticket_string => \@tickets,
# 		ticket_string => $ticket_string,
);

# actually print the page!
output_html_with_http_headers $query, $cookie, $template->output;

# Local Variables:
# tab-width: 4
# End:
