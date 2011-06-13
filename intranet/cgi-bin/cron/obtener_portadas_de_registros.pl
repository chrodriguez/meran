#!/usr/bin/perl

use C4::AR::PortadasRegistros;

my $session = CGI::Session->new();
$session->param("type","intranet");

C4::AR::PortadasRegistros::getAllImages();