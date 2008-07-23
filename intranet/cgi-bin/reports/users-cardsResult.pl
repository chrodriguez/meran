#!/usr/bin/perl


use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;

my $input = new CGI;

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $orden=$obj->{'orden'}||'surname';
my $op=$obj->{'op'};
my $surname1=$obj->{'surname1'};
my $surname2=$obj->{'surname2'};
my $legajo1=$obj->{'legajo1'};
my $legajo2=$obj->{'legajo2'};
my $category=$obj->{'category'};
my $regular=$obj->{'regular'};
my $branch=$obj->{'branch'};
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

