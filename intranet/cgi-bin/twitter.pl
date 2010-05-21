#!/usr/bin/perl

use Net::Twitter;
use Scalar::Util 'blessed';
use CGI;
my $user = 'gaspo53';
my $password = 'secret'; 













my $nt = Net::Twitter->new(
    traits   => [qw/API::REST/],
    username => $user,
    password => $password,
    clientname => "Twitter for MERAN",
    source => '',
);

my $result = $nt->update($ARGV[0]);

if ( my $err = $@ ) {
    die $@ unless blessed $err && $err->isa('Net::Twitter::Error');

    warn "HTTP Response Code: ", $err->code, "\n",
          "HTTP Message......: ", $err->message, "\n",
          "Twitter error.....: ", $err->error, "\n";
}











