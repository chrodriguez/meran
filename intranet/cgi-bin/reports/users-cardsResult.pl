#!/usr/bin/perl


use strict;
use C4::Auth;
use C4::Koha;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::PdfGenerator;

my $input = new CGI;

my $orden=$input->param('orden');
my $op=$input->param('op');
my $surname1=$input->param('surname1');
my $surname2=$input->param('surname2');
my $legajo1=$input->param('legajo1');
my $legajo2=$input->param('legajo2');
my $category=$input->param('category');
my $regular=$input->param('regular');
my $branch=$input->param('branch');
my $count=0;
my @results=();


if ($op ne ''){
 ($count,@results)=C4::AR::Usuarios::BornameSearchForCard($surname1,$surname2,$category,$branch,$orden,$regular,$legajo1,$legajo2);
}


my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/users-cardsResult.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

#Se realiza la busqueda si al algun campo no vacio
$template->param(
		RESULTSLOOP=>\@results,
                cantidad=>$count
	               );

output_html_with_http_headers $input, $cookie, $template->output;

