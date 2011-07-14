package C4::AR::Social;


use strict;
require Exporter;
use Net::Twitter;
use Net::Twitter::Role::OAuth;
use Scalar::Util 'blessed';
use WWW::Shorten::Bitly;
use CGI;

use vars qw(@ISA @EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw(
          &twitterConsumerKey
          &twitterConsumerSecret
          &twitterToken
          &twitterTokenSecret
          &connectTwitter
);




# my $consumer_key        = "ee4q1gf165jmFQTObJVY2w";
# my $consumer_secret     = "F4TEnfC1SjYm3XG6vHZ0aJmsYQIFysyu9bwjG9BDdQ";
# my $token               = "148446079-IL4MsMqXzKU24xMr32No58H5meHmsqLMZHk4qZ0";
# my $token_secret        = "fSCpzZELbLFYQPJtP7nRJFQjgfGXvR0538a0i0AIcj0"; 

