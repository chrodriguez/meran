#!/usr/bin/perl


use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;


my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                        template_name => "reports/estadistica_Anual.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                        debug => 1,
			    });

my  $branch=$input->param('branch');
# ($branch ||($branch=(split("_",(split(";",$cookie))[0]))[1]));


my $year_Default="Seleccione";
my @years;
my @yearsValues;
push (@years,"Seleccione");
for (my $i =2005 ; $i < 2036; $i++){
	push (@years,$i);
}
my $year=CGI::scrolling_list(   -name      => 'year',
				-id	   => 'year',
                                -values    => \@years,
                                -defaults  => 0,
                                -size      => 1,
                                -onChange  =>'consultar()'
                            );

$t_params->{'year'}= $year;
$t_params->{'branch'}= $branch;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
