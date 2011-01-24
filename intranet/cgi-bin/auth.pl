#!/usr/bin/perl

use strict;

use C4::AR::Auth;
use CGI;


my $cgi = new CGI;
# my $t0 = Benchmark->new;
# # ... your code here ...
my ($template, $t_params)   = C4::Output::gettemplate("auth.tmpl", 'intranet');
# my $t1= Benchmark->new;
# my $t2= timediff($t1, $t0);
# warn timestr($t2);
#se inicializa la session y demas parametros para autenticar
my ($session)               = C4::AR::Auth::inicializarAuth($t_params);
# my $t0= Benchmark->new;
# my $t2= timediff($t0, $t1);
# warn timestr($t2);

$t_params->{'sessionClose'} = $cgi->param('sessionClose') || 0;
# my $t1= Benchmark->new;
# my $t2= timediff($t1, $t0);
# warn timestr($t2);

if ($t_params->{'sessionClose'}){
  $t_params->{'mensaje'}    = C4::AR::Mensajes::getMensaje('U358','intranet');
}
# my $t0= Benchmark->new;
# my $t2= timediff($t0, $t1);
# warn timestr($t2);

$t_params->{'loginAttempt'} = $cgi->param('loginAttempt') || 0;

if ($t_params->{'loginAttempt'}){
  $t_params->{'mensaje'}    = C4::AR::Mensajes::getMensaje('U357','intranet');
}
# my $t1= Benchmark->new;
# my $t2= timediff($t1, $t0);
# warn timestr($t2);


if ($session->param('codMsg')){
  $t_params->{'mensaje'}    = C4::AR::Mensajes::getMensaje($session->param('codMsg'),'intranet');
}
# my $t0= Benchmark->new;
# my $t2= timediff($t0, $t1);
# warn timestr($t2);


C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
