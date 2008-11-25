#!/usr/bin/perl

use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::Auth;
use C4::Context;
use CGI;
use CGI::Session;

my $query = new CGI;

my ($template, $params)= C4::Output::gettemplate("auth.tmpl", 'intranet');

my $session = CGI::Session->new();

#AGREGADO PARA MANDARLE AL USUARIO UN NUMERO RANDOM PARA QUE REALICE UN HASH
my $random_number= int(rand()*100000);
$params->{'RANDOM_NUMBER'}= $random_number;
# $params->{'RANDOM_NUMBER'}= $session->param('nroRandom');
my $self_url = $query->url(-absolute => 1);
## FIXME
$params->{'url'}= $self_url;#se le esta pasando la url para el action del FORM, se podria dejar fijo
$params->{'mensaje'}= C4::AR::Mensajes::getMensaje($session->param('codMsg'),'INTRA',[]);

&C4::Auth::output_html_with_http_headers($query, $template, $params, $session);