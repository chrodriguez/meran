#!/usr/bin/perl

use Net::Twitter;
use Net::Twitter::Role::OAuth;
use Scalar::Util 'blessed';
use WWW::Shorten::Bitly;
use CGI;

my $consumer_key        = "ee4q1gf165jmFQTObJVY2w";
my $consumer_secret     = "F4TEnfC1SjYm3XG6vHZ0aJmsYQIFysyu9bwjG9BDdQ";
my $token               = "148446079-IL4MsMqXzKU24xMr32No58H5meHmsqLMZHk4qZ0";
my $token_secret        = "fSCpzZELbLFYQPJtP7nRJFQjgfGXvR0538a0i0AIcj0"; 

my $url = "http://www.google.com";

my $short_url = makeashorterlink($url, 'gaspo53', 'R_2123296565094a87c392b184d2a0910f');


print "\n Short Url: ".$short_url."\n";

my $nt = Net::Twitter->new(
    traits              => ['API::REST', 'OAuth'],
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











