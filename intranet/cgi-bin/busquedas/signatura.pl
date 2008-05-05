#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::AR::DictionarySearch;
use C4::AR::Utilidades;
use HTML::Template;

my $query = new CGI;

my $signatura=$query->param('signatura');
my $dicdetail=$query->param('dicdetail');
($dicdetail) || ($dicdetail=0);

my $search;
$search->{'signatura'}=$signatura;
$search->{'dicdetail'}=$dicdetail;


my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "busquedas/signatura.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {catalogue => 1},
			     debug => 1,
			     });

my ($count,@results)=&DictionarySignatureSearch('intra',$search);

  $template->param(SEARCH_RESULTS => \@results);
  $template->param(numrecords => $count);
  $template->param(value => $signatura);

output_html_with_http_headers $query, $cookie, $template->output;
