#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
# use C4::Search;
use C4::Auth;
use C4::Interface::CGI::Output;
use HTML::Template;

use C4::AR::Catalogacion;
use C4::AR::Busquedas;

my $input=new CGI;

my ($template, $borrowernumber, $cookie) 
    = get_template_and_user({template_name => "opac-detail.tmpl",
			     query => $input,
			     type => "opac",
			     authnotrequired => 1,
			     flagsrequired => {borrow => 1},
			     });

my $idNivel1=$input->param('id1');

my (@nivel2Loop)= &detalleOpacNivel2($idNivel1);

my $nivel1=&buscarNivel1($idNivel1); #C4::AR::Catalogacion;
my @autor=C4::Search::getautor($nivel1->{'autor'});
my @nivel1Loop= &detalleNivel1_copia($idNivel1, $nivel1, 'opac');

for (my $i=0; $i < scalar(@nivel2Loop); $i++){
	@nivel2Loop[$i]->{'loopnivel1'}= \@nivel1Loop;
}
	

$template->param(
	loopnivel2	=> \@nivel2Loop,
);

output_html_with_http_headers $input, $cookie, $template->output;
