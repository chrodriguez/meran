
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  'build_requires' => {
    'MARC::File::XML' => '0',
    'Module::Build' => '0.3601',
    'Test::More' => '0',
    'Time::HiRes' => '0'
  },
  'configure_requires' => {
    'ExtUtils::MakeMaker' => '6.31',
    'Module::Build' => '0.3601'
  },
  'dist_abstract' => 'Moose based MARC records set of tools',
  'dist_author' => [
    'Frederic Demians <f.demians@tamil.fr>'
  ],
  'dist_name' => 'marc-moose',
  'dist_version' => '0.018',
  'license' => 'perl',
  'module_name' => 'marc::moose',
  'recommends' => {},
  'recursive_test_files' => 1,
  'requires' => {
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
  'script_files' => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
