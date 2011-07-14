package C4::AR::Social;

use strict;
require Exporter;
use C4::Context;
use Net::Twitter;
use Net::Twitter::Role::OAuth;
use Scalar::Util 'blessed';
use WWW::Shorten::Bitly;


use vars qw(@EXPORT_OK @ISA);

@ISA=qw(Exporter);

@EXPORT_OK=qw(
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



sub twitterConsumerKey{
    my ($self) = shift;
    my $valor_consumer_key= C4::AR::Preferencias::getValorPreferencia("twitter_consumer_key");
    return $valor_consumer_key;
}

sub twitterConsumerKey{
    my ($self) = shift;
    my $valor_consumer_secret= C4::AR::Preferencias::getValorPreferencia("twitter_consumer_secret");
    return $valor_consumer_secret;
}

sub twitterToken{
    my ($self) = shift;
    my $valor_token= C4::AR::Preferencias::getValorPreferencia("twitter_token");
    return $valor_token;
}

sub twitterTokenSecret{
    my ($self) = shift;
    my $valor_token_secret= C4::AR::Preferencias::getValorPreferencia("twitter_token_secret");
    return $valor_token_secret;
}

sub connectTwitter{
    my ($self) = shift;
    my $consumer_key= twitterConsumerKey();
    my $consumer_secret= twitterConsumerKey();
    my $token= twitterToken();
    my $token_secret= twitterTokenSecret();


    my $nt = Net::Twitter->new(
        traits              => ['API::REST', 'OAuth'],
        consumer_key        => $consumer_key,
        consumer_secret     => $consumer_secret,
        access_token        => $token,
        access_token_secret => $token_secret,
    );
    
    return $nt;

}


END { }       # module clean-up code here (global destructor)

1;
__END__