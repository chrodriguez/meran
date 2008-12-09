package C4::Modelo::MeranDB::DB;

use C4::Context;
# this class IS a "Rose::DB"
use base qw(Rose::DB);

# fyi: a "registry" is the information that is
#      used to log in to the database

# methode to insure we do not inherit the
# registry directly from Rose::DB
__PACKAGE__->use_private_registry;



my $driverDB = 'mysql';   #'mysql';#&C4::Context->config('

my $database = 'V3_newAspect_EINAR';   #C4::Context::config('database');

my $hostname = 'localhost';     #C4::Context->config('hostname');

my $user = 'remote';   #C4::Context->config('user');

my $pass = 'remoteHOST';   #C4::Context->config('pass');

print $database." //// ".$driverDB." //// ".$hostname." //// ".$user." //// ".$pass;
# filling in the registry:
__PACKAGE__->register_db(
      driver   => $driverDB,
      database => $database,
      host     => $hostname,
      username => $user,
      password => $pass,
);

1;
