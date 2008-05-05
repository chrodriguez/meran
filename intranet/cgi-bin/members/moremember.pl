#!/usr/bin/perl

# $Id: moremember.pl,v 1.33.2.1 2003/12/22 10:40:55 tipaul Exp $

# script to do a borrower enquiry/bring up borrower details etc
# Displays all the details about a borrower
# written 20/12/99 by chris@katipo.co.nz
# last modified 21/1/2000 by chris@katipo.co.nz
# modified 31/1/2001 by chris@katipo.co.nz
#   to not allow items on request to be renewed
#
# needs html removed and to use the C4::Output more, but its tricky
#


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
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Interface::CGI::Template;
use CGI;
use C4::Search;
use Date::Manip;
use C4::Date;
#use C4::Reserves2;
use C4::AR::Reserves;
# use C4::Circulation::Renewals2;
use C4::Circulation::Circ2;
use C4::Koha;
use HTML::Template;
use C4::AR::VirtualLibrary; #Matias
use C4::AR::Issues;
use C4::AR::Sanctions;

my $dbh = C4::Context->dbh;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/moremember.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $bornum=$input->param('bornum');
my $mensaje=$input->param('mensaje');#Mensaje que viene desde libreDeuda si es que no se puede imprimir
#start the page and read in includes

my $data=borrdata('',$bornum);

$data->{'updatepassword'}= $data->{'changepassword'};

$template->param($data->{'categorycode'} => 1); # in template <TMPL_IF name="I"> => instutitional (A for Adult & C for children)

# Curso de usuarios#
  	if (C4::Context->preference("usercourse")){$data->{'course'}=1;}
#

$data->{'dateenrolled'} = format_date($data->{'dateenrolled'});
$data->{'expiry'} = format_date($data->{'expiry'});
$data->{'dateofbirth'} = format_date($data->{'dateofbirth'});
$data->{'IS_ADULT'} = ($data->{'categorycode'} ne 'I');

$data->{'ethnicity'} = fixEthnicity($data->{'ethnicity'});

$data->{&expand_sex_into_predicate($data->{'sex'})} = 1;
$data->{'city'}=&getcitycategory($data->{'city'});
$data->{'streetcity'}=&getcitycategory($data->{'streetcity'});

if ($data->{'categorycode'} eq 'C'){
	my $data2=borrdata('',$data->{'guarantor'});
	$data->{'streetaddress'}=$data2->{'streetaddress'};
	$data->{'city'}=&getcitycategory($data2->{'city'});
	$data->{'physstreet'}=$data2->{'physstreet'};
	$data->{'streetcity'}=&getcitycategory($data2->{'streetcity'});
	$data->{'phone'}=$data2->{'phone'};
	$data->{'phoneday'}=$data2->{'phoneday'};
	$data->{'zipcode'} = $data2->{'zipcode'};
}


if ($data->{'ethnicity'} || $data->{'ethnotes'}) {
	$template->param(printethnicityline => 1);
}

if ($data->{'categorycode'} ne 'C'){
	$template->param(isguarantee => 1);
	# FIXME
	# It looks like the $i is only being returned to handle walking through
	# the array, which is probably better done as a foreach loop.
	#
	my ($count,$guarantees)=findguarantees($data->{'borrowernumber'});
	my @guaranteedata;
	for (my $i=0;$i<$count;$i++){
		push (@guaranteedata, {borrowernumber => $guarantees->[$i]->{'borrowernumber'},
					cardnumber => $guarantees->[$i]->{'cardnumber'},
					name => $guarantees->[$i]->{'firstname'} . " " . $guarantees->[$i]->{'surname'}});
	}
	$template->param(guaranteeloop => \@guaranteedata);

} else {
	my ($guarantor)=findguarantor($data->{'borrowernumber'});
	unless ($guarantor->{'borrowernumber'} == 0){
		$template->param(guarantorborrowernumber => $guarantor->{'borrowernumber'}, guarantorcardnumber => $guarantor->{'cardnumber'});
	}
}

my %bor;
$bor{'borrowernumber'}=$bornum;

# Converts the branchcode to the branch name
$data->{'branchcode'} = &getbranchname($data->{'branchcode'});

# Converts the categorycode to the description
$data->{'categorycode'} = &getborrowercategory($data->{'categorycode'});

	# Curso de usuarios#
	if (C4::Context->preference("usercourse")){
	$data->{'usercourse'} = format_date($data->{'usercourse'});
	}
	####################

my ($numaccts,$accts,$total)=getboracctrecord('',\%bor);
my $issues = getissues(\%bor);
my $count=0;
my $venc=0;
my $overdues_count = 0;
my @overdues;
my @issuedat;
my $clase='par';
my $sanctions = hasSanctions($bornum);
foreach my $san (@$sanctions) {
if ($san->{'itemnumber'}) {my $aux=itemdata3($san->{'itemnumber'}); 
			   $san->{'description'}.=": ".$aux->{'title'}." (".$aux->{'author'}.") "; }
$san->{'enddate'}=format_date($san->{'enddate'});
$san->{'startdate'}=format_date($san->{'startdate'});
}
#


foreach my $key (keys %$issues) {
    my $issue = $issues->{$key};
    $issue->{'clase'} = $clase;
    $issue->{'date_due'} = format_date($issue->{'date_due'});

    my $err= "Error con la fecha";
    my $hoy=C4::Date::format_date_in_iso(ParseDate("today"));
    my  $close = ParseDate(C4::Context->preference("close"));
	if (Date::Manip::Date_Cmp($close,ParseDate("today"))<0){#Se paso la hora de cierre
		 $hoy=C4::Date::format_date_in_iso(DateCalc($hoy,"+ 1 day",\$err));}


    my $df=C4::Date::format_date_in_iso(vencimiento($issue->{'itemnumber'}));

    $issue->{'date_fin'} = format_date($df);
   
if (Date::Manip::Date_Cmp($df,$hoy)<0)
        { $venc=1;
          $issue->{'color'} ='red';
        }
#    $issue->{'date_fin'} = format_date(vencimiento($issue->{'itemnumber'}));
#    $venc= ($venc || (Date_Cmp(ParseDate("today"),ParseDate($issue->{'date_fin'})) > 0));

    $issue->{'renew'} = &sepuederenovar2($bornum, $issue->{'itemnumber'});
    if ($issue->{'overdue'}) {
        push @overdues, $issue;
        $overdues_count++;
        $issue->{'overdue'} = 1;
    } else {
        $issue->{'issued'} = 1;
    }
    push @issuedat, $issue;
    $count++;
    if ( $clase eq 'par' ) { $clase = 'impar'; } else {$clase = 'par'; }
	
}

#}

###Einar  Los libros en espera y reservados
my $branches = getbranches();
my ($rcount, $reserves) = DatosReservas($bornum);
my @realreserves;
my @waiting;
my $rcount = 0;
my $wcount = 0;
my $clase1='par';
my $clase2='par';
foreach my $res (@$reserves) {
    $res->{'clase'} = $clase;	
    $res->{'rreminderdate'} = format_date($res->{'rreminderdate'});

	my $author=getautor($res->{'rauthor'});  #Damian - 13/03/2007. Se corrigio para ver el nombre
        $res->{'rauthor'} = $author->{'completo'}; #del autor y no el id.
	$res->{'id'} = $author->{'id'}; 
    if ($res->{'ritemnumber'}) {
	my $item=itemdata2($res->{'ritemnumber'});

	

	$res->{'barcode'} = $item->{'barcode'};
	$res->{'bulk'} = $item->{'bulk'};

	$res->{'clase'} = $clase1;

        $res->{'rbranch'} = &getbranchname($branches->{$res->{'rbranch'}}->{'branchcode'}); #Damian - 13/03/2007. Se ve el nombre de la biblio y no el id.
        push @realreserves, $res;
        $rcount++;
	if ( $clase1 eq 'par' ) { $clase1 = 'impar'; } else {$clase1 = 'par'; }
    }
        else{
	$res->{'clase'} = $clase2;
        push @waiting, $res;
        $wcount++;
	if ( $clase2 eq 'par' ) { $clase2 = 'impar'; } else {$clase2 = 'par'; }
        }
}

#Matias: Esta habilitada la Biblioteca Virtual?
my $virtuallibrary=C4::Context->preference("virtuallibrary");
$template->param(virtuallibrary => $virtuallibrary);
if ($virtuallibrary eq 1)
{
	my ($count2,@requestdata) = allRequests($bornum);
	if ($count2 ne 0){
		$template->param( vrequest => 1, 
				 requestloop     => \@requestdata);
			}

}
#

#### Verifica si la foto ya esta cargada
my $picturesDir= C4::Context->config("picturesdir");
my $foto;
if (opendir(DIR, $picturesDir)) {
	my $pattern= $bornum."[.].";
	my @file = grep { /$pattern/ } readdir(DIR);
	$foto= join("",@file);
	closedir DIR;
} else {
	$foto= 0;
}
####

#### Verifica si hay problemas para subir la foto
my $msgFoto=$input->param('msg');
($msgFoto) || ($msgFoto=0);
####

#### Verifica si hay problemas para borrar un usuario
my $msgError=$input->param('error');
($msgError) || ($msgError=0);
####

$template->param($data);
$template->param(
		bornum          => $bornum,
		mensaje		=> $mensaje,
		totaldue          =>$total,
#los libros que tiene "en espera para retirar"
		waiting=> \@waiting,
#los libros que tiene esperando un ejemplar
		realreserves     => \@realreserves,
###
		issueloop       => \@issuedat,
		foto_name => $foto,
		sanctions       => $sanctions,
		mensaje_error_foto => $msgFoto,
		mensaje_error_borrar => $msgError,
	);
output_html_with_http_headers $input, $cookie, $template->output;
