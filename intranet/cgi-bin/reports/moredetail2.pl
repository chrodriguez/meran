#!/usr/bin/perl
#ver bien que archivos hay que usar

use HTML::Template;
use strict;
require Exporter;
use C4::Koha;
use CGI;
use C4::Search;
use C4::Catalogue;
use C4::Output; # contains gettemplate
#use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Date;

	
	my $input = new CGI;
	my $bib=   $input->param('bib');
	my $tipo=  $input->param('tipo');
	
	my $query;
	my $biblionumber;
	
	my $dbh = C4::Context->dbh;
		
	if($tipo eq 'Grupo'){
		
		$query="Select biblionumber  
		from biblioitems
                where biblioitemnumber=? ";
	}
	elsif($tipo eq 'Ejemplar'){
		$query="Select biblionumber  
		from items
               	where itemnumber=? ";
	}
	

	if($tipo eq 'Libro'){
		$biblionumber = $bib;
	}
	else
	{	#busco el biblionumber
        	my $sth=$dbh->prepare($query);
        	$sth->execute($bib);

		my $data=$sth->fetchrow_hashref;
		$biblionumber = $data->{'biblionumber'};
	}


print $input->redirect("/cgi-bin/koha/detail.pl?bib=$biblionumber");



