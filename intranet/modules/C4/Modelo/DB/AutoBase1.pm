package C4::Modelo::DB::AutoBase1;

use strict;

use base 'Rose::DB';

__PACKAGE__->use_private_registry;

__PACKAGE__->register_db
(
  connect_options => { AutoCommit => 1 },
  driver          => 'mysql',
  dsn             => 'dbi:mysql:dbname=Econo-V2V3;host=localhost',
  password        => 'patyalmicro',
  username        => 'kohaadmin',
);

1;
