#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Date;
use C4::AR::Busquedas;

my $query = new CGI;

my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "reports/reports-home.tmpl",
                                query => $query,
                                type => "intranet",
                                authnotrequired => 0,
                                flagsrequired => {permissions => 1},
                                debug => 1,
                                });

#Matias: Esta habilitada la Biblioteca Virtual?
my $virtuallibrary=C4::Context->preference("virtuallibrary");
$template->param(virtuallibrary => $virtuallibrary);
#


#Por los braches
my @branches;
my @select_branch;
my %select_branches;
my $branches=C4::AR::Busquedas::getBranches();
foreach my $branch (keys %$branches) {
        push @select_branch, $branch;
        $select_branches{$branch} = $branches->{$branch}->{'branchname'};
}

my $CGIbranch=CGI::scrolling_list(      -name      => 'unidadesInformacion',
                                        -id        => 'branch',
                                        -values    => \@select_branch,
                                        -labels    => \%select_branches,
                                        -size      => 1,
                                        -multiple  => 0,
                                 );
#Fin: Por los branches

###Marca la Fecha de Hoy

my @datearr = localtime(time);
my $today =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
my $dateformat = C4::Date::get_date_format();
$template->param( todaydate => format_date($today,$dateformat));

###
$template->param( 
		   listaUnidades        => $CGIbranch
		);
output_html_with_http_headers $query, $cookie, $template->output;
