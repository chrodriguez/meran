#!/usr/bin/perl

use Net::Twitter;
use Scalar::Util 'blessed';
use WWW::Shorten::Bitly;
use CGI;
my $user = 'koha_unlp';
my $password = 'pato123@'; 


my $url = "http://www.google.com";

my $short_url = makeashorterlink($url, 'gaspo53', 'R_2123296565094a87c392b184d2a0910f');


print "\n Short Url: ".$short_url."\n";

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











