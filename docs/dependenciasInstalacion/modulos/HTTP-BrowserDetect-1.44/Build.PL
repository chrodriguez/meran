
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Data::Dump" => 0,
    "English" => 0,
    "File::Slurp" => 0,
    "FindBin" => 0,
    "JSON::PP" => 0,
    "Module::Build" => "0.3601",
    "Test::More" => 0,
    "warnings" => 0
  },
  "configure_requires" => {
    "ExtUtils::MakeMaker" => "6.30",
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "Determine Web browser, version, and platform from an HTTP user agent string",
  "dist_author" => [
    "Lee Semel <lee\@semel.net>",
    "Peter Walsham",
    "Olaf Alders <olaf\@wundercounter.com> (current maintainer)"
  ],
  "dist_name" => "HTTP-BrowserDetect",
  "dist_version" => "1.44",
  "license" => "perl",
  "module_name" => "HTTP::BrowserDetect",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Exporter" => 0,
    "strict" => 0,
    "vars" => 0
  },
  "script_files" => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
