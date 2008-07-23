#!/usr/bin/perl


use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;


my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/estadistica_Anual.tmpl",

			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my  $branch=$input->param('branch');
($branch ||($branch=(split("_",(split(";",$cookie))[0]))[1]));


my $year_Default=2005;
my @years;
for (my $i =2005 ; $i < 2036; $i++){
	push (@years,$i);
}
my $year=CGI::scrolling_list(   -name      => 'year',
				-id	   => 'year',
                                -values    => \@years,
                                -defaults  => $year_Default,
                                -size      => 1,
                                -onChange  =>'consultar()'
                                 );

$template->param( 
			year	  	 => $year,
			branch           => $branch,
		);

output_html_with_http_headers $input, $cookie, $template->output;
