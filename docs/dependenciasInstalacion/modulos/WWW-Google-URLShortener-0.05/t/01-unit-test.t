#!perl

use strict; use warnings;
use WWW::Google::URLShortener;
use Test::More tests => 7;

my ($google);

eval { $google = WWW::Google::URLShortener->new(); };
like($@, qr/ERROR: API Key is missing./);

$google = WWW::Google::URLShortener->new('You_API_Key');
eval { $google->shorten_url(); };
like($@, qr/ERROR: Missing URL./);

eval { $google->expand_url(); };
like($@, qr/ERROR: Missing URL./);

eval { $google->get_analytics(); };
like($@, qr/ERROR: Missing URL./);

eval { $google->shorten_url('http//www.google.com'); };
like($@, qr/ERROR: Invalid URL supplied \[http\/\/www.google.com\]./);

eval { $google->expand_url('http//www.google.com'); };
like($@, qr/ERROR: Invalid URL supplied \[http\/\/www.google.com\]./);

eval { $google->get_analytics('http//www.google.com'); };
like($@, qr/ERROR: Invalid URL supplied \[http\/\/www.google.com\]./);