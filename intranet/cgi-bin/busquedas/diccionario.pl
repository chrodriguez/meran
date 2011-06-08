#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;
use C4::Output;

use C4::AR::DictionarySearch;
use C4::AR::Utilidades;
use HTML::Template;

my $query = new CGI;

# my $dictionary=$query->param('dictionary');
my $dicdetail=$query->param('dicdetail');
 ($dicdetail) || ($dicdetail=0);

open(A, ">>/tmp/debug.txt");
print A "desde diccionario.pl \n";

my $obj=$query->param('obj');
print A "antes de json: $obj \n";


my $obj=$query->param('obj');

if($obj ne ""){
	$obj=from_json_ISO($obj);
}

print A "$obj->{'dictionary'} \n";

close(A);

my $dictionary= $obj->{'dictionary'};
my $funcion= $obj->{'funcion'};

my $search;
$search->{'dictionary'}=$dictionary;
$search->{'dicdetail'}=$dicdetail;


my ($template, $nro_socio, $cookie)= get_template_and_user({
                template_name => "busquedas/diccionario.tmpl",
			    query => $query,
			    type => "intranet",
			    authnotrequired => 0,
			    flagsrequired => {  ui => 'ANY', 
                                    tipo_documento => 'ANY', 
                                    accion => 'CONSULTA', 
                                    entorno => 'undefined'},
			    debug => 1,
        });

my $ini= $obj->{'ini'};#($query->param('ini'));
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

my ($cantidad,@results)=&DictionaryKeywordSearch('intra',$search,$ini,$cantR);

C4::AR::Utilidades::crearPaginador($template, $cantidad, $cantR, $pageNumber, $funcion,$t_params);

  $template->param(SEARCH_RESULTS => \@results);
  $template->param(numrecords => $cantidad);
  $template->param(value => $dictionary);

output_html_with_http_headers $cookie, $template->output;
