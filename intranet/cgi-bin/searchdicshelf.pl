#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Date;
use C4::AR::DictionarySearch;
 
my $input = new CGI;

my ($template, $loggedinuser, $cookie)
= get_template_and_user({
                                template_name => "searchdicshelf.tmpl",
                                query => $input,
                                type => "intranet",
                                authnotrequired => 0,
                                flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                                debug => 1,
                    });


my $dictionary = $input->param("dictionary");
my $dicdetail=$input->param('dicdetail');
($dicdetail) || ($dicdetail=0);

if ($dictionary){
my $env;
my %search;  
$search{'dictionary'} = $dictionary;
$search{'dicdetail'} = $dicdetail;


my     ($count,@results)=&DictionaryKeywordSearch($env,'intra',\%search,20,0);

$template->param(
		results => \@results,
		);
	}

output_html_with_http_headers $cookie, $template->output;
