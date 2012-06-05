use strict;use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'WWW::Google::URLShortener',
    AUTHOR        => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    VERSION_FROM  => 'lib/WWW/Google/URLShortener.pm',
    ABSTRACT_FROM => 'lib/WWW/Google/URLShortener.pm',
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean         => { FILES => 'WWW-Google-URLShortener-*' },
    PREREQ_PM     => {
        'Test::More'          => 0,
        'Readonly'            => '1.03',
        'HTTP::Request'       => '1.40',
        'LWP::UserAgent'      => '2.33',
        'JSON'                => '2.15',
        'Data::Validate::URI' => '0.05',
    },
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
);