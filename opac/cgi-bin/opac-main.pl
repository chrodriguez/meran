#!/usr/bin/perl
use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::Auth;
use C4::Context;
use CGI;
use CGI::Session;

my $input = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
									template_name => "opac-main.tmpl",
									type => "opac",
									query => $input,
									authnotrequired => 1,
									flagsrequired => {borrow => 1},
			 });


## FIXME usar generador de combo para itemtypes
my $dbh = C4::Context->dbh;
my $query="Select itemtype,description from itemtypes order by description";
my $sth=$dbh->prepare($query);
$sth->execute;
my  @itemtype;
my %itemtypes;
while (my ($value,$lib) = $sth->fetchrow_array) {
	push @itemtype, $value;
	$itemtypes{$value}=$lib;
}

my $CGIitemtype=CGI::scrolling_list( -name     => 'itemtype',
			-values   => \@itemtype,
			-labels   => \%itemtypes,
			-size     => 1,
			-multiple => 0 );
$sth->finish;

open(A, ">>/tmp/debug.txt");
print A "desde opac-main: \n";
if( $session->param('borrowernumber') ){
print A "tengo borrower: ".$session->param('borrowernumber')."\n";
}else{
    #se inicializa la session y demas parametros para autenticar
    ($session)= C4::Auth::inicializarAuth($input, $t_params);
}
close(A);
$t_params->{'CGIitemtype'}= $CGIitemtype;
$t_params->{'LibraryName'}= C4::AR::Preferencias->getValorPreferencia("LibraryName");

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
