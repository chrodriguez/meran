#!/usr/bin/perl

use Net::Amazon;
use Net::Amazon::Property;

my $ua = Net::Amazon->new(token => '09RZQDPDWPQK1WWVSH02');

# Get a request object
my $resp = $ua->search(isbn => "9500426404");

if($resp->is_success()) {
  for my $prop ($resp->properties) {
		          
	print  $prop->author()."     ". $prop->title()."\n";
	print $prop->MediumImageUrl()."\n";
	}

} else {
print "Error: ", $resp->message(), "\n";
}
