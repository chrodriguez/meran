#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::Auth;       # get_template_and_user
use C4::Interface::CGI::Output;

my $input = new CGI;
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

my ($template, $session, $t_params)= get_template_and_user({
									template_name => "opac-main.tmpl",
									type => "opac",
									query => $input,
									authnotrequired => 1,
									flagsrequired => {borrow => 1},
			 });

#AGREGADO PARA MANDARLE AL USUARIO UN NUMERO RANDOM PARA QUE REALICE UN HASH
my $random_number_i= int(rand()*100000);


$t_params->{'CGIitemtype'}= $CGIitemtype;
$t_params->{'RANDOM_NUMBER_INICIAL'}= $random_number_i;
$t_params->{'LibraryName'}= C4::Context->preference("LibraryName");

C4::Auth::output_html_with_http_headers($query, $template, $t_params, $session);
