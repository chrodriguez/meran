
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Determine Web browser, version, and platform from an HTTP user agent string",
  "AUTHOR" => "Lee Semel <lee\@semel.net>, Peter Walsham, Olaf Alders <olaf\@wundercounter.com> (current maintainer)",
  "BUILD_REQUIRES" => {
    "Data::Dump" => 0,
    "English" => 0,
    "File::Slurp" => 0,
    "FindBin" => 0,
    "JSON::PP" => 0,
    "Module::Build" => "0.3601",
    "Test::More" => 0,
    "warnings" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30",
    "Module::Build" => "0.3601"
  },
  "DISTNAME" => "HTTP-BrowserDetect",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "HTTP::BrowserDetect",
  "PREREQ_PM" => {
    "Exporter" => 0,
    "strict" => 0,
    "vars" => 0
  },
  "VERSION" => "1.44",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



