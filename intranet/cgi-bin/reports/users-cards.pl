#!/usr/bin/perl


use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::PdfGenerator;
use C4::AR::Busquedas;

my $input = new CGI;

#se verifican los permisos
&C4::Auth::checkauth($input,0,{borrowers => 1},"intranet");
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

my  $ui= $input->param('ui_name') || C4::AR::Preferencias->getValorPreferencia("defaultUI");

my $ComboUI=C4::AR::Utilidades::generarComboUI();

my %params;
$params{'default'}= 'SIN SELECCIONAR';
my $comboCategoriasDeSocio= C4::AR::Utilidades::generarComboCategoriasDeSocio(\%params);


## FIXME user la funcion q genera el combo, asi no va
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

$t_params->{'unidades'}= $ComboUI;
$t_params->{'categories'}= $comboCategoriasDeSocio;
$t_params->{'regulares'}=$CGIregular;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);

}
