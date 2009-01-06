package C4::Modelo::DB::AutoBase1;

use strict;

use base 'Rose::DB';
    use C4::Context;
__PACKAGE__->use_private_registry;

  my $context = new C4::Context;

  my $driverDB = 'mysql';

  my $database = $context->config('database');

  my $hostname = $context->config('hostname');

  my $user = $context->config('user');

  my $pass = $context->config('pass');

__PACKAGE__->register_db
(
    
  connect_options => { AutoCommit => 1 },
<<<<<<< .mine
  driver          => 'mysql',
  dsn             => 'dbi:mysql:dbname=V2;host=localhost',
  username        => 'dev',
  password        => 'dev',
);
=======
  driver          => $driverDB,
  dsn             => "dbi:mysql:dbname=".$database.";host=".$hostname,
  username        => $user,
  password        => $pass,
);
>>>>>>> .r865

1;
