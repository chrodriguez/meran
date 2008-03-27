#!/usr/bin/perl



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
#

use strict;
use C4::Auth;
use C4::Output;
use C4::Koha;
use C4::Search;
use C4::Interface::CGI::Output;
use CGI;
use HTML::Template;
use PDF::Report;
use C4::AR::PdfGenerator;

my $input = new CGI;
my  $orden=$input->param('orden');
my  $op=$input->param('op');
my  $surname1=$input->param('surname1');
my  $surname2=$input->param('surname2');
my  $legajo1=$input->param('legajo1');
my  $legajo2=$input->param('legajo2');
my  $category=$input->param('category');
my  $regular=$input->param('regular');
my  $branch=$input->param('branch');
my  $count=0;
my  @results=();


if ($category eq ''){$category='Todos';}
if ($regular eq ''){$regular='Todos';}

if ($op ne ''){
 ($count,@results)=BornameSearchForCard($surname1,$surname2,$category,$branch,$orden,$regular,$legajo1,$legajo2);
		}

if ($op eq 'pdf') {
#HAY QUE GENERAR EL PDF CON LOS CARNETS
my $tmpFileName= "carnets.pdf";
my $pdf = batchCardsGenerator($count,@results);
print "Content-type: application/pdf\n";
print "Content-Disposition: attachment; filename=\"$tmpFileName\"\n\n";
print $pdf->Finish();

}
else
{

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/users-cards.tmpl",

			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

#Por los braches
my @branches;
my @select_branch;
my %select_branches;
my $branches=getbranches();
foreach my $branch (keys %$branches) {
        push @select_branch, $branch;
        $select_branches{$branch} = $branches->{$branch}->{'branchname'};
}

my $branch= C4::Context->preference('defaultbranch');

my $CGIbranch=CGI::scrolling_list(      -name      => 'branch',
                                        -id        => 'branch',
                                        -values    => \@select_branch,
					-defaults  => $branch,
                                        -labels    => \%select_branches,
                                        -size      => 1,
                                 );

#Fin: Por los branches

my @categories;
my @select_category;
my %select_categories;
my $categories=getallborrowercategorys();
foreach my $category (keys %$categories) {
        push @select_category, $category;
        $select_categories{$category} = $categories->{$category}->{'description'};
}

push @select_category, 'Todos';

my $CGIcategories=CGI::scrolling_list(  -name      => 'category',
                                        -id        => 'category',
                                        -values    => \@select_category,
					-defaults  => $category,
                                        -labels    => \%select_categories,
                                        -size      => 1,
                                 );


my @select_regular;
my %select_regular;
#Lleno los datos del select de regulares
push @select_regular, '1';
push @select_regular, '0';
push @select_regular, 'Todos';
$select_regular{'1'} = 'Regular';
$select_regular{'0'} = 'Irregular';
$select_regular{'Todos'} = 'Todos';

my $CGIregular=CGI::scrolling_list(  -name      => 'regular',
                                        -id        => 'regular',
                                        -values    => \@select_regular,
					-defaults  => $regular,
                                        -labels    => \%select_regular,
                                        -size      => 1,
					);

if ($op eq 'search'){
#Se realiza la busqueda si al algun campo no vacio
$template->param(
		RESULTSLOOP=>\@results,
                cantidad=>$count
	               );
		
	}

$template->param(
		unidades => $CGIbranch,
		branch => $input->param('branch'),
		category => $input->param('category'),
		categories => $CGIcategories,
		orden => $orden,
		surname1=>$surname1,
		surname2=>$surname2,
		legajo1=>$legajo1,
		legajo2=>$legajo2,
		regular=>$regular,
		regulares=>$CGIregular
		);

output_html_with_http_headers $input, $cookie, $template->output;

}
