#!/usr/bin/perl
# Please use 8-character tabs for this file (indents are every 4 characters)

#written 8/5/2002 by Finlay
#script to execute issuing of books

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
use DBI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Koha;
use HTML::Template;
use C4::Date;
use CGI::Util;
use C4::AR::Reserves;
use C4::AR::Issues;
use Date::Manip;
use C4::AR::Sanctions;

my $query=new CGI;

my ($template, $loggedinuser, $cookie) = get_template_and_user
    ({
	template_name	=> 'circ/circulation.tmpl',
	query		=> $query,
	type		=> "intranet",
	authnotrequired	=> 0,
	flagsrequired	=> { circulate => 1 },
    });

my %env;
my $linecolor1='par';
my $linecolor2='impar';
my $branches = getbranches();
my $printers = getprinters(\%env);
my $branch=(split("_",(split(";",$cookie))[0]))[1];
my $printer = getprinter($query, $printers);



my $iteminfo;

## Para el ticket
my $ticket_print = 0;
my $ticket_duedate;
my $ticket_string;
my $ticket_borrower;
my @tickets;

#DAMIAN - Para prestar varios items.
my @chkbox=$query->param('chkbox2');
my $loop=scalar(@chkbox);

#Si viene un itemnumber se trata de prestar desde el catalogo UNO solo
if (($loop eq 0)&&($query->param('itemnumber'))) { $loop=1; $chkbox[0]=$query->param('itemnumber');}

my @infoTotal;

#set up cookie.....
my $branchcookie;
my $printercookie;
if ($query->param('setcookies')) {
	$branchcookie = $query->cookie(-name=>'branch', -value=>"$branch", -expires=>'+1y');
	$printercookie = $query->cookie(-name=>'printer', -value=>"$printer", -expires=>'+1y');
}

$env{'branchcode'}=$branch;
$env{'printer'}=$printer;
$env{'queue'}=$printer;

my $message = $query->param('message');
my $error = $query->param('error');
my $borrowerslist;
my $CGIselectborrower;
my $CGIselectbarcode;
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
		my @values;
		my %labels;
		foreach (@$borrowers){
			push @values,$_->{'borrowernumber'};
			$labels{$_->{'borrowernumber'}} ="$_->{'surname'}, $_->{'firstname'} ($_->{'cardnumber'})";
		}
		$CGIselectborrower=CGI::scrolling_list( -name     => 'borrnumber',
			-values   => \@values,
			-labels   => \%labels,
			-size     => 7,
			-multiple => 0 
		);
	}
}

# Si hay errores, se genera un arreglo con el codigo de barra del item que genero el error y el string
# correspondiente
if($error){
	my @codsErrores=split("/",$query->param('codError'));
	my @errores;
	my @array;
	my $info;
	my $j=0;
	foreach my $err (@codsErrores){
		@array=split("-",$err);
		my $numeroItem=$array[0];
		my $strError=$array[1];
		$info= getiteminformation( \%env, $numeroItem);
		$errores[$j]->{'barcode'}=$info->{'barcode'};
		$errores[$j]->{'string'}=procesarStr($strError);;
		$j++;
	}
$template->param(errores=>\@errores);
}

my $print=$query->param('print');
my $bornum = $query->param('borrnumber');
my $itemnumber = $query->param('itemnumber') || $query->param('ticket');

my $strItemnumber="";
# if ($iteminfo->{'barcode'} eq ''  && $print eq 'maybe'){
# 	$print = 'yes';
# }
if ($print eq 'yes' && $bornum ne ''){
	printslip(\%env,$bornum);
	$query->param('borrnumber','');
	$bornum='';
}

# get the borrower information.....
my $borrower;
my $flags;
my $hash;
my $max= getmaxissues();
$template->param(issues_max =>$max);

if($bornum){
	($borrower, $flags, $hash) = getpatroninformation(\%env,$bornum,0);
	if ($query->param('ticket')){ # se realizo el prestamo
		$ticket_borrower = $borrower;
		my $barcodes="";
		my @itemPrestados=split("/",$query->param('ticket'));
		my $i=0;
		foreach my $itemnumber (@itemPrestados){
			$iteminfo= getiteminformation( \%env, $itemnumber);
			$ticket_string=crearTicket($iteminfo,$loggedinuser);
			$tickets[$i]->{'ticket_string'}=$ticket_string;
			$tickets[$i]->{'number'}=$i;
			$barcodes.=", ".$iteminfo->{'barcode'};
			$i++;
		}
		$message="Se prest&oacute; el/los ejemplar/es".$barcodes." al usuario ".$ticket_borrower->{'firstname'} . " " . $ticket_borrower->{'surname'};
	} 
	else{
		for(my $i=0;$i<$loop;$i++){
			my $itemnumber=$chkbox[$i];
			$strItemnumber.=$itemnumber."#";
			$iteminfo= getiteminformation( \%env, $itemnumber);
			my ($total,$forloan,$notforloan,$unavailable,$issue,$issuenfl,$reserve,$shared,$copy,@results)=allitems($iteminfo->{'biblioitemnumber'},'intranet');
			
#Los disponibles son los prestados + los reservados + los que se pueden prestar + los de sala
			my $available= $issue+ $issuenfl + $reserve + $forloan + $notforloan;
			my @values;
			my %labels;
			foreach (@results){
				if (!$_->{'issued'} && (($iteminfo->{'notforloan'} && $_->{'notforloan'}) || (!$iteminfo->{'notforloan'} && $_->{'forloan'}))){ 
#solo pone los items que no estan prestados
					push @values,$_->{'itemnumber'};
					$labels{$_->{'itemnumber'}} ="$_->{'barcode'}";
				}
			}
			my $CGIselectbarcode=CGI::scrolling_list(
				-name => 'itemnumber'.$i,
				-values => \@values,
				-labels => \%labels,
				-default => $iteminfo->{'itemnumber'}, 
				-size => 1,
				-multiple => 0
			);

			my $defaultissuetype= C4::Context->preference('defaultissuetype');
# 			my ($valuesIss,$labelsIss)=&IssuesType2($iteminfo->{'notforloan'});
#Miguel - estoy probando esta funcion, para que muestre los tipos de prestamos en los que el usuario no 
#esta sancionado
			my ($valuesIss,$labelsIss)=&IssuesType3($iteminfo->{'notforloan'}, $bornum);
			
#para verificar si se tiene q mostrar el combo de tipos de prestamos o no
#ya que el usuario puede estar sancionado para un tipo de prestamo en particular y el combo puede vernir vacio
			my $selectissuetypecant= scalar(@$valuesIss);
			$template->param(seletcIssueTypeEnabled => $selectissuetypecant);

			my $selectissuetype=CGI::scrolling_list(
				-name => 'issuetype'.$i,
				-values => $valuesIss,
				-labels => $labelsIss,
				-default => $defaultissuetype,
				-size => 1,
				-multiple => 0
			);

			$infoTotal[$i]->{'iteminfo'}=$iteminfo;
			$infoTotal[$i]->{'itemnumber'}=$itemnumber;
			$infoTotal[$i]->{'author'}=$iteminfo->{'author'};
			$infoTotal[$i]->{'title'}=$iteminfo->{'title'};
			$infoTotal[$i]->{'unititle'}=$iteminfo->{'unititle'};
			$infoTotal[$i]->{'edition'}=$iteminfo->{'number'};
			$infoTotal[$i]->{'codbarra'}=$CGIselectbarcode;
			$infoTotal[$i]->{'tipoprest'}=$selectissuetype;
		}
#Fin de lo agregado por Luciano para los tipos de prestamo
	}
	if ($branchcookie) {
		$cookie=[$cookie, $branchcookie, $printercookie];
	}

# Si esta bien con los libros...
# Obtengo el maximo de prestamos que se pueden pedir, veo la cantidad de prestamos
# realizados por el usuario y a partir de ahi genero los mensajes para mandar al tmpl
# Verifica si tiene sanciones
	my ($cant, @issuetypes) = PrestamosMaximos ($bornum);

#$template->param(cant_issues =>$cant_issues);
##########################FIXME###############################################################################
#$template->param(all_issues =>1) if ($cant_issues == $max); # el usuario tiene todos los libros permitidos...
	$template->param(MAXISSUES => \@issuetypes);# if ($cant > 0); # el usuario tiene mas libros de los permitidos...
##############################################################################################################
	my $sanctions = hasSanctions($bornum);
	
	my $dateformat = C4::Date::get_date_format();
	foreach my $san (@$sanctions) {
		if ($san->{'itemnumber'}) {
			my $aux=itemdata3($san->{'itemnumber'}); 
			$san->{'description'}.=": ".$aux->{'title'}." (".$aux->{'author'}.") "; 
		}

		if ($san->{'reservaNoRetiradaVencida'}){
		#Miguel - Tiene reserva no retirada vencida, no se le muestra el combo para prestar
			$template->param(reservaNoRetiradaVencida =>$san->{'reservaNoRetiradaVencida'});
		}
	$san->{'enddate'}=format_date($san->{'enddate'},$dateformat);
	$san->{'startdate'}=format_date($san->{'startdate'},$dateformat);
	}

	$template->param(sanctions =>$sanctions);
	my $debts= tieneLibroVencido("", $bornum); # indica si el usuario tiene libros vencidos
	$template->param(debts =>$debts);
} #end if (bornum)

# now the reserved items....
my ($rescount, $reserves) = DatosReservas ($bornum);
my @realreserves;
my @waiting;
my $rcount = 0;
my $wcount = 0;
my $clase1='par';
my $clase2='par';
my $dateformat = C4::Date::get_date_format();
foreach my $res (@$reserves) {
	$res->{'rreminderdate'} = format_date($res->{'rreminderdate'},$dateformat);
	$res->{'rnotificationdate'}  = format_date($res->{'rnotificationdate'},$dateformat);
	$res->{'rreminderdate'}  = format_date($res->{'rreminderdate'},$dateformat);

	#Corregido 13/03/07 Miguel
	#obtengo el autor
 	my $author=getautor($res->{'rauthor'});
	#guardo el Apellido, Nombre del autor
	$res->{'rauthor'} = $author->{'completo'}; #le paso Apellido y Nombre
	#guardo el ID de autor para luego hacer busqueda por este campo
	$res->{'id'} = $author->{'id'}; #le paso el Id del autor  

	if ($res->{'ritemnumber'}) {
		$clase1= ($clase1 eq 'par')?'impar':'par';
		$res->{'clase'}= $clase1;
		$res->{'rbranch'} = $branches->{$res->{'rbranch'}}->{'branchcode'};
		push @realreserves, $res;
		$rcount++;
	} else { 
		$clase2= ($clase2 eq 'par')?'impar':'par';
		$res->{'clase'}= $clase2;
		push @waiting, $res;
		$wcount++;
	} 
}#end for

$template->param(
		findborrower => $findborrower,
		borrower => $borrower,
		borrowernumber => $bornum,
		branch => $branch,
		printer => $printer,
		branchname => $branches->{$branch}->{'branchname'},
		printername => $printers->{$printer}->{'printername'},
		firstname => $borrower->{'firstname'},
		surname => $borrower->{'surname'},
		zipcode => $borrower->{'zipcode'},
		categorycode => &C4::AR::Busquedas::getborrowercategory($borrower->{'categorycode'}),
		documenttype => $borrower->{'documenttype'},
		documentnumber => $borrower->{'documentnumber'},
		emailaddress => $borrower->{'emailaddress'},
		streetaddress => $borrower->{'streetaddress'},
		city => &darCiudad($borrower->{'city'}),
		phone => $borrower->{'phone'},
		cardnumber => $borrower->{'cardnumber'},
 		barcode => $iteminfo->{'barcode'},
		edition => $iteminfo->{'number'},
 		volume => $iteminfo->{'volume'},
 		itemnumber => $itemnumber,
 		biblioitemnumber => $iteminfo->{'biblioitemnumber'},
		message => $message,
		error => $error,
		CGIselectborrower => $CGIselectborrower,
		CGIselectbarcode => $CGIselectbarcode,
		notforloan => $iteminfo->{'notforloan'},
		author => $iteminfo->{'author'},
		title => $iteminfo->{'title'},
		unititle => $iteminfo->{'unititle'},
		RESERVES => \@realreserves,
		reserves_count => $rcount,
		WAITRESERVES => \@waiting,
		waiting_count => $wcount,
#agregado damian para prestar varios items
		chkbox     =>join(",",@chkbox),
		strItemnumber => $strItemnumber,
		infoTotal => \@infoTotal,
		ticket_string => \@tickets,
);


output_html_with_http_headers $query, $cookie, $template->output;

####################################################################
# Extra subroutines
# FIXME - This clashes with &C4::Print::printslip
sub printslip {
    my ($env,$bornum)=@_;
    my ($borrower, $flags) = getpatroninformation($env,$bornum,0);
    $env->{'todaysissues'}=1;
    my ($borrowerissues) = currentissues($env, $borrower);
    $env->{'nottodaysissues'}=1;
    $env->{'todaysissues'}=0;
    my ($borroweriss2)=currentissues($env, $borrower);
    $env->{'nottodaysissues'}=0;
    my $i=0;
    my @issues;
    foreach (sort {$a <=> $b} keys %$borrowerissues) {
	$issues[$i]=$borrowerissues->{$_};
	my $dd=$issues[$i]->{'date_due'};
	#convert to nz style dates
	#this should be set with some kinda config variable
	my @tempdate=split(/-/,$dd);
	$issues[$i]->{'date_due'}="$tempdate[2]/$tempdate[1]/$tempdate[0]";
	$i++;
    }
    foreach (sort {$a <=> $b} keys %$borroweriss2) {
	$issues[$i]=$borroweriss2->{$_};
	my $dd=$issues[$i]->{'date_due'};
	#convert to nz style dates
	#this should be set with some kinda config variable
	my @tempdate=split(/-/,$dd);
	$issues[$i]->{'date_due'}="$tempdate[2]/$tempdate[1]/$tempdate[0]";
	$i++;
    }
    remoteprint($env,\@issues,$borrower);
}

sub procesarStr(){
	my ($strError)=@_;
	if($strError eq "SANCIONADO_O_LIBROS_VENCIDOS"){ 
		return "El usuario est&aacute; sancionado o tiene libros vencidos";
	}
	elsif($strError eq "SUPERA_MAX_RESERVAS"){
		return "El usuario supera el n&uacute;mero m&aacute;ximo de reservas";
	}
	elsif($strError eq "YA_TIENE_PRESTAMO_SOBRE_EL_GRUPO"){
		return "El usuario ya tiene un pr&eacute;stamo sobre este grupo";
	}
	elsif($strError eq "NO_HAY_MAS_EJEMPLARES_RESERVA_SOBRE_GRUPO"){
		return "No hay m&aacute;s ejemplares disponibles, se realiz&oacute; una reserva sobre el grupo";
	}
	elsif($strError eq "NO_HAY_MAS_EJEMPLARES_NO_RESERVA"){
		return "No hay m&aacute;s ejemplares disponibles y no puede hacer m&aacute;s reservas porque lleg&oacute; el l&iacute;mite";
	}elsif($strError eq "NO_HAY_MAS_EJEMPLARES_NO_RESERVA_INTRANET"){
		return "No hay m&aacute;s ejemplares disponibles";
	}
	elsif($strError eq "IRREGULAR"){
		return "El usuario no es un alumno regular";
	}
	elsif($strError eq "YA_TIENE_TODOS_LOS_EJEMPLARES_PARA_EL_TIPO_DE_PRESTAMO"){
		return "El usuario supera el n&uacute;mero m&aacute;ximo de ejemplares para ese tipo de pr&eacute;stamo.";
	}
	elsif($strError eq "NO_ES_HORA_DEL_PRESTAMO_ESPECIAL"){
		return "Estamos fuera del horario de realizaci&oacute;n del pr&eacute;stamo especial.";
	}
	elsif($strError eq "FALTAN_PARAMETROS"){
		return "por falta par&aacute;metros";
	}
	elsif($strError eq "EL_DOCUMENTO_ESTA_PRESTADO"){
		return "El documento esta prestado, seleccione otro c&oacute;digo de barra";
	}
}

# Local Variables:
# tab-width: 8
# End:
