#!/usr/bin/perl


use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::PdfGenerator;
use C4::AR::Busquedas;

my $input = new CGI;

my $op=$input->param('op');

if ($op eq 'pdf') {

my $orden=$input->param('orden');
my $surname1=$input->param('surname1');
my $surname2=$input->param('surname2');
my $legajo1=$input->param('legajo1');
my $legajo2=$input->param('legajo2');
my $category=$input->param('category');
my $regular=$input->param('regular');
my $branch=$input->param('branch');
my $count=0;
my @results=();

($count,@results)=C4::AR::Usuarios::BornameSearchForCard($surname1,$surname2,$category,$branch,$orden,$regular,$legajo1,$legajo2);


#HAY QUE GENERAR EL PDF CON LOS CARNETS
&batchCardsGenerator($count,@results);

}
else
{

my ($template, $session, $t_params) = get_template_and_user({
                                                template_name => "reports/users-cards.tmpl",
                                                query => $input,
                                                type => "intranet",
                                                authnotrequired => 0,
                                                flagsrequired => {borrowers => 1},
                                                debug => 1,
			    });
#Por los branches

#Por los braches
my @branches;
my @select_branch;
my %select_branches;
my $branches=C4::AR::Busquedas::getBranches();
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


my ($select_category,$select_categories)=C4::AR::Usuarios::obtenerCategorias();

push @$select_category, 'Todos';

my $CGIcategories=CGI::scrolling_list(  -name      => 'category',
                                        -id        => 'category',
                                        -values    => $select_category,
					-defaults  => 'Todos',
                                        -labels    => $select_categories,
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
					-defaults  => 'Todos',
                                        -labels    => \%select_regular,
                                        -size      => 1,
					);

$t_params->{'unidades'}= $CGIbranch;
$t_params->{'categories'}= $CGIcategories;
$t_params->{'regulares'}=$CGIregular;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);

}
