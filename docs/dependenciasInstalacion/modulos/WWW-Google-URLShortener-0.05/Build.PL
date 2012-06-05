use strict;use warnings;
use Module::Build;

my $builder = Module::Build->new(
    sign              => 1,
    module_name       => 'WWW::Google::URLShortener',
    license           => 'perl',
    dist_author       => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    dist_version_from => 'lib/WWW/Google/URLShortener.pm',
    add_to_cleanup    => [ 'WWW-Google-URLShortener-*' ],
    build_requires    => {
        'Test::More'          => 0,
        'Readonly'            => '1.03',
        'HTTP::Request'       => '1.40',
        'LWP::UserAgent'      => '2.33',
        'JSON'                => '2.15',
        'Data::Validate::URI' => '0.05',
    },
);

$builder->create_build_script();