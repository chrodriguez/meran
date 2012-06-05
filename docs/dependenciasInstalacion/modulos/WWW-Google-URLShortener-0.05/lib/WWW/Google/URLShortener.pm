package WWW::Google::URLShortener;

use strict; use warnings;

use Carp;
use Readonly;
use Data::Dumper;

use JSON;
use HTTP::Request;
use LWP::UserAgent;
use Data::Validate::URI qw/is_web_uri/;

=head1 NAME

WWW::Google::URLShortener - Interface to Google URL Shortener API.

=head1 VERSION

Version 0.05

=cut

our $VERSION = '0.05';
Readonly my $API_VERSION => 'v1';
Readonly my $API_URL     => "https://www.googleapis.com/urlshortener/$API_VERSION/url";

=head1 DESCRIPTION

The Google URL Shortener  at  goo.gl  is a service that takes long URLs and squeezes them into
fewer characters to make a link that is easier to share, tweet, or email to friends. Currently
it supports version v1.

IMPORTANT: The version  v1  of the Google URL Shortener API is in Labs, and its features might
change unexpectedly until it graduates.

=head1 CONSTRUCTOR

The constructor expects your application API, which you can get it for FREE from Google.

    use strict; use warnings;
    use WWW::Google::URLShortener;

    my $api_key = 'Your_API_Key';
    my $google  = WWW::Google::URLShortener->new($api_key);

=cut

sub new
{
    my $class   = shift;
    my $api_key = shift;
    croak("ERROR: API Key is missing.\n")
        unless defined $api_key;

    my $self = { api_key  => $api_key,
                 base_url => $API_URL . '?key=' . $api_key,
                 browser => LWP::UserAgent->new(),
               };
    bless $self, $class;
    return $self;
}

=head1 METHODS

=head2 shorten_url()

Returns the shorten  url  for the given long url as provided by Google URL Shortener API. This
method expects one scalar parameter i.e. the long url.

    use strict; use warnings;
    use WWW::Google::URLShortener;

    my $api_key = 'Your_API_Key';
    my $google  = WWW::Google::URLShortener->new($api_key);
    print $google->shorten_url('http://www.google.com');

=cut

sub shorten_url
{
    my $self = shift;
    my $url  = shift;
    croak("ERROR: Missing URL.\n")
        unless defined $url;
    croak("ERROR: Invalid URL supplied [$url].\n")
        unless is_web_uri($url);
        
    my ($request, $response, $content);    
    $request  = $self->_prepare_request({longUrl => $url});
    $response = $self->{browser}->request($request);
    croak("ERROR: Couldn't process $url [".$response->status_line . "]\n")
        unless $response->is_success;
    $content  = $response->content();
    croak("ERROR: No data found.\n")
        unless defined $content;

    $content  = from_json($content);
    return $content->{id};
}

=head2 expand_url()

Returns the expaned url  for the given long url as provided by Google URL Shortener API.  This
method expects one scalar parameter i.e. the short url.

    use strict; use warnings;
    use WWW::Google::URLShortener;

    my $api_key = 'Your_API_Key';
    my $google  = WWW::Google::URLShortener->new($api_key);
    print $google->expand_url('http://goo.gl/fbsS');

=cut

sub expand_url
{
    my $self = shift;
    my $url  = shift;
    croak("ERROR: Missing URL.\n")
        unless defined $url;
    croak("ERROR: Invalid URL supplied [$url].\n")
        unless is_web_uri($url);
    
    my ($request, $response, $content);    
    $request  = $self->_prepare_request({shortUrl => $url});    
    $response = $self->{browser}->request($request);
    croak("ERROR: Couldn't process ".$self->{base_url}." [".$response->status_line . "]\n")
        unless $response->is_success;
    $content  = $response->content();
    croak("ERROR: No data found.\n")
        unless defined $content;

    $content  = from_json($content);
    return $content->{longUrl};
}

=head2 get_analytics()

Returns the analytics  for  the given short url as provided by Google URL Shortener API in the
XML format. This method expects one scalar parameter i.e. the short url.

    use strict; use warnings;
    use WWW::Google::URLShortener;

    my $api_key = 'Your_API_Key';
    my $google  = WWW::Google::URLShortener->new($api_key);
    print $google->get_analytics('http://goo.gl/fbsS');

=cut

sub get_analytics
{
    my $self = shift;
    my $url  = shift;
    croak("ERROR: Missing URL.\n")
        unless defined $url;
    croak("ERROR: Invalid URL supplied [$url].\n")
        unless is_web_uri($url);
    
    my ($request, $response, $content);    
    $request  = $self->_prepare_request({shortUrl => $url, analytics => 1});    
    $response = $self->{browser}->request($request);
    croak("ERROR: Couldn't process ".$self->{base_url}." [".$response->status_line . "]\n")
        unless $response->is_success;
    $content  = $response->content();
    croak("ERROR: No data found.\n")
        unless defined $content;

    $content  = from_json($content);
    return _get_analytics($content);
}

sub _prepare_request
{
    my $self    = shift;
    my $data    = shift;
    
    return HTTP::Request->new(GET => $API_URL . '?shortUrl=' . $data->{shortUrl} . '&projection=FULL')
        if exists($data->{analytics});
        
    return HTTP::Request->new(GET => $API_URL . '?shortUrl=' . $data->{shortUrl})
        if exists($data->{shortUrl});

    my $request = HTTP::Request->new(POST => $self->{base_url});
    $request->header('Content-Type' => 'application/json');
    $request->content(to_json($data));
    return $request;
}

sub _get_analytics
{
    my $data = shift;
    my $xml  = qq {<?xml version="1.0" encoding="UTF-8"?>\n};
    $xml .= qq {<analytics>\n};
    foreach my $type (keys %{$data->{'analytics'}})
    {
        $xml .= qq {\t<$type>\n};
        $xml .= qq {\t\t<clicks shortUrl="} . 
                $data->{'analytics'}->{$type}->{longUrlClicks} .
                qq {" longUrl="}. $data->{'analytics'}->{$type}->{longUrlClicks} . 
                qq{"/>\n};
        foreach (keys %{$data->{'analytics'}->{$type}})
        {
            next unless ref($data->{'analytics'}->{$type}->{$_});
            $xml .= qq {\t\t<$_>\n};
            my $id;
            if ($_ eq 'countries')
            {
                $id = 'country';
            }
            else
            {
                $id = substr($_,0,length($_)-1);
            }    
            map { $xml .= qq {\t\t\t<$id id="} . $_->{id}. qq{" count="}. $_->{count} .qq{"/>\n}; } @{$data->{'analytics'}->{$type}->{$_}};
            $xml .= qq {\t\t</$_>\n};
        }
        $xml .= qq {\t</$type>\n};
    }
    $xml .= qq {</analytics>\n};
    
    return $xml;
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 BUGS

Please  report  any bugs or feature requests to C<bug-www-google-urlshortener at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Google-URLShortener>.  
I will be notified and then you'll automatically be notified of progress on your bug as I make
changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Google::URLShortener

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Google-URLShortener>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-Google-URLShortener>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-Google-URLShortener>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-Google-URLShortener/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Mohammad S Anwar.

This  program  is  free  software; you can redistribute it and/or modify it under the terms of
either:  the  GNU  General Public License as published by the Free Software Foundation; or the
Artistic License.

See http://dev.perl.org/licenses/ for more information.

=head1 DISCLAIMER

This  program  is  distributed  in  the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

1; # End of WWW::Google::URLShortener