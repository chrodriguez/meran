
use strict;
use warnings;



use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'Moose based MARC records set of tools',
  'AUTHOR' => 'Frederic Demians <f.demians@tamil.fr>',
  'BUILD_REQUIRES' => {
    'MARC::File::XML' => '0',
    'Module::Build' => '0.3601',
    'Test::More' => '0',
    'Time::HiRes' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31',
    'Module::Build' => '0.3601'
  },
  'DISTNAME' => 'marc-moose',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'NAME' => 'marc::moose',
  'PREREQ_PM' => {
    'Carp' => '0',
    'JSON' => '0',
    'MARC::Record' => '0',
    'Moose' => '1.00',
    'Moose::Util::TypeConstraints' => '0',
    'Text::Iconv' => '1.7',
    'XML::SAX' => '0',
    'XML::SAX::Base' => '0',
    'XML::Simple' => '0',
    'XML::Writer' => '0.606',
    'YAML' => '0',
    'YAML::Syck' => '0',
    'namespace::autoclean' => '0',
    'overload' => '0'
  },
  'VERSION' => '0.018',
  'test' => {
    'TESTS' => 't/*.t'
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



