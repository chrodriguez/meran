#!/usr/bin/perl

#script to administer the senction rules
#written 25/07/2005 by Luciano Iglesias (li@info.unlp.edu.ar)
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
use C4::Context;
use C4::Output;
use C4::Search;
use HTML::Template;
use C4::Auth;
use C4::Interface::CGI::Output;

my $input = new CGI;
my $issue= $input->param('issuetypes') || undef;
my $category= $input->param('categories') || undef;
my @issuestypes= $input->param('issuestypes');

#FIXME salvar los valores enviados y ver que se hizo clic en Guardar
#open L,">/tmp/lucho";
#my $v;
#foreach $v (@issuestypes) { 
#	printf L  "$v\n";
#}

sub in_array() {
	my $val = shift @_ || return 0;
	my @array = @_;
	foreach (@array)
		{ return 1 if ($val eq $_); }
	return 0;
}

my $sugestedOrder= 1;
my $sanctiontypecode= undef;
my $dbh = C4::Context->dbh;

my $action= $input->param('accion') || undef;
if ($action eq 'delete') {
	my $sanctiontypecode1= $input->param('sanctiontypecode');
	my $sanctionrulecode= $input->param('sanctionrulecode');
	my $sth = $dbh->prepare("delete from sanctiontypesrules where sanctiontypecode = ? and sanctionrulecode = ?");
	$sth->execute($sanctiontypecode1, $sanctionrulecode);
} elsif ($action eq 'add') {
	my $order= $input->param('orders');
	my $amount= $input->param('amounts');
	my $sanctiontypecode1= $input->param('sanctiontypecode');
	my $sanctionrulecode= $input->param('rules');
	my $sth = $dbh->prepare("insert into sanctiontypesrules (sanctiontypecode,sanctionrulecode,sanctiontypesrules.order,amount) values (?,?,?,?)");
	$sth->execute($sanctiontypecode1, $sanctionrulecode, $order, $amount);
}

my ($template, $loggedinuser, $cookie) 
    = get_template_and_user({template_name => "parameters/sanctions.tmpl",
                             query => $input,
                             type => "intranet",
			     flagsrequired => {parameters => 1},
			     authnotrequired => 0,
                             debug => 1,
                             });

my $sth = $dbh->prepare("select * from issuetypes order by description");
$sth->execute();
my %issueslabels;
my @issuesvalues;
while (my $res = $sth->fetchrow_hashref) {
	$issue= $res->{'issuecode'} unless $issue;
	push @issuesvalues, $res->{'issuecode'};
	$issueslabels{$res->{'issuecode'}} = $res->{'description'};
}
$sth->finish;
my $CGIissuetypes=CGI::scrolling_list( 
			-name => 'issuetypes',
                        -values   => \@issuesvalues,
                        -labels   => \%issueslabels,
			-default => $issue,
			-onChange => "submit();",
                        -size     => 1,
                        -multiple => 0 );

my $sth = $dbh->prepare("select * from categories order by description");
$sth->execute();
my %categorieslabels;
my @categoriesvalues;
while (my $res = $sth->fetchrow_hashref) {
	$category= $res->{'categorycode'} unless $category;
        push @categoriesvalues, $res->{'categorycode'};
        $categorieslabels{$res->{'categorycode'}} = $res->{'description'};
}
$sth->finish;
my $CGIcategories=CGI::scrolling_list(
                        -name => 'categories',
                        -values   => \@categoriesvalues,
                        -labels   => \%categorieslabels,
			-default => $category,
			-onChange => "submit();",
                        -size     => 1,
                        -multiple => 0 );


my $sth = $dbh->prepare("select *,issuetypes.description as descissuetype, categories.description as desccategory from sanctiontypes inner join sanctiontypesrules on sanctiontypes.sanctiontypecode = sanctiontypesrules.sanctiontypecode inner join sanctionrules on sanctiontypesrules.sanctionrulecode = sanctionrules.sanctionrulecode inner join issuetypes on sanctiontypes.issuecode = issuetypes.issuecode inner join categories on categories.categorycode = sanctiontypes.categorycode where sanctiontypes.issuecode = ? and sanctiontypes.categorycode = ? order by sanctiontypesrules.order");
$sth->execute($issue, $category);
my @sanctionsarray;
while (my $res = $sth->fetchrow_hashref) {
	$sanctiontypecode= $res->{'sanctiontypecode'} unless $sanctiontypecode;
	($res->{'amount'} eq '0')?$res->{'amount'}='Infinito':undef;
        push (@sanctionsarray, $res);
}
$sth->finish;

unless ($sanctiontypecode) {
	my $sth = $dbh->prepare("select * from sanctiontypes where issuecode = ? and categorycode = ?");
	$sth->execute($issue, $category);
	my $res;
	if ($res= $sth->fetchrow_hashref) {
		$sanctiontypecode= $res->{'sanctiontypecode'};
	} else {
		my $sth = $dbh->prepare("insert into sanctiontypes (issuecode,categorycode) values (?,?)");
		$sth->execute($issue, $category);
		my $sth = $dbh->prepare("select * from sanctiontypes where issuecode = ? and categorycode = ?");
		$sth->execute($issue, $category);
		$res= $sth->fetchrow_hashref;
		$sanctiontypecode= $res->{'sanctiontypecode'};
	}
}

if ($action eq 'issuestypes') {
	my $sth = $dbh->prepare("delete from sanctionissuetypes where sanctiontypecode = ?");
	$sth->execute($sanctiontypecode);
	my $i;
	foreach $i (@issuestypes) { 
		my $sth = $dbh->prepare("insert into sanctionissuetypes (sanctiontypecode,issuecode) values (?,?)");
		$sth->execute($sanctiontypecode,$i);
	}
}


my $sth = $dbh->prepare("select * from sanctionrules order by delaydays, sanctiondays");
$sth->execute();
my %ruleslabels;
my @rulesvalues;
while (my $res = $sth->fetchrow_hashref) {
	push @rulesvalues, $res->{'sanctionrulecode'};
	$ruleslabels{$res->{'sanctionrulecode'}} = "Dias de demora: ".$res->{'delaydays'}.". Dias de sancion: ".$res->{'sanctiondays'};
}
$sth->finish;
my $CGIrules=CGI::scrolling_list(
                        -name => 'rules',
                        -values   => \@rulesvalues,
                        -labels   => \%ruleslabels,
                        -size     => 1,
                        -multiple => 0 );

if ($sanctiontypecode) {
	my $sth= $dbh->prepare("select max(sanctiontypesrules.order) from sanctiontypesrules where sanctiontypecode = ?");
	$sth->execute($sanctiontypecode);
	my $data= $sth->fetchrow_array;
	$sugestedOrder=  $data + 1;
}

my %orders;
my @orders;
for (my $i=1; $i < 21; $i++) {
        push @orders, $i;
        $orders{$i} = $i;
}
$sth->finish;
my $CGIorders=CGI::scrolling_list(
                        -name => 'orders',
                        -values   => \@orders,
                        -labels   => \%orders,
			-default => $sugestedOrder,
                        -size     => 1,
                        -multiple => 0 );

my %amounts;
my @amounts;
push @amounts, 0;
$amounts{0} = "Infinito";
for (my $i=1; $i < 21; $i++) {
        push @amounts, $i;
        $amounts{$i} = $i;
}
$sth->finish;
my $CGIamounts=CGI::scrolling_list(
                        -name => 'amounts',
                        -values   => \@amounts,
                        -labels   => \%amounts,
                        -default => 1,
                        -size     => 1,
                        -multiple => 0 );


my $sth= $dbh->prepare("SELECT * FROM sanctionissuetypes where sanctiontypecode = ?");
$sth->execute($sanctiontypecode);
my @issuescodes;
while (my $res = $sth->fetchrow_hashref) {
        push @issuescodes, $res->{'issuecode'};
}

my $sth= $dbh->prepare("SELECT * FROM issuetypes ORDER BY description");
$sth->execute();
my @issues;
while (my $res = $sth->fetchrow_hashref) {
	$res->{'checked'}= &in_array($res->{'issuecode'}, @issuescodes);
        push @issues, $res;
}
$sth->finish;

$template->param(
	issues => \@issues,
	amounts => $CGIamounts,
	orders => $CGIorders,
	sanctiontypecode => $sanctiontypecode, 
	loop_sanctions_types => \@sanctionsarray,
	sanctions_rules => $CGIrules,
	issues_types => $CGIissuetypes,
	categories => $CGIcategories
);

output_html_with_http_headers $input, $cookie, $template->output;
