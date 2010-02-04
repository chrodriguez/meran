#!/usr/bin/perl
use Rose::DB::Object::Loader;

my $loader = Rose::DB::Object::Loader->new(
                   db_dsn       => 'dbi:mysql:dbname=Econo-V2V3;host=localhost',
                   db_username  => 'kohaadmin',
                   db_password  => 'patyalmicro',
                   db_options   => { AutoCommit => 1},
		  class_prefix => 'C4::Modelo'
                    );
$loader->make_modules(  module_dir => "/usr/local/koha/intranet/modules/",
                                        );

use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
my $MARCDetail_array2= C4::AR::Busquedas::getNivelesMARC($idNivel3,'intra');
