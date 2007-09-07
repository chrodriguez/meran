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
use C4::Reserves2;
use C4::Output;
use C4::Print;
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
my $input=new CGI;
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
my $dbh = C4::Context->dbh;

## Para el ticket
my $ticket_print = 0;
my $ticket_duedate;
my $iteminfo;
my $ticket_string;
my $ticket_borrower;

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

# check and see if we should print
$template->param($query->param('codError')=>1) if $query->param('codError');
my $print=$query->param('print');
my $bornum = $query->param('borrnumber');
my $itemnumber = $query->param('itemnumber') || $query->param('ticket');
my $iteminfo= getiteminformation( \%env, $itemnumber);

if ($iteminfo->{'barcode'} eq ''  && $print eq 'maybe'){
	$print = 'yes';
}
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

if ($bornum) {
    ($borrower, $flags, $hash) = getpatroninformation(\%env,$bornum,0);

    if ($query->param('ticket')){ # se realizo el prestamo
	    $ticket_duedate = vencimiento($itemnumber);
	    $ticket_borrower = $borrower;
	    $ticket_string = 
		    "?borrowerName=" . CGI::Util::escape($ticket_borrower->{'firstname'} . " " . $ticket_borrower->{'surname'}) .
		    "&borrowerNumber=" . CGI::Util::escape($ticket_borrower->{'cardnumber'}) .
		    "&author=" . CGI::Util::escape($iteminfo->{'author'}) .
		    "&bookTitle=" . CGI::Util::escape($iteminfo->{'title'}) .
		    "&topoSign=" . CGI::Util::escape($iteminfo->{'bulk'}) .
		    "&barcode=" . CGI::Util::escape($iteminfo->{'barcode'}) .
		    "&borrowDate=" . CGI::Util::escape(format_date_hour(ParseDate("today"))) .
		    "&returnDate=" . CGI::Util::escape(format_date($ticket_duedate)) .
		    "&librarian=" . CGI::Util::escape($template->param('loggedinusername')).
		    "&issuedescription=" . CGI::Util::escape($iteminfo->{'issuedescription'}).
		    "&librarianNumber=" . $loggedinuser;

	    $message="Se prest&oacute; el ejemplar ".$iteminfo->{'barcode'}." al usuario ".$ticket_borrower->{'firstname'} . " " . $ticket_borrower->{'surname'};
    } else {
	my ($total,$available,$forloan,$notforloan,$unavailable,$issue,$shared,@results)=allitems($iteminfo->{'biblioitemnumber'},'intranet');
	my @values;
	my %labels;
	foreach (@results){
		if (!$_->{'issued'} && (($iteminfo->{'notforloan'} && $_->{'notforloan'}) || (!$iteminfo->{'notforloan'} && $_->{'forloan'}))) { #solo pone los items que no estan prestados
			push @values,$_->{'itemnumber'};
			$labels{$_->{'itemnumber'}} ="$_->{'barcode'}";
		}
	}

	$CGIselectbarcode=CGI::scrolling_list(
			-name => 'itemnumber',
			-values => \@values,
			-labels => \%labels,
			-default => $iteminfo->{'itemnumber'}, 
			-size => 1,
			-multiple => 0
			);
    }

#Agregado por Luciano para poner los tipos de prestamos existentes
my $defaultissuetype= C4::Context->preference('defaultissuetype');
$template->param(issuetypes =>sanctionSelect($dbh,$defaultissuetype,undef,$iteminfo->{'notforloan'}));
#Fin de lo agregado por Luciano para los tipos de prestamo

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
$template->param(sanctions =>$sanctions);
my $debts= hasDebts($dbh, $bornum); # indica si el usuario tiene libros vencidos
$template->param(debts =>$debts);
} # if (bornum)

# now the reserved items....
my ($rescount, $reserves) = DatosReservas ($bornum);
my @realreserves;
my @waiting;
my $rcount = 0;
my $wcount = 0;
my $clase1='par';
my $clase2='par';
foreach my $res (@$reserves) {
	$res->{'rreminderdate'} = format_date($res->{'rreminderdate'});
	$res->{'rnotificationdate'}  = format_date($res->{'rnotificationdate'});
	$res->{'rreminderdate'}  = format_date($res->{'rreminderdate'});

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
}

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
		categorycode => &getborrowercategory($borrower->{'categorycode'}),
		documenttype => $borrower->{'documenttype'},
		documentnumber => $borrower->{'documentnumber'},
		emailaddress => $borrower->{'emailaddress'},
		streetaddress => $borrower->{'streetaddress'},
		city => $borrower->{'city'},
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
		ticket_string => $ticket_string,
		notforloan => $iteminfo->{'notforloan'},
		author => $iteminfo->{'author'},
		title => $iteminfo->{'title'},
		unititle => $iteminfo->{'unititle'},
		RESERVES => \@realreserves,
		reserves_count => $rcount,
		WAITRESERVES => \@waiting,
		waiting_count => $wcount
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

# Local Variables:
# tab-width: 8
# End:
