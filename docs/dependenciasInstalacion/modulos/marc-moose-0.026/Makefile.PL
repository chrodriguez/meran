
use strict;
use warnings;

use 5.010;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Moose based MARC records set of tools",
  "AUTHOR" => "Fr\303\251d\303\251ric Demians <f.demians\@tamil.fr>",
  "BUILD_REQUIRES" => {
    "MARC::File::XML" => 0,
    "Test::More" => 0,
    "Time::HiRes" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "marc-moose",
  "EXE_FILES" => [
    "bin/marcmoose"
  ],
  "LICENSE" => "perl",
  "NAME" => "marc::moose",
  "PREREQ_PM" => {
    "Carp" => 0,
    "Getopt::Long" => 0,
    "JSON" => 0,
    "MARC::Record" => 0,
    "Moose" => "1.00",
    "Moose::Role" => 0,
    "Moose::Util::TypeConstraints" => 0,
    "MooseX::RW::Reader" => 0,
    "MooseX::RW::Reader::File" => 0,
    "MooseX::RW::Writer" => 0,
    "Pod::Usage" => 0,
    "Text::Iconv" => "1.7",
    "XML::SAX" => 0,
    "XML::SAX::Base" => 0,
    "XML::Simple" => 0,
    "XML::Writer" => "0.606",
    "YAML" => 0,
    "YAML::Syck" => 0,
    "base" => 0,
    "strict" => 0,
    "utf8" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.026",
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



