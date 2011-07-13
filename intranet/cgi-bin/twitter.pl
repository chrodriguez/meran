#!/usr/bin/perl

use Net::Twitter;
use Scalar::Util 'blessed';
use WWW::Shorten::Bitly;
use CGI;
my $user = 'koha_unlp';
my $password = 'pato123@'; 

my $consumer_key        = "Bk6HpbcEPLWWKJdYHjTJXQ";
my $consumer_secret     = "IRo34n7Mkd2VRhinUGXoInKsoxVub9ubanBSmmuLIg";
my $token               = "148446079-6piw6kAePtptOnAQK3hIxWxKXXhPhW95u4gxRuBE";
my $token_secret        = "rPyA0Xkdl05ehFOEXkVA0ENlAGsnyZAiN2WKZb1zOw"; 

my $url = "http://www.google.com";

my $short_url = makeashorterlink($url, 'gaspo53', 'R_2123296565094a87c392b184d2a0910f');


print "\n Short Url: ".$short_url."\n";

my $nt = Net::Twitter->new(
    traits   => [qw/OAuth API::REST/],
    consumer_key        => $consumer_key,
    consumer_secret     => $consumer_secret,
    access_token        => $token,
    access_token_secret => $token_secret,
);


my $result = $nt->update($ARGV[0]);


if ( my $err = $@ ) {
    die $@ unless blessed $err && $err->isa('Net::Twitter::Error');

    warn "HTTP Response Code: ", $err->code, "\n",
          "HTTP Message......: ", $err->message, "\n",
          "Twitter error.....: ", $err->error, "\n";
}











