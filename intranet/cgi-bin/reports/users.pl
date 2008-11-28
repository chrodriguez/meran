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
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Estadisticas;
use C4::AR::Busquedas;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                                                template_name => "reports/users.tmpl",
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
my $branches=C4::AR::Busquedas::getBranches();
foreach my $branch (keys %$branches) {
        push @select_branch, $branch;
        $select_branches{$branch} = $branches->{$branch}->{'branchname'};
}


my  $branch=$input->param('branch');
($branch ||(C4::Context->preference('defaultbranch') ));

my $CGIbranch=CGI::scrolling_list(      -name      => 'branch',
                                        -id        => 'branch',
                                        -values    => \@select_branch,
					-defaults  => $branch,
                                        -labels    => \%select_branches,
                                        -size      => 1,
                                 );

#Fin: Por los branches

#CATEGORIAS
my ($valuesCateg,$labelsCateg)=C4::AR::Usuarios::obtenerCategorias();
my $CGIcateg=CGI::scrolling_list(    -name      => 'categoria',
                                     -id        => 'categoria',
                                     -values    => $valuesCateg,
				     -defaults  => $branch,
                                     -labels    => $labelsCateg,
                                     -size      => 1,
                                 );
#Para los a�os
my @date=localtime;
my $year_Default= $date[5]+1900;
my @years;
for (my $i =2005 ; $i < 2036; $i++){
	push (@years,$i);
}
my $years=CGI::scrolling_list(  -name      => 'year',
				-id	   => 'year',
                                -values    => \@years,
                                -defaults  => $year_Default,
                                -size      => 1,
                                 );
#fin a�os

$t_params->{'unidades'}= $CGIbranch;
$t_params->{'categorias'}= $CGIcateg;
$t_params->{'years'}= $years;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);