package C4::Modelo::DB::AutoBase1;

use strict;

use base 'Rose::DB';

__PACKAGE__->use_private_registry;

__PACKAGE__->register_db
(
  connect_options => { AutoCommit => 1 },
  driver          => 'mysql',
  dsn             => 'dbi:mysql:dbname=V2;host=localhost',
  password        => 'dev',
  username        => 'dev',
);

1;
