#!/usr/bin/perl
use strict;
require Exporter;
use C4::AR::Auth;
use CGI;
use JSON;
use C4::AR::BackgroundJob;
use Proc::Simple;
use C4::AR::Utilidades;

my $input = new CGI;
my $obj=$input->param('obj');
my $job;

$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $accion = $obj->{'accion'};


#if ($accion eq "START_DEMO"){
	
	 $job = C4::AR::BackgroundJob->new("DEMO","NULL",0);
     my $proc = Proc::Simple->new();
     
     $proc->start(\&C4::AR::Utilidades::demo_test,$job);
     C4::AR::Auth::printValue($job->id);
     
#}
